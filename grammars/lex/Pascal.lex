%{
#include "yygrammar.h"
%}
%%
","         { return ','; }
"+"         { return '+'; }
"-"         { return '-'; }
"*"         { return '*'; }
"/"         { return '/'; }
"("         { return '('; }
")"         { return ')'; }
"."         { return '.'; }
";"         { return ';'; }
":"         { return ':'; }
"^"         { return '^'; }
"["         { return '['; }
"]"         { return ']'; }
"="         { return '='; }
"<"         { return '<'; }
">"         { return '>'; }
".."          { return DOTDOT; }
">="          { return GE; }
"_if"          { return IF; }
"_then"          { return THEN; }
"_downto"          { return DOWNTO; }
"_repeat"          { return REPEAT; }
"_function"          { return FUNCTION; }
"_of"          { return OF; }
"_begin"          { return SBEGIN; }
"_label"          { return LABEL; }
"aString"          { return STRING; }
"_while"          { return WHILE; }
"_record"          { return RECORD; }
"_sfile"          { return SFILE; }
"_do"          { return DO; }
"_var"          { return VAR; }
"_with"          { return WITH; }
"1"          { return UNSIGNED_INT; }
"_const"          { return CONST; }
"_set"          { return SET; }
"_until"          { return UNTIL; }
"_to"          { return TO; }
"_end"          { return END; }
"_type"          { return TYPE; }
"<="          { return LE; }
"_else"          { return ELSE; }
"_array"          { return ARRAY; }
"_packed"          { return PACKED; }
"!="          { return NE; }
"_and"          { return AND; }
"_not"          { return NOT; }
"_procedure"          { return PROCEDURE; }
"_div"          { return DIV; }
"_nil"          { return NIL; }
"_case"          { return CASE; }
"_becomes"          { return BECOMES; }
"abcd"          { return IDENTIFIER; }
"_for"          { return FOR; }
"1.0"          { return UNSIGNED_REAL; }
"_in"          { return IN; }
"_program"          { return PROGRAM; }
"_or"          { return OR; }
"_goto"          { return GOTO; }
"_mod"          { return MOD; }
" "         { /* skip blank */ }
\r          { yypos++; /* adjust linenumber and skip newline */ }
\n          { yypos++; /* adjust linenumber and skip newline */ }
.           { printf("\n++ illegal token : %s ++", yytext); yyerror("illegal xyz token"); }
