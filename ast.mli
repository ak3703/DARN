type bop = Add | Sub | Mul | Div | Less | Greater | Leq | Geq | Or | And

type uop = Not

type expr =
    IntLiteral of int
    | FloatLiteral of float
    | Id of string
    | Binop of expr * bop * expr
    | Unop of uop * expr

type program = expr
