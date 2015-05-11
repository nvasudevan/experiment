# Copyright (c) 2012 King's College London
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


import argparse
import os, sys
import sets
import CFG, Lexer
import ValidGrammar


def alts_info(cfg, tlen):
    total, empty = 0,0
    long_alts = 0
    longest = 0
    nonterms, terms = 0,0
    for rule in cfg.rules:
        total += len(rule.seqs)
        for ind, seq in enumerate(rule.seqs):
            l = len(seq)
            if l == 0:
                empty += 1
                
            if l > tlen:
                long_alts += 1
                
            if l > longest:
                longest = l

        for seq in rule.seqs:
            for e in seq:
                if isinstance(e, CFG.Non_Term_Ref):
                    nonterms += 1
                else:
                    terms += 1

    return total, empty, long_alts, longest, nonterms, terms



if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument('gp', help='relative path to grammar file')
    parser.add_argument('lp', help='relative path to lex file')
    parser.add_argument('altlen', help='threshold alternative length')
    args = parser.parse_args()
    gp = args.gp
    lp = args.lp
    altlen = int(args.altlen)
    lex = Lexer.parse(open(lp, "r").read())
    cfg = CFG.parse(lex, open(gp, "r").read())
    total, empty, long_alts, longest, nonterms, terms = alts_info(cfg, altlen)
    cycles = ValidGrammar.cyclicInfo(cfg, lex)
    
    headers =  "rules, alts, empty, empty(%), long alts, long alts(%), longest, nonterms, terms, cycles"
    print headers
    print "%s, %s, %s, %s, %s, %s, %s, %s, %s, %s" % \
          (len(cfg.rules), total, empty, ((empty * 1.0)/total),
           long_alts, ((long_alts * 1.0)/total) , longest, nonterms, terms, cycles)
    
