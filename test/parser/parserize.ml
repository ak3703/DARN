open Ast
open Printf

let _ =
    let lexbuf = Lexing.from_channel stdin in
    let ast = Parser.program Scanner.token lexbuf in
    let _ = Semant.check ast in
    let result = string_of_program ast in
    print_string result
