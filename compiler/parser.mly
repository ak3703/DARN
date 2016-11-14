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

/* Assignment */
%token ASSIGN 

/* Variable Type */
%token BOOL INT FLOAT CHAR VOID

/* Functional Keywords */
%token RETURN

/* End Of File */
%token EOF 

/* Literals */
%token <int> INTLITERAL
%token <float> FLOATLITERAL

%token <string> ID

%right ASSIGN
%left OR
%left AND
%left EQ NEQ
%left LT GT LEQ GEQ
%left PLUS MINUS
%left TIMES DIVIDE 
%right NOT

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

expr_opt:
    /* nothing */ { Noexpr }
    | expr          { $1 }

expr:
    arith_ops           { $1 }
    | bool_ops          { $1 }
    | expr ASSIGN expr  { Assign($1, $3)  }
    | LPAREN expr RPAREN { $2 }
    | INTLITERAL        {IntLiteral($1)   }
    | FLOATLITERAL      {FloatLiteral($1) }
    | TRUE              {BoolLiteral(true)}
    | FALSE             {BoolLiteral(false)}
    | ID 			{Id($1)} 

arith_ops:
    expr PLUS expr    {Binop($1, Add, $3)  }
    | expr MINUS expr   {Binop($1, Sub, $3)  }
    | expr TIMES expr   {Binop($1, Mul, $3)  } 
    | expr DIVIDE expr  {Binop($1, Div, $3)  }

bool_ops:
    expr LT expr      {Binop($1, Less, $3) }
    | expr GT expr      {Binop($1, Greater, $3) }
    | expr LEQ expr     {Binop($1, Leq, $3)  }
    | expr GEQ expr     {Binop($1, Geq, $3)  }
    | expr NEQ expr     {Binop($1, Neq, $3)  }
    | expr EQ expr      {Binop($1, Eq, $3)   }
    | expr OR expr      {Binop($1, Or, $3)   }
    | expr AND expr     {Binop($1, And, $3)  } 
    | NOT expr		    {Unop(Not, $2)    }

