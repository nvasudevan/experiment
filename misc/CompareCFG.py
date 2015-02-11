#!/usr/bin/env python

import CFG, Lexer
import sys
import CombiList, EquivChecks


class CompareCFG:

    def __init__(self, lp, bg, tg):
        self.bg = bg
        self.tg = tg
        self.lex = Lexer.parse(open(lp,"r").read())
        self.bcfg = CFG.parse(self.lex, open(self.bg, "r").read())
        self.tcfg = CFG.parse(self.lex, open(self.tg, "r").read())

    
    def replace_sym_in_seqs(self, seqs, sym_from, sym_to):
        _seqs = []
        for seq in seqs:
            _seq = []
            for e in seq:
                if isinstance(e, CFG.Non_Term_Ref):
                    if e.name == sym_from.name:
                        _seq.append(CFG.Non_Term_Ref(sym_to.name))
                    else:
                        _seq.append(e) 
                else:
                    _seq.append(e)
    
            _seqs.append(_seq)
    
        return _seqs
    
    
    def replace_sym_in_cfg(self, cfg, sym_from, sym_to):
        """Replace all occurances of sym_from to sym_to in the grammar """
        _tokens = cfg.tokens
        _rules = []
        for rule in cfg.rules:
            _seqs = self.replace_sym_in_seqs(rule.seqs, sym_from, sym_to)
            if rule.name == sym_from.name:
                _rules.append(CFG.Rule(sym_to.name,_seqs))
            else:
                _rules.append(CFG.Rule(rule.name,_seqs))
    
        return CFG.CFG(_tokens,_rules)
 
    
    def initial_list(self):
        """ Build the list of symbols to compare from the start rule """
        symsb, symst = [],[]
        for seq in self.bcfg.get_rule('root').seqs:
            for e in seq:
                if isinstance(e, CFG.Non_Term_Ref):
                    symsb.append(e)
    
        for seq in self.tcfg.get_rule('root').seqs:
            for e in seq:
                if isinstance(e, CFG.Non_Term_Ref):
                    symst.append(e)
    
        return CombiList.combine_lists(symsb,symst)


    def alpha_cmp(self):
        if not EquivChecks.start_rule_check(self.bcfg, self.tcfg): 
            return False

        c = initial_list()
        for l in c.combs:
            b,t = l
            _cfg = self.bcfg
            print "%s -> %s" % (b,t)
            for i,_ in enumerate(b):
                print "%s -> %s" % (b[i],t[i])
                _cfg = self.replace_sym_in_cfg(_cfg, b[i], t[i])
                if EquivChecks.is_cfg_equiv(_cfg,self.tcfg):
                    print "Cfg's %s and %s are equivalent" % (self.bg, self.tg)
                    return True
     
        return False
    

def compare(lp, bgp, tgp):
    """ Two cfg's are equivalent if:
        1) the grammars have the same rules after sorting the alternatives
        2) the grammars identical rules (and alts) after alpha renaming
    """
    cmpcfg = CompareCFG(lp, bgp, tgp)
    if not cmpcfg.alpha_cmp():
        print "Alpha: %s != %s" % (bgp,tgp)
        return False

    return True


if __name__ == "__main__":
    lp = sys.argv[1]
    bgp = sys.argv[2]
    tgp = sys.argv[3] 
    if compare(lp, bgp, tgp):
        print "baseg <=> targetg"
    else:
        print "baseg != targetg"

