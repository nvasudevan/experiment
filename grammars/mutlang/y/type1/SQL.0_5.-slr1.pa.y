%token NULL_VALUE
%token NOT
%token OR
%token AND
%token SET
%token UPDATE
%token DELETE
%token WHERE
%token FROM
%token SELECT
%token EQUAL
%token IS
%token NAME
%token BY
%token COMPARISON_OPERATOR
%token ORDER

%%

y_sql :  y_select
|  y_update
|  y_delete
;

y_assignment :  NAME EQUAL y_expression
;

y_assignments :  y_assignment
|  y_assignments ',' y_assignment
;

y_boolean :  y_comparison
|  NOT y_boolean
|  '(' y_sub_condition ')'
;

y_sub_condition2 :  y_sub_condition2 AND y_boolean
|  y_boolean
;

y_term :  '-' y_term
|  y_atom
;

y_condition :  y_sub_condition
;

y_order :  NAME
;

y_product :  y_product '/' y_term
|  y_term
|  y_product '*' y_term
;

y_select :  SELECT y_columns FROM y_table WHERE y_condition ORDER BY y_order
|  SELECT y_columns FROM y_table WHERE y_condition
;

y_sub_condition :  y_sub_condition2
|  y_sub_condition OR y_sub_condition2
;

y_expression :  y_expression '+' y_product
|  y_product
|  y_expression '-' y_product
;

y_value : 
;

y_update :  UPDATE y_table SET y_assignments WHERE y_condition
|  UPDATE y_table SET y_assignments
;

y_delete :  DELETE FROM y_table WHERE y_condition
;

y_comparison :  y_expression COMPARISON_OPERATOR y_expression
|  y_expression IS NULL_VALUE
|  y_expression NOT NULL_VALUE
|  y_expression EQUAL y_expression
;

y_atom :  '(' y_expression ')'
|  y_value
;

y_columns :  '*'
;

y_table :  NAME
;
