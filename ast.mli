type bop = Add | Sub | Mul | Div 

type uop = Not

type expr =
    Literal of int
    | Variable of string
    | Binop of expr * bop * expr
    | Unop of uop * expr

type program = expr
(* TODO: Why are we not allowed to have this in the mli file
let string_of_bop = function
      Add -> "+"
      | Sub -> "-"
      | Mul -> "*"
      | Div -> "/"
let rec string_of_expr expr =
    Literal(i) -> "int_lit " ^ string_of_int i 
    Binop(r1, bop, r2) -> "Binop { " ^ string_of_expr r1 ^ " " ^ string_of_bop
    bop ^ " " ^ string_of_expr r2 ^ " }" 
    *)
