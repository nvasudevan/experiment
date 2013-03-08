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

def uniqSymbols(n_syms):
    symbols =  Set()
    # we need one less nonterminal as we have start symbol - root
    while (len(symbols) < (n_syms)):
        sym = ''.join(random.choice(string.uppercase) for x in range(random.randint(2,5)))
        symbols.add(sym)

    return list(symbols)


def genSymbols(sym_type, n_nonterms, n_terms):
    if sym_type == "short":
        # one of the nonterminal will be 'root'. so we need one less
        nonterms = random.sample(string.uppercase,n_nonterms-1)
        terms = random.sample(string.lowercase,n_terms)
    else:
        # we need one less nonterminal as we have start symbol - root
        symlist = uniqSymbols((n_nonterms-1) + n_terms)  
        nonterms,terms = symlist[0:n_nonterms-1],symlist[n_nonterms-1:]
        
    return nonterms,terms
    
def genLex(terms_map, grammardir):
    lex_file = grammardir + "/lex"
    f_lex = open(lex_file,"w")
    f_lex.write("%{" + "\n")
    f_lex.write('#include "yygrammar.h"' + "\n")
    f_lex.write("%}" + "\n")
    f_lex.write("%%" + "\n")
    f_lex.write('" "    { /* skip blank */ }\n')
    f_lex.write('\\n     { yypos++; /* adjust linenumber and skip newline */ }' + "\n")
    f_lex.write('\\r     { yypos++; /* adjust linenumber and skip newline */ }' + "\n")
    f_lex.write('.      { yyerror("illegal token"); }' + "\n")
    for key in terms_map.keys():
        f_lex.write('"' + terms_map[key] + '"     { return ' + key + "; }\n")
    f_lex.close()
    
    return lex_file
    
    
def write(rulesd, terms_map, gf):
    cfg = open(gf,"w")
    root_rule = rulesd.pop('root')
    cfg.write("%token " + ", ".join(terms_map.keys()) + ";\n\n")
    cfg.write("%nodefault\n\n")
    cfg.write("root: " + root_rule + ";\n")
    _keys = rulesd.keys()
    for key in _keys:
        cfg.write(key + ": " + rulesd.pop(key) + ";\n")
    cfg.close()        
    
    
def valid(gf, lf):
    import Lexer, CFG
    lex = Lexer.parse(open(lf, "r").read())
    # filter out: 1) root: ''; 2) X : A | A
    # 3) X: ''; - empty rules
    cfg = CFG.parse(lex, open(gf, "r").read())
    #print "CFG:\n%s\n" % cfg
    root_rule = cfg.get_rule('root')
    if len(root_rule.seqs) == 1 and len(root_rule.seqs[0]) == 0:
        print "empty root rule \n"
        return False
         
    for rule in cfg.rules:
        seqs_set = Set()
        for seq in rule.seqs:
            seqs_set.add(" ".join(str(x) for x in seq))
                
        if len(rule.seqs) != len(list(seqs_set)):
            print "[duplicate] %s : %s \n" % (rule.name,seqs_set)
            return False
                
    for rule in cfg.rules:
        if (len(rule.seqs) == 1) and len(rule.seqs[0]) == 0:
            print "*EMPTY* " , rule
            return False
             
    return True        
