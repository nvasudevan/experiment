%token PROGRAM
%token PACKED
%token PROCEDURE
%token FUNCTION
%token SFILE
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
%token BECOMES
%token IDENTIFIER
%token STRING
%token UNSIGNED_INT

%%

program :  PROGRAM newident external_files ';' block '.'
;

case_label :  constant
;

variable_dcls :  variable_dcls ';' variable_dcl
|  variable_dcl
;

statements :  statements ';' statement
|  statement
;

var_dcl_part :  VAR variable_dcls ';'
;

case_list_elem :  case_label_list ':' statement
| 
| 
;

compound_stmt :  SBEGIN statements END
;

case_list :  case_list ';' case_list_elem
|  case_list_elem
;

colon_things :  ':' expression
|  ':' expression ':' expression
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

paramtype :  ident
;

direction :  DOWNTO
;

index_t_list :  IDENTIFIER
;

newident_list :  new_id_list
;

param_group :  newident_list ':' paramtype
;

block :  opt_declarations statement_part
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
|  IF expression THEN statement ELSE statement
| 
|  REPEAT statements UNTIL expression
;

label :  UNSIGNED_INT
;

variable :  ident actual_params
;

variable_dcl :  newident_list ':' type
;

case_label_list :  case_label_list ',' case_label
|  case_label
;

relational_op :  '='
;

simple_expr :  term
|  '-' term
|  '+' term
;

type_def :  newident '=' type
;

unsigned_lit :  unsigned_num
|  STRING
;

constant :  ident
|  unsigned_num
|  STRING
|  '-' ident
|  '+' ident
|  '-' unsigned_num
|  '+' unsigned_num
;

new_id_list :  new_id_list ',' newident
|  newident
;

variant_part :  CASE tag_field OF variants
;

field_list :  fixed_part ';' variant_part
|  fixed_part
|  variant_part
;

factor :  '(' expression ')'
|  variable
|  unsigned_lit
;

formal_p_sect :  VAR param_group
|  proc_heading
|  func_heading
|  param_group
;

statement_part :  compound_stmt
;

proc_heading :  PROCEDURE newident formal_params
;

actual_param :  expression colon_things
|  expression
;

declarations :  declarations declaration
|  declaration
;

opt_declarations : 
|  declarations
;

body :  IDENTIFIER
|  block
;

func_heading :  FUNCTION newident function_form
;

proc_or_func :  func_heading ';' body ';'
|  proc_heading ';' body ';'
;

rec_var_list :  IDENTIFIER
;

declaration :  var_dcl_part
|  type_dcl_part
|  proc_dcl_part
;

formal_p_sects :  formal_p_sect
|  formal_p_sects ';' formal_p_sect
;

formal_params :  '(' formal_p_sects ')'
| 
;

procedure_call :  ident actual_params
;

simple_type :  ident
|  '(' newident_list ')'
;

term :  factor
;

type_defs :  type_defs ';' type_def
|  type_def
;

type_dcl_part :  TYPE type_defs ';'
;

struct_type :  SFILE OF type
|  RECORD field_list END
|  ARRAY '[' index_t_list ']' OF type
;

ident :  IDENTIFIER
;

actuals_list :  actuals_list ',' actual_param
|  actual_param
;

function_form :  formal_params ':' ident
| 
;

actual_params : 
|  '(' actuals_list ')'
;

type :  simple_type
|  PACKED struct_type
|  struct_type
;

unsigned_num :  UNSIGNED_INT
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

proc_dcl_part :  proc_or_func
;
