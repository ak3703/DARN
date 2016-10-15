type bop = Add | Sub | Mul | Div 

type uop = Neg | Not
type expr =
    Literal of int
    | Binop of expr * bop * expr

type program = expr
