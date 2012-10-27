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

direction :  DOWNTO
;

newident_list :  new_id_list
;

param_group :  newident_list ':' paramtype
;

label :  UNSIGNED_INT
;

variable :  variable '^'
|  variable '[' expressions ']'
|  variable '.' ident
|  ident actual_params
;

type_def :  newident '=' type
;

variable_dcl :  newident_list ':' type
;

unsigned_lit :  unsigned_num
|  STRING
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

rec_var_list :  record_var
|  rec_var_list ',' record_var
;

proc_or_func :  func_heading ';' body ';'
|  proc_heading ';' body ';'
;

mult_op :  '*'
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

type_defs :  type_defs ';' type_def
|  type_def
;

type_dcl_part :  TYPE type_defs ';'
;

actuals_list :  actuals_list ',' actual_param
|  actual_param
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

variant : 
|  case_label_list ':' '(' field_list ')'
;

variants :  variant
|  variants ';' variant
;

expression :  simple_expr
|  simple_expr relational_op simple_expr
;

expressions :  expressions ',' expression
|  expression
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

tag_field :  newident ':' ident
|  ident
;

record_section :  newident_list ':' type
| 
;

fixed_part :  fixed_part ';' record_section
|  record_section
;

index_t_list :  simple_type
|  index_t_list ',' simple_type
;

block :  opt_declarations statement_part
;

add_op :  OR
;

external_files :  '(' newident_list ')'
| 
;

newident :  IDENTIFIER
;

statement :  procedure_call
|  CASE expression OF case_list END
|  WHILE expression DO statement
|  WITH rec_var_list DO statement
|  compound_stmt
|  label ':' statement
|  FOR ident BECOMES expression direction expression DO statement
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
|  simple_expr add_op term
|  '+' term
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

members : 
|  member
|  members ',' member
;

member_list :  members
| 
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
