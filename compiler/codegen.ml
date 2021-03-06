(* Code generation: translate takes a semantically checked AST and
produces LLVM IR

LLVM tutorial: Make sure to read the OCaml version of the tutorial

http://llvm.org/docs/tutorial/index.html

Detailed documentation on the OCaml LLVM library:

http://llvm.moe/
http://llvm.moe/ocaml/

*)

module L = Llvm
module A = Ast
open Exceptions

module StringMap = Map.Make(String)

let translate (globals, functions) =
  let context = L.global_context () in
  let the_module = L.create_module context "DARN"
  and i32_t  = L.i32_type  context
  and i8_t   = L.i8_type   context
  and float_t = L.double_type context
  and pointer_t = L.pointer_type
  and array_t   = L.array_type
  and i1_t   = L.i1_type   context
  and void_t = L.void_type context in

  let ltype_of_typ = function
      A.Int -> i32_t
    | A.Bool -> i1_t
    | A.Float -> float_t
    | A.Char   -> i8_t
    | A.String -> pointer_t i8_t
    | A.Void -> void_t
    | A.Matrix1DType(typ, size) -> (match typ with
                                            A.Int -> array_t i32_t size
                                          | A.Float -> array_t float_t size
                                          | A.Bool -> array_t i1_t size
                                          | A.Matrix2DType(typ, size1, size2) -> (match typ with
                                                                                  A.Int -> array_t (array_t i32_t size2) size1
                                                                                | A.Float -> array_t (array_t float_t size2) size1
                                                                                | _ -> raise ( UnsupportedMatrixType )
                                                                              )
                                          | _ -> raise ( UnsupportedMatrixType )
                                         ) 
    | A.Matrix2DType(typ, size1, size2) -> (match typ with
                                            A.Int -> array_t (array_t i32_t size2) size1
                                          | A.Float -> array_t (array_t float_t size2) size1
                                          | A.Matrix1DType(typ1, size3) -> (match typ1 with
                                                                         | A.Int -> array_t (array_t (array_t i32_t size3) size2) size1
                                                                         | A.Float -> array_t (array_t (array_t float_t size3) size2) size1
                                                                         | _ -> raise (UnsupportedMatrixType)
                                                                        )
                                          | _ -> raise ( UnsupportedMatrixType )
                                         )
    | A.Matrix1DPointer(t) -> (match t with
                                   A.Int -> pointer_t i32_t
                                 | A.Float -> pointer_t float_t
                                 | _ -> raise (IllegalPointerType))
    | A.Matrix2DPointer(t) -> (match t with
                                   A.Int -> pointer_t i32_t
                                 | A.Float -> pointer_t float_t
                                 | _ -> raise (IllegalPointerType))

  in

  (* Declare each global variable; remember its value in a map *)
  let global_vars =
    let global_var m (t, n) =
      let init = L.const_int (ltype_of_typ t) 0
      in StringMap.add n (L.define_global n init the_module) m in
    List.fold_left global_var StringMap.empty globals in

  (* Declare printf(), which the print built-in function will call *)
  let printf_t = L.var_arg_function_type i32_t [| L.pointer_type i8_t |] in
  let printf_func = L.declare_function "printf" printf_t the_module in

  (* Define each function (arguments and return type) so we can call it *)
  let function_decls =
    let function_decl m fdecl =
      let name = fdecl.A.fname
      and formal_types =
  Array.of_list (List.map (fun (t,_) -> ltype_of_typ t) fdecl.A.formals)
      in let ftype = L.function_type (ltype_of_typ fdecl.A.typ) formal_types in
      StringMap.add name (L.define_function name ftype the_module, fdecl) m in
    List.fold_left function_decl StringMap.empty functions in
  
  (* Fill in the body of the given function *)
  let build_function_body fdecl =
    let (the_function, _) = StringMap.find fdecl.A.fname function_decls in
    let builder = L.builder_at_end context (L.entry_block the_function) in

    let int_format_str = L.build_global_stringptr "%d" "fmt" builder 
    and float_format_str = L.build_global_stringptr "%f" "fmt" builder in
    (* add float... and float_format_str = L.build_global_stringptr "%f\n" "fmt" builder in *)
    
    (* Construct the function's "locals": formal arguments and locally
       declared variables.  Allocate each on the stack, initialize their
       value, if appropriate, and remember their values in the "locals" map *)
    let local_vars =
      let add_formal m (t, n) p = L.set_value_name n p;
  let local = L.build_alloca (ltype_of_typ t) n builder in
  ignore (L.build_store p local builder);
  StringMap.add n local m in

      let add_local m (t, n) =
  let local_var = L.build_alloca (ltype_of_typ t) n builder
  in StringMap.add n local_var m in

      let formals = List.fold_left2 add_formal StringMap.empty fdecl.A.formals
          (Array.to_list (L.params the_function)) in
      List.fold_left add_local formals fdecl.A.locals in

    (* Return the value for a variable or formal argument *)
    let lookup n = try StringMap.find n local_vars
                   with Not_found -> StringMap.find n global_vars
    in

    let check_function =
        List.fold_left (fun m (t, n) -> StringMap.add n t m)
        StringMap.empty (globals @ fdecl.A.formals @ fdecl.A.locals)
    in

    let type_of_identifier s =
      let symbols = check_function in
      StringMap.find s symbols
    in

    let build_1D_matrix_argument s builder =
      L.build_in_bounds_gep (lookup s) [| L.const_int i32_t 0; L.const_int i32_t 0 |] s builder
    in

    let build_2D_matrix_argument s builder =
      L.build_in_bounds_gep (lookup s) [| L.const_int i32_t 0; L.const_int i32_t 0; L.const_int i32_t 0 |] s builder
    in


    let build_1D_matrix_access s i1 i2 builder isAssign =
      if isAssign
        then L.build_gep (lookup s) [| i1; i2 |] s builder
      else
         L.build_load (L.build_gep (lookup s) [| i1; i2 |] s builder) s builder
    in

    let build_2D_matrix_access s i1 i2 i3 builder isAssign =
      if isAssign
        then L.build_gep (lookup s) [| i1; i2; i3 |] s builder
      else
         L.build_load (L.build_gep (lookup s) [| i1; i2; i3 |] s builder) s builder
    in

    let build_pointer_dereference s builder isAssign =
      if isAssign
        then L.build_load (lookup s) s builder
      else
        L.build_load (L.build_load (lookup s) s builder) s builder
    in

    let build_pointer_increment s builder isAssign =
      if isAssign
        then L.build_load (L.build_in_bounds_gep (lookup s) [| L.const_int i32_t 1 |] s builder) s builder
      else
        L.build_in_bounds_gep (L.build_load (L.build_in_bounds_gep (lookup s) [| L.const_int i32_t 0 |] s builder) s builder) [| L.const_int i32_t 1 |] s builder
    in

    let rec matrix_expression e =
       match e with
       | A.IntLiteral i -> i
       | A.Binop (e1, op, e2) -> (match op with
              A.Add     -> (matrix_expression e1) + (matrix_expression e2)
            | A.Sub     -> (matrix_expression e1) - (matrix_expression e2)
            | A.Mul    -> (matrix_expression e1) * (matrix_expression e2)
            | A.Div     -> (matrix_expression e1) / (matrix_expression e2)
            | _ -> 0)
       | _ -> 0
    in

    let find_matrix_type matrix =
      match (List.hd matrix) with
        A.IntLiteral _ -> ltype_of_typ (A.Int)
      | A.FloatLiteral _ -> ltype_of_typ (A.Float)
      | A.BoolLiteral _ -> ltype_of_typ (A.Bool)
      | _ -> raise (UnsupportedMatrixType) in

    (* Construct code for an expression; return its value *)
    let rec expr builder = function
    A.IntLiteral i -> L.const_int i32_t i
      | A.FloatLiteral f -> L.const_float float_t f
      | A.BoolLiteral b -> L.const_int i1_t (if b then 1 else 0)
      | A.CharLiteral c -> L.const_int i8_t (Char.code c)
      | A.StringLiteral s -> L.const_string context s
      | A.Noexpr -> L.const_int i32_t 0
      | A.Id s -> L.build_load (lookup s) s builder
      | A.MatrixLiteral s -> L.const_array (find_matrix_type s) (Array.of_list (List.map (expr builder) s))
      | A.Matrix1DReference (s) -> build_1D_matrix_argument s builder
      | A.Matrix2DReference (s) -> build_2D_matrix_argument s builder
      | A.Len s -> (match (type_of_identifier s) with A.Matrix1DType(_, l) -> L.const_int i32_t l 
                                                      | _ -> L.const_int i32_t 0 )
      | A.Height s -> (match (type_of_identifier s) with A.Matrix2DType(_, l, _) -> L.const_int i32_t l
                                                      | _ -> L.const_int i32_t 0 )
      | A.Width s -> (match (type_of_identifier s) with A.Matrix2DType(_, _, l) -> L.const_int i32_t l
                                                      | _ -> L.const_int i32_t 0 )
      | A.Matrix1DAccess (s, e1) -> let i1 = expr builder e1 in (match (type_of_identifier s) with 
                                                      A.Matrix1DType(_, l) -> (
                                                        if (matrix_expression e1) >= l then raise(MatrixOutOfBounds)
                                                        else build_1D_matrix_access s (L.const_int i32_t 0) i1 builder false)
                                                      | _ -> build_1D_matrix_access s (L.const_int i32_t 0) i1 builder false )
      | A.Matrix2DAccess (s, e1, e2) -> let i1 = expr builder e1 and i2 = expr builder e2 in (match (type_of_identifier s) with 
                                                      A.Matrix2DType(_, l1, l2) -> (
                                                        if (matrix_expression e1) >= l1 then raise(MatrixOutOfBounds)
                                                        else if (matrix_expression e2) >= l2 then raise(MatrixOutOfBounds)
                                                        else build_2D_matrix_access s (L.const_int i32_t 0) i1 i2 builder false)
                                                      | _ -> build_2D_matrix_access s (L.const_int i32_t 0) i1 i2 builder false )
      | A.PointerIncrement (s) ->  build_pointer_increment s builder false
      | A.Dereference (s) -> build_pointer_dereference s builder false
      | A.Binop (e1, op, e2) ->
        let e1' = expr builder e1
        and e2' = expr builder e2 in
          let float_bop operator = 
            (match operator with
              A.Add     -> L.build_fadd
            | A.Sub     -> L.build_fsub
            | A.Mul    -> L.build_fmul
            | A.Div     -> L.build_fdiv
            | A.And     -> L.build_and
            | A.Or      -> L.build_or
            | A.Eq   -> L.build_fcmp L.Fcmp.Oeq
            | A.Neq     -> L.build_fcmp L.Fcmp.One
            | A.Less    -> L.build_fcmp L.Fcmp.Olt
            | A.Leq     -> L.build_fcmp L.Fcmp.Ole
            | A.Greater -> L.build_fcmp L.Fcmp.Ogt
            | A.Geq     -> L.build_fcmp L.Fcmp.Oge
            ) e1' e2' "tmp" builder 
          in 

          let int_bop operator = 
            (match operator with
              A.Add     -> L.build_add
            | A.Sub     -> L.build_sub
            | A.Mul    -> L.build_mul
                  | A.Div     -> L.build_sdiv
            | A.And     -> L.build_and
            | A.Or      -> L.build_or
            | A.Eq   -> L.build_icmp L.Icmp.Eq
            | A.Neq     -> L.build_icmp L.Icmp.Ne
            | A.Less    -> L.build_icmp L.Icmp.Slt
            | A.Leq     -> L.build_icmp L.Icmp.Sle
            | A.Greater -> L.build_icmp L.Icmp.Sgt
            | A.Geq     -> L.build_icmp L.Icmp.Sge
            ) e1' e2' "tmp" builder
          in

        let string_of_e1'_llvalue = L.string_of_llvalue e1'
        and string_of_e2'_llvalue = L.string_of_llvalue e2' in

        let space = Str.regexp " " in

        let list_of_e1'_llvalue = Str.split space string_of_e1'_llvalue
        and list_of_e2'_llvalue = Str.split space string_of_e2'_llvalue in

        let i32_re = Str.regexp "i32\\|i32*\\|i8\\|i8*\\|i1\\|i1*"
        and float_re = Str.regexp "double\\|double*" in

        let rec match_string regexp str_list i =
         let length = List.length str_list in
         match (Str.string_match regexp (List.nth str_list i) 0) with
           true -> true
         | false -> if (i > length - 2) then false else match_string regexp str_list (succ i) in

        let get_type llvalue =
           match (match_string i32_re llvalue 0) with
             true  -> "int"
           | false -> (match (match_string float_re llvalue 0) with
                         true -> "float"
                       | false -> "") in

        let e1'_type = get_type list_of_e1'_llvalue
        and e2'_type = get_type list_of_e2'_llvalue in

        let build_ops_with_types typ1 typ2 =
          match (typ1, typ2) with
            "int", "int" -> int_bop op
          | "float" , "float" -> float_bop op
          | _, _ -> raise(IllegalAssignment)
        in
        build_ops_with_types e1'_type e2'_type
      | A.Unop(op, e) ->
        let e' = expr builder e in

        let float_uops operator =
          match operator with
            A.Neg -> L.build_fneg e' "tmp" builder
          | A.Not -> raise(IllegalUnop)  in

        let int_uops operator =
          match operator with
            A.Neg -> L.build_neg e' "tmp" builder
          | A.Not -> L.build_not e' "tmp" builder in

        let bool_uops operator = 
          match operator with
          A.Neg -> L.build_neg e' "tmp" builder
          | A.Not -> L.build_not e' "tmp" builder in

        let string_of_e'_llvalue = L.string_of_llvalue e' in

        let space = Str.regexp " " in

        let list_of_e'_llvalue = Str.split space string_of_e'_llvalue in

        let i32_re = Str.regexp "i32\\|i32*"
        and float_re = Str.regexp "double\\|double*"
        and bool_re = Str.regexp "i1\\|i1*" in

        let rec match_string regexp str_list i =
           let length = List.length str_list in
           match (Str.string_match regexp (List.nth str_list i) 0) with
             true -> true
           | false -> if (i > length - 2) then false else match_string regexp str_list (succ i) in

        let get_type llvalue =
           match (match_string i32_re llvalue 0) with
             true  -> "int"
           | false -> (match (match_string float_re llvalue 0) with
                         true -> "float"
                       | false -> (match (match_string bool_re llvalue 0) with
                                    true -> "bool"
                                  | false -> "")) in

        let e'_type = get_type list_of_e'_llvalue  in

        let build_ops_with_type typ =
          match typ with
            "int" -> int_uops op
          | "float" -> float_uops op
          | "bool" -> bool_uops op
          | _ -> raise(IllegalAssignment)
        in

        build_ops_with_type e'_type
      | A.Assign (e1, e2) -> let e1' = (match e1 with
                                            A.Id s -> lookup s
                                          | A.Matrix1DAccess (s, e1) -> let i1 = expr builder e1 in (match (type_of_identifier s) with 
                                                      A.Matrix1DType(_, l) -> (
                                                        if (matrix_expression e1) >= l then raise(MatrixOutOfBounds)
                                                        else build_1D_matrix_access s (L.const_int i32_t 0) i1 builder true)
                                                      | _ -> build_1D_matrix_access s (L.const_int i32_t 0) i1 builder true )
                                          | A.Matrix2DAccess (s, e1, e2) -> let i1 = expr builder e1 and i2 = expr builder e2 in (match (type_of_identifier s) with 
                                                      A.Matrix2DType(_, l1, l2) -> (
                                                        if (matrix_expression e1) >= l1 then raise(MatrixOutOfBounds)
                                                        else if (matrix_expression e2) >= l2 then raise(MatrixOutOfBounds)
                                                        else build_2D_matrix_access s (L.const_int i32_t 0) i1 i2 builder true)
                                                      | _ -> build_2D_matrix_access s (L.const_int i32_t 0) i1 i2 builder true )
                                          | A.PointerIncrement(s) -> build_pointer_increment s builder true
                                          | A.Dereference(s) -> build_pointer_dereference s builder true
                                          | _ -> raise (IllegalAssignment)
                                          )
                            and e2' = expr builder e2 in
                     ignore (L.build_store e2' e1' builder); e2'
      | A.Call ("print", [e]) | A.Call ("printb", [e]) ->
    L.build_call printf_func [| int_format_str ; (expr builder e) |]
      "printf" builder
      | A.Call ("printf", [e]) ->
    L.build_call printf_func [| float_format_str ; (expr builder e) |]
      "printf" builder
      | A.Call ("prints", [e]) -> let get_string = function A.StringLiteral s -> s | _ -> "" in
      let s_ptr = L.build_global_stringptr ((get_string e)) ".str" builder in
    L.build_call printf_func [| s_ptr |] 
      "printf" builder
      | A.Call (f, act) ->
         let (fdef, fdecl) = StringMap.find f function_decls in
   let actuals = List.rev (List.map (expr builder) (List.rev act)) in
   let result = (match fdecl.A.typ with A.Void -> ""
                                            | _ -> f ^ "_result") in
         L.build_call fdef (Array.of_list actuals) result builder
    in

    (* Invoke "f builder" if the current block doesn't already
       have a terminal (e.g., a branch). *)
    let add_terminal builder f =
      match L.block_terminator (L.insertion_block builder) with
  Some _ -> ()
      | None -> ignore (f builder) in
  
    (* Build the code for the given statement; return the builder for
       the statement's successor *)
    let rec stmt builder = function
  A.Block sl -> List.fold_left stmt builder sl
      | A.Expr e -> ignore (expr builder e); builder
      | A.Return e -> ignore (match fdecl.A.typ with
    A.Void -> L.build_ret_void builder
  | _ -> L.build_ret (expr builder e) builder); builder
      | A.If (predicate, then_stmt, else_stmt) ->
         let bool_val = expr builder predicate in
   let merge_bb = L.append_block context "merge" the_function in

   let then_bb = L.append_block context "then" the_function in
   add_terminal (stmt (L.builder_at_end context then_bb) then_stmt)
     (L.build_br merge_bb);

   let else_bb = L.append_block context "else" the_function in
   add_terminal (stmt (L.builder_at_end context else_bb) else_stmt)
     (L.build_br merge_bb);

   ignore (L.build_cond_br bool_val then_bb else_bb builder);
   L.builder_at_end context merge_bb

      | A.While (predicate, body) ->
    let pred_bb = L.append_block context "while" the_function in
    ignore (L.build_br pred_bb builder);

    let body_bb = L.append_block context "while_body" the_function in
    add_terminal (stmt (L.builder_at_end context body_bb) body)
      (L.build_br pred_bb);

    let pred_builder = L.builder_at_end context pred_bb in
    let bool_val = expr pred_builder predicate in

    let merge_bb = L.append_block context "merge" the_function in
    ignore (L.build_cond_br bool_val body_bb merge_bb pred_builder);
    L.builder_at_end context merge_bb

      | A.For (e1, e2, e3, body) -> stmt builder
      ( A.Block [A.Expr e1 ; A.While (e2, A.Block [body ; A.Expr e3]) ] )
    in

    (* Build the code for each statement in the function *)
    let builder = stmt builder (A.Block fdecl.A.body) in

    (* Add a return if the last block falls off the end *)
    add_terminal builder (match fdecl.A.typ with
        A.Void -> L.build_ret_void
      | A.Int -> L.build_ret (L.const_int i32_t 0)
      | A.Float -> L.build_ret (L.const_float float_t 0.0)
      | A.Bool -> L.build_ret (L.const_int i1_t 0)
      | A.Char -> L.build_ret (L.const_int i8_t 0)
      | _ -> raise (WrongReturn))
  in

  List.iter build_function_body functions;
  the_module
