%token UNSIGNED_INT UNSIGNED_REAL STRING IDENTIFIER
%token NE LE GE BECOMES DIV MOD NIL IN OR AND NOT DOTDOT
%token IF THEN ELSE CASE OF REPEAT UNTIL WHILE DO FOR TO DOWNTO
%token SBEGIN END WITH GOTO CONST VAR TYPE ARRAY RECORD SET SFILE FUNCTION
%token PROCEDURE LABEL PACKED PROGRAM

%%


program : PROGRAM newident external_files ';' block '.'
;
fixed_part : record_section | fixed_part ';' record_section
;
compound_stmt : SBEGIN statements END
;
expressions : expression | expressions ',' expression
;
actual_params : '(' actuals_list ')' | 
;
formal_params : '(' formal_p_sects ')' | 
;
newident : IDENTIFIER
;
mult_op : AND | MOD | DIV | '/' | '*'
;
factor : NOT factor | set | '(' expression ')' | unsigned_lit | variable
;
param_group : newident_list ':' paramtype
;
assignment : variable BECOMES expression
;
case_list : case_list_elem | case_list ';' case_list_elem
;
unsigned_lit : NIL | STRING | unsigned_num
;
function_form : formal_params ':' ident | 
;
procedure_call : ident actual_params
;
paramtype : PACKED ARRAY '[' index_spec ']' OF ident | ARRAY '[' index_specs ']' OF paramtype | ident
;
opt_declarations : declarations | 
;
statement_part : compound_stmt
;
field_list : variant_part | fixed_part ';' variant_part | fixed_part
;
case_list_elem :  | case_label_list ':' statement
;
add_op : OR | '-' | '+'
;
var_dcl_part : VAR variable_dcls ';'
;
unsigned_num : UNSIGNED_REAL | UNSIGNED_INT
;
type : '^' IDENTIFIER | struct_type | PACKED struct_type | simple_type
;
declarations : declaration | declarations declaration
;
record_var : variable
;
proc_or_func : func_heading ';' body ';' | proc_heading ';' body ';'
;
formal_p_sects : formal_p_sect | formal_p_sects ';' formal_p_sect
;
newident_list : new_id_list
;
const_def : newident '=' constant
;
variable_dcls : variable_dcl | variable_dcls ';' variable_dcl
;
simple_type : ident | constant DOTDOT constant | '(' newident_list ')'
;
colon_things : ':' expression ':' expression | ':' expression
;
case_label : constant
;
constant : STRING | '-' ident | '+' ident | ident | '-' unsigned_num | '+' unsigned_num | unsigned_num
;
new_id_list : newident | new_id_list ',' newident
;
member_list : members | 
;
body : IDENTIFIER | block
;
actual_param : expression colon_things | expression
;
member : expression DOTDOT expression | expression
;
proc_heading : PROCEDURE newident formal_params
;
members : member | members ',' member
;
expression : simple_expr relational_op simple_expr | simple_expr
;
index_t_list : simple_type | index_t_list ',' simple_type
;
tag_field : ident | newident ':' ident
;
label_dcl_part : LABEL labels ';'
;
variants : variant | variants ';' variant
;
block : opt_declarations statement_part
;
type_dcl_part : TYPE type_defs ';'
;
variable_dcl : newident_list ':' type
;
index_spec : newident DOTDOT newident ':' ident
;
func_heading : FUNCTION newident function_form
;
variant :  | case_label_list ':' '(' field_list ')'
;
rec_var_list : record_var | rec_var_list ',' record_var
;
external_files : '(' newident_list ')' | 
;
formal_p_sect : func_heading | proc_heading | VAR param_group | param_group
;
const_dcl_part : CONST const_defs ';'
;
type_def : newident '=' variable_dcls
;
labels : label | labels ',' label
;
direction : DOWNTO | TO
;
variable : variable '^' | variable '.' ident | variable '[' expressions ']' | ident actual_params
;
declaration : proc_dcl_part | var_dcl_part | type_dcl_part | const_dcl_part | label_dcl_part
;
relational_op : IN | NE | GE | LE | '>' | '<' | '='
;
case_label_list : case_label | case_label_list ',' case_label
;
actuals_list : actual_param | actuals_list ',' actual_param
;
record_section :  | newident_list ':' type
;
label : UNSIGNED_INT
;
type_defs : type_def | type_defs ';' type_def
;
ident : IDENTIFIER
;
statement : WITH rec_var_list DO statement | FOR ident BECOMES expression direction expression DO statement | REPEAT statements UNTIL expression | WHILE expression DO statement | CASE expression OF case_list END | IF expression THEN statement ELSE statement | GOTO label | procedure_call | assignment | compound_stmt | label ':' statement | 
;
proc_dcl_part : proc_or_func
;
variant_part : CASE tag_field OF variants
;
term : term mult_op factor | factor
;
index_specs : index_spec | index_specs ';' index_spec
;
const_defs : const_def | const_defs ';' const_def
;
struct_type : SFILE OF type | SET OF simple_type | RECORD field_list END | ARRAY '[' index_t_list ']' OF type
;
statements : statement | statements ';' statement
;
simple_expr : simple_expr add_op term | '-' term | '+' term | term
;
set : '[' member_list ']'
;
