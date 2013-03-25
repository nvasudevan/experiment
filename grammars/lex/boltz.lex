%{
#include "yygrammar.h"
%}
%%
" "    { /* skip blank */ }
\n     { yypos++; /* adjust linenumber and skip newline */ }
\r     { yypos++; /* adjust linenumber and skip newline */ }
.      { yyerror("illegal token"); }
"SRLN"     { return TK_SRLN; }
"WAOE"     { return TK_WAOE; }
"WJM"     { return TK_WJM; }
"SZ"     { return TK_SZ; }
"XL"     { return TK_XL; }
"QQN"     { return TK_QQN; }
"JPEXV"     { return TK_JPEXV; }
"GDOL"     { return TK_GDOL; }
"QKIA"     { return TK_QKIA; }
"KDV"     { return TK_KDV; }
"PML"     { return TK_PML; }
"IL"     { return TK_IL; }
"HMKX"     { return TK_HMKX; }
"NPI"     { return TK_NPI; }
"UND"     { return TK_UND; }
