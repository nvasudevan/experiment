%{
#include "yygrammar.h"
%}
%%
","              { return ','; }
"+"              { return '+'; }
"-"              { return '-'; }
"*"              { return '*'; }
"/"              { return '/'; }
"{"              { return '{'; }
"}"              { return '}'; }
">"              { return '>'; }
"["              { return '['; }
"]"              { return ']'; }
"="              { return '='; }
":"              { return COLON_TK; }
"@charset"       { return CHARSET_SYM; }
"a_string"       { return STRING; }
";"              { return SC_TK; }
"<!--"		     { return CDO;}
"-->"			 { return CDC;}
"_s"			 { return S;}
"@import"        { return IMPORT_SYM; }
"@media"         { return MEDIA_SYM; }
"url(a_string)"  { return URI; }
"@page"          { return PAGE_SYM; }
"abcd"           { return IDENT; }
"#hashstring"    { return HASH; }
"!important"     { return IMPORTANT_SYM; }
"100.01em"		 { return EMS;}
"100.01ex" 	     { return EXS;}
"100.01px"		 { return LENGTH;}
"100.01deg"		 { return ANGLE;}
"100.01ms"		 { return TIME;}
"100.01khz"		 { return FREQ;}
"100.01%"	     { return PERCENTAGE;}
"100.01"		 { return NUMBER;}
"_function("	 { return FUNCTION;}
"~="			 { return INCLUDES;}
"|="		     { return DASHMATCH;}
" "         { /* skip blank */ }
\r               { yypos++; /* adjust linenumber and skip newline */ }
\n               { yypos++; /* adjust linenumber and skip newline */ }
.                { printf("\n++ illegal token : %s ++", yytext); yyerror("illegal xyz token"); }
