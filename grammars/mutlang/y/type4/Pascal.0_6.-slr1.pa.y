%token PROGRAM

%%

program :  PROGRAM newident external_files ';' block '.'
;

opt_declarations : 
| 
;

block :  opt_declarations statement_part
;

external_files : 
;

statement_part :  SBEGIN END
;

newident :  IDENTIFIER
;
