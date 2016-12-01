open Ast
open Parser

let tokenize = function 
(* Punctuation *)
| LPAREN -> "LPAREN"
| RPAREN -> "RPAREN"
| LBRACK -> "LBRACK"
| RBRACK -> "RBRACK"
| LCURLY -> "LCURLY"
| RCURLY -> "RCURLY"
| SEMI -> "SEMI"
| COMMA -> "COMMA"
| COLON -> "COLON"
(* Arithmetic *)
| PLUS -> "PLUS"
| MINUS -> "MINUS"
| TIMES -> "TIMES"
| DIVIDE -> "DIVIDE"
(* Assignment *)
| ASSIGN -> "ASSIGN"
(* Relational *)
| EQ -> "EQ"
| NEQ -> "NEQ"
| LT -> "LT"
| LEQ -> "LEQ"
| GT -> "GT"
| GEQ -> "GEQ"
(* Logical *)
| AND -> "AND"
| OR -> "OR"
| NOT -> "NOT"
(* Conditional and Loops *)
| IF -> "IF"
| ELSE -> "ELSE"
| ELIF -> "ELIF"
| FOR -> "FOR"
| WHILE -> "WHILE"
(* Return *)
| RETURN -> "RETURN"
(* Types *)
| TRUE -> "TRUE"
| FALSE -> "FALSE"
| CHAR -> "CHAR"
| INT -> "INT"
| FLOAT -> "FLOAT"
| BOOL -> "BOOL"
| VOID -> "VOID"
(* Literal *)
| INTLITERAL(int) -> "INTLITERAL"
| FLOATLITERAL(float) -> "FLOATLITERAL"
| ID(string) -> "ID"
| CHARLITERAL(char) -> "CHARLITERAL"
| STRINGLITERAL(string) -> "STRINGLITERAL"
| EOF -> "EOF"

let _ =
    let lexbuf = Lexing.from_channel stdin in 
    let rec print_tokens = function
    | EOF -> " "
    | token -> 
            print_endline (tokenize token);
            print_tokens (Scanner.token lexbuf) in
    print_tokens (Scanner.token lexbuf)
