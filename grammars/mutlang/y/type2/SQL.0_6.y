%token COMPARISON_OPERATOR
%token NAME
%token STRING
%token INTNUM
%token FLOATNUM
%token ADD
%token COLUMN
%token EQUAL
%token SELECT FROM WHERE
%token DELETE
%token INSERT INTO VALUES
%token UPDATE SET
%token AND
%token OR
%token NOT
%token ALTER TTABLE
%token CREATE
%token DROP
%token NULL_VALUE
%token VARCHAR
%token INT
%token INTEGER
%token DOUBLE
%token PRECISION
%token DATE
%token ORDER BY
%token IS

%%


y_sql : y_delete | y_update | y_select | y_insert | y_drop | y_create | y_alter
;
y_assignments : y_assignments ',' y_assignment | y_assignment
;
y_insert : INSERT INTO y_table '(' y_columns ')' y_values | INSERT INTO y_table y_values
;
y_expression : y_expression '-' y_product | y_expression '+' y_product | y_product
;
y_sub_condition2 : y_sub_condition2 AND y_boolean | y_boolean
;
y_column : NAME
;
y_columns : y_column_list | '*'
;
y_atom : '(' y_expression ')' | y_column | y_value
;
y_sub_condition : y_sub_condition OR y_sub_condition2 | y_sub_condition2
;
y_drop : DROP TTABLE y_table
;
y_condition : y_sub_condition
;
y_assignment : NAME EQUAL y_expression | NAME EQUAL NULL_VALUE
;
y_value_list : y_value_list ',' '-' FLOATNUM | y_value_list ',' FLOATNUM | y_value_list ',' '-' INTNUM | y_value_list ',' INTNUM | y_value_list ',' STRING | y_value_list ',' NULL_VALUE | '-' FLOATNUM | FLOATNUM | '-' INTNUM | INTNUM | STRING | NULL_VALUE
;
y_term : '-' y_term | y_atom
;
y_delete : DELETE FROM y_table WHERE y_condition | DELETE FROM y_table
;
y_alter : ALTER TTABLE y_table ADD y_columndef | ALTER TTABLE y_table ADD COLUMN y_columndef
;
y_update : UPDATE y_table SET y_assignments WHERE y_condition | UPDATE y_table SET y_assignments
;
y_comparison : y_expression NOT NULL_VALUE | y_expression IS NULL_VALUE | y_expression COMPARISON_OPERATOR y_expression | y_expression EQUAL y_expression
;
y_value : FLOATNUM | INTNUM | STRING
;
y_columndefs : y_columndefs ',' y_columndef | y_columndef
;
y_columndef : y_order DATE | NAME DOUBLE PRECISION | NAME DOUBLE | NAME INTEGER | NAME INT | NAME VARCHAR '(' INTNUM ')'
;
y_product : y_product '/' y_term | y_product '*' y_term | y_term
;
y_table : NAME
;
y_order : NAME
;
y_values : VALUES '(' y_value_list ')'
;
y_create : CREATE TTABLE y_table '(' y_columndefs ')'
;
y_select : SELECT y_columns FROM y_table WHERE y_condition ORDER BY y_order | SELECT y_columns FROM y_table ORDER BY y_order | SELECT y_columns FROM y_table WHERE y_condition | SELECT y_columns FROM y_table
;
y_boolean : NOT y_boolean | '(' y_sub_condition ')' | y_comparison
;
y_column_list : y_column_list ',' NAME | NAME
;
