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


import sys
import sets
import CFG, Lexer

def altsInfo(cfg):
    _total, _empty = 0,0
    for rule in cfg.rules:
        _total += len(rule.seqs)
        for ind,seq in enumerate(rule.seqs):
            if len(seq) == 0:
                _empty += 1
                
    return _total, _empty



def symbolInfo(cfg):
    _nt_pts,_t_pts = 0,0
    for rule in cfg.rules:
        for seq in rule.seqs:
            for e in seq:
                if isinstance(e, CFG.Non_Term_Ref):
                    _nt_pts+=1 
                else:
                    _t_pts+=1
                    
    return _nt_pts, _t_pts



def removeTerms(cfg):
    _rules, _indices, _r_remove = {}, {}, []
    for rule in cfg.rules:
        rule_seqs = []
        for ind,seq in enumerate(rule.seqs):
            _seq = []
            for e in seq:
                if isinstance(e, CFG.Non_Term_Ref):
                    _seq.append(e.name)

            if len(_seq) == 0:
                if not _indices.__contains__(rule.name):
                    _indices[rule.name] = ind
                    _r_remove.append(rule.name)
            rule_seqs.append(_seq)
        if not _indices.__contains__(rule.name):
            _rules[rule.name] = rule_seqs
            
    return _rules, _indices, _r_remove
    
    

def removeMatchedRuleRefs(rules, indices):
    _r_remove = []
    for key in rules.keys():
        rule_seqs = []
        for ind,seq in enumerate(rules[key]):
            _seq = []
            for e in seq:
                if e not in indices.keys():
                    _seq.append(e)
            if len(_seq)== 0:
                indices[key] = ind
                _r_remove.append(key)
                break
            rule_seqs.append(_seq)
                
        rules[key] = rule_seqs
        
    return _r_remove
       
       
       
def cyclicInfo(cfg,lex):
    rules, indices, r_remove = removeTerms(cfg)
    
    if len(r_remove) > 0:
        while True:
            r_remove = removeMatchedRuleRefs(rules,indices)
            if len(r_remove) == 0:
                break
                
            for _key in r_remove:
                del rules[_key]
        
    cyclic_rules = []
    for key in rules.keys():
        if key not in indices.keys():
            cyclic_rules.append("%s : %s" % (key, rules[key]))

    return cyclic_rules

       

if __name__ == "__main__":

    gp = sys.argv[1]
    lp = sys.argv[2]
    lex = Lexer.parse(open(lp, "r").read())
    cfg = CFG.parse(lex, open(gp, "r").read())
    cyclic_rules = cyclicInfo(cfg,lex)
    total_alts, empty_alts = altsInfo(cfg)
    nt_pts,t_pts = symbolInfo(cfg)
    
    print "no_rules: " , len(cfg.rules)
    print "empty/total alts: %s/%s" % (str(empty_alts),str(total_alts))
    print "nonterminal_pts: %i,%f" % (nt_pts,(nt_pts*1.0/(nt_pts+t_pts)))
    print "terminal_pts: %i,%f" % (t_pts,(t_pts*1.0/(nt_pts+t_pts)))     
    print "nonterminating_rules: %s" % (" \n ".join(cyclic_rules))
    
