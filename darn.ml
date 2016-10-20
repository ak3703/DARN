open Ast

let string_of_bop = function
      Add -> "+"
      | Sub -> "-"
      | Mul -> "*"
      | Div -> "/"
      | Less -> "<"
      | Greater -> ">"
      | Leq -> "<="
      | Geq -> ">="

let string_of_uop = function
      Not -> "!"
(* string print tree*)
let rec string_of_expr = function
    Literal(i) -> "int_lit " ^ string_of_int i
    | Variable(i) -> "var " ^ i
    | Unop(uop, r1) -> "Unop { " ^ (string_of_uop uop) ^ " " ^ string_of_expr r1 ^ " }"
    | Binop(r1, bop, r2) -> "Binop { " ^ string_of_expr r1 ^ " " ^ (string_of_bop
    bop) ^ " " ^ (string_of_expr r2) ^ " }"

let _ =
    let lexbuf = Lexing.from_channel stdin in
    let expr = Parser.program Scanner.token lexbuf in
    let result = string_of_expr expr in
    print_endline result
