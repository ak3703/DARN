{ open Parser }

let letter = ['a'-'z' 'A'-'Z']
let digit = ['0'-'9']

rule token = parse 
      [' ' '\t' '\r' '\n'] { token lexbuf }
    | "/*"                 { comment lexbuf }
    | '+'                  { PLUS }
    | '-'                  { MINUS }
    | '*'                  { TIMES }
    | '/'                  { DIVIDE }
    | ['0'-'9']+ as lxm    { LITERAL(int_of_string lxm) }
    | eof                  { EOF }
and comment = parse 
     "*/"                  { token lexbuf }
    | _                    { comment lexbuf }
