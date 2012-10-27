%token RETURN
%token FOR
%token DO
%token WHILE
%token SWITCH
%token ELSE
%token IF
%token DEFAULT
%token CASE
%token ELIPSIS
%token ENUM
%token OR_OP
%token AND_OP
%token NE_OP
%token EQ_OP
%token GE_OP
%token LE_OP
%token RIGHT_OP
%token LEFT_OP
%token DEC_OP
%token INC_OP
%token PTR_OP
%token SIZEOF

%%

file :  file external_definition
|  external_definition
;

initializer_list :  initializer_list ',' initializer
|  initializer
;

external_definition :  function_definition
|  declaration
;

exclusive_or_expr :  and_expr
|  exclusive_or_expr '^' and_expr
;

assignment_expr :  unary_expr assignment_operator assignment_expr
|  conditional_expr
;

constant_expr :  conditional_expr
;

declarator :  declarator2
|  pointer declarator2
;

struct_declarator :  ':' constant_expr
|  declarator ':' constant_expr
|  declarator
;

logical_and_expr :  inclusive_or_expr
|  logical_and_expr AND_OP inclusive_or_expr
;

logical_or_expr :  logical_or_expr OR_OP logical_and_expr
|  logical_and_expr
;

statement :  iteration_statement
|  expression_statement
|  jump_statement
|  compound_statement
|  labeled_statement
|  selection_statement
;

iteration_statement :  FOR '(' expr ';' expr ';' ')' statement
|  FOR '(' expr ';' ';' expr ')' statement
|  DO statement WHILE '(' expr ')' ';'
|  FOR '(' ';' ';' ')' statement
|  FOR '(' ';' expr ';' ')' statement
|  FOR '(' ';' expr ';' expr ')' statement
|  FOR '(' ';' ';' expr ')' statement
|  FOR '(' expr ';' ';' ')' statement
|  FOR '(' expr ';' expr ';' expr ')' statement
|  WHILE '(' expr ')' statement
;

parameter_type_list :  parameter_list
|  parameter_list ',' ELIPSIS
;

abstract_declarator2 :  '(' abstract_declarator ')'
|  abstract_declarator2 '[' constant_expr ']'
|  '[' constant_expr ']'
|  abstract_declarator2 '(' parameter_type_list ')'
|  '(' parameter_type_list ')'
|  abstract_declarator2 '(' ')'
|  abstract_declarator2 '[' ']'
;

argument_expr_list :  argument_expr_list ',' assignment_expr
|  assignment_expr
;

struct_declaration_list :  struct_declaration
|  struct_declaration_list struct_declaration
;

enumerator :  identifier
|  identifier '=' constant_expr
;

assignment_operator :  '='
;

declarator2 :  declarator2 '[' constant_expr ']'
|  declarator2 '(' parameter_type_list ')'
|  declarator2 '(' parameter_identifier_list ')'
|  '(' declarator ')'
|  declarator2 '(' ')'
|  declarator2 '[' ']'
|  identifier
;

postfix_expr :  postfix_expr '.' identifier
|  postfix_expr PTR_OP identifier
|  postfix_expr '[' expr ']'
|  postfix_expr '(' argument_expr_list ')'
|  postfix_expr '(' ')'
|  postfix_expr DEC_OP
|  primary_expr
|  postfix_expr INC_OP
;

struct_or_union_specifier :  struct_or_union identifier '{' struct_declaration_list '}'
|  struct_or_union '>' '{' struct_declaration_list '}'
;

function_body :  declaration_list compound_statement
|  compound_statement
;

function_definition :  declarator function_body
|  declaration_specifiers declarator function_body
;

struct_or_union :  UNION
;

cast_expr :  '(' type_name ')' cast_expr
|  unary_expr
;

conditional_expr :  logical_or_expr '?' logical_or_expr ':' conditional_expr
|  logical_or_expr
;

storage_class_specifier :  REGISTER
;

unary_operator :  '&'
|  '+'
|  '*'
|  '-'
;

enumerator_list :  enumerator
|  enumerator_list ',' enumerator
;

struct_declarator_list :  struct_declarator
|  struct_declarator_list ',' struct_declarator
;

equality_expr :  relational_expr
|  equality_expr EQ_OP relational_expr
|  equality_expr NE_OP relational_expr
;

type_specifier_list :  type_specifier
|  type_specifier_list type_specifier
;

enum_specifier :  ENUM identifier '{' enumerator_list '}'
|  ENUM '{' enumerator_list '}'
;

struct_declaration :  type_specifier_list struct_declarator_list ';'
;

and_expr :  equality_expr
|  and_expr '&' equality_expr
;

type_name :  type_specifier_list abstract_declarator
|  type_specifier_list
;

type_specifier :  struct_or_union_specifier
|  enum_specifier
;

unary_expr :  postfix_expr
|  SIZEOF unary_expr
|  unary_operator cast_expr
|  SIZEOF '(' type_name ')'
|  INC_OP unary_expr
|  DEC_OP unary_expr
;

declaration_specifiers :  type_specifier declaration_specifiers
|  storage_class_specifier declaration_specifiers
|  type_specifier
;

parameter_declaration :  type_specifier_list declarator
|  type_name
;

identifier :  IDENTIFIER
;

parameter_list :  parameter_declaration
|  parameter_list ',' parameter_declaration
;

init_declarator :  declarator '=' initializer
|  declarator
;

declaration :  declaration_specifiers init_declarator_list ';'
|  declaration_specifiers ';'
;

additive_expr :  additive_expr '+' multiplicative_expr
|  multiplicative_expr
|  additive_expr '-' multiplicative_expr
;

selection_statement :  IF '(' expr ')' statement ELSE statement
|  SWITCH '(' expr ')' statement
;

relational_expr :  relational_expr '>' shift_expr
|  relational_expr '<' shift_expr
|  relational_expr LE_OP shift_expr
|  relational_expr GE_OP shift_expr
|  shift_expr
;

shift_expr :  shift_expr LEFT_OP additive_expr
|  shift_expr RIGHT_OP additive_expr
|  additive_expr
;

expression_statement :  ';'
|  expr ';'
;

expr :  assignment_expr
|  expr ',' assignment_expr
;

jump_statement :  RETURN expr ';'
;

pointer :  '*' type_specifier_list pointer
|  '*' type_specifier_list
|  '*' pointer
|  '*'
;

statement_list :  statement
|  statement_list statement
;

declaration_list :  declaration
|  declaration_list declaration
;

primary_expr :  '(' expr ')'
|  identifier
;

compound_statement :  '{' declaration_list statement_list '}'
|  '{' declaration_list '}'
|  '{' statement_list '}'
;

multiplicative_expr :  multiplicative_expr '%' cast_expr
|  cast_expr
|  multiplicative_expr '/' cast_expr
|  multiplicative_expr '*' cast_expr
;

labeled_statement :  CASE constant_expr ':' statement
|  identifier ':' statement
|  DEFAULT ':' statement
;

identifier_list :  identifier
|  identifier_list ',' identifier
;

parameter_identifier_list :  identifier_list ',' ELIPSIS
|  identifier_list
;

init_declarator_list :  init_declarator_list ',' init_declarator
|  init_declarator
;

abstract_declarator :  abstract_declarator2
|  pointer
|  pointer abstract_declarator2
;

initializer :  '{' initializer_list ',' '}'
|  assignment_expr
|  '{' initializer_list '}'
;

inclusive_or_expr :  exclusive_or_expr
|  inclusive_or_expr '|' exclusive_or_expr
;
