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
  | BOOL
  | INT
  | FLOAT
  | CHAR
  | TRUE
  | FALSE
  | EQ
  | NEQ
  | LT
  | LEQ
  | GT
  | GEQ
  | AND
  | OR
  | INTLITERAL of (int)
  | FLOATLITERAL of (float)
  | ID of (string)

val program :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.program
