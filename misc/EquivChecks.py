# Given two grammars, do the initial checks on the difference sizes 
# on the root alternativess.

import CFG
import sys

#def check_seq_sizes(seqs):
#    sizes = {}
#    for seq in seqs:
#        l = len(seq)
#        if sizes.has_key(l):
#            sizes[l] += sizes[l]
#        else:
#            sizes[l] = 1 
#
#    return sizes
#

def rename_syms(seqs):
    _seqs = []
    for seq in seqs:
        _seq = []
        for e in seq:
            if isinstance(e,CFG.Non_Term_Ref):
                _seq.append('X')
            else:
                _seq.append('y')

        _seqs.append(_seq)

    return _seqs


def start_rule_check(g1,g2):
    # initial check, if the no of alts for root is different, then 
    # the cfg's can't be equivalent
    seqs1 = g1.get_rule('root').seqs
    seqs2 = g2.get_rule('root').seqs

    _seqs1 = rename_syms(seqs1)
    _seqs2 = rename_syms(seqs2)
    _seqs1.sort()
    _seqs2.sort()
    if _seqs1 != _seqs2:
        print "root alts have different symbol patterns:\n%s -- %s" % (_seqs1,_seqs2)
        return False

    return True
    

def sorted_cfg(cfg):
    """ Sort the string equivalent of alternatives for a rule """
    _cfg = {}
    for rule in cfg.rules:
        pp_seqs = []
        for seq in rule.seqs:
            pp_seqs.append(" ".join([str(x) for x in seq]))
            
        pp_seqs.sort()
        _cfg[rule.name] = pp_seqs 

    return _cfg


def is_cfg_equiv(g1, g2):
    _g1 = sorted_cfg(g1)
    _g2 = sorted_cfg(g2)
    if _g1 != _g2:
        return False 

    return True

