%{
#include "yygrammar.h"
%}
%%
","      { return ','; }
"+"      { return '+'; }
"-"      { return '-'; }
"*"      { return '*'; }
"/"      { return '/'; }
"("      { return '('; }
")"      { return ')'; }
"into"      { return INTO; }
"1"     { return INTEGER; }
"precision"      { return PRECISION; }
"varchar"      { return VARCHAR; }
">="      { return COMPARISON_OPERATOR; }
"ttable"      { return TTABLE; }
"null_value"      { return NULL_VALUE; }
"by"      { return BY; }
"column"      { return COLUMN; }
"="      { return EQUAL; }
"a_String"      { return STRING; }
"0.01"      { return DOUBLE; }
"2"      { return INT; }
"aname"      { return NAME; }
"update"      { return UPDATE; }
"where"      { return WHERE; }
"set"      { return SET; }
"add"      { return ADD; }
"select"     { return SELECT; }
"create"     { return CREATE; }
"insert"     { return INSERT; }
"12"      { return INTNUM; }
"and"      { return AND; }
"alter"      { return ALTER; }
"not"      { return NOT; }
"drop"      { return DROP; }
"date"      { return DATE; }
"order"      { return ORDER; }
"delete"     { return DELETE; }
"10.01"      { return FLOATNUM; }
"from"      { return FROM; }
"is"      { return IS; }
"or"      { return OR; }
"values"      { return VALUES; }
" "        { /* skip blank */ }
\r         { yypos++; /* adjust linenumber and skip newline */ }
\n         { yypos++; /* adjust linenumber and skip newline */ }
.          { printf("\n++ illegal token : %s ++", yytext); yyerror("illegal xyz token"); }
