%{
#include "yygrammar.h"
%}
%%
" "    { /* skip blank */ }
\n     { yypos++; /* adjust linenumber and skip newline */ }
\r     { yypos++; /* adjust linenumber and skip newline */ }
.      { yyerror("illegal token"); }
"VECI"     { return TK_VECI; }
"NWKJD"     { return TK_NWKJD; }
"ZV"     { return TK_ZV; }
"LS"     { return TK_LS; }
"GZTS"     { return TK_GZTS; }
"QZSG"     { return TK_QZSG; }
"FYILM"     { return TK_FYILM; }
"EP"     { return TK_EP; }
"OOQON"     { return TK_OOQON; }
"KU"     { return TK_KU; }
