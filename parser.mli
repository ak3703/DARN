type token =
  | SEMI
  | LPAREN
  | RPAREN
  | LCURLY
  | RCURLY
  | LBRACK
  | RBRACK
  | COMMA
  | COLON
  | PLUS
  | MINUS
  | TIMES
  | DIVIDE
  | EOF
  | ASSIGN
  | NOT
  | EQ
  | NEQ
  | LT
  | LEQ
  | GT
  | GEQ
  | AND
  | OR
  | LITERAL of (int)
  | VARIABLE of (string)

val program :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.program
