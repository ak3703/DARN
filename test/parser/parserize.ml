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
    | Noexpr -> ""

let string_of_typ = function
    Int -> "int"
  | Bool -> "bool"
  | Void -> "void"

let string_of_vdecl (t, id) = string_of_typ t ^ " " ^ id ^ ";\n"

let string_of_program (vars, funcs) =
  String.concat "" (List.map string_of_vdecl vars) ^ "\n" 

let _ =
    let lexbuf = Lexing.from_channel stdin in
    let ast = Parser.program Scanner.token lexbuf in
    let result = string_of_program ast in
    print_string result
