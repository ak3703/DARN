{ 

	open Parser 

	let unescape s =
    	Scanf.sscanf ("\"" ^ s ^ "\"") "%S%!" (fun x -> x)

}
let whitespace = [' ' '\t' '\r' '\n']
let esc = '\\' ['\\' ''' '"' 'n' 'r' 't']
let esc_ch = ''' (esc) '''
let ascii = ([' '-'!' '#'-'[' ']'-'~'])
let digits = ['0'-'9']
let alphabet = ['a'-'z' 'A'-'Z']
let alphanumund = alphabet | digits | '_'
let integer = digits+
let decimal = ['.']
let float = digits* decimal digits+ | digits+ decimal digits*
let string = '"' ( (ascii | esc)* as s ) '"'
let char = ''' ( ascii | digits ) '''
let id = alphabet alphanumund*

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

(* Reference Dereference *)
| '%' { PERCENT } | '#' { OCTOTHORP }

(* Conditional and Loops *)    
|   "if"    { IF }  |   "else"  { ELSE }    |   "elif"  { ELIF }
|   "for"   { FOR } |   "while" { WHILE }

(* Return *)
|   "return"    { RETURN }

(* Types *)
|   "true"  { TRUE }    |   "false" { FALSE }   |   "char"  { CHAR }
|   "int"   { INT }     |   "float" { FLOAT }   |   "bool"  { BOOL }
| 	"void"   { VOID }

(* Matrices *)
|  "len"	{ LEN }		|  	"height" { HEIGHT } |	"width" { WIDTH }

(* Literal *)
|   ['0'-'9']+ as lxm   { INTLITERAL(int_of_string lxm) }
|   float as lxm        { FLOATLITERAL(float_of_string lxm) }
| 	string       				{ STRINGLITERAL(unescape s) }
| 	char    as lxm { CHARLITERAL(String.get lxm 1) }
|   id      as lxm { ID(lxm) }

(* EOF *)
|   eof { EOF }

and comment = parse 
"*/"    { token lexbuf }
|   _   { comment lexbuf }
