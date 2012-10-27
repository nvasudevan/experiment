%token PROGRAM
%token PROCEDURE
%token FUNCTION
%token VAR

%%

program :  PROGRAM newident external_files ';' block '.'
;

variable_dcls :  variable_dcls ';' variable_dcl
|  variable_dcl
;

proc_heading :  PROCEDURE newident formal_params
;

var_dcl_part :  VAR variable_dcls ';'
;

declarations :  declarations declaration
|  declaration
;

body :  block
;

opt_declarations :  declarations
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

declaration :  var_dcl_part
|  proc_dcl_part
;

external_files : 
;

formal_p_sects :  formal_p_sect
|  formal_p_sects ';' formal_p_sect
;

newident :  IDENTIFIER
;

formal_params :  '(' formal_p_sects ')'
| 
;

simple_type :  ident
;

variable_dcl :  newident_list ':' type
;

ident :  IDENTIFIER
;

function_form :  formal_params ':' ident
| 
;

type :  simple_type
;

formal_p_sect :  VAR param_group
|  proc_heading
|  func_heading
|  param_group
;

statement_part : 
;

proc_dcl_part :  proc_or_func
;
