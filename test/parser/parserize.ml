open Ast
open Printf

let string_of_bop = function
      Add -> "+"
      | Sub -> "-"
      | Mul -> "*"
      | Div -> "/"
      | Less -> "<"
      | Greater -> ">"
      | Leq -> "<="
      | Geq -> ">="
      | Or -> "||"
      | And -> "&&"
      | Eq -> "=="
      | Neq -> "!="
      
let string_of_uop = function
      Not -> "!"

(* string print tree*)
let rec string_of_expr = function
    IntLiteral(i) -> "int_lit " ^ string_of_int i
    | FloatLiteral(i) -> "float_lit " ^ string_of_float i
    | BoolLiteral(i) -> "bool_lit " ^ string_of_bool i
    | Id(i) -> "var " ^ i
    | Unop(uop, r1) -> "Unop { " ^ (string_of_uop uop) ^ " " ^ string_of_expr r1 ^ " }"
    | Binop(r1, bop, r2) -> "Binop { " ^ string_of_expr r1 ^ " " ^ (string_of_bop
    bop) ^ " " ^ (string_of_expr r2) ^ " }"
    | Assign(r1, r2) -> "Assign { " ^ (string_of_expr r1) ^ " =  " ^ (string_of_expr r2) ^ " }"
    | Call(f, el) ->
      f ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
    | Noexpr -> ""

let rec string_of_stmt = function
    Block(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_stmt stmts) ^ "}\n"
  | Expr(expr) -> string_of_expr expr ^ ";\n";
  | Return(expr) -> "return " ^ string_of_expr expr ^ ";\n";
  | If(e, s, Block([])) -> "if (" ^ string_of_expr e ^ ")\n" ^ string_of_stmt s
  | If(e, s1, s2) ->  "if (" ^ string_of_expr e ^ ")\n" ^
      string_of_stmt s1 ^ "else\n" ^ string_of_stmt s2
  | For(e1, e2, e3, s) ->
      "for (" ^ string_of_expr e1  ^ " ; " ^ string_of_expr e2 ^ " ; " ^
      string_of_expr e3  ^ ") " ^ string_of_stmt s
  | While(e, s) -> "while (" ^ string_of_expr e ^ ") " ^ string_of_stmt s

let string_of_typ = function
    Int -> "int"
  | Bool -> "bool"
  | Void -> "void"

let string_of_vdecl (t, id) = "vdecl { \n" ^ string_of_typ t ^ " id " ^ id ^ 
  ";\n}\n"

let string_of_fdecl fdecl =
  "fdecl { \n" ^ string_of_typ fdecl.typ ^ " " ^
  fdecl.fname ^ "(" ^ String.concat ", " (List.map snd fdecl.formals) ^
  ") {\n" ^
  String.concat "" (List.map string_of_vdecl fdecl.locals) ^
  String.concat "" (List.map string_of_stmt fdecl.body) ^
  "} \n}\n"

let string_of_program (vars, funcs) =
  String.concat "" (List.map string_of_vdecl vars) ^ "\n" ^
  String.concat "\n" (List.map string_of_fdecl funcs)

let _ =
    let lexbuf = Lexing.from_channel stdin in
    let ast = Parser.program Scanner.token lexbuf in
    let result = string_of_program ast in
    print_string result
