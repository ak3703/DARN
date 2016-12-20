%{ open Ast %}

/* Punctuation */
%token SEMI LPAREN RPAREN LCURLY RCURLY LBRACK RBRACK COMMA COLON

/* Arithmetic */
%token PLUS MINUS TIMES DIVIDE 

/* Boolean Value */
%token TRUE FALSE

/* Conditional Operators */
%token IF ELSE ELIF FOR WHILE

/* Relational Operators */
%token EQ NEQ LT LEQ GT GEQ 

/* Logical Operators */
%token AND OR NOT

/* Matrices */
%token LEN HEIGHT WIDTH

/* Assignment */
%token ASSIGN 

/* Variable Type */
%token BOOL INT FLOAT CHAR VOID

/* Functional Keywords */
%token RETURN

/* Reference and Dereference */
%token OCTOTHORP PERCENT

/* End Of File */
%token EOF 

/* Literals */
%token <int> INTLITERAL
%token <float> FLOATLITERAL
%token <string> STRINGLITERAL
%token <char> CHARLITERAL

%token <string> ID

%nonassoc NOELSE
%nonassoc ELSE
%nonassoc NOLBRACK
%nonassoc LBRACK
%right ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LT GT LEQ GEQ
%left PLUS MINUS
%left TIMES DIVIDE 
%right NOT NEG

%start program  
%type <Ast.program> program 

%%

program: 
    decls EOF { $1 }

decls:
    /* nothing */       { [], []}
    | decls vdecl       { ($2 :: fst $1), snd $1 }
    | decls fdecl       { fst $1, ($2 :: snd $1) }

fdecl:
   typ ID LPAREN formals_opt RPAREN LCURLY vdecl_list stmt_list RCURLY
     { { typ = $1;
     fname = $2;
     formals = $4;
     locals = List.rev $7;
     body = List.rev $8 } }

formals_opt:
    /* nothing */ { [] }
    | formal_list { List.rev $1 }

formal_list:
    typ ID  { [($1,$2)] }
    | formal_list COMMA typ ID { ($3,$4) :: $1 }

typ:
  INT { Int }
  | BOOL { Bool }
  | VOID { Void }
  | FLOAT { Float }
  | CHAR { Char }
  | matrix1D_typ { $1 }
  | matrix2D_typ { $1 }
  | matrix1D_pointer_typ { $1 }
  | matrix2D_pointer_typ { $1 }

matrix1D_typ:
    typ LBRACK INTLITERAL RBRACK %prec NOLBRACK  { Matrix1DType($1, $3) }

matrix2D_typ:
    typ LBRACK INTLITERAL RBRACK LBRACK INTLITERAL RBRACK  { Matrix2DType($1, $3, $6) }

matrix1D_pointer_typ:
  typ LBRACK RBRACK %prec NOLBRACK { Matrix1DPointer($1)}

matrix2D_pointer_typ:
  typ LBRACK RBRACK LBRACK RBRACK { Matrix2DPointer($1) }

vdecl_list:
    /* nothing */    { [] }
  | vdecl_list vdecl { $2 :: $1 }

vdecl:
   typ ID SEMI { ($1, $2) }

stmt_list:
    /* nothing */  { [] }
  | stmt_list stmt { $2 :: $1 }

stmt:
    expr SEMI { Expr $1 }
    | RETURN SEMI { Return Noexpr }
    | RETURN expr SEMI { Return $2 }
    | LCURLY stmt_list RCURLY { Block(List.rev $2) }
    | IF LPAREN expr RPAREN stmt %prec NOELSE { If($3, $5, Block([])) }
    | IF LPAREN expr RPAREN stmt ELSE stmt    { If($3, $5, $7) }
    | FOR LPAREN expr_opt SEMI expr SEMI expr_opt RPAREN stmt { For($3, $5, $7, $9) }
    | WHILE LPAREN expr RPAREN stmt { While($3, $5) }
    /* add conditional statements and return */ 
    
expr_opt:
    /* nothing */ { Noexpr }
    | expr          { $1 }

expr:
    arith_ops                                       { $1 }
    | bool_ops                                      { $1 }
    | primitives                                    { $1 }
    | expr ASSIGN expr                              { Assign($1, $3)  }
    | LPAREN expr RPAREN                            { $2 }
    | CHARLITERAL                                   { CharLiteral($1) }
    | STRINGLITERAL                                 { StringLiteral($1) }
    | TRUE                                          { BoolLiteral(true) }
    | FALSE                                         { BoolLiteral(false) }
    | ID LPAREN actuals_opt RPAREN                  { Call($1, $3)}
    | LBRACK matrix_literal RBRACK                  { MatrixLiteral(List.rev $2) }
    | ID LBRACK expr  RBRACK %prec NOLBRACK         { Matrix1DAccess($1, $3)}
    | ID LBRACK expr  RBRACK LBRACK expr  RBRACK    { Matrix2DAccess($1, $3, $6)}
    | LEN LPAREN ID RPAREN                          { Len($3) }
    | HEIGHT LPAREN ID RPAREN                       { Height($3) }
    | WIDTH LPAREN ID RPAREN                        { Width($3) }
    | ID 			                                      { Id($1)} 
    | PERCENT ID                                  { Matrix1DReference($2)}
    | PERCENT PERCENT ID                        { Matrix2DReference($3)}
    | OCTOTHORP ID                                  { Dereference($2)}
    | PLUS PLUS ID                                  { PointerIncrement($3) }

primitives:
    INTLITERAL                                    { IntLiteral($1)   }
  | FLOATLITERAL                                  { FloatLiteral($1) }

matrix_literal:
    primitives                      { [$1] }
  | matrix_literal COMMA primitives { $3 :: $1 }

arith_ops:
    expr PLUS expr    {Binop($1, Add, $3)  }
    | expr MINUS expr   {Binop($1, Sub, $3)  }
    | expr TIMES expr   {Binop($1, Mul, $3)  } 
    | expr DIVIDE expr  {Binop($1, Div, $3)  }

bool_ops:
    expr LT expr        {Binop($1, Less, $3) }
    | expr GT expr      {Binop($1, Greater, $3) }
    | expr LEQ expr     {Binop($1, Leq, $3)  }
    | expr GEQ expr     {Binop($1, Geq, $3)  }
    | expr NEQ expr     {Binop($1, Neq, $3)  }
    | expr EQ expr      {Binop($1, Eq, $3)   }
    | expr OR expr      {Binop($1, Or, $3)   }
    | expr AND expr     {Binop($1, And, $3)  } 
    | NOT expr		      {Unop(Not, $2)    }
    | MINUS expr %prec NEG { Unop(Neg, $2) }

actuals_opt:
    /* nothing */ { [] }
  | actuals_list  { List.rev $1 }

actuals_list:
    expr                    { [$1] }
  | actuals_list COMMA expr { $3 :: $1 }

