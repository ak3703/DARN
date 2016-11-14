type bop = Add | Sub | Mul | Div | Less | Greater 
					| Leq | Geq | Or | And | Eq | Neq 

type uop = Not

type typ = Int | Bool | Void

type bind = typ * string

type expr =
    IntLiteral of int
    | FloatLiteral of float
    | BoolLiteral of bool
    | Id of string
    | Binop of expr * bop * expr
    | Unop of uop * expr
    | Assign of expr * expr
    | Call of string * expr list
    | Noexpr

type stmt = 
		Block of stmt list
	| Expr of expr
  | Return of expr
  | If of expr * stmt * stmt
  | For of expr * expr * expr * stmt
  | While of expr * stmt

type func_decl = {
	typ : typ;
	fname : string;
	formals : bind list;
	locals : bind list;
	body : stmt list;
}
 

type program = bind list * func_decl list
