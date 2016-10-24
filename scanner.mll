{ open Parser }

let letter = ['a'-'z' 'A'-'Z']
let digit = ['0'-'9']
let decimal = ['.']
let float = digit* decimal digit+ | digit+ decimal digit*

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
    | '>'                  { GT }
    | ">="                 { GEQ }
    | "&&"                 { AND }
    | "||"                 { OR }
    | "!"                  { NOT }
    | ['0'-'9']+ as lxm    { INTLITERAL(int_of_string lxm) }
    | float as lxm         { FLOATLITERAL(float_of_string lxm) }
    | ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm {ID(lxm)}
    | eof                  { EOF }
and comment = parse 
     "*/"                  { token lexbuf }
    | _                    { comment lexbuf }
