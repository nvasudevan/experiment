%token IDENTIFIER CONSTANT STRING_LITERAL SIZEOF
%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN TYPE_NAME
%token TYPEDEF EXTERN STATIC AUTO REGISTER
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token STRUCT UNION ENUM ELIPSIS
%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%%


file : file external_definition | external_definition
;
parameter_identifier_list : identifier_list ',' ELIPSIS | identifier_list
;
jump_statement : RETURN expr ';' | RETURN ';' | BREAK ';' | CONTINUE ';' | GOTO identifier ';'
;
and_expr : and_expr '&' equality_expr | equality_expr
;
struct_or_union : UNION | STRUCT
;
struct_or_union_specifier : struct_or_union identifier | struct_or_union '{' struct_declaration_list '}' | struct_or_union identifier '{' struct_declaration_list '}'
;
logical_or_expr : logical_or_expr OR_OP logical_and_expr | logical_and_expr
;
struct_declarator : declarator ':' constant_expr | ':' constant_expr | declarator
;
initializer_list : initializer_list ',' initializer | initializer
;
compound_statement : '{' declaration_list statement_list '}' | '{' declaration_list '}' | '{' statement_list '}' | '{' '}'
;
equality_expr : equality_expr NE_OP relational_expr | equality_expr EQ_OP relational_expr | relational_expr
;
declaration_specifiers : type_specifier declaration_specifiers | type_specifier | storage_class_specifier declaration_specifiers | storage_class_specifier
;
function_definition : declaration_specifiers declarator function_body | declarator function_body
;
assignment_operator : OR_ASSIGN | XOR_ASSIGN | AND_ASSIGN | RIGHT_ASSIGN | LEFT_ASSIGN | SUB_ASSIGN | ADD_ASSIGN | MOD_ASSIGN | DIV_ASSIGN | MUL_ASSIGN | '='
;
logical_and_expr : logical_and_expr AND_OP inclusive_or_expr | inclusive_or_expr
;
primary_expr : '(' expr ')' | STRING_LITERAL | CONSTANT | identifier
;
shift_expr : shift_expr RIGHT_OP additive_expr | shift_expr LEFT_OP additive_expr | additive_expr
;
struct_declaration : type_specifier_list struct_declarator_list ';'
;
conditional_expr : logical_or_expr '?' logical_or_expr ':' conditional_expr | logical_or_expr
;
relational_expr : relational_expr GE_OP shift_expr | relational_expr LE_OP shift_expr | relational_expr '>' shift_expr | relational_expr '<' shift_expr | shift_expr
;
iteration_statement : FOR '(' expr ';' expr ';' expr ')' statement | FOR '(' expr ';' expr ';' ')' statement | FOR '(' expr ';' ';' expr ')' statement | FOR '(' expr ';' ';' ')' statement | FOR '(' ';' expr ';' expr ')' statement | FOR '(' ';' expr ';' ')' statement | FOR '(' ';' ';' expr ')' statement | FOR '(' ';' ';' ')' statement | DO statement WHILE '(' expr ')' ';' | WHILE '(' expr ')' statement
;
additive_expr : additive_expr '-' multiplicative_expr | additive_expr '+' multiplicative_expr | multiplicative_expr
;
expression_statement : expr ';' | ';'
;
external_definition : declaration | function_definition
;
unary_expr : SIZEOF '(' type_name ')' | SIZEOF unary_expr | unary_operator cast_expr | DEC_OP unary_expr | INC_OP unary_expr | postfix_expr
;
enumerator : identifier '=' constant_expr | identifier
;
abstract_declarator2 : abstract_declarator2 '(' parameter_type_list ')' | abstract_declarator2 '(' ')' | '(' parameter_type_list ')' | '(' ')' | abstract_declarator2 '[' constant_expr ']' | abstract_declarator2 '[' ']' | '[' constant_expr ']' | '[' ']' | '(' abstract_declarator ')'
;
labeled_statement : DEFAULT ':' statement | CASE constant_expr ':' statement | identifier ':' statement
;
declaration_list : declaration_list declaration | declaration
;
struct_declarator_list : struct_declarator_list ',' struct_declarator | struct_declarator
;
init_declarator : declarator '=' initializer | declarator
;
enum_specifier : ENUM identifier | ENUM identifier '{' enumerator_list '}' | ENUM '{' enumerator_list '}'
;
postfix_expr : postfix_expr DEC_OP | postfix_expr INC_OP | postfix_expr PTR_OP identifier | postfix_expr '.' identifier | postfix_expr '(' argument_expr_list ')' | postfix_expr '(' ')' | postfix_expr '[' expr ']' | primary_expr
;
multiplicative_expr : multiplicative_expr '%' cast_expr | multiplicative_expr '/' cast_expr | multiplicative_expr '*' cast_expr | cast_expr
;
inclusive_or_expr : inclusive_or_expr '|' exclusive_or_expr | exclusive_or_expr
;
init_declarator_list : init_declarator_list ',' init_declarator | init_declarator
;
pointer : '*' type_specifier_list pointer | '*' pointer | '*' type_specifier_list | '*'
;
selection_statement : SWITCH '(' expr ')' statement | IF '(' expr ')' statement ELSE statement
;
declaration : declaration_specifiers init_declarator_list ';' | declaration_specifiers ';'
;
type_specifier : TYPE_NAME | enum_specifier | struct_or_union_specifier | VOID | VOLATILE | CONST | DOUBLE | FLOAT | UNSIGNED | SIGNED | LONG | INT | SHORT | CHAR
;
enumerator_list : enumerator_list ',' enumerator | enumerator
;
expr : expr ',' assignment_expr | assignment_expr
;
cast_expr : '(' type_name ')' cast_expr | unary_expr
;
unary_operator : '!' | '~' | '-' | '+' | '*' | '&'
;
identifier_list : identifier_list ',' identifier | identifier
;
parameter_list : parameter_list ',' parameter_declaration | parameter_declaration
;
storage_class_specifier : REGISTER | AUTO | STATIC | EXTERN | TYPEDEF
;
declarator : pointer declarator2 | declarator2
;
type_name : type_specifier_list abstract_declarator | type_specifier_list
;
exclusive_or_expr : exclusive_or_expr '^' and_expr | and_expr
;
constant_expr : conditional_expr
;
statement : jump_statement | iteration_statement | selection_statement | expression_statement | compound_statement | labeled_statement
;
abstract_declarator : pointer abstract_declarator2 | abstract_declarator2 | pointer
;
statement_list : statement_list statement | statement
;
struct_declaration_list : struct_declaration_list struct_declaration | struct_declaration
;
parameter_type_list : ',' ELIPSIS | parameter_list
;
identifier : IDENTIFIER
;
function_body : declaration_list compound_statement | compound_statement
;
assignment_expr : unary_expr assignment_operator assignment_expr | conditional_expr
;
argument_expr_list : argument_expr_list ',' assignment_expr | assignment_expr
;
type_specifier_list : type_specifier_list type_specifier | type_specifier
;
parameter_declaration : type_name | type_specifier_list declarator
;
initializer : '{' initializer_list ',' '}' | '{' initializer_list '}' | assignment_expr
;
declarator2 : declarator2 '(' parameter_identifier_list ')' | declarator2 '(' parameter_type_list ')' | declarator2 '(' ')' | declarator2 '[' constant_expr ']' | declarator2 '[' ']' | '(' declarator ')' | identifier
;
