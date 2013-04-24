# Copyright (c) 2013 King's College London
# created by Laurence Tratt and Naveneetha Vasudevan
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

import random, string
import sys
from sets import Set
import GrammarInfo


def genSymbols(cfggen, minsize, maxsize):
    # we need one less nonterminal as we have start symbol - root
    n_syms = (cfggen.no_nonterms-1) + cfggen.no_terms
    symbols =  Set()
    while (len(symbols) < (n_syms)):
        sym = ''.join(random.choice(string.uppercase) for x in range(random.randint(minsize,maxsize)))
        symbols.add(sym)
            
    symlist = list(symbols)  
    nonterms,terms = symlist[0:cfggen.no_nonterms-1],symlist[cfggen.no_nonterms-1:]
        
    return nonterms,terms
    
def genLex(cfggen):
    lex_file = cfggen.grammardir + "/lex"
    f_lex = open(lex_file,"w")
    f_lex.write("%{" + "\n")
    f_lex.write('#include "yygrammar.h"' + "\n")
    f_lex.write("%}" + "\n")
    f_lex.write("%%" + "\n")

    for _key in cfggen.lexterms:
        __key = "'" + _key + "'"
        f_lex.write('"' + _key + '"     { return ' + __key + "; }\n")
        
    for _key in cfggen.lexterms_multi.keys():
        f_lex.write('"' + cfggen.lexterms_multi[_key] + '"     { return ' + _key + "; }\n")

    ## these entries should come last in a lex file
    f_lex.write('" "    { /* skip blank */ }\n')
    f_lex.write('\\n     { yypos++; /* adjust linenumber and skip newline */ }' + "\n")
    f_lex.write('\\r     { yypos++; /* adjust linenumber and skip newline */ }' + "\n")
    f_lex.write('.      { yyerror("illegal token"); }' + "\n")
    f_lex.close()
    
    return lex_file
    
    
def write(cfg, cfggen, gf):
    f_cfg = open(gf,"w")
    root_rule = cfg.pop('root')
    f_cfg.write("%token " + ", ".join(cfggen.lexterms_multi.keys()) + ";\n\n")
    f_cfg.write("%nodefault\n\n")
    f_cfg.write("root: " + root_rule + ";\n\n")
    _keys = cfg.keys()
    for key in _keys:
        f_cfg.write(key + ": " + cfg.pop(key) + ";\n\n")
    f_cfg.close()        
    
# filter out: 
# 1) no of alternatives > 5
# 2) X: ''; - empty rules
# 3) percentage of empty alternatives > 5
# 4) X : A | A | Z
# 5) nonterminating type rules: A: B; B: C; C: A
        
def valid(gf, lf):
    import Lexer, CFG
    lex = Lexer.parse(open(lf, "r").read())

    cfg = CFG.parse(lex, open(gf, "r").read())

    totalrules = len(cfg.rules)
    totalalts = 0
    emptyalts = 0
    for rule in cfg.rules:
        n_alts = len(rule.seqs)
        totalalts += n_alts

        if n_alts > 5:
            sys.stdout.write("l>")
            sys.stdout.flush()
            return False            
        
        if n_alts == 1 and len(rule.seqs[0]) == 0:
            sys.stdout.write("e")
            sys.stdout.flush()
            return False
            
        for seq in rule.seqs:
            n_syms = len(seq)
            if n_syms == 0:
                emptyalts += 1          

    if (emptyalts * 1.0)/totalalts > 0.05:
        sys.stdout.write("5")
        sys.stdout.flush()
        return False
                
    # 2
    for rule in cfg.rules:
        seqs_set = Set()
        for seq in rule.seqs:
            seqs_set.add(" ".join(str(x) for x in seq))
                
        if len(rule.seqs) != len(list(seqs_set)):
            sys.stdout.write("a")
            sys.stdout.flush()
            return False
       
    # 3         
    cyclic_rules = GrammarInfo.cyclicInfo(cfg,lex)
    if len(cyclic_rules) > 0:
        sys.stdout.write("c")
        sys.stdout.flush()
        return False
        
        
    return True        
    
if __name__ == "__main__":
    import sys
    gf = sys.argv[1]
    lf = sys.argv[2]
    print gf, lf     
    print valid(gf,lf)
