/*
 * C# grammar in BNF.
 * For original grammar refer to https://github.com/mono/mono/blob/master/mcs/mcs/cs-parser.jay
 * The original grammar had 7 s-r conficts. I  have added comments (labeled as 'Krish') at places where I have
 * modified the original grammar
 * I have left most of the comments from the original grammar as is for reference
 */
%token EOF
%token NONE   /* This token is never returned by our lexer */
%token ERROR		// This is used not by the parser, but by the tokenizer.
			// do not remove.

/*
 *These are the C# keywords
 */
%token FIRST_KEYWORD
%token ABSTRACT	
%token AS
%token ADD
%token BASE	
%token BOOL	
%token BREAK	
%token BYTE	
%token CASE	
%token CATCH	
%token CHAR	
%token CHECKED	
%token CLASS	
%token CONST	
%token CONTINUE	
%token DECIMAL	
%token DEFAULT	
%token DELEGATE	
%token DO	
%token DOUBLE	
%token ELSE	
%token ENUM	
%token EVENT	
%token EXPLICIT	
%token EXTERN	
%token FALSE	
%token FINALLY	
%token FIXED	
%token FLOAT	
%token FOR	
%token FOREACH	
%token GOTO	
%token IF	
%token IMPLICIT	
%token IN	
%token INT	
%token INTERFACE
%token INTERNAL	
%token IS	
%token LOCK	
%token LONG	
%token NAMESPACE
%token NEW	
%token NULL	
%token OBJECT	
%token OPERATOR	
%token OUT	
%token OVERRIDE	
%token PARAMS	
%token PRIVATE	
%token PROTECTED
%token PUBLIC	
%token READONLY	
%token REF	
%token RETURN	
%token REMOVE
%token SBYTE	
%token SEALED	
%token SHORT	
%token SIZEOF	
%token STACKALLOC
%token STATIC	
%token STRING	
%token STRUCT	
%token SWITCH	
%token THIS	
%token THROW	
%token TRUE	
%token TRY	
%token TYPEOF	
%token UINT	
%token ULONG	
%token UNCHECKED
%token UNSAFE	
%token USHORT	
%token USING	
%token VIRTUAL	
%token VOID	
%token VOLATILE
%token WHERE
%token WHILE	
%token ARGLIST
%token PARTIAL
%token ARROW
%token FROM
%token FROM_FIRST
%token JOIN
%token ON
%token EQUALS
%token SELECT
%token GROUP
%token BY
%token LET
%token ORDERBY
%token ASCENDING
%token DESCENDING
%token INTO
%token INTERR_NULLABLE
%token EXTERN_ALIAS
%token REFVALUE
%token REFTYPE
%token MAKEREF
%token ASYNC
%token AWAIT

/* C# keywords which are not really keywords */
%token GET
%token SET

%left LAST_KEYWORD

/* C# single character operators/punctuation. */
%token OPEN_BRACE
%token CLOSE_BRACE
%token OPEN_BRACKET
%token CLOSE_BRACKET
%token OPEN_PARENS
%token CLOSE_PARENS

%token DOT
%token COMMA
%token COLON
%token SEMICOLON
%token TILDE

%token PLUS
%token MINUS
%token BANG
%token ASSIGN
%token OP_LT
%token OP_GT
%token BITWISE_AND
%token BITWISE_OR
%token STAR
%token PERCENT
%token DIV
%token CARRET
%token INTERR

/* C# multi-character operators. */
%token DOUBLE_COLON
%token OP_INC
%token OP_DEC
%token OP_SHIFT_LEFT
%token OP_SHIFT_RIGHT
%token OP_LE
%token OP_GE
%token OP_EQ
%token OP_NE
%token OP_AND
%token OP_OR
%token OP_MULT_ASSIGN
%token OP_DIV_ASSIGN
%token OP_MOD_ASSIGN
%token OP_ADD_ASSIGN
%token OP_SUB_ASSIGN
%token OP_SHIFT_LEFT_ASSIGN
%token OP_SHIFT_RIGHT_ASSIGN
%token OP_AND_ASSIGN
%token OP_XOR_ASSIGN
%token OP_OR_ASSIGN
%token OP_PTR
%token OP_COALESCING

/* Generics <,> tokens */
%token OP_GENERICS_LT
%token OP_GENERICS_LT_DECL
%token OP_GENERICS_GT

%token LITERAL

%token IDENTIFIER
%token OPEN_PARENS_LAMBDA
%token OPEN_PARENS_CAST
%token GENERIC_DIMENSION
%token DEFAULT_COLON
%token OPEN_BRACKET_EXPR

// Make the parser go into eval mode parsing (statements and compilation units).
%token EVAL_STATEMENT_PARSER
%token EVAL_COMPILATION_UNIT_PARSER
%token EVAL_USING_DECLARATIONS_UNIT_PARSER

%token DOC_SEE

// 
// This token is generated to trigger the completion engine at this point
//
%token GENERATE_COMPLETION

//
// This token is return repeatedly after the first GENERATE_COMPLETION
// token is produced and before the final EOF
//
%token COMPLETE_COMPLETION


%start compilation_unit
%%

compilation_unit
	: outer_declaration opt_EOF
	| interactive_parsing  opt_EOF
	| documentation_parsing
	;
	
outer_declaration
	: opt_extern_alias_directives opt_using_directives
	| opt_extern_alias_directives opt_using_directives namespace_or_type_declarations opt_attributes
	| opt_extern_alias_directives opt_using_directives attribute_sections
	| error
	;
	
opt_EOF
	: /* empty */
	| EOF
	;

extern_alias_directives
	: extern_alias_directive
	| extern_alias_directives extern_alias_directive
	;

extern_alias_directive
	: EXTERN_ALIAS IDENTIFIER IDENTIFIER SEMICOLON
	| EXTERN_ALIAS error
	;
 
using_directives
	: using_directive 
	| using_directives using_directive
	;

using_directive
	: using_namespace
	;

using_namespace
	: USING namespace_or_type_expr SEMICOLON 
	| USING IDENTIFIER ASSIGN namespace_or_type_expr SEMICOLON
	| USING error
	;

//
// Strictly speaking, namespaces don't have attributes but
// we parse global attributes along with namespace declarations and then
// detach them
// 
namespace_declaration
	: opt_attributes NAMESPACE namespace_name OPEN_BRACE 
          opt_extern_alias_directives opt_using_directives 
          opt_namespace_or_type_declarations CLOSE_BRACE opt_semicolon_error
	| opt_attributes NAMESPACE namespace_name
	;

opt_semicolon_error
	: /* empty */
	| SEMICOLON
	| error
	;

namespace_name
	: IDENTIFIER
	| namespace_name DOT IDENTIFIER
	| error
	;

opt_semicolon
	: /* empty */
	| SEMICOLON
	;

opt_comma
	: /* empty */
	| COMMA
	;

opt_using_directives
	: /* empty */
	| using_directives
	;

opt_extern_alias_directives
	: /* empty */
	| extern_alias_directives
	;

opt_namespace_or_type_declarations
	: /* empty */
	| namespace_or_type_declarations
	;

namespace_or_type_declarations
	: namespace_or_type_declaration
	| namespace_or_type_declarations namespace_or_type_declaration
	;

namespace_or_type_declaration
	: type_declaration
	| namespace_declaration
	| attribute_sections CLOSE_BRACE 
	;

type_declaration
	: class_declaration		
	| struct_declaration
	| interface_declaration
	| enum_declaration		
	| delegate_declaration
//
// Enable this when we have handled all errors, because this acts as a generic fallback
//
//	| error {
//		Console.WriteLine ("Token=" + yyToken);
//		report.Error (1518, GetLocation ($1), "Expected class, struct, interface, enum or delegate");
//	  }
	;

//
// Attributes
//

opt_attributes
	: /* empty */ 
	| attribute_sections
    ;
 
attribute_sections
	: attribute_section
	| attribute_sections attribute_section
	;
	
attribute_section
	: OPEN_BRACKET attribute_section_cont
	;	
	
attribute_section_cont
	: attribute_target COLON attribute_list opt_comma CLOSE_BRACKET
	| attribute_list opt_comma CLOSE_BRACKET
	| IDENTIFIER error
	| error
	;	

attribute_target
	: IDENTIFIER
	| EVENT 
	| RETURN
	;

attribute_list
	: attribute
	| attribute_list COMMA attribute
	;

attribute
	: attribute_name opt_attribute_arguments
	;

attribute_name
	: namespace_or_type_expr
	;

opt_attribute_arguments
	: /* empty */ 
	| OPEN_PARENS attribute_arguments CLOSE_PARENS
	;

/* 
 * Krish: positional_or_named_argument covers the named_attribute_argument via expression
 */

attribute_arguments
	: /* empty */
	| positional_or_named_argument
     /* | named_attribute_argument 
        | attribute_arguments COMMA named_attribute_argument
      */
        | attribute_arguments COMMA positional_or_named_argument
    ;

positional_or_named_argument
	: expression
	| named_argument
	| error
	;

/*
named_attribute_argument
	: IDENTIFIER ASSIGN expression
	;
*/
	
named_argument
	: identifier_inside_body COLON opt_named_modifier expression_or_error
	;
	
opt_named_modifier
	: /* empty */ 
	| REF
	| OUT
	;
		  
opt_class_member_declarations
	: /* empty */
	| class_member_declarations
	;

class_member_declarations
	: class_member_declaration
	| class_member_declarations class_member_declaration
	;
	
class_member_declaration
	: constant_declaration
	| field_declaration
	| method_declaration
	| property_declaration
	| event_declaration
	| indexer_declaration
	| operator_declaration
	| constructor_declaration
	| destructor_declaration
	| type_declaration
	| attributes_without_members
	| incomplete_member
	| error
	;

struct_declaration
	: opt_attributes opt_modifiers opt_partial STRUCT type_declaration_name opt_class_base opt_type_parameter_constraints_clauses OPEN_BRACE opt_class_member_declarations CLOSE_BRACE opt_semicolon
	| opt_attributes opt_modifiers opt_partial STRUCT error
	;
	
constant_declaration
	: opt_attributes opt_modifiers CONST type IDENTIFIER constant_initializer opt_constant_declarators SEMICOLON
	| opt_attributes opt_modifiers CONST type error
	;
	
opt_constant_declarators
	: /* empty */
	| constant_declarators
	;
	
constant_declarators
	: constant_declarator
	| constant_declarators constant_declarator
	;
	
constant_declarator
	: COMMA IDENTIFIER constant_initializer
	;		

constant_initializer
	: ASSIGN constant_initializer_expr
	| error
	;
	
constant_initializer_expr
	: constant_expression
	| array_initializer
	;

field_declaration
	: opt_attributes opt_modifiers member_type 
          IDENTIFIER opt_field_initializer opt_field_declarators SEMICOLON
	| opt_attributes opt_modifiers FIXED simple_type 
          IDENTIFIER fixed_field_size opt_fixed_field_declarators SEMICOLON
	| opt_attributes opt_modifiers FIXED simple_type error SEMICOLON
	;
	
opt_field_initializer
	: /* empty */
	| ASSIGN variable_initializer
	;
	
opt_field_declarators
	: /* empty */
	| field_declarators
	;
	
field_declarators
	: field_declarator
	| field_declarators field_declarator
	;
	
field_declarator
	: COMMA IDENTIFIER
	| COMMA IDENTIFIER ASSIGN variable_initializer
	;	

opt_fixed_field_declarators
	: /* empty */
	| fixed_field_declarators
	;
	
fixed_field_declarators
	: fixed_field_declarator
	| fixed_field_declarators fixed_field_declarator
	;
	
fixed_field_declarator
	: COMMA IDENTIFIER fixed_field_size
	;

fixed_field_size
	: OPEN_BRACKET expression CLOSE_BRACKET
	| OPEN_BRACKET error
	;

variable_initializer
	: expression
	| array_initializer
	| error
	;

method_declaration
	: method_header method_body
	;

method_header
	: opt_attributes opt_modifiers member_type method_declaration_name 
          OPEN_PARENS opt_formal_parameter_list CLOSE_PARENS 
          opt_type_parameter_constraints_clauses
	| opt_attributes opt_modifiers PARTIAL VOID method_declaration_name 
          OPEN_PARENS opt_formal_parameter_list CLOSE_PARENS 
          opt_type_parameter_constraints_clauses
	| opt_attributes opt_modifiers member_type modifiers method_declaration_name 
          OPEN_PARENS opt_formal_parameter_list CLOSE_PARENS
	| opt_attributes opt_modifiers member_type method_declaration_name error
	;

method_body
	: block
	| SEMICOLON
	;

opt_formal_parameter_list
	: /* empty */	
	| formal_parameter_list
	;
	
formal_parameter_list
	: fixed_parameters
	| fixed_parameters COMMA parameter_array
	| fixed_parameters COMMA arglist_modifier
	| parameter_array COMMA error
	| fixed_parameters COMMA parameter_array COMMA error
	| arglist_modifier COMMA error
	| fixed_parameters COMMA ARGLIST COMMA error 
	| parameter_array 
	| arglist_modifier
	| error
	;

fixed_parameters
	: fixed_parameter	
	| fixed_parameters COMMA fixed_parameter
	;

fixed_parameter
	: opt_attributes opt_parameter_modifier parameter_type identifier_inside_body
	| opt_attributes opt_parameter_modifier parameter_type identifier_inside_body 
          OPEN_BRACKET CLOSE_BRACKET
	| attribute_sections error
	| opt_attributes opt_parameter_modifier parameter_type error
	| opt_attributes opt_parameter_modifier parameter_type 
          identifier_inside_body ASSIGN constant_expression
	;

opt_parameter_modifier
	: /* empty */	
	| parameter_modifiers
	;

parameter_modifiers
	: parameter_modifier
	| parameter_modifiers parameter_modifier
	;

parameter_modifier
	: REF
	| OUT
	| THIS
	;

parameter_array
	: opt_attributes params_modifier type IDENTIFIER
	| opt_attributes params_modifier type IDENTIFIER ASSIGN constant_expression
	| opt_attributes params_modifier type error
	;
	
params_modifier
	: PARAMS
	| PARAMS parameter_modifier
	| PARAMS params_modifier
	;
	
arglist_modifier
	: ARGLIST
	;
	
property_declaration
	: opt_attributes opt_modifiers member_type member_declaration_name 
          OPEN_BRACE accessor_declarations CLOSE_BRACE
	;


indexer_declaration
	: opt_attributes opt_modifiers
	  member_type indexer_declaration_name OPEN_BRACKET
	  opt_formal_parameter_list CLOSE_BRACKET 
	  OPEN_BRACE accessor_declarations 
	  CLOSE_BRACE
	;


accessor_declarations
	: get_accessor_declaration
	| get_accessor_declaration accessor_declarations
	| set_accessor_declaration
	| set_accessor_declaration accessor_declarations
	| error
	;

get_accessor_declaration
	: opt_attributes opt_modifiers GET accessor_body
	;

set_accessor_declaration
	: opt_attributes opt_modifiers SET 
	  accessor_body
	;

accessor_body
	: block 
	| SEMICOLON
	| error
	;

interface_declaration
	: opt_attributes opt_modifiers opt_partial 
          INTERFACE type_declaration_name opt_class_base opt_type_parameter_constraints_clauses 
          OPEN_BRACE opt_interface_member_declarations CLOSE_BRACE opt_semicolon 
	| opt_attributes opt_modifiers opt_partial INTERFACE error
	;

opt_interface_member_declarations
	: /* empty */
	| interface_member_declarations
	;

interface_member_declarations
	: interface_member_declaration
	| interface_member_declarations interface_member_declaration
	;

interface_member_declaration
	: constant_declaration
	| field_declaration
	| method_declaration
	| property_declaration
	| event_declaration
	| indexer_declaration
	| operator_declaration
	| constructor_declaration
	| type_declaration
	;

operator_declaration
	: opt_attributes opt_modifiers operator_declarator operator_body
	;

operator_body 
	: block
	| SEMICOLON 
	; 

operator_type
	: type_expression_or_array
	| VOID
	;

operator_declarator
	: operator_type OPERATOR overloadable_operator OPEN_PARENS opt_formal_parameter_list CLOSE_PARENS
	| conversion_operator_declarator
	;

overloadable_operator
// Unary operators:
	: BANG  
        | TILDE 
        | OP_INC
        | OP_DEC
        | TRUE 
        | FALSE
// Unary and binary:
        | PLUS
        | MINUS
// Binary:
        | STAR
        | DIV
        | PERCENT
        | BITWISE_AND
        | BITWISE_OR
        | CARRET
        | OP_SHIFT_LEFT
        | OP_SHIFT_RIGHT
        | OP_EQ
        | OP_NE
        | OP_GT
        | OP_LT
        | OP_GE
        | OP_LE
	;

conversion_operator_declarator
	: IMPLICIT OPERATOR type OPEN_PARENS opt_formal_parameter_list CLOSE_PARENS
	| EXPLICIT OPERATOR type OPEN_PARENS opt_formal_parameter_list CLOSE_PARENS
	| IMPLICIT error 
	| EXPLICIT error 
	;

constructor_declaration
	: constructor_declarator constructor_body
	;

constructor_declarator
	: opt_attributes opt_modifiers IDENTIFIER 
          OPEN_PARENS opt_formal_parameter_list CLOSE_PARENS opt_constructor_initializer
	;

constructor_body
	: block_prepared
	| SEMICOLON
	;

opt_constructor_initializer
	: /* Empty */
	| constructor_initializer
	;

constructor_initializer
	: COLON BASE OPEN_PARENS opt_argument_list CLOSE_PARENS
	| COLON THIS OPEN_PARENS opt_argument_list CLOSE_PARENS
	| COLON error
	| error
	;

destructor_declaration
	: opt_attributes opt_modifiers TILDE 
	  IDENTIFIER OPEN_PARENS CLOSE_PARENS method_body
	;

event_declaration
	: opt_attributes opt_modifiers EVENT type member_declaration_name 
          opt_event_initializer opt_event_declarators SEMICOLON
	| opt_attributes opt_modifiers EVENT type member_declaration_name 
          OPEN_BRACE event_accessor_declarations CLOSE_BRACE
	| opt_attributes opt_modifiers EVENT type error
	;
	
opt_event_initializer
	: /* empty */
	| ASSIGN
	  event_variable_initializer
	;
	
opt_event_declarators
	: /* empty */
	| event_declarators
	;
	
event_declarators
	: event_declarator
	| event_declarators event_declarator
	;
	
event_declarator
	: COMMA IDENTIFIER
	| COMMA IDENTIFIER ASSIGN
	  event_variable_initializer
	;
	
event_variable_initializer
	: variable_initializer
	;
	
event_accessor_declarations
	: add_accessor_declaration remove_accessor_declaration
	| remove_accessor_declaration add_accessor_declaration
	| add_accessor_declaration
	| remove_accessor_declaration
	| error
	;

add_accessor_declaration
	: opt_attributes opt_modifiers ADD
	  event_accessor_block
	;
	
remove_accessor_declaration
	: opt_attributes opt_modifiers REMOVE
	  event_accessor_block
	;

event_accessor_block
	: opt_semicolon
	| block
	;

attributes_without_members
	: attribute_sections CLOSE_BRACE
	;

// For full ast try to recover incomplete ambiguous member
// declaration in form on class X { public int }
incomplete_member
	: opt_attributes opt_modifiers member_type CLOSE_BRACE
	;
	  
enum_declaration
	: opt_attributes opt_modifiers ENUM type_declaration_name opt_enum_base 
          OPEN_BRACE opt_enum_member_declarations CLOSE_BRACE opt_semicolon
	;

opt_enum_base
	: /* empty */
	| COLON type
	| COLON error
	;

opt_enum_member_declarations
	: /* empty */
	| enum_member_declarations
	| enum_member_declarations COMMA
	;

enum_member_declarations
	: enum_member_declaration
	| enum_member_declarations COMMA enum_member_declaration
	;

enum_member_declaration
	: opt_attributes IDENTIFIER
	| opt_attributes IDENTIFIER
	  ASSIGN constant_expression
	| opt_attributes IDENTIFIER error
	| attributes_without_members
	;

delegate_declaration
	: opt_attributes
	  opt_modifiers
	  DELEGATE
	  member_type type_declaration_name
	  OPEN_PARENS
	  opt_formal_parameter_list CLOSE_PARENS
	  opt_type_parameter_constraints_clauses
	  SEMICOLON
	;

opt_nullable
	: /* empty */
	| INTERR_NULLABLE
	;

namespace_or_type_expr
	: member_name
	| qualified_alias_member IDENTIFIER opt_type_argument_list
	;

member_name
	: simple_name_expr
	| namespace_or_type_expr DOT IDENTIFIER opt_type_argument_list
	;

simple_name_expr
	: IDENTIFIER opt_type_argument_list
	;
	
//
// Generics arguments  (any type, without attributes)
//
opt_type_argument_list
        :
	| OP_GENERICS_LT type_arguments OP_GENERICS_GT
	| OP_GENERICS_LT error
	;

type_arguments
	: type
	| type_arguments COMMA type
	;

//
// Generics parameters (identifiers only, with attributes), used in type or method declarations
//
type_declaration_name
	: IDENTIFIER
	  opt_type_parameter_list
	;

member_declaration_name
	: method_declaration_name
	;

method_declaration_name
	: type_declaration_name
	| explicit_interface IDENTIFIER opt_type_parameter_list
	;
	
indexer_declaration_name
	: THIS
	| explicit_interface THIS
	;

explicit_interface
	: IDENTIFIER opt_type_argument_list DOT
	| qualified_alias_member IDENTIFIER opt_type_argument_list DOT
	| explicit_interface IDENTIFIER opt_type_argument_list DOT
	;
	
opt_type_parameter_list
	: /* empty */
	| OP_GENERICS_LT_DECL type_parameters OP_GENERICS_GT
	;

type_parameters
	: type_parameter
	| type_parameters COMMA type_parameter
	;

type_parameter
	: opt_attributes opt_type_parameter_variance IDENTIFIER
  	| error
 	;

//
// All types where void is allowed
//
type_and_void
	: type_expression_or_array
	| VOID
	;
	
member_type
	: type_and_void
	;
	
//
// A type which does not allow `void' to be used
//
type
	: type_expression_or_array
	| VOID
	;
	
simple_type
	: type_expression
	| VOID
	;
	
parameter_type
	: type_expression_or_array
	| VOID
	;

type_expression_or_array
	: type_expression
	| type_expression rank_specifiers
	;
	
type_expression
	: namespace_or_type_expr opt_nullable
	| namespace_or_type_expr pointer_stars
	| builtin_types opt_nullable
	| builtin_types pointer_stars
	| VOID pointer_stars
	;

type_list
	: base_type_name
	| type_list COMMA base_type_name
	;

base_type_name
	: type
	;
	
/*
 * replaces all the productions for isolating the various
 * simple types, but we need this to reuse it easily in variable_type
 */
builtin_types
	: OBJECT
	| STRING
	| BOOL
	| DECIMAL
	| FLOAT	
	| DOUBLE
	| integral_type
	;

integral_type
	: SBYTE
	| BYTE
	| SHORT
	| USHORT
	| INT
	| UINT
	| LONG
	| ULONG
	| CHAR	
	;

//
// Expressions, section 7.5
//


primary_expression
	: primary_expression_or_type 
	| literal
	| array_creation_expression 
	| parenthesized_expression
	| default_value_expression
	| invocation_expression
	| element_access
	| this_access
	| base_access
	| post_increment_expression
	| post_decrement_expression
	| object_or_delegate_creation_expression
	| anonymous_type_expression
	| typeof_expression
	| sizeof_expression
	| checked_expression
	| unchecked_expression
	| pointer_member_access
	| anonymous_method_expression
	| undocumented_expressions
	;

primary_expression_or_type
	: IDENTIFIER opt_type_argument_list
	| IDENTIFIER GENERATE_COMPLETION 
	| member_access
	;

literal
	: boolean_literal
	| LITERAL
	| NULL	
	;

boolean_literal
	: TRUE
	| FALSE
	;


//
// Here is the trick, tokenizer may think that parens is a special but
// parser is interested in open parens only, so we merge them.
// Consider: if (a)foo ();
//
open_parens_any
	: OPEN_PARENS
	| OPEN_PARENS_CAST
	;

// 
// Use this production to accept closing parenthesis or 
// performing completion
//
close_parens
	: CLOSE_PARENS
	| COMPLETE_COMPLETION
	;


parenthesized_expression
	: OPEN_PARENS expression CLOSE_PARENS
	| OPEN_PARENS expression COMPLETE_COMPLETION
	;
	
member_access
	: primary_expression DOT identifier_inside_body opt_type_argument_list
	| builtin_types DOT identifier_inside_body opt_type_argument_list
	| BASE DOT identifier_inside_body opt_type_argument_list
	| qualified_alias_member identifier_inside_body opt_type_argument_list
	| primary_expression DOT GENERATE_COMPLETION 
	| primary_expression DOT IDENTIFIER GENERATE_COMPLETION 
	| builtin_types DOT GENERATE_COMPLETION
	| builtin_types DOT IDENTIFIER GENERATE_COMPLETION 
	;

invocation_expression
	: primary_expression open_parens_any opt_argument_list close_parens
	| primary_expression open_parens_any argument_list error
	| primary_expression open_parens_any error
	;

opt_object_or_collection_initializer
	: /* empty */	
	| object_or_collection_initializer
	;

/* 
 * Krish: 1st alternative modified to only end with CLOSE_BRACE to resolve s-r conflict
 */
object_or_collection_initializer
	: OPEN_BRACE opt_member_initializer_list CLOSE_BRACE 
	| OPEN_BRACE member_initializer_list COMMA CLOSE_BRACE
	;

opt_member_initializer_list
	: /* empty */
	| member_initializer_list
	;

member_initializer_list
	: member_initializer
	| member_initializer_list COMMA member_initializer
	| member_initializer_list error 
	;

member_initializer
	: IDENTIFIER ASSIGN initializer_value
	| AWAIT ASSIGN initializer_value
	| GENERATE_COMPLETION 
	| non_assignment_expression opt_COMPLETE_COMPLETION  
	| OPEN_BRACE expression_list CLOSE_BRACE
	| OPEN_BRACE CLOSE_BRACE
	;

initializer_value
	: expression
	| object_or_collection_initializer
	;

opt_argument_list
	: /* empty */
	| argument_list
	;

argument_list
	: argument_or_named_argument
	| argument_list COMMA argument
	| argument_list COMMA named_argument
	| argument_list COMMA error
	| COMMA error
	;

argument
	: expression
	| non_simple_argument
	;

argument_or_named_argument
	: argument
	| named_argument
	;

non_simple_argument
	: REF variable_reference 
	| OUT variable_reference 
	| ARGLIST OPEN_PARENS argument_list CLOSE_PARENS
	| ARGLIST OPEN_PARENS CLOSE_PARENS
	;

variable_reference
	: expression
	;

element_access
	: primary_expression  OPEN_BRACKET_EXPR expression_list_arguments CLOSE_BRACKET	
	| primary_expression  OPEN_BRACKET_EXPR expression_list_arguments error
	| primary_expression  OPEN_BRACKET_EXPR error
	;

expression_list
	: expression_or_error
	| expression_list COMMA expression_or_error
	;
	
expression_list_arguments
	: expression_list_argument
	| expression_list_arguments COMMA expression_list_argument
	;
	
expression_list_argument
	: expression
	| named_argument
	;

this_access
	: THIS
	;

base_access
	: BASE OPEN_BRACKET_EXPR expression_list_arguments CLOSE_BRACKET
	| BASE OPEN_BRACKET error
	;

post_increment_expression
	: primary_expression OP_INC
	;

post_decrement_expression
	: primary_expression OP_DEC
	;
	
object_or_delegate_creation_expression
	: NEW new_expr_type open_parens_any opt_argument_list CLOSE_PARENS 
          opt_object_or_collection_initializer
	| NEW new_expr_type object_or_collection_initializer
	;

array_creation_expression
	: NEW new_expr_type OPEN_BRACKET_EXPR expression_list CLOSE_BRACKET 
          opt_rank_specifier opt_array_initializer
	| NEW new_expr_type rank_specifiers array_initializer 
	| NEW rank_specifier array_initializer
	| NEW new_expr_type OPEN_BRACKET CLOSE_BRACKET OPEN_BRACKET_EXPR error CLOSE_BRACKET 
	| NEW new_expr_type error
	;

new_expr_type
	: simple_type
	;

anonymous_type_expression
	: NEW OPEN_BRACE anonymous_type_parameters_opt_comma CLOSE_BRACE
	;

anonymous_type_parameters_opt_comma
	: anonymous_type_parameters_opt
	| anonymous_type_parameters COMMA
	;

anonymous_type_parameters_opt
	: 
	| anonymous_type_parameters
	;

anonymous_type_parameters
	: anonymous_type_parameter
	| anonymous_type_parameters COMMA anonymous_type_parameter
	;

anonymous_type_parameter
	: identifier_inside_body ASSIGN variable_initializer
	| identifier_inside_body
	| member_access
	| error
	;

opt_rank_specifier
	: /* empty */
	| rank_specifiers
	;

rank_specifiers
	: rank_specifier
	| rank_specifier rank_specifiers
	;

rank_specifier
	: OPEN_BRACKET CLOSE_BRACKET
	| OPEN_BRACKET dim_separators CLOSE_BRACKET
	;

dim_separators
	: COMMA
	| dim_separators COMMA
	;

opt_array_initializer
	: /* empty */
	| array_initializer
	;

array_initializer
	: OPEN_BRACE CLOSE_BRACE
	| OPEN_BRACE variable_initializer_list opt_comma CLOSE_BRACE
	;

variable_initializer_list
	: variable_initializer
	| variable_initializer_list COMMA variable_initializer
	;

typeof_expression
	: TYPEOF
	  open_parens_any typeof_type_expression CLOSE_PARENS
	;
	
typeof_type_expression
	: type_and_void
	| unbound_type_name
	| error
	;
	
unbound_type_name
	: identifier_inside_body generic_dimension
	| qualified_alias_member identifier_inside_body generic_dimension
	| unbound_type_name DOT identifier_inside_body
	| unbound_type_name DOT identifier_inside_body generic_dimension
	| namespace_or_type_expr DOT identifier_inside_body generic_dimension
	;

generic_dimension
	: GENERIC_DIMENSION
	;
	
qualified_alias_member
	: IDENTIFIER DOUBLE_COLON
	;

sizeof_expression
	: SIZEOF open_parens_any type CLOSE_PARENS
	| SIZEOF open_parens_any type error
	;

checked_expression
	: CHECKED open_parens_any expression CLOSE_PARENS
	| CHECKED error
	;

unchecked_expression
	: UNCHECKED open_parens_any expression CLOSE_PARENS
	| UNCHECKED error
	;

pointer_member_access
	: primary_expression OP_PTR IDENTIFIER opt_type_argument_list
	;

anonymous_method_expression
	: DELEGATE opt_anonymous_method_signature
	  block
	| ASYNC DELEGATE opt_anonymous_method_signature
	  block
	;

opt_anonymous_method_signature
	: 
	| anonymous_method_signature
	;

anonymous_method_signature
	: OPEN_PARENS
	  opt_formal_parameter_list CLOSE_PARENS
	;

default_value_expression
	: DEFAULT open_parens_any type CLOSE_PARENS
	;

unary_expression
	: primary_expression 
	| BANG prefixed_unary_expression
	| TILDE prefixed_unary_expression
	| OPEN_PARENS_CAST type CLOSE_PARENS prefixed_unary_expression
	| AWAIT prefixed_unary_expression
	| BANG error
	| TILDE error
	| OPEN_PARENS_CAST type CLOSE_PARENS error
	| AWAIT error
	;

	//
	// The idea to split this out is from Rhys' grammar
	// to solve the problem with casts.
	//
prefixed_unary_expression
	: unary_expression
	| PLUS prefixed_unary_expression
	| MINUS prefixed_unary_expression 
	| OP_INC prefixed_unary_expression 
	| OP_DEC prefixed_unary_expression 
	| STAR prefixed_unary_expression
	| BITWISE_AND prefixed_unary_expression
	| PLUS error
	| MINUS error 
	| OP_INC error 
	| OP_DEC error 
	| STAR error
	| BITWISE_AND error
	;

multiplicative_expression
	: prefixed_unary_expression
	| multiplicative_expression STAR prefixed_unary_expression
	| multiplicative_expression DIV prefixed_unary_expression
	| multiplicative_expression PERCENT prefixed_unary_expression 
	| multiplicative_expression STAR error
	| multiplicative_expression DIV error
	| multiplicative_expression PERCENT error 
	;

additive_expression
	: multiplicative_expression
	| additive_expression PLUS multiplicative_expression 
	| additive_expression MINUS multiplicative_expression
	| additive_expression AS type
	| additive_expression IS type
	| additive_expression PLUS error 
	| additive_expression MINUS error
	| additive_expression AS error
	| additive_expression IS error
	;

shift_expression
	: additive_expression
	| shift_expression OP_SHIFT_LEFT additive_expression
	| shift_expression OP_SHIFT_RIGHT additive_expression
	| shift_expression OP_SHIFT_LEFT error
	| shift_expression OP_SHIFT_RIGHT error
	; 

relational_expression
	: shift_expression
	| relational_expression OP_LT shift_expression
	| relational_expression OP_GT shift_expression
	| relational_expression OP_LE shift_expression
	| relational_expression OP_GE shift_expression
	| relational_expression OP_LT error
	| relational_expression OP_GT error
	| relational_expression OP_LE error
	| relational_expression OP_GE error
	;

equality_expression
	: relational_expression
	| equality_expression OP_EQ relational_expression
	| equality_expression OP_NE relational_expression
	| equality_expression OP_EQ error
	| equality_expression OP_NE error
	; 

and_expression
	: equality_expression
	| and_expression BITWISE_AND equality_expression
	| and_expression BITWISE_AND error
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression CARRET and_expression
	| exclusive_or_expression CARRET error
	;

inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression BITWISE_OR exclusive_or_expression
	| inclusive_or_expression BITWISE_OR error
	;

conditional_and_expression
	: inclusive_or_expression
	| conditional_and_expression OP_AND inclusive_or_expression
	| conditional_and_expression OP_AND error
	;

conditional_or_expression
	: conditional_and_expression
	| conditional_or_expression OP_OR conditional_and_expression
	| conditional_or_expression OP_OR error
	;
	
null_coalescing_expression
	: conditional_or_expression
	| conditional_or_expression OP_COALESCING null_coalescing_expression
	;

conditional_expression
	: null_coalescing_expression
	| null_coalescing_expression INTERR expression COLON expression
	| null_coalescing_expression INTERR expression error
	| null_coalescing_expression INTERR expression COLON error
	| null_coalescing_expression INTERR expression COLON CLOSE_BRACE
	;

assignment_expression
	: prefixed_unary_expression ASSIGN expression
	| prefixed_unary_expression OP_MULT_ASSIGN expression
	| prefixed_unary_expression OP_DIV_ASSIGN expression
	| prefixed_unary_expression OP_MOD_ASSIGN expression
	| prefixed_unary_expression OP_ADD_ASSIGN expression
	| prefixed_unary_expression OP_SUB_ASSIGN expression
	| prefixed_unary_expression OP_SHIFT_LEFT_ASSIGN expression
	| prefixed_unary_expression OP_SHIFT_RIGHT_ASSIGN expression
	| prefixed_unary_expression OP_AND_ASSIGN expression
	| prefixed_unary_expression OP_OR_ASSIGN expression
	| prefixed_unary_expression OP_XOR_ASSIGN expression
	;

lambda_parameter_list
	: lambda_parameter
	| lambda_parameter_list COMMA lambda_parameter
	;

lambda_parameter
	: parameter_modifier parameter_type identifier_inside_body
	| parameter_type identifier_inside_body
	| IDENTIFIER
	| AWAIT
	;

opt_lambda_parameter_list
	: /* empty */
	| lambda_parameter_list	
	;

lambda_expression_body
	: expression	// All expressions must handle error or current block won't be restored and breaking ast completely
	| block
	| error
	;

expression_or_error
	: expression
	| error
	;
	
lambda_expression
	: IDENTIFIER ARROW 
	  lambda_expression_body
	| AWAIT ARROW
	  lambda_expression_body
	| ASYNC identifier_inside_body ARROW
	  lambda_expression_body
	| OPEN_PARENS_LAMBDA
	  opt_lambda_parameter_list CLOSE_PARENS ARROW 
	  lambda_expression_body
	| ASYNC OPEN_PARENS_LAMBDA
	  opt_lambda_parameter_list CLOSE_PARENS ARROW 
	  lambda_expression_body
	;

expression
	: assignment_expression 
	| non_assignment_expression
	;
	
non_assignment_expression
	: conditional_expression
	| lambda_expression
	| query_expression
	| ARGLIST
	;
	
undocumented_expressions
	: REFVALUE OPEN_PARENS non_assignment_expression COMMA type CLOSE_PARENS
	| REFTYPE open_parens_any expression CLOSE_PARENS
	| MAKEREF open_parens_any expression CLOSE_PARENS
	;

constant_expression
	: expression
	;

boolean_expression
	: expression
	;

//
// 10 classes
//
class_declaration
	: opt_attributes
	  opt_modifiers
	  opt_partial
	  CLASS
	  type_declaration_name
	  opt_class_base
	  opt_type_parameter_constraints_clauses
	  OPEN_BRACE opt_class_member_declarations CLOSE_BRACE
	  opt_semicolon 
	;	

opt_partial
	: /* empty */
	| PARTIAL
	;

opt_modifiers
	: /* empty */
	| modifiers
	;

modifiers
	: modifier
	| modifiers modifier
	;

modifier
	: NEW
	| PUBLIC
	| PROTECTED
	| INTERNAL
	| PRIVATE
	| ABSTRACT
	| SEALED
	| STATIC
	| READONLY
	| VIRTUAL
	| OVERRIDE
	| EXTERN
	| VOLATILE
	| UNSAFE
	| ASYNC
	;
	
opt_class_base
	: /* empty */
	| COLON type_list
	| COLON type_list error
	;

opt_type_parameter_constraints_clauses
	: /* empty */
	| type_parameter_constraints_clauses 
	;

type_parameter_constraints_clauses
	: type_parameter_constraints_clause
	| type_parameter_constraints_clauses type_parameter_constraints_clause
	; 

type_parameter_constraints_clause
	: WHERE IDENTIFIER COLON type_parameter_constraints
	| WHERE IDENTIFIER error
	; 

type_parameter_constraints
	: type_parameter_constraint
	| type_parameter_constraints COMMA type_parameter_constraint
	;

type_parameter_constraint
	: type
	| NEW OPEN_PARENS CLOSE_PARENS
	| CLASS
	| STRUCT
	;

opt_type_parameter_variance
	: /* empty */
	| type_parameter_variance
	;

type_parameter_variance
	: OUT
	| IN
	;

//
// Statements (8.2)
//

//
// A block is "contained" on the following places:
//	method_body
//	property_declaration as part of the accessor body (get/set)
//      operator_declaration
//	constructor_declaration
//	destructor_declaration
//	event_declaration as part of add_accessor_declaration or remove_accessor_declaration
//      
block
	: OPEN_BRACE  
	  opt_statement_list block_end
	;

block_end 
	: CLOSE_BRACE 
	| COMPLETE_COMPLETION
	;


block_prepared
	: OPEN_BRACE
	  opt_statement_list CLOSE_BRACE 
	;

opt_statement_list
	: /* empty */
	| statement_list 
	;

statement_list
	: statement
	| statement_list statement
	;

statement
	: block_variable_declaration
	| valid_declaration_statement
	| labeled_statement
	| error
	;

//
// The interactive_statement and its derivatives are only 
// used to provide a special version of `expression_statement'
// that has a side effect of assigning the expression to
// $retval
//
interactive_statement_list
	: interactive_statement
	| interactive_statement_list interactive_statement
	;

interactive_statement
	: block_variable_declaration
	| interactive_valid_declaration_statement
	| labeled_statement
	;

valid_declaration_statement
        : valid_declaration_statement_1
        | selection_statement
	| iteration_statement
	| lock_statement
	| using_statement
	| fixed_statement
        ;

valid_declaration_statement_1
	: block
	| empty_statement
	| expression_statement
	| jump_statement		  
	| try_statement
	| checked_statement
	| unchecked_statement
	| unsafe_statement
	;

interactive_valid_declaration_statement
	: block
	| empty_statement
        | interactive_expression_statement
        | selection_statement
	| iteration_statement
	| jump_statement		  
	| try_statement
	| checked_statement
	| unchecked_statement
	| lock_statement
	| using_statement
	| unsafe_statement
	| fixed_statement
	;

embedded_statement
	: valid_declaration_statement
	| block_variable_declaration
	| labeled_statement
	| error
	;

embedded_statement_if_else
        : valid_declaration_statement_1
        | block_variable_declaration
        | identifier_inside_body COLON
        ;

empty_statement
	: SEMICOLON
	;

labeled_statement
	: identifier_inside_body COLON 
	  statement
	;

variable_type
	: variable_type_simple
	| variable_type_simple rank_specifiers
	;

/* 
 * The following is from Rhys' grammar:
 * > Types in local variable declarations must be recognized as 
 * > expressions to prevent reduce/reduce errors in the grammar.
 * > The expressions are converted into types during semantic analysis.
 */
/*
 * Krish: Removed alternative 'primary_expression_or_type pointer_stars' to resolve s-r conflict
 */
variable_type_simple
	: primary_expression_or_type opt_nullable 
      /*  | primary_expression_or_type pointer_stars */
	| builtin_types opt_nullable
	| builtin_types pointer_stars
	| VOID pointer_stars
	| VOID
	;
	
pointer_stars
	: pointer_star
	| pointer_star pointer_stars
	;

pointer_star
	: STAR
	;

identifier_inside_body
	: IDENTIFIER
	| AWAIT
	;

block_variable_declaration
	: variable_type identifier_inside_body opt_local_variable_initializer 
          opt_variable_declarators SEMICOLON
	| CONST variable_type identifier_inside_body
	  const_variable_initializer opt_const_declarators SEMICOLON
	;

opt_local_variable_initializer
	: /* empty */
	| ASSIGN block_variable_initializer
	| error
	;

opt_variable_declarators
	: /* empty */
	| variable_declarators
	;
	
opt_using_or_fixed_variable_declarators
	: /* empty */
	| variable_declarators
	;	
	
variable_declarators
	: variable_declarator
	| variable_declarators variable_declarator
	;
	
variable_declarator
	: COMMA identifier_inside_body
	| COMMA identifier_inside_body ASSIGN block_variable_initializer
	;
	
const_variable_initializer
	: /* empty */
	| ASSIGN constant_initializer_expr 
	;
	
opt_const_declarators
	: /* empty */
	| const_declarators
	;
	
const_declarators
	: const_declarator
	| const_declarators const_declarator
	;
	
const_declarator
	: COMMA identifier_inside_body ASSIGN constant_initializer_expr
	;
	
block_variable_initializer
	: variable_initializer
	| STACKALLOC simple_type OPEN_BRACKET_EXPR expression CLOSE_BRACKET
	| STACKALLOC simple_type
	;

expression_statement
	: statement_expression SEMICOLON
	| statement_expression COMPLETE_COMPLETION 
	| statement_expression CLOSE_BRACE
	;

interactive_expression_statement
	: interactive_statement_expression SEMICOLON 
	| interactive_statement_expression COMPLETE_COMPLETION 
	;

	//
	// We have to do the wrapping here and not in the case above,
	// because statement_expression is used for example in for_statement
	//
statement_expression
	: expression
	;

interactive_statement_expression
	: expression
	| error
	;
	
selection_statement
	: if_statement
	| switch_statement
	; 

/*
 * Krish: The rule 'embedded_statement_if_else' is somewhat restrictivei.
 * The originial grammar has embedded_statement. which seems to result 
 * in s-r conflict when seeing 'ELSE' token
 */
if_statement
	: IF open_parens_any boolean_expression CLOSE_PARENS embedded_statement_if_else
	| IF open_parens_any boolean_expression CLOSE_PARENS embedded_statement_if_else 
          ELSE embedded_statement_if_else
	| IF open_parens_any boolean_expression error
	;

switch_statement
	: SWITCH open_parens_any expression CLOSE_PARENS 
          OPEN_BRACE opt_switch_sections CLOSE_BRACE
	| SWITCH open_parens_any expression error
	;

opt_switch_sections
	: /* empty */ 		
	| switch_sections
	;

switch_sections
	: switch_section 
	| switch_sections switch_section
	| error
	;

switch_section
	: switch_labels statement_list 
	;

switch_labels
	: switch_label 
	| switch_labels switch_label 
	;

switch_label
	: CASE constant_expression COLON
	| CASE constant_expression error
	| DEFAULT_COLON
	;

iteration_statement
	: while_statement
	| do_statement
	| for_statement
	| foreach_statement
	;

while_statement
	: WHILE open_parens_any boolean_expression CLOSE_PARENS embedded_statement
	| WHILE open_parens_any boolean_expression error
	;

do_statement
	: DO embedded_statement WHILE open_parens_any boolean_expression CLOSE_PARENS SEMICOLON
	| DO embedded_statement error
	| DO embedded_statement WHILE open_parens_any boolean_expression error
	;

for_statement
	: FOR open_parens_any
	  for_statement_cont
	;
	
// Has to use be extra rule to recover started block
for_statement_cont
	: opt_for_initializer SEMICOLON
	  for_condition_and_iterator_part
	  embedded_statement
	| error
	;

for_condition_and_iterator_part
	: opt_for_condition SEMICOLON for_iterator_part 
	// Handle errors in the case of opt_for_condition being followed by
	// a close parenthesis
	| opt_for_condition close_parens_close_brace 
	;

for_iterator_part
	: opt_for_iterator CLOSE_PARENS 
	| opt_for_iterator CLOSE_BRACE 
	; 

close_parens_close_brace 
	: CLOSE_PARENS
	| CLOSE_BRACE 
	;

opt_for_initializer
	: /* empty */
	| for_initializer	
	;

for_initializer
	: variable_type identifier_inside_body
	  opt_local_variable_initializer opt_variable_declarators
	| statement_expression_list
	;

opt_for_condition
	: /* empty */	
	| boolean_expression
	;

opt_for_iterator
	: /* empty */	
	| for_iterator
	;

for_iterator
	: statement_expression_list
	;

statement_expression_list
	: statement_expression
	| statement_expression_list COMMA statement_expression
	;

foreach_statement
	: FOREACH open_parens_any type error
	| FOREACH open_parens_any type identifier_inside_body error
	| FOREACH open_parens_any type identifier_inside_body IN expression CLOSE_PARENS 
	  embedded_statement
	;

jump_statement
	: break_statement
	| continue_statement
	| goto_statement
	| return_statement
	| throw_statement
	| yield_statement
	;

break_statement
	: BREAK SEMICOLON
	;

continue_statement
	: CONTINUE SEMICOLON
	| CONTINUE error
	;

goto_statement
	: GOTO identifier_inside_body SEMICOLON 
	| GOTO CASE constant_expression SEMICOLON
	| GOTO DEFAULT SEMICOLON 
	; 

return_statement
	: RETURN opt_expression SEMICOLON
	| RETURN expression error
	| RETURN error
	;

throw_statement
	: THROW opt_expression SEMICOLON
	| THROW expression error
	| THROW error
	;

yield_statement 
	: identifier_inside_body RETURN opt_expression SEMICOLON
	| identifier_inside_body RETURN expression error
	| identifier_inside_body BREAK SEMICOLON
	;

opt_expression
	: /* empty */
	| expression
	;

try_statement
	: TRY block catch_clauses
	| TRY block FINALLY block
	| TRY block catch_clauses FINALLY block
	| TRY block error
	;

catch_clauses
	: catch_clause 
	| catch_clauses catch_clause
	;

opt_identifier
	: /* empty */
	| identifier_inside_body
	;

catch_clause 
	: CATCH block
	| CATCH open_parens_any type opt_identifier CLOSE_PARENS block_prepared
	| CATCH open_parens_any error
	| CATCH open_parens_any type opt_identifier CLOSE_PARENS error
	;

checked_statement
	: CHECKED block
	;

unchecked_statement
	: UNCHECKED block
	;

unsafe_statement
	: UNSAFE block 
	;

lock_statement
	: LOCK open_parens_any expression CLOSE_PARENS embedded_statement
	| LOCK open_parens_any expression error
	;

fixed_statement
	: FIXED open_parens_any variable_type identifier_inside_body 
          using_or_fixed_variable_initializer opt_using_or_fixed_variable_declarators 
          CLOSE_PARENS embedded_statement
	;

using_statement
	: USING open_parens_any variable_type identifier_inside_body 
          using_initialization CLOSE_PARENS embedded_statement
	| USING open_parens_any expression CLOSE_PARENS embedded_statement
	| USING open_parens_any expression error
	;
	
using_initialization
	: using_or_fixed_variable_initializer opt_using_or_fixed_variable_declarators
	| error
	;
	
using_or_fixed_variable_initializer
	: /* empty */
	| ASSIGN variable_initializer
	;


// LINQ

query_expression
	: first_from_clause query_body 
	| nested_from_clause query_body

	// Bubble up COMPLETE_COMPLETION productions
	| first_from_clause COMPLETE_COMPLETION 
	| nested_from_clause COMPLETE_COMPLETION 
	;
	
first_from_clause
	: FROM_FIRST identifier_inside_body IN expression
	| FROM_FIRST type identifier_inside_body IN expression
	;

nested_from_clause
	: FROM identifier_inside_body IN expression
	| FROM type identifier_inside_body IN expression
	;
	
from_clause
	: FROM identifier_inside_body IN
	  expression_or_error
	| FROM type identifier_inside_body IN
	  expression_or_error
	;	
/* 
 * author: Krish
 * Introduced query_body_tail (slightly restrictive) to resolve INTO s-r conflict
 */
query_body
        : query_body_clauses  query_body_tail
        | query_body_tail
        | query_body_clauses COMPLETE_COMPLETION
        | query_body_clauses error
        | error
        ;
	
query_body_tail 
        : select_or_group_clause opt_query_continuation
        ;

select_or_group_clause
	: SELECT expression_or_error
	| GROUP expression_or_error BY expression_or_error
	| GROUP expression_or_error error
	;

	
query_body_clauses
	: query_body_clause
	| query_body_clauses query_body_clause
	;
	
query_body_clause
	: from_clause
	| let_clause 
	| where_clause
	| join_clause
	| orderby_clause
	;
	
let_clause
	: LET identifier_inside_body ASSIGN 
	  expression_or_error
	;

where_clause
	: WHERE
	  expression_or_error
	;
	
join_clause
	: JOIN identifier_inside_body IN
	  expression_or_error ON
	  expression_or_error EQUALS
	  expression_or_error opt_join_into
	| JOIN type identifier_inside_body IN
	  expression_or_error ON
	  expression_or_error EQUALS
	  expression_or_error opt_join_into
	;
	
opt_join_into
	: /* empty */
	| INTO identifier_inside_body
	;
	
orderby_clause
	: ORDERBY
	  orderings
	;
	
orderings
	: order_by
	| order_by COMMA
	  orderings_then_by
	;
	
orderings_then_by
	: then_by
	| orderings_then_by COMMA
	 then_by
	;	
	
order_by
	: expression
	| expression ASCENDING
	| expression DESCENDING
	;

then_by
	: expression
	| expression ASCENDING
	| expression DESCENDING
	;

opt_query_continuation
	: INTO identifier_inside_body query_body
        ; 

//
// Support for using the compiler as an interactive parser
//
// The INTERACTIVE_PARSER token is first sent to parse our
// productions;  If the result is a Statement, the parsing
// is repeated, this time with INTERACTIVE_PARSE_WITH_BLOCK
// to setup the blocks in advance.
//
// This setup is here so that in the future we can add 
// support for other constructs (type parsing, namespaces, etc)
// that do not require a block to be setup in advance
//

interactive_parsing
	: EVAL_STATEMENT_PARSER EOF 
	| EVAL_USING_DECLARATIONS_UNIT_PARSER using_directives opt_COMPLETE_COMPLETION
	| EVAL_STATEMENT_PARSER
	  interactive_statement_list opt_COMPLETE_COMPLETION
	| EVAL_COMPILATION_UNIT_PARSER interactive_compilation_unit
	;

interactive_compilation_unit
	: opt_extern_alias_directives opt_using_directives
	| opt_extern_alias_directives opt_using_directives namespace_or_type_declarations
	;

opt_COMPLETE_COMPLETION
	: 
	| COMPLETE_COMPLETION
	;

/*
close_brace_or_complete_completion
	: CLOSE_BRACE
	| COMPLETE_COMPLETION
	;
*/
	
//
// XML documentation code references micro parser
//
documentation_parsing
	: DOC_SEE doc_cref
	;

doc_cref
	: doc_type_declaration_name opt_doc_method_sig
	| builtin_types opt_doc_method_sig
	| builtin_types DOT IDENTIFIER opt_doc_method_sig
	| doc_type_declaration_name DOT THIS
	| doc_type_declaration_name DOT THIS OPEN_BRACKET
	  opt_doc_parameters CLOSE_BRACKET
	| EXPLICIT OPERATOR type opt_doc_method_sig
	| IMPLICIT OPERATOR type opt_doc_method_sig
	| OPERATOR overloadable_operator opt_doc_method_sig
	;
	
doc_type_declaration_name
	: type_declaration_name
	| doc_type_declaration_name DOT type_declaration_name
	;
	
opt_doc_method_sig
	: /* empty */
	| OPEN_PARENS
	  opt_doc_parameters CLOSE_PARENS
	;
	
opt_doc_parameters
	: /* empty */
	| doc_parameters
	;
	
doc_parameters
	: doc_parameter
	| doc_parameters COMMA doc_parameter
	;
	
doc_parameter
	: opt_parameter_modifier parameter_type
	;
	
