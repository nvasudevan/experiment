%token OP_TK
%token ASSIGN_TK
%token NEG_TK
%token NOT_TK
%token REL_CL_TK
%token REL_QM_TK
%token ASSERT_TK
%token NEW_TK
%token TRY_TK
%token SWITCH_TK
%token CLASS_TK
%token WHILE_TK
%token SUPER_TK
%token CASE_TK
%token INTERFACE_TK
%token RETURN_TK
%token INSTANCEOF_TK
%token ELSE_TK
%token THROW_TK
%token IF_TK
%token INCR_TK
%token DECR_TK
%token LTE_TK
%token LT_TK
%token GTE_TK
%token GT_TK
%token NEQ_TK
%token EQ_TK
%token BOOL_OR_TK
%token BOOL_AND_TK
%token OR_TK
%token XOR_TK
%token AND_TK
%token ZRS_TK
%token SRS_TK
%token LS_TK
%token DOT_TK
%token REM_TK
%token DIV_TK
%token C_TK
%token SC_TK
%token MULT_TK
%token CSB_TK
%token MINUS_TK
%token OSB_TK
%token PLUS_TK
%token CCB_TK
%token OCB_TK
%token CP_TK

%%

goal :  compilation_unit
;

name :  simple_name
;

primary_no_new_array :  class_instance_creation_expression
|  OP_TK expression CP_TK
|  field_access
|  array_access
|  method_invocation
;

for_begin :  for_header for_init
;

for_statement :  for_begin SC_TK expression SC_TK for_update CP_TK statement
|  for_begin SC_TK SC_TK for_update CP_TK statement
;

variable_initializers :  variable_initializer
|  variable_initializers C_TK variable_initializer
;

conditional_or_expression :  conditional_or_expression BOOL_OR_TK conditional_and_expression
|  conditional_and_expression
;

super : 
;

type_declaration :  empty_statement
|  class_declaration
|  interface_declaration
;

something_dot_new :  primary DOT_TK NEW_TK
;

class_instance_creation_expression :  something_dot_new identifier OP_TK CP_TK
|  something_dot_new identifier OP_TK CP_TK class_body
|  anonymous_class_creation
|  NEW_TK class_type OP_TK argument_list CP_TK
|  something_dot_new identifier OP_TK argument_list CP_TK class_body
|  something_dot_new identifier OP_TK argument_list CP_TK
;

method_declaration :  method_header method_body
;

variable_declarators :  variable_declarators C_TK variable_declarator
|  variable_declarator
;

class_declaration :  modifiers CLASS_TK identifier super interfaces class_body
|  CLASS_TK identifier super interfaces class_body
;

type :  FP_TK
;

modifiers :  MODIFIER_TK
;

interface_declaration :  INTERFACE_TK identifier interface_body
|  INTERFACE_TK identifier extends_interfaces interface_body
|  modifiers INTERFACE_TK identifier extends_interfaces interface_body
|  modifiers INTERFACE_TK identifier interface_body
;

field_declaration :  modifiers type variable_declarators SC_TK
|  type variable_declarators SC_TK
;

multiplicative_expression :  multiplicative_expression MULT_TK unary_expression
|  multiplicative_expression DIV_TK unary_expression
|  multiplicative_expression REM_TK unary_expression
|  unary_expression
;

constructor_header :  ID_TK OP_TK CP_TK
;

empty_statement :  SC_TK
;

class_member_declaration :  method_declaration
|  class_declaration
|  field_declaration
|  interface_declaration
|  empty_statement
;

constructor_declaration :  constructor_header constructor_body
;

assert_statement :  ASSERT_TK expression SC_TK
|  ASSERT_TK expression REL_CL_TK expression SC_TK
;

constant_expression :  expression
;

for_update :  statement_expression_list
;

interface_member_declaration :  interface_declaration
|  constant_declaration
|  abstract_method_declaration
|  class_declaration
;

for_statement_nsi :  for_begin SC_TK expression SC_TK for_update CP_TK statement_nsi
|  for_begin SC_TK SC_TK for_update CP_TK statement_nsi
;

interface_member_declarations :  interface_member_declarations interface_member_declaration
|  interface_member_declaration
;

do_statement_begin :  DO_TK
;

do_statement :  do_statement_begin statement WHILE_TK OP_TK expression CP_TK SC_TK
;

local_variable_declaration_statement :  local_variable_declaration SC_TK
;

extends_interfaces :  EXTENDS_TK ID_TK
;

type_declarations :  type_declarations type_declaration
|  type_declaration
;

package_declaration :  PACKAGE_TK ID_TK SC_TK
;

switch_labels :  switch_label
|  switch_labels switch_label
;

switch_block_statement_groups :  switch_block_statement_group
|  switch_block_statement_groups switch_block_statement_group
;

switch_block_statement_group :  switch_labels block_statements
;

switch_block :  OCB_TK CCB_TK
|  OCB_TK switch_block_statement_groups switch_labels CCB_TK
|  OCB_TK switch_block_statement_groups CCB_TK
|  OCB_TK switch_labels CCB_TK
;

if_then_else_statement_nsi :  IF_TK OP_TK expression CP_TK statement_nsi ELSE_TK statement_nsi
;

for_header :  FOR_TK OP_TK
;

finally :  if_then_else_statement_nsi block
;

statement :  labeled_statement
|  if_then_statement
|  statement_without_trailing_substatement
|  if_then_else_statement
|  for_statement
|  while_statement
;

method_body :  block
|  SC_TK
;

switch_expression :  SWITCH_TK OP_TK expression CP_TK
;

labeled_statement :  label_decl statement
;

pre_increment_expression :  INCR_TK unary_expression
;

statement_expression :  class_instance_creation_expression
|  post_increment_expression
|  pre_decrement_expression
|  pre_increment_expression
|  assignment
|  method_invocation
|  post_decrement_expression
;

expression_statement :  statement_expression SC_TK
;

statement_expression_list :  statement_expression_list C_TK statement_expression
|  statement_expression
;

final :  modifiers
;

field_access :  primary DOT_TK identifier
;

local_variable_declaration :  final type variable_declarators
|  type variable_declarators
;

for_init :  statement_expression_list
|  local_variable_declaration
;

conditional_expression :  conditional_or_expression REL_QM_TK expression REL_CL_TK conditional_expression
|  conditional_or_expression
;

block_end :  CCB_TK
;

constructor_block_end :  block_end
;

explicit_constructor_invocation :  this_or_super OP_TK argument_list CP_TK SC_TK
|  name DOT_TK SUPER_TK OP_TK argument_list CP_TK SC_TK
;

block_begin :  OCB_TK
;

block :  block_begin block_end
|  block_begin block_statements block_end
;

static_initializer :  static_ block
;

constructor_body :  block_begin explicit_constructor_invocation block_statements constructor_block_end
|  block_begin explicit_constructor_invocation constructor_block_end
|  block_begin block_statements constructor_block_end
;

statement_nsi :  labeled_statement_nsi
|  for_statement_nsi
|  statement_without_trailing_substatement
|  while_statement_nsi
|  if_then_else_statement_nsi
;

label_decl :  identifier REL_CL_TK
;

labeled_statement_nsi :  label_decl statement_nsi
;

assignment_expression :  assignment
|  conditional_expression
;

left_hand_side :  field_access
|  array_access
|  name
;

assignment :  left_hand_side assignment_operator assignment_expression
;

and_expression :  equality_expression
|  and_expression AND_TK equality_expression
;

exclusive_or_expression :  exclusive_or_expression XOR_TK and_expression
|  and_expression
;

abstract_method_declaration :  method_header SC_TK
;

variable_initializer :  array_initializer
|  expression
;

variable_declarator_id :  identifier
|  variable_declarator_id OSB_TK CSB_TK
;

import_declarations :  IMPORT_TK ID_TK SC_TK
;

variable_declarator :  variable_declarator_id ASSIGN_TK variable_initializer
|  variable_declarator_id
;

assignment_operator :  ASSIGN_TK
;

simple_name :  identifier
;

interfaces : 
;

constant_declaration :  field_declaration
;

block_statement :  local_variable_declaration_statement
|  class_declaration
|  statement
;

primitive_type :  FP_TK
;

block_statements :  block_statements block_statement
|  block_statement
;

identifier :  ID_TK
;

unary_expression_not_plus_minus :  postfix_expression
|  cast_expression
|  NOT_TK unary_expression
|  NEG_TK unary_expression
;

dims :  OSB_TK CSB_TK
|  dims OSB_TK CSB_TK
;

cast_expression :  OP_TK expression CP_TK unary_expression_not_plus_minus
|  OP_TK primitive_type CP_TK unary_expression
|  OP_TK name dims CP_TK unary_expression_not_plus_minus
|  OP_TK primitive_type dims CP_TK unary_expression
;

class_body :  OCB_TK class_body_declarations CCB_TK
|  OCB_TK CCB_TK
;

class_type :  ID_TK
;

anonymous_class_creation :  NEW_TK class_type OP_TK argument_list CP_TK class_body
|  NEW_TK class_type OP_TK CP_TK class_body
;

array_initializer :  OCB_TK variable_initializers C_TK CCB_TK
|  OCB_TK variable_initializers CCB_TK
;

while_expression :  WHILE_TK OP_TK expression CP_TK
;

inclusive_or_expression :  inclusive_or_expression OR_TK exclusive_or_expression
|  exclusive_or_expression
;

this_or_super :  THIS_TK
;

conditional_and_expression :  conditional_and_expression BOOL_AND_TK inclusive_or_expression
|  inclusive_or_expression
;

catch_clause_parameter :  CATCH_TK OP_TK FP_TK ID_TK CP_TK
;

unary_expression :  trap_overflow_corner_case
|  MINUS_TK trap_overflow_corner_case
;

pre_decrement_expression :  DECR_TK unary_expression
;

post_decrement_expression :  postfix_expression DECR_TK
;

expression :  assignment_expression
;

argument_list :  argument_list C_TK expression
|  expression
;

dim_expr :  OSB_TK expression CSB_TK
;

dim_exprs :  dim_exprs dim_expr
|  dim_expr
;

postfix_expression :  post_increment_expression
|  primary
|  name
|  post_decrement_expression
;

switch_label :  CASE_TK constant_expression REL_CL_TK
;

post_increment_expression :  postfix_expression INCR_TK
;

compilation_unit :  type_declarations
|  import_declarations type_declarations
|  package_declaration import_declarations type_declarations
|  package_declaration type_declarations
;

trap_overflow_corner_case :  unary_expression_not_plus_minus
|  pre_decrement_expression
|  PLUS_TK unary_expression
|  pre_increment_expression
;

switch_statement :  switch_expression switch_block
;

catch_clause :  catch_clause_parameter block
;

catches :  catches catch_clause
|  catch_clause
;

equality_expression :  relational_expression
|  equality_expression EQ_TK relational_expression
|  equality_expression NEQ_TK relational_expression
;

return_statement :  RETURN_TK expression SC_TK
;

synchronized_statement :  synchronized OP_TK expression CP_TK block
;

method_header :  VOID_TK ID_TK OP_TK CP_TK
;

throw_statement :  THROW_TK expression SC_TK
;

try_statement :  TRY_TK block catches
|  TRY_TK block finally
|  TRY_TK block catches finally
;

primary :  primary_no_new_array
|  array_creation_expression
;

if_then_statement :  IF_TK OP_TK expression CP_TK statement
;

method_invocation :  name OP_TK argument_list CP_TK
|  primary DOT_TK identifier OP_TK argument_list CP_TK
|  primary DOT_TK identifier OP_TK CP_TK
|  SUPER_TK DOT_TK identifier OP_TK argument_list CP_TK
;

if_then_else_statement :  IF_TK OP_TK expression CP_TK statement_nsi ELSE_TK statement
;

class_or_interface_type :  ID_TK
;

while_statement :  while_expression statement
;

class_body_declaration :  class_member_declaration
|  constructor_declaration
|  block
|  static_initializer
;

class_body_declarations :  class_body_declarations class_body_declaration
|  class_body_declaration
;

array_creation_expression :  NEW_TK primitive_type dim_exprs dims
|  NEW_TK class_or_interface_type dim_exprs dims
|  NEW_TK primitive_type dims array_initializer
|  NEW_TK class_or_interface_type dims array_initializer
|  NEW_TK class_or_interface_type dim_exprs
|  NEW_TK primitive_type dim_exprs
;

statement_without_trailing_substatement :  do_statement
|  empty_statement
|  expression_statement
|  throw_statement
|  switch_statement
|  block
|  try_statement
|  assert_statement
|  return_statement
|  synchronized_statement
;

synchronized :  MODIFIER_TK
;

while_statement_nsi :  while_expression statement_nsi
;

interface_body :  OCB_TK interface_member_declarations CCB_TK
;

shift_expression :  shift_expression LS_TK additive_expression
|  additive_expression
|  shift_expression SRS_TK additive_expression
|  shift_expression ZRS_TK additive_expression
;

reference_type :  ID_TK
;

relational_expression :  relational_expression GT_TK shift_expression
|  relational_expression GTE_TK shift_expression
|  shift_expression
|  relational_expression LT_TK shift_expression
|  relational_expression LTE_TK shift_expression
|  relational_expression INSTANCEOF_TK reference_type
;

array_access :  name OSB_TK expression CSB_TK
|  primary_no_new_array OSB_TK expression CSB_TK
;

static_ :  MODIFIER_TK
;

additive_expression :  multiplicative_expression
|  additive_expression PLUS_TK multiplicative_expression
|  additive_expression MINUS_TK multiplicative_expression
;
