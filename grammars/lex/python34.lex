%{
#include "yygrammar.h"
%}
%%
","              { return ','; }
"+"              { return '+'; }
"-"              { return '-'; }
"*"              { return '*'; }
"/"              { return '/'; }
"%"              { return '%'; }
"("              { return '('; }
")"              { return ')'; }
">"              { return '>'; }
"<"              { return '<'; }
"{"              { return '{'; }
"}"              { return '}'; }
"["              { return '['; }
"]"              { return ']'; }
"@"              { return '@'; }
"="              { return '='; }
"^"              { return '^'; }
"&"              { return '&'; }
"~"              { return '~'; }
"NEWLINE"              { return NEWLINE; }
"ENDMARKER"              { return ENDMARKER; }
"SC_TK"              { return SC_TK; }
"YIELD_TK"              { return YIELD_TK; }
"FROM_TK"              { return FROM_TK; }
"DEL_TK"              { return DEL_TK; }
"PASS_TK"              { return PASS_TK; }
"BREAK_TK"              { return BREAK_TK; }
"RAISE_TK"              { return RAISE_TK; }
"CONTINUE_TK"              { return CONTINUE_TK; }
"RETURN_TK"              { return RETURN_TK; }
"AS_TK"              { return AS_TK; }
"NAME_TK"              { return NAME_TK; }
"IMPORT_TK"              { return IMPORT_TK; }
"ELLIPSIS_TK"              { return ELLIPSIS_TK; }
"GLOBAL_TK"              { return GLOBAL_TK; }
"NONLOCAL_TK"              { return NONLOCAL_TK; }
"ASSERT_TK"              { return ASSERT_TK; }
"IF_TK"              { return IF_TK; }
"ELSE_TK"              { return ELSE_TK; }
"ELIF_TK"              { return ELIF_TK; }
"OR_TK"              { return OR_TK; }
"AND_TK"              { return AND_TK; }
"NOT_TK"              { return NOT_TK; }
"PIPE_TK"              { return PIPE_TK; }
"LEFTSHIFT_TK"              { return LEFTSHIFT_TK; }
"RIGHTSHIFT_TK"              { return RIGHTSHIFT_TK; }
"DOUBLESLASH_TK"              { return DOUBLESLASH_TK; }
"DOUBLESTAR_TK"              { return DOUBLESTAR_TK; }
"NUMBER_TK"              { return NUMBER_TK; }
"TRUE_TK"              { return TRUE_TK; }
"FALSE_TK"              { return FALSE_TK; }
"STRING_TK"              { return STRING_TK; }
"NONE_TK"              { return NONE_TK; }
"FOR_TK"              { return FOR_TK; }
"IN_TK"              { return IN_TK; }
"INDENT_TK"              { return INDENT_TK; }
"DEDENT_TK"              { return DEDENT_TK; }
"WHILE_TK"              { return WHILE_TK; }
"WITH_TK"              { return WITH_TK; }
"TRY_TK"              { return TRY_TK; }
"EXCEPT_TK"              { return EXCEPT_TK; }
"FINALLY_TK"              { return FINALLY_TK; }
"DEF_TK"              { return DEF_TK; }
"CLASS_TK"              { return CLASS_TK; }
"FWDARROW_TK"              { return FWDARROW_TK; }
"LAMBDA_TK"              { return LAMBDA_TK; }
"EQ_TK"              { return EQ_TK; }
"GE_TK"              { return GE_TK; }
"IS_TK"              { return IS_TK; }
"LE_TK"              { return LE_TK; }
"NOTEQ_TK"              { return NOTEQ_TK; }
"NOTEQ2_TK"              { return NOTEQ2_TK; }
"PLUS_ASSIGN_TK"              { return PLUS_ASSIGN_TK; }
"MINUS_ASSIGN_TK"              { return MINUS_ASSIGN_TK; }
"MULT_ASSIGN_TK"              { return MULT_ASSIGN_TK; }
"DIV_ASSIGN_TK"              { return DIV_ASSIGN_TK; }
"MOD_ASSIGN_TK"              { return MOD_ASSIGN_TK; }
"AND_ASSIGN_TK"              { return AND_ASSIGN_TK; }
"OR_ASSIGN_TK"              { return OR_ASSIGN_TK; }
"XOR_ASSIGN_TK"              { return XOR_ASSIGN_TK; }
"LSHIFT_ASSIGN_TK"              { return LSHIFT_ASSIGN_TK; }
"RSHIFT_ASSIGN_TK"              { return RSHIFT_ASSIGN_TK; }
"EXP_ASSIGN_TK"              { return EXP_ASSIGN_TK; }
"DIV2_ASSIGN_TK"              { return DIV2_ASSIGN_TK; }
"DOT_TK"              { return DOT_TK; }
"COLON_TK"              { return COLON_TK; }
\r               { yypos++; /* adjust linenumber and skip newline */ }
\n               { yypos++; /* adjust linenumber and skip newline */ }
.                { printf("\n++ illegal token : %s ++", yytext); yyerror("illegal xyz token"); }
