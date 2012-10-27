%token PROGRAM
%token PROCEDURE
%token FUNCTION
%token IDENTIFIER
%token VAR
%token CONST

%%

program :  PROGRAM newident external_files ';' block '.'
;

variable_dcls :  variable_dcls ';' variable_dcl
|  variable_dcl
;

declarations :  declarations declaration
|  declaration
;

proc_heading :  PROCEDURE newident formal_params
;

opt_declarations : 
|  declarations
;

var_dcl_part :  VAR variable_dcls ';'
;

body :  IDENTIFIER
|  block
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

formal_p_sects :  formal_p_sect
|  formal_p_sects ';' formal_p_sect
;

newident :  IDENTIFIER
;

formal_params :  '(' formal_p_sects ')'
| 
;

declaration :  var_dcl_part
|  type_dcl_part
|  const_dcl_part
|  proc_dcl_part
;

simple_type :  ident
;

variable_dcl :  newident_list ':' type
;

type_def :  newident '=' type
;

constant :  ident
;

ident :  IDENTIFIER
;

function_form :  formal_params ':' ident
| 
;

type_defs :  type_defs ';' type_def
|  type_def
;

const_def :  newident '=' constant
;

type_dcl_part :  type_defs type_defs ';'
;

const_defs :  IDENTIFIER '=' STRING
|  const_defs ';' const_def
;

const_dcl_part :  CONST const_defs ';'
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

proc_dcl_part :  proc_or_func
;
