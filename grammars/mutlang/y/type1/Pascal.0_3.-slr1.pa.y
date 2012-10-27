%token OF
%token CASE
%token PROGRAM
%token PACKED
%token PROCEDURE
%token FUNCTION
%token SFILE
%token RECORD
%token ARRAY
%token TYPE
%token VAR
%token END

%%

program :  PROGRAM newident external_files ';' block '.'
;

variable_dcls :  variable_dcls ';' variable_dcl
|  variable_dcl
;

var_dcl_part :  VAR variable_dcls ';'
;

tag_field :  IDENTIFIER
;

record_section :  newident_list ':' type
| 
;

fixed_part :  fixed_part ';' record_section
|  record_section
;

paramtype :  ident
;

index_t_list :  IDENTIFIER
;

newident_list :  IDENTIFIER
;

block :  opt_declarations statement_part
;

param_group :  newident_list ':' paramtype
;

external_files : 
;

case_label_list :  STRING
;

newident :  IDENTIFIER
;

variable_dcl :  newident_list ':' type
;

type_def :  newident '=' type
;

variant_part :  CASE tag_field OF variants
;

field_list : 
|  fixed_part ';' variant_part
|  fixed_part
|  variant_part
;

formal_p_sect :  VAR param_group
|  proc_heading
|  func_heading
|  param_group
;

statement_part :  SBEGIN END
;

proc_heading :  PROCEDURE newident formal_params
;

declarations :  declarations declaration
|  declaration
;

opt_declarations :  declarations
;

body :  block
;

func_heading :  FUNCTION newident function_form
;

proc_or_func :  func_heading ';' body ';'
|  proc_heading ';' body ';'
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

simple_type :  ident
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

function_form :  formal_params ':' ident
| 
;

type :  simple_type
|  PACKED struct_type
|  struct_type
;

variant :  case_label_list ':' '(' field_list ')'
;

variants :  variant
|  variants ';' variant
;

proc_dcl_part :  proc_or_func
;
