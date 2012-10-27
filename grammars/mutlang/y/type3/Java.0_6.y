%token   PLUS_TK         MINUS_TK        MULT_TK         DIV_TK    REM_TK
%token   LS_TK           SRS_TK          ZRS_TK
%token   AND_TK          XOR_TK          OR_TK
%token   BOOL_AND_TK BOOL_OR_TK
%token   EQ_TK NEQ_TK GT_TK GTE_TK LT_TK LTE_TK
%token   MODIFIER_TK
%token   DECR_TK INCR_TK
%token   DEFAULT_TK      IF_TK              THROW_TK
%token   BOOLEAN_TK      DO_TK              IMPLEMENTS_TK
%token   THROWS_TK       BREAK_TK           IMPORT_TK
%token   ELSE_TK         INSTANCEOF_TK      RETURN_TK
%token   VOID_TK         CATCH_TK           INTERFACE_TK
%token   CASE_TK         EXTENDS_TK         FINALLY_TK
%token   SUPER_TK        WHILE_TK           CLASS_TK
%token   SWITCH_TK       TRY_TK
%token   FOR_TK          NEW_TK             CONTINUE_TK
%token   PACKAGE_TK         THIS_TK
%token   ASSERT_TK
%token   INTEGRAL_TK
%token   FP_TK
%token   ID_TK
%token   REL_QM_TK         REL_CL_TK NOT_TK  NEG_TK
%token   ASSIGN_ANY_TK   ASSIGN_TK
%token   OP_TK  CP_TK  OCB_TK  CCB_TK  OSB_TK  CSB_TK  SC_TK  C_TK DOT_TK
%token   STRING_LIT_TK   CHAR_LIT_TK        INT_LIT_TK        FP_LIT_TK
%token   BOOL_LIT_TK       NULL_TK

%%


goal : compilation_unit
;
import_declaration : type_import_on_demand_declaration | single_type_import_declaration
;
argument_list : argument_list C_TK expression | expression
;
pre_decrement_expression : DECR_TK unary_expression
;
catch_clause_parameter : CATCH_TK OP_TK formal_parameter CP_TK
;
conditional_and_expression : conditional_and_expression BOOL_AND_TK inclusive_or_expression | inclusive_or_expression
;
anonymous_class_creation : NEW_TK class_type OP_TK CP_TK class_body | NEW_TK class_type OP_TK argument_list CP_TK class_body
;
continue_statement : CONTINUE_TK identifier SC_TK | CONTINUE_TK SC_TK
;
block_statements : block_statements block_statement | block_statement
;
assignment_operator : ASSIGN_TK | ASSIGN_ANY_TK
;
variable_declarator : variable_declarator_id ASSIGN_TK variable_initializer | variable_declarator_id
;
assignment : left_hand_side assignment_operator assignment_expression
;
labeled_statement_nsi : label_decl statement_nsi
;
constructor_body : block_begin explicit_constructor_invocation block_statements constructor_block_end | block_begin block_statements constructor_block_end | block_begin explicit_constructor_invocation constructor_block_end | block_begin constructor_block_end
;
for_init : local_variable_declaration | statement_expression_list | 
;
formal_parameter_list : formal_parameter_list C_TK formal_parameter | formal_parameter
;
labeled_statement : label_decl statement
;
for_header : FOR_TK OP_TK
;
switch_block : OCB_TK switch_block_statement_groups switch_labels CCB_TK | OCB_TK switch_block_statement_groups CCB_TK | OCB_TK switch_labels CCB_TK | OCB_TK CCB_TK
;
extends_interfaces : extends_interfaces C_TK interface_type | EXTENDS_TK interface_type
;
local_variable_declaration_statement : local_variable_declaration SC_TK
;
do_statement : do_statement_begin statement WHILE_TK OP_TK expression CP_TK SC_TK
;
interface_member_declarations : interface_member_declarations interface_member_declaration | interface_member_declaration
;
assert_statement : ASSERT_TK expression SC_TK | ASSERT_TK expression REL_CL_TK expression SC_TK
;
constructor_declaration : constructor_header constructor_body
;
field_declaration : modifiers type variable_declarators SC_TK | type variable_declarators SC_TK
;
class_instance_creation_expression : something_dot_new identifier OP_TK argument_list CP_TK class_body | something_dot_new identifier OP_TK argument_list CP_TK | something_dot_new identifier OP_TK CP_TK class_body | something_dot_new identifier OP_TK CP_TK | anonymous_class_creation | NEW_TK class_type OP_TK CP_TK | NEW_TK class_type OP_TK argument_list CP_TK
;
variable_initializers : variable_initializers C_TK variable_initializer | variable_initializer
;
for_begin : for_header for_init
;
type_import_on_demand_declaration : IMPORT_TK name DOT_TK MULT_TK SC_TK
;
static_ : array_access modifiers
;
relational_expression : relational_expression INSTANCEOF_TK reference_type | relational_expression GTE_TK shift_expression | relational_expression LTE_TK shift_expression | relational_expression GT_TK shift_expression | relational_expression LT_TK shift_expression | shift_expression
;
literal : NULL_TK | STRING_LIT_TK | CHAR_LIT_TK | BOOL_LIT_TK | FP_LIT_TK | INT_LIT_TK
;
class_body_declarations : class_body_declarations class_body_declaration | class_body_declaration
;
reference_type : array_type | class_or_interface_type
;
method_invocation : SUPER_TK DOT_TK identifier OP_TK argument_list CP_TK | SUPER_TK DOT_TK identifier OP_TK CP_TK | primary DOT_TK identifier OP_TK argument_list CP_TK | primary DOT_TK identifier OP_TK CP_TK | name OP_TK argument_list CP_TK | name OP_TK CP_TK
;
method_header : modifiers VOID_TK method_declarator throws | modifiers type method_declarator throws | VOID_TK method_declarator throws | type method_declarator throws
;
identifier : ID_TK
;
catches : catches catch_clause | catch_clause
;
unary_expression : MINUS_TK trap_overflow_corner_case | trap_overflow_corner_case
;
post_increment_expression : postfix_expression INCR_TK
;
dim_exprs : dim_exprs dim_expr | dim_expr
;
postfix_expression : post_decrement_expression | post_increment_expression | name | primary
;
class_type : class_or_interface_type
;
this_or_super : SUPER_TK | THIS_TK
;
variable_initializer : array_initializer | expression
;
expression : assignment_expression
;
cast_expression : OP_TK name dims CP_TK unary_expression_not_plus_minus | OP_TK expression CP_TK unary_expression_not_plus_minus | OP_TK primitive_type CP_TK unary_expression | OP_TK primitive_type dims CP_TK unary_expression
;
constructor_declarator : simple_name OP_TK formal_parameter_list CP_TK | simple_name OP_TK CP_TK
;
import_declarations : import_declarations import_declaration | import_declaration
;
exclusive_or_expression : exclusive_or_expression XOR_TK and_expression | and_expression
;
primitive_type : BOOLEAN_TK | FP_TK | INTEGRAL_TK
;
static_initializer : static_ block
;
block : block_begin block_statements block_end | block_begin block_end
;
name : qualified_name | simple_name
;
local_variable_declaration : final type variable_declarators | type variable_declarators
;
expression_statement : statement_expression SC_TK
;
pre_increment_expression : INCR_TK unary_expression
;
switch_expression : SWITCH_TK OP_TK expression CP_TK
;
finally : FINALLY_TK block
;
switch_block_statement_groups : switch_block_statement_groups switch_block_statement_group | switch_block_statement_group
;
compilation_unit : package_declaration import_declarations type_declarations | import_declarations type_declarations | package_declaration type_declarations | package_declaration import_declarations | type_declarations | import_declarations | package_declaration | 
;
interface_type : class_or_interface_type
;
for_statement_nsi : for_begin SC_TK SC_TK for_update CP_TK statement_nsi | for_begin SC_TK expression SC_TK for_update CP_TK statement_nsi
;
modifiers : modifiers MODIFIER_TK | MODIFIER_TK
;
class_member_declaration : empty_statement | interface_declaration | class_declaration | method_declaration | field_declaration
;
class_type_list : class_type_list C_TK class_type | class_type
;
super : EXTENDS_TK class_type | 
;
conditional_or_expression : conditional_or_expression BOOL_OR_TK conditional_and_expression | conditional_and_expression
;
for_statement : for_begin SC_TK SC_TK for_update CP_TK statement | for_begin SC_TK expression SC_TK for_update CP_TK statement
;
block_begin : OCB_TK
;
final : modifiers
;
shift_expression : shift_expression ZRS_TK additive_expression | shift_expression SRS_TK additive_expression | shift_expression LS_TK additive_expression | additive_expression
;
interface_declaration : modifiers INTERFACE_TK identifier extends_interfaces interface_body | INTERFACE_TK identifier extends_interfaces interface_body | modifiers INTERFACE_TK identifier interface_body | INTERFACE_TK identifier interface_body
;
statement_nsi : for_statement_nsi | while_statement_nsi | if_then_else_statement_nsi | labeled_statement_nsi | statement_without_trailing_substatement
;
catch_clause : catch_clause_parameter block
;
constructor_header : modifiers constructor_declarator throws | constructor_declarator throws
;
statement : for_statement | while_statement | if_then_else_statement | if_then_statement | labeled_statement | statement_without_trailing_substatement
;
statement_without_trailing_substatement : assert_statement | try_statement | throw_statement | synchronized_statement | return_statement | continue_statement | break_statement | do_statement | switch_statement | expression_statement | empty_statement | block
;
switch_labels : switch_labels switch_label | switch_label
;
statement_expression : class_instance_creation_expression | method_invocation | post_decrement_expression | post_increment_expression | pre_decrement_expression | pre_increment_expression | assignment
;
variable_declarator_id : variable_declarator_id OSB_TK CSB_TK | identifier
;
while_expression : WHILE_TK OP_TK expression CP_TK
;
inclusive_or_expression : inclusive_or_expression OR_TK exclusive_or_expression | exclusive_or_expression
;
array_type : name dims | primitive_type dims
;
explicit_constructor_invocation : name DOT_TK SUPER_TK OP_TK CP_TK SC_TK | name DOT_TK SUPER_TK OP_TK argument_list CP_TK SC_TK | this_or_super OP_TK argument_list CP_TK SC_TK | this_or_super OP_TK CP_TK SC_TK
;
constant_declaration : field_declaration
;
interfaces : IMPLEMENTS_TK interface_type_list | 
;
formal_parameter : final type variable_declarator_id | type variable_declarator_id
;
abstract_method_declaration : method_header SC_TK
;
throw_statement : THROW_TK expression SC_TK
;
class_or_interface_type : name
;
method_declarator : method_declarator OSB_TK CSB_TK | identifier OP_TK formal_parameter_list CP_TK | identifier OP_TK CP_TK
;
qualified_name : name DOT_TK identifier
;
throws : THROWS_TK class_type_list | 
;
dim_expr : OSB_TK expression CSB_TK
;
assignment_expression : assignment | conditional_expression
;
field_access : SUPER_TK DOT_TK identifier | primary DOT_TK identifier
;
class_body_declaration : block | constructor_declaration | static_initializer | class_member_declaration
;
method_body : SC_TK | block
;
block_statement : class_declaration | statement | local_variable_declaration_statement
;
type : reference_type | primitive_type
;
class_declaration : CLASS_TK identifier super interfaces class_body | modifiers CLASS_TK identifier super interfaces class_body
;
switch_block_statement_group : switch_labels block_statements
;
if_then_statement : IF_TK OP_TK expression CP_TK statement
;
break_statement : BREAK_TK identifier SC_TK | BREAK_TK SC_TK
;
if_then_else_statement_nsi : IF_TK OP_TK expression CP_TK statement_nsi ELSE_TK statement_nsi
;
block_end : CCB_TK
;
if_then_else_statement : IF_TK OP_TK expression CP_TK statement_nsi ELSE_TK statement
;
switch_label : DEFAULT_TK REL_CL_TK | CASE_TK constant_expression REL_CL_TK
;
do_statement_begin : DO_TK
;
constructor_block_end : block_end
;
switch_statement : switch_expression switch_block
;
multiplicative_expression : multiplicative_expression REM_TK unary_expression | multiplicative_expression DIV_TK unary_expression | multiplicative_expression MULT_TK unary_expression | unary_expression
;
return_statement : RETURN_TK expression SC_TK | RETURN_TK SC_TK
;
variable_declarators : variable_declarators C_TK variable_declarator | variable_declarator
;
type_declarations : type_declarations type_declaration | type_declaration
;
method_declaration : method_header method_body
;
interface_member_declaration : interface_declaration | class_declaration | abstract_method_declaration | constant_declaration
;
primary_no_new_array : name DOT_TK THIS_TK | type_literals | array_access | method_invocation | field_access | class_instance_creation_expression | OP_TK expression CP_TK | THIS_TK | literal
;
label_decl : identifier REL_CL_TK
;
statement_expression_list : statement_expression_list C_TK statement_expression | statement_expression
;
synchronized : modifiers
;
constant_expression : expression
;
array_creation_expression : NEW_TK primitive_type dims array_initializer | NEW_TK class_or_interface_type dims array_initializer | NEW_TK class_or_interface_type dim_exprs dims | NEW_TK primitive_type dim_exprs dims | NEW_TK class_or_interface_type dim_exprs | NEW_TK primitive_type dim_exprs
;
single_type_import_declaration : IMPORT_TK name SC_TK
;
array_access : primary_no_new_array OSB_TK expression CSB_TK | name OSB_TK expression CSB_TK
;
class_body : OCB_TK class_body_declarations CCB_TK | OCB_TK CCB_TK
;
type_literals : VOID_TK DOT_TK CLASS_TK | primitive_type DOT_TK CLASS_TK | array_type DOT_TK CLASS_TK | name DOT_TK CLASS_TK
;
synchronized_statement : synchronized OP_TK expression CP_TK block
;
post_decrement_expression : postfix_expression DECR_TK
;
primary : array_creation_expression | primary_no_new_array
;
package_declaration : PACKAGE_TK name SC_TK
;
and_expression : and_expression AND_TK equality_expression | equality_expression
;
for_update : statement_expression_list | 
;
empty_statement : SC_TK
;
interface_type_list : interface_type_list C_TK interface_type | interface_type
;
equality_expression : equality_expression NEQ_TK relational_expression | equality_expression EQ_TK relational_expression | relational_expression
;
array_initializer : OCB_TK variable_initializers C_TK CCB_TK | OCB_TK variable_initializers CCB_TK | OCB_TK C_TK CCB_TK | OCB_TK CCB_TK
;
simple_name : identifier
;
type_declaration : empty_statement | interface_declaration | class_declaration
;
conditional_expression : conditional_or_expression REL_QM_TK expression REL_CL_TK conditional_expression | conditional_or_expression
;
trap_overflow_corner_case : unary_expression_not_plus_minus | PLUS_TK unary_expression | pre_decrement_expression | pre_increment_expression
;
left_hand_side : array_access | field_access | name
;
unary_expression_not_plus_minus : cast_expression | NEG_TK unary_expression | NOT_TK unary_expression | postfix_expression
;
dims : dims OSB_TK CSB_TK | OSB_TK CSB_TK
;
try_statement : TRY_TK block catches finally | TRY_TK block finally | TRY_TK block catches
;
additive_expression : additive_expression MINUS_TK multiplicative_expression | additive_expression PLUS_TK multiplicative_expression | multiplicative_expression
;
interface_body : OCB_TK interface_member_declarations CCB_TK | OCB_TK CCB_TK
;
while_statement_nsi : while_expression statement_nsi
;
something_dot_new : primary DOT_TK NEW_TK | name DOT_TK NEW_TK
;
while_statement : while_expression statement
;
