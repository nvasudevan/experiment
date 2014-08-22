
%token	LLITERAL
%token	LASOP LCOLAS
%token	LBREAK LCASE LCHAN LCONST LCONTINUE LDDD
%token	LDEFAULT LDEFER LELSE LFALL LFOR LFUNC LGO LGOTO
%token	LIF LIMPORT LINTERFACE LMAP LNAME
%token	LPACKAGE LRANGE LRETURN LSELECT LSTRUCT LSWITCH
%token	LTYPE LVAR

%token	LANDAND LANDNOT LBODY LCOMM LDEC LEQ LGE LGT
%token	LIGNORE LINC LLE LLSH LLT LNE LOROR LRSH

%token		NotParen
%token		'('

%%
file:
	loadsys
	package
	imports
	xdcl_list
;

package:
|	LPACKAGE sym ';'
;

loadsys:
	import_package
	import_there
;

imports:
|	imports import ';'
;

import:
	LIMPORT import_stmt
|	LIMPORT '(' import_stmt_list osemi ')'
|	LIMPORT '(' ')'
;

import_stmt:
	import_here import_package import_there
|	import_here import_there
;

import_stmt_list:
	import_stmt
|	import_stmt_list ';' import_stmt
;

import_here:
	LLITERAL
|	sym LLITERAL
|	'.' LLITERAL
;

import_package:
	LPACKAGE LNAME import_safety ';'
;

import_safety:
|	LNAME
;

import_there:
	hidden_import_list '$' '$'
;

xdcl:
|	common_dcl
|	xfndcl
|	non_dcl_stmt
|	error
;

common_dcl:
	LVAR vardcl
|	LVAR '(' vardcl_list osemi ')'
|	LVAR '(' ')'
|	lconst constdcl
|	lconst '(' constdcl osemi ')'
|	lconst '(' constdcl ';' constdcl_list osemi ')'
|	lconst '(' ')'
|	LTYPE typedcl
|	LTYPE '(' typedcl_list osemi ')'
|	LTYPE '(' ')'
;

lconst:
	LCONST
;

vardcl:
	dcl_name_list ntype
|	dcl_name_list ntype '=' expr_list
|	dcl_name_list '=' expr_list
;

constdcl:
	dcl_name_list ntype '=' expr_list
|	dcl_name_list '=' expr_list
;

constdcl1:
	constdcl
|	dcl_name_list ntype
|	dcl_name_list
;

typedclname:
	sym
;

typedcl:
	typedclname ntype
;

simple_stmt:
	expr
|	expr LASOP expr
|	expr_list '=' expr_list
|	expr_list LCOLAS expr_list
|	expr LINC
|	expr LDEC
;

case:
	LCASE expr_or_type_list ':'
|	LCASE expr_or_type_list '=' expr ':'
|	LCASE expr_or_type_list LCOLAS expr ':'
|	LDEFAULT ':'
;

compound_stmt: '{' stmt_list '}'
;

caseblock:
	case
	stmt_list
;

caseblock_list:
|	caseblock_list caseblock
;

loop_body:
	LBODY
	stmt_list '}'
;

range_stmt:
	expr_list '=' LRANGE expr
|	expr_list LCOLAS LRANGE expr
;

for_header:
	osimple_stmt ';' osimple_stmt ';' osimple_stmt
|	osimple_stmt
|	range_stmt
;

for_body:
	for_header loop_body
;

for_stmt:
	LFOR
	for_body
;

if_header:
	osimple_stmt
|	osimple_stmt ';' osimple_stmt
;

if_stmt:
	LIF
	if_header
	loop_body
	elseif_list else
;

elseif:
	LELSE LIF 
	if_header loop_body
;

elseif_list:
|	elseif_list elseif
;

else:
|	LELSE compound_stmt
;

switch_stmt:
	LSWITCH
	if_header
	LBODY caseblock_list '}'
;

select_stmt:
	LSELECT
	LBODY caseblock_list '}'
;

expr: 
    uexpr
|   uexpr_prefix expr
;
    
uexpr_prefix:
    uexpr_plus | uexpr_multi | uexpr_div | uexpr_subtract | uexpr_power
    | uexpr_and | uexpr_or | uexpr_mod | uexpr_lcomm
    | uexpr_llsh | uexpr_lrsh | uexpr_landnot
    | uexpr_loror | uexpr_landand
    | uexpr_leq | uexpr_lne | uexpr_llt | uexpr_lle | uexpr_lge | uexpr_lgt
;

uexpr_plus:
    uexpr '+'
;

uexpr_subtract:
    uexpr '-'
;

uexpr_power:
    uexpr '^'
;

uexpr_multi:
    uexpr '*'
;

uexpr_div:
    uexpr '/'
;

uexpr_mod:
    uexpr '%'
;

uexpr_or:
    uexpr '|'
;

uexpr_and:
    uexpr '&'
;

uexpr_lcomm:
    uexpr LCOMM
;

uexpr_llsh:
    uexpr LLSH
;

uexpr_lrsh:
    uexpr LRSH
;

uexpr_landnot:
    uexpr LANDNOT
;

uexpr_loror:
    uexpr LOROR
;

uexpr_landand:
    uexpr LANDAND
;

uexpr_leq:
    uexpr LEQ
;

uexpr_lne:
    uexpr LNE
;

uexpr_llt:
    uexpr LLT
;

uexpr_lle:
    uexpr LLE
;

uexpr_lge:
    uexpr LGE
;

uexpr_lgt:
    uexpr LGT
;

uexpr:
	pexpr
|	'*' uexpr
|	'&' uexpr
|	'+' uexpr
|	'-' uexpr
|	'!' uexpr
|	'~' uexpr
|	'^' uexpr
|	LCOMM uexpr
;

pseudocall:
	pexpr '(' ')'
|	pexpr '(' expr_or_type_list ocomma ')'
|	pexpr '(' expr_or_type_list LDDD ocomma ')'
;

pexpr_no_paren:
	LLITERAL
|	name
|	pexpr '.' sym
|	pexpr '.' '(' expr_or_type ')'
|	pexpr '.' '(' LTYPE ')'
|	pexpr '[' expr ']'
|	pexpr '[' oexpr ':' oexpr ']'
|	pseudocall
|	convtype '(' expr ocomma ')'
|	comptype lbrace start_complit braced_keyval_list '}'
|	pexpr_no_paren '{' start_complit braced_keyval_list '}'
|	'(' expr_or_type ')' '{' start_complit braced_keyval_list '}'
|	fnliteral
;

start_complit:
;

keyval:
	expr ':' complitexpr
;

bare_complitexpr:
	expr
|	'{' start_complit braced_keyval_list '}'
;

complitexpr:
	expr
|	'{' start_complit braced_keyval_list '}'
;

pexpr:
	pexpr_no_paren
|	'(' expr_or_type ')'
;

expr_or_type:
	expr
|	non_expr_type 
;

name_or_type:
	ntype
;

lbrace:
	LBODY
|	'{'
;

new_name:
	sym
;

dcl_name:
	sym
;

onew_name:
|	new_name
;

sym:
	LNAME
|	hidden_importsym
|	'?'
;

hidden_importsym:
	'@' LLITERAL '.' LNAME
;

name:
	sym NotParen
;

labelname:
	new_name
;

dotdotdot:
	LDDD
|	LDDD ntype
;

ntype:
	recvchantype
|	fntype
|	othertype
|	ptrtype
|	dotname
|	'(' ntype ')'
;

non_expr_type:
	recvchantype
|	fntype
|	othertype
|	'*' non_expr_type
;

non_recvchantype:
	fntype
|	othertype
|	ptrtype
|	dotname
|	'(' ntype ')'
;

convtype:
	fntype
|	othertype
;

comptype:
	othertype
;

fnret_type:
	recvchantype
|	fntype
|	othertype
|	ptrtype
|	dotname
;

dotname:
	name
|	name '.' sym
;

othertype:
	'[' oexpr ']' ntype
|	'[' LDDD ']' ntype
|	LCHAN non_recvchantype
|	LCHAN LCOMM ntype
|	LMAP '[' ntype ']' ntype
|	structtype
|	interfacetype
;

ptrtype:
	'*' ntype
;

recvchantype:
	LCOMM LCHAN ntype
;

structtype:
	LSTRUCT lbrace structdcl_list osemi '}'
|	LSTRUCT lbrace '}'
;

interfacetype:
	LINTERFACE lbrace interfacedcl_list osemi '}'
|	LINTERFACE lbrace '}'
;

xfndcl:
	LFUNC fndcl fnbody
;

fndcl:
	sym '(' oarg_type_list_ocomma ')' fnres
|	'(' oarg_type_list_ocomma ')' sym '(' oarg_type_list_ocomma ')' fnres
;

hidden_fndcl:
	hidden_pkg_importsym '(' ohidden_funarg_list ')' ohidden_funres
|	'(' hidden_funarg_list ')' sym '(' ohidden_funarg_list ')' ohidden_funres
;

fntype:
	LFUNC '(' oarg_type_list_ocomma ')' fnres
;

fnbody:
|	'{' stmt_list '}'
;

fnres:
	NotParen
|	fnret_type
|	'(' oarg_type_list_ocomma ')'
;

fnlitdcl:
	fntype
;

fnliteral:
	fnlitdcl lbrace stmt_list '}'
|	fnlitdcl error
;

xdcl_list:
|	xdcl_list xdcl ';'
;

vardcl_list:
	vardcl
|	vardcl_list ';' vardcl
;

constdcl_list:
	constdcl1
|	constdcl_list ';' constdcl1
;

typedcl_list:
	typedcl
|	typedcl_list ';' typedcl
;

structdcl_list:
	structdcl
|	structdcl_list ';' structdcl
;

interfacedcl_list:
	interfacedcl
|	interfacedcl_list ';' interfacedcl
;

structdcl:
	new_name_list ntype oliteral
|	embed oliteral
|	'(' embed ')' oliteral
|	'*' embed oliteral
|	'(' '*' embed ')' oliteral
|	'*' '(' embed ')' oliteral
;

packname:
	LNAME
|	LNAME '.' sym
;

embed:
	packname
;

interfacedcl:
	new_name indcl
|	packname
|	'(' packname ')'
;

indcl:
	'(' oarg_type_list_ocomma ')' fnres
;

arg_type:
	name_or_type
|	sym name_or_type
|	sym dotdotdot
|	dotdotdot
;

arg_type_list:
	arg_type
|	arg_type_list ',' arg_type
;

oarg_type_list_ocomma:
|	arg_type_list ocomma
;

/*
 * statement
 */
stmt:
|	compound_stmt
|	common_dcl
|	non_dcl_stmt
|	error
;

non_dcl_stmt:
	simple_stmt
|	for_stmt
|	switch_stmt
|	select_stmt
|	if_stmt
|	labelname ':'
	stmt
|	LFALL
|	LBREAK onew_name
|	LCONTINUE onew_name
|	LGO pseudocall
|	LDEFER pseudocall
|	LGOTO new_name
|	LRETURN oexpr_list
;

stmt_list:
	stmt
|	stmt_list ';' stmt
;

new_name_list:
	new_name
|	new_name_list ',' new_name
;

dcl_name_list:
	dcl_name
|	dcl_name_list ',' dcl_name
;

expr_list:
	expr
|	expr_list ',' expr
;

expr_or_type_list:
	expr_or_type
|	expr_or_type_list ',' expr_or_type
;

/*
 * list of combo of keyval and val
 */
keyval_list:
	keyval
|	bare_complitexpr
|	keyval_list ',' keyval
|	keyval_list ',' bare_complitexpr
;

braced_keyval_list:
|	keyval_list ocomma
;

/*
 * optional things
 */
osemi:
|	';'
;

ocomma:
|	','
;

oexpr:
|	expr
;

oexpr_list:
|	expr_list
;

osimple_stmt:
|	simple_stmt
;

ohidden_funarg_list:
|	hidden_funarg_list
;

ohidden_structdcl_list:
|	hidden_structdcl_list
;

ohidden_interfacedcl_list:
|	hidden_interfacedcl_list
;

oliteral:
|	LLITERAL
;

/*
 * import syntax from package header
 */
hidden_import:
	LIMPORT LNAME LLITERAL ';'
|	LVAR hidden_pkg_importsym hidden_type ';'
|	LCONST hidden_pkg_importsym '=' hidden_constant ';'
|	LCONST hidden_pkg_importsym hidden_type '=' hidden_constant ';'
|	LTYPE hidden_pkgtype hidden_type ';'
|	LFUNC hidden_fndcl fnbody ';'
;

hidden_pkg_importsym:
	hidden_importsym
;

hidden_pkgtype:
	hidden_pkg_importsym
;

/*
 *  importing types
 */

hidden_type:
	hidden_type_misc
|	hidden_type_recv_chan
|	hidden_type_func
;

hidden_type_non_recv_chan:
	hidden_type_misc
|	hidden_type_func
;

hidden_type_misc:
	hidden_importsym
|	LNAME
|	'[' ']' hidden_type
|	'[' LLITERAL ']' hidden_type
|	LMAP '[' hidden_type ']' hidden_type
|	LSTRUCT '{' ohidden_structdcl_list '}'
|	LINTERFACE '{' ohidden_interfacedcl_list '}'
|	'*' hidden_type
|	LCHAN hidden_type_non_recv_chan
|	LCHAN '(' hidden_type_recv_chan ')'
|	LCHAN LCOMM hidden_type
;

hidden_type_recv_chan:
	LCOMM LCHAN hidden_type
;

hidden_type_func:
	LFUNC '(' ohidden_funarg_list ')' ohidden_funres
;

hidden_funarg:
	sym hidden_type oliteral
|	sym LDDD hidden_type oliteral
;

hidden_structdcl:
	sym hidden_type oliteral
;

hidden_interfacedcl:
	sym '(' ohidden_funarg_list ')' ohidden_funres
|	hidden_type
;

ohidden_funres:
|	hidden_funres
;

hidden_funres:
	'(' ohidden_funarg_list ')'
|	hidden_type
;

/*
 *  importing constants
 */

hidden_literal:
	LLITERAL
|	'-' LLITERAL
|	sym
;

hidden_constant:
	hidden_literal
|	'(' hidden_literal '+' hidden_literal ')'
;

hidden_import_list:
|	hidden_import_list hidden_import
;

hidden_funarg_list:
	hidden_funarg
|	hidden_funarg_list ',' hidden_funarg
;

hidden_structdcl_list:
	hidden_structdcl
|	hidden_structdcl_list ';' hidden_structdcl
;

hidden_interfacedcl_list:
	hidden_interfacedcl
|	hidden_interfacedcl_list ';' hidden_interfacedcl
;

