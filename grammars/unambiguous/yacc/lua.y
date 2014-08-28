%token SC_TK RETURN BREAK NIL WHILE DO END REPEAT UNTIL IF THEN ELSEIF ELSE FOR FUNCTION LOCAL IN VAR_LENGTH_PARAMS STRING_CONCAT LE GE EQ TILDE_EQ AND OR GLOBAL NOT LITERAL NAME NUMBER OB_TK CB_TK

%%

block: stmt opt_sc_tk opt_finish
;

opt_finish: |  finish opt_sc_tk
;

opt_sc_tk : | SC_TK
;

stmt:  multi_vars '=' exprs
	 |  IF expr THEN block multi_elseif else_stmt_opt END
	 |  FUNCTION func_name '(' opt_params ')' block END
	 |  LOCAL FUNCTION func_name '(' opt_params ')' block END
	 |  LOCAL multi_names multi_values_opt
	 |  call
	 |  DO block END
	 |  WHILE expr DO block END
     |  REPEAT block UNTIL expr
	 |  FOR name '=' expr ',' exprs DO block END
	 |  FOR name ',' name IN expr DO block END 
;

multi_vars: var | multi_vars ',' var
;

elseif: ELSEIF expr THEN block 
;

multi_elseif: | multi_elseif elseif
;

else_stmt_opt: |  ELSE block
;

multi_names : name | multi_names ',' name
;

multi_values_opt: | '=' exprs
;

finish: RETURN exprs |  BREAK name
;

func_name:  name '.' NAME func_opt_keys 
;

func_opt_keys: ':' NAME
;

params :  VAR_LENGTH_PARAMS 
      | namelist 
      | namelist ',' VAR_LENGTH_PARAMS
;

namelist: name | namelist ',' name
;
 
opt_params: | params
;

var: name
   | primary index
   | var index
   | call index
;

index  :  '[' expr ']' | '.' key
;

call   :  primary opt_colon_key args
         |  var opt_colon_key args
         |  call opt_colon_key args
;

opt_colon_key: | ':' key
;

args   :  '(' opt_exprs ')' | table_cons | literal
;

exprs: expr | exprs ',' expr 
;

opt_exprs: | exprs
;

table_cons: OB_TK CB_TK  | OB_TK fields CB_TK 
;

fields: expr_fields expr_fields_tail
         |  mapping_fields 
         |  mapping_fields SC_TK 
         |  mapping_fields SC_TK expr_fields
         |  SC_TK 
         |  SC_TK expr_or_mapping_fields
;

expr_or_mapping_fields: expr_fields | mapping_fields
;

expr_fields:  exprs opt_comma
;

expr_fields_tail: |  SC_TK opt_mapping_fields
;

mapping_fields:  mapping_field ',' mapping_field opt_comma 
;

opt_mapping_fields: | mapping_fields
;

opt_comma: | ','
;

mapping_field: '[' expr ']' '=' expr | NAME '=' expr
;

binop: '+' | '-' | '/' | '^' | STRING_CONCAT | AND | OR
         |  '<' | LE | '>' | GE | EQ | TILDE_EQ
;

expr:  primary | var | call 
      | unop 
      | expr binop expr
;

primary:  NIL | number | literal | '%' name 
     |  FUNCTION '(' opt_params ')' block END | '(' expr ')' 
	 | table_cons
;

unop: '-' | NOT | '#'
;

key: NAME | AND | BREAK | DO | END | ELSE | ELSEIF
         |  FOR | FUNCTION | GLOBAL | IF | IN | LOCAL | NIL
         |  NOT | OR | RETURN | REPEAT | THEN | UNTIL | WHILE
;

literal: LITERAL
;

name: NAME
;

number: NUMBER
;
