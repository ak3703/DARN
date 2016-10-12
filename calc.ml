open Ast

let arr = Array.make 10 0;;

let rec eval = function
    Lit(x) -> x
    | Var(x) -> arr.(x)
    | Asn(e1, e2) ->
            let _ = arr.(e1) <- (eval e2) in arr.(e1)
    | Seq(e1, e2) ->
            let _ = eval e1 in eval e2
    | Binop(e1, op, e2) ->
            let v1 = eval e1 and v2 = eval e2 in
            match op with
            Add -> v1 + v2
            | Sub -> v1 - v2
            | Mul -> v1 * v2
            | Div -> v1 / v2

let _ =
    let lexbuf = Lexing.from_channel stdin in
    let expr = Parser.expr Scanner.token lexbuf in
    let result = eval expr in
    print_endline (string_of_int result)
