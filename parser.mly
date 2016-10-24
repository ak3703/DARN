%{ open Ast %}

%token SEMI LPAREN RPAREN LCURLY RCURLY LBRACK RBRACK COMMA COLON
%token PLUS MINUS TIMES DIVIDE EOF ASSIGN NOT
%token BOOL INT FLOAT CHAR TRUE FALSE
%token EQ NEQ LT LEQ GT GEQ AND OR

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
program: expr EOF { $1 }
expr:
      expr PLUS expr    {Binop($1, Add, $3) }
    | expr MINUS expr   {Binop($1, Sub, $3) }
    | expr TIMES expr   {Binop($1, Mul, $3) } 
    | expr DIVIDE expr  {Binop($1, Div, $3) }
    | expr LT expr      {Binop($1, Less, $3) }
    | expr GT expr      {Binop($1, Greater, $3) }
    | expr LEQ expr     {Binop($1, Leq, $3) }
    | expr GEQ expr     {Binop($1, Geq, $3) }
    | expr NEQ expr     {Binop($1, Neq, $3) }
    | expr EQ expr      {Binop($1, Eq, $3) }
    | expr OR expr      {Binop($1, Or, $3) }
    | expr AND expr     {Binop($1, And, $3) }
    | NOT expr			{Unop(Not, $2) }
    | ID ASSIGN expr    { Assign($1, $3) }
    | LPAREN expr RPAREN { $2 }
    | INTLITERAL        {IntLiteral($1)}
    | FLOATLITERAL      {FloatLiteral($1)}
    | ID 			    {Id($1)}
