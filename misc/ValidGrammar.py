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

import random, string, copy
import sys
from sets import Set
import Lexer, CFG


def prune_rules(cfg):
    """ Builds cfg by leaving out non-terminal symbols which have no 
        corresponding rules. While pruning, if a rule has no alts, then
        the subsequent reference to that rule can be excluded """
    _cfg = {}
    to_remove = []
    for key in cfg.keys():
        seqs = []
        for seq in cfg[key]:
            if (str(seq[0]) in cfg.keys()):
                if (str(seq[0]) not in to_remove):
                    seqs.append(seq)
            
        if len(seqs) > 0:
            _cfg[key] = seqs
        else:
            to_remove.append(key)
            
    return _cfg


def vertical_ambiguity(cfg):
    """ We build a string equivalent of each alternative and if the string
        equivalent is identical, then the rule is vertically ambiguous"""
    for rule in cfg.rules:
        seqs = Set()
        for seq in rule.seqs:
            seqs.add(" ".join(str(x) for x in seq))
                
        if len(rule.seqs) != len(list(seqs)):
            return True     
    
    return False


def cyclic_ambiguity(cfg):
    """ Check for cyclic ambiguity (A: A or A: B; B: A) """
    # First, exclude root rule, only include single sym alts with non-terms
    _cfg = {}
    for rule in cfg.rules:
        if rule.name != 'root':
            single_sym_alts = []
            for seq in rule.seqs:
                if len(seq) == 1:
                    if isinstance(seq[0], CFG.Non_Term_Ref):
                        single_sym_alts.append(seq)

            if len(single_sym_alts) > 0:
                _cfg[rule.name] = single_sym_alts


    # keep pruning rules until there is no change.
    # if the final cfg is not empty, we have a cycle (direct/indirect)
    found = True
    while found:
        cfg_pruned = prune_rules(_cfg)
        if cfg_pruned != _cfg:
            _cfg = cfg_pruned
            found = True
        else:
            found = False
                    
    if len(_cfg) > 0:
        return True

    return False
    

def ambiguous(cfg):
    """ Checks if the rule is ambiguous:
        a) X : A | A | Z
        b) A: A """
    
    # (a)
    if vertical_ambiguity(cfg):
        return True
    
    # (b)
    if cyclic_ambiguity(cfg):
        return True
    
    return False


def remove_terminals(cfg):
    rules, indices, rules_to_remove = {}, {}, []
    for rule in cfg.rules:
        rule_seqs = []
        for i,seq in enumerate(rule.seqs):
            _seq = []
            for e in seq:
                if isinstance(e, CFG.Non_Term_Ref):
                    _seq.append(e.name)

            if len(_seq) == 0:
                if rule.name not in indices.keys():
                    indices[rule.name] = i
                    rules_to_remove.append(rule.name)

            rule_seqs.append(_seq)

        if rule.name not in indices.keys():
            rules[rule.name] = rule_seqs
            
    return rules, indices, rules_to_remove
    
    

def remove_matched_rule_refs(rules, indices):
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

       
def cyclicInfo(cfg, lex):
    rules, indices, removed = remove_terminals(cfg)
    
    if len(removed) > 0:
        while True:
            removed = remove_matched_rule_refs(rules,indices)
            if len(removed) == 0:
                break
                
            for k in removed:
                del rules[k]
        
    cyclic_rules = []
    for key in rules.keys():
        if key not in indices.keys():
            cyclic_rules.append("%s : %s" % (key, rules[key]))

    return cyclic_rules


def unproductive(cfg, lex):
    """ Checks if the grammar contains rules that don't consume any input'.
        Rules of this type don't consume any input:
        A: B; B: C; C: A """
    unproductive_rules = cyclicInfo(cfg,lex)
    if len(unproductive_rules) > 0:
        return True


def unreachable(cfg):
    """ Checks if every non-terminal is reachable from start symbol
        we build this reachable non-terms in two phases: 
        1) build the initial list from root rule; 
        2) now iterate through the list, and add reachable non-terms"""
    root_rule = cfg.rules[0]
    nonterms = [(rule.name) for rule in cfg.rules if rule.name != root_rule.name]

    reach_nonterms = Set()
    for seq in root_rule.seqs:
        for e in seq:
            if isinstance(e, CFG.Non_Term_Ref):
                reach_nonterms.add(e.name)

    # we use the initial set to start of searching for reachability
    exploring = copy.copy(reach_nonterms)
    # keep track of symbols for which we have explored reachability
    explored = Set()
    while len(exploring) > 0:
	name = exploring.pop()
	explored.add(name)
        rule = cfg.get_rule(name)
        for seq in rule.seqs:
            for e in seq:
                if isinstance(e, CFG.Non_Term_Ref):
                    reach_nonterms.add(e.name)
                    if e.name not in explored:
                        exploring.add(e.name)

    return set(nonterms) - set(reach_nonterms)

        
def has_too_many_alts(cfg, maxalts):
    for rule in cfg.rules:
        if len(rule.seqs) > maxalts:
            return True            

    return False


def empty_rule(cfg):
    """ A: ; is an empty rule """
    for rule in cfg.rules:
        if len(rule.seqs) == 1 and len(rule.seqs[0]) == 0:
            return True

    return False


def has_too_many_empty_alts(cfg, ratio):
    total = 0
    empty = 0
    for rule in cfg.rules:
        alts = len(rule.seqs)
        total += alts
        
        for seq in rule.seqs:
            if len(seq) == 0:
                empty += 1          

    if (empty * 1.0)/total > ratio:
        return True

    return False



def valid(gf, lf, max_alts_allowed=None, empty_alts_ratio=None):
    """ Generated grammar is valid if it:
        a) has no empty rule
	b) number of alternatives/rule < max_alts_allowed
        c) %age of empty alternatives < empty_alts_ratio 
        d) has no unreachable rules 
        e) doesn't contain a subset which taken no input 
	f) is not trivially ambiguous """
       
    lex = Lexer.parse(open(lf, "r").read())
    cfg = CFG.parse(lex, open(gf, "r").read())

    # check for empty rules
    if empty_rule(cfg):
	return False

    # check if any of the rule has > N alts
    if max_alts_allowed is not None:
	if has_too_many_alts(cfg, max_alts_allowed):
	    return False

    # check if we have too many empty alts
    if empty_alts_ratio is not None:
	if has_too_many_empty_alts(cfg, empty_alts_ratio):
	    return False

    # Check if all the rules are reachable from the start rule.
    if (len(unreachable(cfg)) > 0):
        print "unreachable: " , unreachable(cfg)
        sys.stdout.write("r")
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
    print valid(gf,lf,5,0.05)
