%token PROGRAM
%token PROCEDURE
%token FUNCTION
%token VAR

%%

program :  PROGRAM newident external_files ';' block '.'
;

proc_heading :  PROCEDURE newident formal_params
;

variable_dcls :  variable_dcls ';' variable_dcl
|  variable_dcl
;

declarations :  declarations declaration
|  variants declaration
;

opt_declarations :  declarations
;

var_dcl_part :  VAR variable_dcls ';'
;

body :  block
;

func_heading :  FUNCTION newident function_form
;

proc_or_func :  func_heading ';' body ';'
|  proc_heading ';' body ';'
;

paramtype :  ident
;

newident_list :  IDENTIFIER
;

block :  opt_declarations statement_part
;

param_group :  newident_list ':' paramtype
;

external_files : 
;

formal_p_sects :  formal_p_sects ';' formal_p_sect
|  formal_p_sect
;

declaration :  proc_dcl_part
|  var_dcl_part
;

variants :  variant
;

newident :  IDENTIFIER
;

formal_params :  '(' formal_p_sects ')'
| 
;

variable_dcl :  newident_list ':' type
;

simple_type :  ident
;

ident :  IDENTIFIER
;

function_form :  formal_params ':' ident
| 
;

type :  simple_type
;

statement_part :  SBEGIN END
;

formal_p_sect :  proc_heading
|  func_heading
|  param_group
|  VAR param_group
;

variant : 
;

proc_dcl_part :  proc_or_func
;
