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

# works for the following Boltzmann spec:
#
#data Cfg = Cfg  Rule ... Rule deriving (Typeable, Data, Show) 
#data Rule = SingleAlt Alt | RuleAlts1 Rule Alt deriving (Typeable, Data, Show) 
#data Alt = EmptyAltSyms | SingleAltSyms1 Symbol | AltSyms1 Alt Symbol deriving (Typeable, Data, Show)   
#data Symbol = NonTerm NonTerm | Term Term deriving (Typeable, Data, Show) 
#data NonTerm = AAA | BBB | ... deriving (Typeable, Data, Show) 
#data Term = XXX | YYY | ... deriving (Typeable, Data, Show)

import re, sys

_RE_ID = re.compile("[a-zA-Z_][a-zA-Z_0-9]*")
_CFG_CTOR = "Cfg"
_SINGLE_ALT_CTOR = "SingleAlt"
_RULEALTS_CTOR = ["RuleAlts1"]

_ALTSYMS_ID = re.compile("AltSyms[0-9]+")
_SINGLE_ALTSYMS_CTOR = "SingleAltSyms1"
_EMPTY_ALTSYMS_CTOR = "EmptyAltSyms"
_NONTERM_CTOR = "NonTerm"
_TERM_CTOR = "Term"

class _ParseCfg:

    def _ws(self, _string, i):
        while i < len(_string) and _string[i] in " \r\n\t":
            i+=1
        return i
    
    def _r_non_ws(self, _string, i):
        while i > 0 and _string[i] not in " \r\n\t":
            i-=1
        return i
            
    
    def _id(self, _string, i):
        m = _RE_ID.match(_string,i)
        if not m:
            return i, None
            
        return m.end(0), m.group()
    
    def _r_match_bkt(self, _str, i):
        brack_cnt=0
        j=i
        while i >= 0:
            if _str[i] == ")":
               brack_cnt+=1
            elif _str[i] == "(":
               brack_cnt-=1
               
            if brack_cnt == 0:
                return i-1, _str[i:j+1]
                
            i-=1
            
    # 'i' starts with "("
    def _match_bkt(self, _str, i):
        brack_cnt=0
        m_str=""
        
        while i < len(_str):
            if _str[i] == "(":
               brack_cnt+=1
            elif _str[i] == ")":
               brack_cnt-=1
               
            m_str += _str[i]
            if brack_cnt == 0:
                return i+1, m_str
                
            i+=1

    def _alt(self, rule, j):
        _, alt1 = self._match_bkt(rule,j)
        # there are three options:
        # 1) # (RuleAlts .. (AltSyms ...))
        # 1) # (SingleAlt .. (AltSyms ...))
        # 2) # (RuleAlts .. EmptyAlt)
        if alt1[len(alt1)-2] == ")":
            _, alt2 = self._r_match_bkt(alt1,len(alt1)-2)
            return alt2
        else:
            # has to be a EmptyAlt
            m = len(alt1)-2
            n = self._r_non_ws(alt1,m)
            _,name = self._id(alt1,n+1)
            
            assert name == _EMPTY_ALTSYMS_CTOR
            return ""
    
    def _rule(self, rule):
        alts=[]
        i=(len(rule)-1)
        while (i >= 0):
            # index of next non white space reverse direction
            # so "abc defg", j will point to index 3 from the beginning
            j = self._r_non_ws(rule,i)

            if j == 0:
                assert rule[0] == "("
                _,name = self._id(rule,1)
                if name == _SINGLE_ALT_CTOR:
                    alt = self._alt(rule,j)
                    alts.append(alt)
                    return alts
                        
                assert name in _RULEALTS_CTOR
                
                alt = self._alt(rule,j)
                alts.append(alt)
                return alts
                    
            elif rule[j+1] == "(":
                _,name = self._id(rule,j+2)
                if name in _RULEALTS_CTOR or name in _SINGLE_ALT_CTOR:
                    alt = self._alt(rule,j+1)
                    alts.append(alt)
            else: 
                k,name = self._id(rule,j+1)
                
            i=j-1
        
      
    def _parse(self, cfg, lexterms):
        i=len(_CFG_CTOR)
        bz_rules=[]
        while i < len(cfg):
            i = self._ws(cfg,i)
            j, name = self._id(cfg,i)
            assert cfg[j] == "("
            i, rule = self._match_bkt(cfg,j)
            bz_rules.append(rule)
    
        
        rules=[]
        for bz_rule in bz_rules:
            bz_alts = self._rule(bz_rule)
            alts=[]
            for bz_alt in bz_alts:
                alt = re.sub(r'\b%s\b' % _SINGLE_ALTSYMS_CTOR,"",bz_alt)
                alt = re.sub(_ALTSYMS_ID,"",alt)
                alt = re.sub(r'\b%s\b' % _EMPTY_ALTSYMS_CTOR,"",alt)
                alt = re.sub(r'\b%s\b' % _NONTERM_CTOR,"",alt)
                alt = re.sub(r'\b%s\b' % _TERM_CTOR,"",alt)
                alt = alt.replace("(","")
                alt = alt.replace(")","")
                alt_list = alt.split()
                quoted_alt_list = []
                for sym in alt_list:
                    if sym in lexterms:
                        quoted_alt_list.append("'%s'" % sym)
                    else:
                        quoted_alt_list.append(sym)
                        
                alt_str=" ".join(sym for sym in quoted_alt_list)
                alts.append(alt_str)
            
            rules.append(" | ".join(_alt for _alt in alts))
            
        return rules
        

def parse(cfg,lexterms):
    return _ParseCfg()._parse(cfg, lexterms)


if __name__ == "__main__":
    print "---"
    import sys 
    cfg = sys.argv[1]
    grammardir = sys.argv[2]
    f_lexterms = open(grammardir  + "/" + "lexterms","r")
    lexterms_line = f_lexterms.readline()
    f_lexterms.close()
    lexterms = lexterms_line.split(" | ")

    _rules = parse(cfg, lexterms) 
    for rule in _rules:
        print "->%s \n" % rule
    
