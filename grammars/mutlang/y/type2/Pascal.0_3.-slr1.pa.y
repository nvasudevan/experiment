%token PROGRAM
%token PACKED
%token PROCEDURE
%token FUNCTION
%token SFILE
%token SET
%token RECORD
%token ARRAY
%token TYPE
%token VAR
%token WITH
%token END
%token SBEGIN
%token FOR
%token DO
%token WHILE
%token UNTIL
%token REPEAT
%token OF
%token CASE
%token ELSE
%token THEN
%token IF
%token DOTDOT
%token NOT
%token BECOMES
%token IDENTIFIER
%token STRING
%token UNSIGNED_INT

%%

program :  PROGRAM newident external_files ';' block '.'
;

case_label :  constant
;

case_list_elem :  case_label_list ':' statement
| 
;

case_list :  case_list ';' case_list_elem
|  case_list_elem
;

assignment :  variable BECOMES expression
;

colon_things :  ':' expression
|  ':' expression ':' expression
;

paramtype :  PACKED ARRAY '[' index_spec ']' OF ident
|  ARRAY '[' index_specs ']' OF paramtype
|  ident
;

newident_list :  new_id_list
;

param_group :  newident_list ':' paramtype
;

direction :  variable
;

variable :  variable '^'
|  variable '[' expressions ']'
|  variable '.' ident
|  ident actual_params
;

label :  UNSIGNED_INT
;

variable_dcl :  newident_list ':' type
;

unsigned_lit :  unsigned_num
|  STRING
;

type_def :  newident '=' type
;

constant :  '-' ident
|  unsigned_num
|  STRING
|  '+' ident
|  '-' unsigned_num
|  '+' unsigned_num
|  ident
;

set :  '[' member_list ']'
;

new_id_list :  new_id_list ',' newident
|  newident
;

factor :  '(' expression ')'
|  variable
|  unsigned_lit
|  set
|  NOT factor
;

formal_p_sect :  proc_heading
|  func_heading
|  param_group
|  VAR param_group
;

proc_heading :  PROCEDURE newident formal_params
;

body :  IDENTIFIER
|  block
;

func_heading :  FUNCTION newident function_form
;

proc_or_func :  func_heading ';' body ';'
|  proc_heading ';' body ';'
;

mult_op :  '*'
;

rec_var_list :  record_var
|  rec_var_list ',' record_var
;

record_var :  variable
;

formal_p_sects :  formal_p_sect
|  formal_p_sects ';' formal_p_sect
;

formal_params :  '(' formal_p_sects ')'
| 
;

declaration :  var_dcl_part
|  type_dcl_part
|  proc_dcl_part
;

simple_type :  ident
|  constant DOTDOT constant
|  '(' newident_list ')'
;

term :  term mult_op factor
|  factor
;

actuals_list :  actuals_list ',' actual_param
|  actual_param
;

type_defs :  type_defs ';' type_def
|  type_def
;

type_dcl_part :  TYPE type_defs ';'
;

actual_params : 
|  '(' actuals_list ')'
;

struct_type :  SFILE OF type
|  RECORD field_list END
|  SET OF simple_type
|  ARRAY '[' index_t_list ']' OF type
;

type :  simple_type
|  PACKED struct_type
|  struct_type
;

expression :  simple_expr
|  simple_expr relational_op simple_expr
;

variant :  case_label_list ':' '(' field_list ')'
| 
;

expressions :  expressions ',' expression
|  expression
;

variants :  variants ';' variant
|  variant
;

statements :  statements ';' statement
|  statement
;

variable_dcls :  variable_dcls ';' variable_dcl
|  variable_dcl
;

compound_stmt :  SBEGIN statements END
;

var_dcl_part :  VAR variable_dcls ';'
;

record_section :  newident_list ':' type
| 
;

tag_field :  newident ':' ident
|  ident
;

fixed_part :  fixed_part ';' record_section
|  record_section
;

block :  opt_declarations statement_part
;

add_op :  '+'
|  '-'
;

index_t_list :  simple_type
|  index_t_list ',' simple_type
;

external_files :  '(' newident_list ')'
| 
;

newident :  IDENTIFIER
;

statement :  procedure_call
|  CASE expression OF case_list END
|  WHILE expression DO statement
|  compound_stmt
|  FOR ident BECOMES expression direction expression DO statement
|  WITH rec_var_list DO statement
|  label ':' statement
|  assignment
|  IF expression THEN statement ELSE statement
| 
|  REPEAT statements UNTIL expression
;

case_label_list :  case_label
|  case_label_list ',' case_label
;

relational_op :  '='
;

simple_expr :  term
|  '-' term
|  '+' term
|  simple_expr add_op term
;

variant_part :  CASE tag_field OF variants
;

field_list :  fixed_part ';' variant_part
|  fixed_part
|  variant_part
;

statement_part :  compound_stmt
;

member :  expression
|  expression DOTDOT expression
;

declarations :  declarations declaration
|  declaration
;

actual_param :  expression colon_things
|  expression
;

opt_declarations : 
|  declarations
;

index_specs :  index_spec
|  index_specs ';' index_spec
;

index_spec :  newident DOTDOT newident ':' ident
;

members :  member
|  members ',' member
;

member_list :  members
;

procedure_call :  ident actual_params
;

ident :  IDENTIFIER
;

function_form :  formal_params ':' ident
| 
;

unsigned_num :  UNSIGNED_INT
;

proc_dcl_part :  proc_or_func
;
