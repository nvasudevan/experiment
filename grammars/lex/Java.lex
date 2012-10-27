%{
#include "yygrammar.h"
%}
%%
"_public"            { return MODIFIER_TK; }
"interface"            { return INTERFACE_TK; }
"_rem"            { return REM_TK; }
"!="            { return NEQ_TK; }
"_super"            { return SUPER_TK; }
"_if"            { return IF_TK; }
"_break"            { return BREAK_TK; }
"_default"            { return DEFAULT_TK; }
"0.0"            { return FP_LIT_TK; }
"_or"            { return OR_TK; }
"_finally"            { return FINALLY_TK; }
"_import"            { return IMPORT_TK; }
"_for"            { return FOR_TK; }
"_dot"            { return DOT_TK; }
"a"            { return CHAR_LIT_TK; }
"rel_cl"            { return REL_CL_TK; }
"="            { return ASSIGN_TK; }
"-"            { return MINUS_TK; }
"_sc_tk"            { return SC_TK; }
">>"            { return SRS_TK; }
"++"            { return INCR_TK; }
"||"            { return BOOL_OR_TK; }
"_class"            { return CLASS_TK; }
"_else"            { return ELSE_TK; }
"+"            { return PLUS_TK; }
"<="            { return LTE_TK; }
"_this"            { return THIS_TK; }
"rel_qm"            { return REL_QM_TK; }
"_true"            { return BOOL_LIT_TK; }
"package"            { return PACKAGE_TK; }
"<<"            { return LS_TK; }
"1"            { return INT_LIT_TK; }
"_null"            { return NULL_TK; }
"aString"            { return STRING_LIT_TK; }
"_do"            { return DO_TK; }
"_throws"            { return THROWS_TK; }
"_neg"            { return NEG_TK; }
">="            { return GTE_TK; }
">>>"            { return ZRS_TK; }
"_catch"            { return CATCH_TK; }
"_try"            { return TRY_TK; }
"abcd"            { return ID_TK; }
"+="            { return ASSIGN_ANY_TK; }
"_new"            { return NEW_TK; }
"("            { return OP_TK; }
"_throw"            { return THROW_TK; }
"_assert"            { return ASSERT_TK; }
"_continue"            { return CONTINUE_TK; }
"<"            { return LT_TK; }
"_boolean"            { return BOOLEAN_TK; }
"_float"            { return FP_TK; }
">"            { return GT_TK; }
")"            { return CP_TK; }
"/"            { return DIV_TK; }
"]"            { return CSB_TK; }
"!"            { return NOT_TK; }
"_void"            { return VOID_TK; }
"_and"            { return AND_TK; }
"extends"            { return EXTENDS_TK; }
"^"            { return XOR_TK; }
"["            { return OSB_TK; }
"&&"            { return BOOL_AND_TK; }
"}"            { return CCB_TK; }
","            { return C_TK; }
"=="            { return EQ_TK; }
"instanceof"            { return INSTANCEOF_TK; }
"_int"            { return INTEGRAL_TK; }
"{"            { return OCB_TK; }
"*"            { return MULT_TK; }
"--"            { return DECR_TK; }
"implements"            { return IMPLEMENTS_TK; }
"_Return"            { return RETURN_TK; }
"_case"            { return CASE_TK; }
"_while"            { return WHILE_TK; }
"_swithch"            { return SWITCH_TK; }
" "         { /* skip blank */ }
\r          { yypos++; /* adjust linenumber and skip newline */ }
\n          { yypos++; /* adjust linenumber and skip newline */ }
.           { printf("\n++ illegal token : %s ++", yytext); yyerror("illegal xyz token"); }
