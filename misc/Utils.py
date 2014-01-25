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

def splitLex(terms):
    lexterms, lexterms_multi = [],{}
    for _term in terms:
        if len(_term) == 1:
            lexterms.append(_term)
        else:
            lexterms_multi['TK_' + _term] = _term
            
    return lexterms, lexterms_multi
    
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
    
    
def write(cfg, tokenlist, gf):
    f_cfg = open(gf,"w")
    root_rule = cfg.pop('root')
    f_cfg.write("%token " + ", ".join(tokenlist) + ";\n\n")
    f_cfg.write("%nodefault\n\n")
    f_cfg.write("root: " + root_rule + ";\n\n")
    _keys = cfg.keys()
    for key in _keys:
        f_cfg.write(key + ": " + cfg.pop(key) + ";\n\n")
    f_cfg.close()        

def verticalamb(cfg):
    """ Check for vertical ambiguity """
    for rule in cfg.rules:
        seqs_set = Set()
        for seq in rule.seqs:
            seqs_set.add(" ".join(str(x) for x in seq))
                
        if len(rule.seqs) != len(list(seqs_set)):
            return True     
    
    return False


def cyclicamb(cfg):
    """ Check for cyclic ambiguity"""
    for rule in cfg.rules:
        for seq in rule.seqs:
            if len(seq) == 1:
                if str(rule.name) == str(seq[0]):
                    print "rule: " , rule
                    return True
        
    return False
    

def ambiguous(cfg):
    """ Checks if the rule is ambiguous:
        a) X : A | A | Z
        b) A: A """
    
    # (a)
    if verticalamb(cfg):
        return True
    
    # (b) - to be done
    if cyclicamb(cfg):
        return True
    
    return False

    
def unproductive(cfg, lex):
    """ Checks if the grammar is unproductive.
        Grammar is unproductive if it contains rules of the type:
        A: B; B: C; C: A """
    unproductive_rules = GrammarInfo.cyclicInfo(cfg,lex)
    if len(unproductive_rules) > 0:
        return True
        
        
def valid(gf, lf, maxalts_allowed, emptyalts_ratio, max_alt_length):
    """ Checks if the generated grammar is valid. That is:
        a) number of alternative for a rule < X
        b) contains no empty rules (so A: ;)
        c) %age of empty alternatives < Y """
       
    import Lexer, CFG
    lex = Lexer.parse(open(lf, "r").read())
    cfg = CFG.parse(lex, open(gf, "r").read())

    totalrules = len(cfg.rules)
    totalalts = 0
    emptyalts = 0
    for rule in cfg.rules:
        n_alts = len(rule.seqs)
        totalalts += n_alts

        if n_alts > maxalts_allowed:
            sys.stdout.write("n>")
            sys.stdout.flush()
            return False            
        
        if n_alts == 1 and len(rule.seqs[0]) == 0:
            sys.stdout.write("e")
            sys.stdout.flush()
            return False
            
        for seq in rule.seqs:
            n_syms = len(seq)
            if n_syms > max_alt_length:
                sys.stdout.write("l>")
                sys.stdout.flush()
                return False
                
            if n_syms == 0:
                emptyalts += 1          

    if (emptyalts * 1.0)/totalalts > emptyalts_ratio:
        sys.stdout.write(">%s" % str(emptyalts_ratio))
        sys.stdout.flush()
        return False

    # Check if the grammar is unproductive        
    if unproductive(cfg,lex):
        sys.stdout.write("u")
        sys.stdout.flush()    
        return False
                        
    # Check the grammar for trivial ambiguities
    if ambiguous(cfg):
        sys.stdout.write("a")
        sys.stdout.flush()
        return False
        
    return True        
    
if __name__ == "__main__":
    import sys
    gf = sys.argv[1]
    lf = sys.argv[2]
    print gf, lf     
    print valid(gf,lf,5,0.05,7)
