{ open Parser }

let letter = ['a'-'z' 'A'-'Z']
let digit = ['0'-'9']

rule token = parse 
      [' ' '\t' '\r' '\n'] { token lexbuf }
    | "/*"                 { comment lexbuf }
    | '('                  { LPAREN }
    | ')'                  { RPAREN }
    | '['                  { LBRACK }
    | ']'                  { RBRACK }
    | '{'                  { LCURLY }
    | '}'                  { RCURLY }
    | ';'                  { SEMI }
    | ','                  { COMMA }
    | ':'                  { COLON }
    | '+'                  { PLUS }
    | '-'                  { MINUS }
    | '*'                  { TIMES }
    | '/'                  { DIVIDE }
    | '='                  { ASSIGN }
    | "=="                 { EQ }
    | "!="                 { NEQ }
    | '<'                  { LT }
    | "<="                 { LEQ }
    | ">"                  { GT }
    | ">="                 { GEQ }
    | "&& "                { AND }
    | "||"                 { OR }
    | "!"                  { NOT }
    | ['0'-'9']+ as lxm    { LITERAL(int_of_string lxm) }
    | ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm {VARIABLE(lxm)}
    | eof                  { EOF }
and comment = parse 
     "*/"                  { token lexbuf }
    | _                    { comment lexbuf }
