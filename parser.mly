%{ open Ast %}

%token SEMI LPAREN RPAREN LCURLY RCURLY LBRACK RBRACK COMMA COLON
%token PLUS MINUS TIMES DIVIDE EOF ASSIGN NOT
%token EQ NEQ LT LEQ GT GEQ AND OR

%token <int> LITERAL

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
    | LITERAL           {Literal($1)}
