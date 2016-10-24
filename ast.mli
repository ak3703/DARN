type bop = Add | Sub | Mul | Div | Less | Greater | Leq | Geq | Or | And | Eq |
Neq 

type uop = Not

type op = Assign

type expr =
    IntLiteral of int
    | FloatLiteral of float
    | Id of string
    | Binop of expr * bop * expr
    | Unop of uop * expr
    | Assign of string * expr

type program = expr
