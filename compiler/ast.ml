type op = Add | Sub | Mul | Div | Less | Greater 
					| Leq | Geq | Or | And | Eq | Neq 

type uop = Not | Neg

type typ = 
    Int 
    | Bool 
    | Void 
    | Float
    | Char
    | String
    | Matrix1DType of typ * int
    | Matrix2DType of typ * int * int
    | Matrix1DPointer of typ
    | Matrix2DPointer of typ

type bind = typ * string

type expr =
    IntLiteral of int
    | FloatLiteral of float
    | BoolLiteral of bool
    | CharLiteral of char
    | StringLiteral of string
    | Id of string
    | Binop of expr * op * expr
    | Unop of uop * expr
    | Assign of expr * expr
    | PointerIncrement of string
    | MatrixLiteral of expr list
    | Matrix1DAccess of string * expr 
    | Matrix2DAccess of string * expr * expr
    | Len of string
    | Height of string
    | Width of string
    | Call of string * expr list
    | Noexpr
    | Matrix1DReference of string
    | Matrix2DReference of string
    | Dereference of string

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


(* Pretty Printer *)
let string_of_bop = function
      Add -> "+"
      | Sub -> "-"
      | Mul -> "*"
      | Div -> "/"
      | Less -> "<"
      | Greater -> ">"
      | Leq -> "<="
      | Geq -> ">="
      | Or -> "||"
      | And -> "&&"
      | Eq -> "=="
      | Neq -> "!="
      
let string_of_uop = function
      Not -> "!"
     | Neg -> "-"

let string_of_matrix m =
  let rec string_of_matrix_lit = function
      [] -> "]"
    | [hd] -> (match hd with
                IntLiteral(i) -> string_of_int i
              | FloatLiteral(i) -> string_of_float i
              | BoolLiteral(i) -> string_of_bool i
              | Id(s) -> s
              | _ -> raise( Failure("Illegal expression in matrix literal") )) ^ string_of_matrix_lit []
    | hd::tl -> (match hd with
                    IntLiteral(i) -> string_of_int i ^ ", "
                  | FloatLiteral(i) -> string_of_float i ^ ", "
                  | BoolLiteral(i) -> string_of_bool i ^ ", "
                  | Id(s) -> s
                  | _ -> raise( Failure("Illegal expression in matrix literal") )) ^ string_of_matrix_lit tl
  in
  "[" ^ string_of_matrix_lit m

let rec string_of_expr = function
    IntLiteral(i) -> string_of_int i
    | FloatLiteral(i) -> string_of_float i
    | BoolLiteral(i) -> string_of_bool i
    | CharLiteral(i) ->  String.make 1 i
    | StringLiteral(i) -> i
    | Id(i) -> i
    | Unop(uop, r1) -> (string_of_uop uop) ^ string_of_expr r1
    | Binop(r1, bop, r2) -> string_of_expr r1 ^ " " ^ (string_of_bop
    bop) ^ " " ^ (string_of_expr r2)
    | PointerIncrement(s) -> "++" ^ s 
    | Assign(r1, r2) -> (string_of_expr r1) ^ " =  " ^ (string_of_expr r2) 
    | MatrixLiteral(m) -> string_of_matrix m
    | Matrix1DAccess(s, r1) -> s ^ "[" ^ (string_of_expr r1) ^ "]"
    | Matrix2DAccess(s, r1, r2) -> s ^ "[" ^ (string_of_expr r1) ^ "]" ^ "[" ^ (string_of_expr r2) ^ "]"
    | Len(s) -> "len(" ^ s ^ ")"
    | Height(s) -> "height(" ^ s ^ ")"
    | Width(s) -> "width(" ^ s ^ ")"
    | Call(f, el) ->
      f ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
    | Noexpr -> ""
    | Matrix1DReference(s) -> "%" ^ s
    | Matrix2DReference(s) -> "%%" ^ s
    | Dereference(s) -> "#" ^ s

let rec string_of_stmt = function
    Block(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_stmt stmts) ^ "}\n"
  | Expr(expr) -> string_of_expr expr ^ ";\n";
  | Return(expr) -> "return " ^ string_of_expr expr ^ ";\n";
  | If(e, s, Block([])) -> "if (" ^ string_of_expr e ^ ")\n" ^ string_of_stmt s
  | If(e, s1, s2) ->  "if (" ^ string_of_expr e ^ ")\n" ^
      string_of_stmt s1 ^ "else\n" ^ string_of_stmt s2
  | For(e1, e2, e3, s) ->
      "for (" ^ string_of_expr e1  ^ " ; " ^ string_of_expr e2 ^ " ; " ^
      string_of_expr e3  ^ ") " ^ string_of_stmt s
  | While(e, s) -> "while (" ^ string_of_expr e ^ ") " ^ string_of_stmt s

let rec string_of_typ = function
    Int -> "int"
  | Bool -> "bool"
  | Void -> "void"
  | Float -> "float"
  | Char -> "char"
  | String -> "string"
  | Matrix1DType(t, i1) -> string_of_typ t ^ "[" ^ string_of_int i1 ^ "]"
  | Matrix2DType(t, i1, i2) -> string_of_typ t ^ "[" ^ string_of_int i1 ^ "]" ^ "[" ^ string_of_int i2 ^ "]"
  | Matrix1DPointer(t) -> string_of_typ t ^ "[]"
  | Matrix2DPointer(t) -> string_of_typ t ^ "[][]"

let string_of_vdecl (t, id) = string_of_typ t ^ " " ^ id ^ ";\n"

let string_of_fdecl fdecl =
  string_of_typ fdecl.typ ^ " " ^
  fdecl.fname ^ "(" ^ String.concat ", " (List.map snd fdecl.formals) ^
  ")\n{\n" ^
  String.concat "" (List.map string_of_vdecl fdecl.locals) ^
  String.concat "" (List.map string_of_stmt fdecl.body) ^
  "} \n"

let string_of_program (vars, funcs) =
  String.concat "" (List.map string_of_vdecl vars) ^ "\n" ^
  String.concat "\n" (List.map string_of_fdecl funcs)

