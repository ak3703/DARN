open Ast

let string_of_bop = function
      Add -> "+"
      | Sub -> "-"
      | Mul -> "*"
      | Div -> "/"

let rec string_of_expr = function
    Literal(i) -> "int_lit " ^ string_of_int i
    | Binop(r1, bop, r2) -> "Binop { " ^ string_of_expr r1 ^ " " ^ (string_of_bop
    bop) ^ " " ^ (string_of_expr r2) ^ " }"

let _ =
    let lexbuf = Lexing.from_channel stdin in
    let expr = Parser.program Scanner.token lexbuf in
    let result = string_of_expr expr in
    print_endline result
