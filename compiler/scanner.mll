{ open Parser }

let letter = ['a'-'z' 'A'-'Z']
let digit = ['0'-'9']
let decimal = ['.']
let float = digit* decimal digit+ | digit+ decimal digit*


rule token = parse

(* Whitespace *)
[' ' '\t' '\r' '\n']    { token lexbuf }

(* Comment *)
| "/*"  { comment lexbuf }

(* Punctuation *)
|   '(' { LPAREN }  |   ')' { RPAREN }  |   '[' { LBRACK }  
|   ']' { RBRACK }  |   '{' { LCURLY }  |   '}' { RCURLY }
|   ';' { SEMI }    |   ',' { COMMA }   |   ':' { COLON }

(* Arithmetic *)    
|   '+' { PLUS }    |   '-' { MINUS }
|   '*' { TIMES }   |   '/' { DIVIDE }

(* Assignment *)
|   '='     { ASSIGN }

(* Relational *)
|   "=="    { EQ }  |   "!="    { NEQ } |   '<'     { LT }  
|   "<="    { LEQ } |   '>'     { GT }  |   ">="    { GEQ } 

(* Logical *)
|   "&&"    { AND } |   "||"    { OR }  |   "!"     { NOT }
    
(* Conditional and Loops *)    
|   "if"    { IF }  |   "else"  { ELSE }    |   "elif"  { ELIF }
|   "for"   { FOR } |   "while" { WHILE }

(* Return *)
|   "return"    { RETURN }

(* Types *)
|   "true"  { TRUE }    |   "false" { FALSE }   |   "char"  { CHAR }
|   "int"   { INT }     |   "float" { FLOAT }   |   "bool"  { BOOL }

(* Literal *)
|   ['0'-'9']+ as lxm   { INTLITERAL(int_of_string lxm) }
|   float as lxm        { FLOATLITERAL(float_of_string lxm) }
|   ['a'-'z' 'A'-'Z']['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm  {ID(lxm)}

(* EOF *)
|   eof { EOF }

and comment = parse 
"*/"    { token lexbuf }
|   _   { comment lexbuf }
