#!/usr/bin/env python

import CFG, Lexer
import sys


def _cfg(cfg):
    _cfg = {}
    for rule in cfg.rules:
        pp_seqs = []
        for seq in rule.seqs:
            pp_seqs.append(" ".join([str(x) for x in seq]))
            
        pp_seqs.sort()
        _cfg[rule.name] = pp_seqs 

    return _cfg


def compare(gp1, gp2, lp):
    lex = Lexer.parse(open(lp,"r").read())
    cfg1 = CFG.parse(lex, open(gp1, "r").read())
    cfg2 = CFG.parse(lex, open(gp2, "r").read())
    _cfg1 = _cfg(cfg1)
    _cfg2 = _cfg(cfg2)
    
    if _cfg1 == _cfg2:
        return True

    return False

if __name__ == "__main__":
    lp = sys.argv[1]
    g1 = sys.argv[2]
    g2 = sys.argv[3]
    print compare(g1, g2, lp)
