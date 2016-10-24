type bop = Add | Sub | Mul | Div | Less | Greater | Leq | Geq | Or | And | Eq |
Neq 

type uop = Not

type expr =
    IntLiteral of int
    | FloatLiteral of float
    | BoolLiteral of bool
    | Id of string
    | Binop of expr * bop * expr
    | Unop of uop * expr
    | Assign of expr * expr


type program = expr
