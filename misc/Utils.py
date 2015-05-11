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
import Lexer, CFG


def max_no_alts(cfg):
    n = 0
    for rule in cfg.rules:
        l = len(rule.seqs)
        if l > n:
            n = l

    return n


def sym_tokens(gp):
    gf = open(gp, "r")
    lines = gf.readlines()
    gf.close()

    for l in lines:
        if l.startswith("%token"):
            return l[6:l.index(";")].replace(" ","").split(",")

    return []


def cfg_header(gp):
    gf = open(gp, "r")
    lines = gf.readlines()
    gf.close()

    header = "%nodefault\n\n"
    for l in lines:
        if l.startswith("%token"):
            header = "{0}\n%nodefault\n\n".format(l)
            return header

    return header


def genSymbols(cfggen, minsize, maxsize):
    # we need one less nonterminal as we have start symbol - root
    n_syms = (cfggen.no_nonterms-1) + cfggen.no_terms
    symbols =  Set()
    while (len(symbols) < (n_syms)):
        size = random.randint(minsize,maxsize)
        sym = ''.join(random.choice(string.uppercase) for x in range(size))
        symbols.add(sym)
            
    symlist = list(symbols)  
    nonterms = symlist[0:cfggen.no_nonterms-1]
    terms = symlist[cfggen.no_nonterms-1:]
        
    return nonterms,terms


def splitLex(terms):
    lexterms, lexterms_multi = [],{}
    for t in terms:
        if len(t) == 1:
            lexterms.append(t)
        else:
            lexterms_multi['TK_' + t] = t
            
    return lexterms, lexterms_multi


def genLex(cfggen):
    lp = cfggen.grammardir + "/lex"
    lf = open(lp,"w")
    lf.write("%{" + "\n")
    lf.write('#include "yygrammar.h"' + "\n")
    lf.write("%}" + "\n")
    lf.write("%%" + "\n")

    for t in cfggen.lexterms:
        quoted_t = "'" + t + "'"
        lf.write('"' + t + '"     { return ' + quoted_t + "; }\n")
        
    for t in cfggen.lexterms_multi.keys():
        lf.write('"' + cfggen.lexterms_multi[t] + '"     { return ' + t + "; }\n")

    ## these entries should come last in a lex file
    lf.write('" "     { /* skip blank */ }\n')
    lf.write('\\n     { yypos++; /* adjust linenumber and skip newline */ }' + "\n")
    lf.write('\\r     { yypos++; /* adjust linenumber and skip newline */ }' + "\n")
    lf.write('.       { yyerror("illegal token"); }' + "\n")

    lf.close()
    
    return lf
    
    
def write(cfg, tokenlist, gp):
    gf = open(gp,"w")
    gf.write("%token " + ", ".join(tokenlist) + ";\n\n")
    gf.write("%nodefault\n\n")

    rule = cfg.pop('root')
    gf.write("root: " + rule + ";\n\n")

    for k in cfg.keys():
        gf.write(k + ": " + cfg[k] + ";\n\n")

    gf.close()        


