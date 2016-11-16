open Ast

module StringMap = Map.Make(String)

let check (globals, functions) = (*add tuples, matrices as args *)

(* From MicroC *)

(* Raise an exception if the given list has a duplicate *)
  let report_duplicate exceptf list =
    let rec helper = function
	    n1 :: n2 :: _ when n1 = n2 -> raise (Failure (exceptf n1))
        | _ :: t -> helper t
        | [] -> ()
    in helper (List.sort compare list)
  in

(* Raise an exception if a given binding is to a void type *)
  let check_not_void exceptf = function
      (Void, n) -> raise (Failure (exceptf n))
    | _ -> ()
  in

(* Raise an exception of the given rvalue type cannot be assigned to
     the given lvalue type *)
  let check_assign lvaluet rvaluet err =
     if lvaluet = rvaluet then lvaluet else raise err
  in

(* Raise an exception if the tuple or matrix type is not in typedefs *)


(********* Checking Global Variables *****************)

(* Check globals for undefined references to tuples or matrices: add a check_defined function *)

(* Check global variables for void types *)
List.iter (check_not_void (fun n -> "Illegal void global " ^ n)) globals;

(* Check global variables for duplicate names *)
report_duplicate (fun n -> "Duplicate global " ^ n) (List.map snd globals);

(********* Checking Tuples *****************)

(********* Checking Matrices *****************)

(********* Checking Functions *****************)

(* Check that functions matrix, tuple, print are not defined *)

(* Check function named print is not defined *)
if List.mem "print" (List.map (fun fd -> fd.fname) functions) 
then raise (Failure ("Function print may not be defined")) else ();

(* Check that there are no duplicate function names *)
report_duplicate (fun n -> "Duplicate function " ^ n)
  (List.map (fun fd -> fd.fname) functions);

(* Function declaration for a named function *)
let built_in_decls = StringMap.add "print"
	{ typ = Void; fname = "print"; formals = [(Int, "x")]; (* change to a String for hello world*)
	  locals = []; body = [] } (StringMap.singleton "printb" {
	  typ = Void; fname = "printb"; formals = [(Bool, "x")];
	  locals = []; body = [] })
in

(* Built-in functions, print and printb *)
let function_decls = 
	List.fold_left (fun m fd -> StringMap.add fd.fname fd m) built_in_decls functions
in

let function_decl s = try StringMap.find s function_decls 
	with Not_found -> raise (Failure ("Unrecognized function " ^ s))
in

(* Ensure "main" is defined *)
let _ = function_decl "main" in

(* A function that is used to check each function *)
let check_function func =

	(* Check for undefined references to tuples or matrices *)

	List.iter(check_not_void (fun n -> 
		"Illegal void formal " ^ n ^ " in " ^ func.fname)) func.formals;

	report_duplicate (fun n ->
		"Duplicate formal " ^ n ^ " in " ^ func.fname)(List.map snd func.formals);

	List.iter (check_not_void (fun n ->
		"Illegal void local " ^ n ^ " in " ^ func.fname)) func.locals;

	report_duplicate (fun n ->
		"Duplicate local " ^ n ^ " in " ^ func.fname)(List.map snd func.locals);

(******* Checking Variables **********)
(* Type of each variable (global, formal, or local *)
    let symbols = List.fold_left (fun m (t, n) -> StringMap.add n t m)
	StringMap.empty (globals @ func.formals @ func.locals )
    in

    let type_of_identifier s =
      try StringMap.find s symbols
      with Not_found -> raise (Failure ("undeclared identifier " ^ s))
    in
(****** Establish the Type of Each Expression, Operator, Function Call, Statement *****)
(* Return the type of an expression or throw an exception *)
	let rec expr = function
	     IntLiteral _ -> Int
      | BoolLiteral _ -> Bool
      | Id s -> type_of_identifier s
      | Binop(e1, op, e2) as e -> let t1 = expr e1 and t2 = expr e2 in
	(match op with
          Add | Sub | Mul | Div when t1 = Int && t2 = Int -> Int
		  | Eq | Neq when t1 = t2 -> Bool
		  | Less | Leq | Greater | Geq when t1 = Int && t2 = Int -> Bool
		  | And | Or when t1 = Bool && t2 = Bool -> Bool
        		| _ -> raise (Failure ("Illegal binary operator " ^
             		string_of_typ t1 ^ " " ^ string_of_bop op ^ " " ^
              		string_of_typ t2 ^ " in " ^ string_of_expr e))
        )
      | Unop(op, e) as ex -> let t = expr e in
	 (match op with
	   (*Neg when t = Int -> Int*)
	 Not when t = Bool -> Bool
         | _ -> raise (Failure ("Illegal unary operator " ^ string_of_uop op ^
	  		   string_of_typ t ^ " in " ^ string_of_expr ex)))
      | Noexpr -> Void
      | Assign(var, e) as ex -> let lt = type_of_identifier var
                                and rt = expr e in
        check_assign lt rt (Failure ("Illegal assignment " ^ string_of_typ lt ^
				     " = " ^ string_of_typ rt ^ " in " ^ 
				     string_of_expr ex))
      | Call(fname, actuals) as call -> let fd = function_decl fname in
         if List.length actuals != List.length fd.formals then
           raise (Failure ("expecting " ^ string_of_int
             (List.length fd.formals) ^ " arguments in " ^ string_of_expr call))
         else
           List.iter2 (fun (ft, _) e -> let et = expr e in
              ignore (check_assign ft et
                (Failure ("Illegal actual argument found " ^ string_of_typ et ^
                " expected " ^ string_of_typ ft ^ " in " ^ string_of_expr e))))
             fd.formals actuals;
           fd.typ
    in

    let check_bool_expr e = if expr e != Bool
     then raise (Failure ("expected Boolean expression in " ^ string_of_expr e))
     else () in

    (* Verify a statement or throw an exception *)
    let rec stmt = function
	Block sl -> let rec check_block = function
           [Return _ as s] -> stmt s
         | Return _ :: _ -> raise (Failure "nothing may follow a return")
         | Block sl :: ss -> check_block (sl @ ss)
         | s :: ss -> stmt s ; check_block ss
         | [] -> ()
        in check_block sl
      | Expr e -> ignore (expr e)
      | Return e -> let t = expr e in if t = func.typ then () else
         raise (Failure ("return gives " ^ string_of_typ t ^ " expected " ^
                         string_of_typ func.typ ^ " in " ^ string_of_expr e))
           
      | If(p, b1, b2) -> check_bool_expr p; stmt b1; stmt b2
      | For(e1, e2, e3, st) -> ignore (expr e1); check_bool_expr e2;
                               ignore (expr e3); stmt st
      | While(p, s) -> check_bool_expr p; stmt s
    in

    stmt (Block func.body)
   
  in
  List.iter check_function functions


























