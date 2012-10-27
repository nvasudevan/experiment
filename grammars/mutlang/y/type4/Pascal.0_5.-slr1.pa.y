%token PROGRAM
%token PROCEDURE
%token FUNCTION

%%

program :  PROGRAM newident external_files ';' block '.'
;

declarations :  declarations declaration
|  declaration
;

proc_heading :  PROCEDURE newident formal_params
;

opt_declarations :  declarations
;

body : 
;

func_heading :  FUNCTION newident function_form
;

proc_or_func :  func_heading ';' body ';'
|  proc_heading ';' body ';'
;

block :  opt_declarations statement_part
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

declaration :  proc_dcl_part
;

ident :  IDENTIFIER
;

function_form :  formal_params ':' ident
| 
;

statement_part :  SBEGIN END
;

formal_p_sect :  proc_heading
|  func_heading
;

proc_dcl_part :  proc_or_func
;
