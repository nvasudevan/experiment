%token PROGRAM

%%

program :  PROGRAM newident external_files ';' block '.'
;

declarations :  declarations declaration
|  declaration
;

opt_declarations : 
|  declarations
;

block :  opt_declarations statement_part
;

statement_part :  SBEGIN END
;

external_files : 
;

newident :  IDENTIFIER
;

declaration :  proc_dcl_part
;

proc_dcl_part : 
;
