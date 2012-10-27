%token DOUBLE
%token COLUMN
%token CREATE
%token ADD
%token TTABLE
%token ALTER
%token NAME

%%

y_sql :  y_alter
|  y_create
;

y_columndef :  NAME DOUBLE
|  NAME DOUBLE
;

y_alter :  ALTER TTABLE y_table ADD y_columndef
|  ALTER TTABLE y_table ADD COLUMN y_columndef
;

y_create :  CREATE TTABLE y_table '(' y_columndefs ')'
;

y_columndefs :  y_columndef
|  y_columndefs ',' y_columndef
;

y_table :  NAME
;
