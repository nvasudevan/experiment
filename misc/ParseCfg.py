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

import re, sys

_RE_ID = re.compile("[a-zA-Z_][a-zA-Z_0-9]*")
_CFG_CTOR = "Cfg"
_RULE_ALTS_CTOR = "RuleAlts"
_EMPTY_RULE_CTOR = "EmptyRule"
_EMPTY_ALT_CTOR = "EmptyAlt"

class _ParseCfg:

    def _ws(self, _string, i):
        while i < len(_string) and _string[i] in " \r\n\t":
            i+=1
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
    
    def rule_alts(self, rule):
        alts=[]
        i=(len(rule)-1)
        while (i >= 0):
            #print "-- " , i , rule[i]
            j,name = self._id(rule,i)
            if name == _RULE_ALTS_CTOR:
                j, alt1 = self._match_bkt(rule,i-1)
                #print "=> alt1: " , alt1
                if alt1[len(alt1)-2] == ")":
                    # (Rule1 .. (Alt1 ...)); hence -2 from reverse
                    k, alt2 = self._r_match_bkt(alt1,len(alt1)-2) 
#                    print "=> alt2: " , alt2
                    alts.append(alt2)
                else: 
                    k = len(alt1)-2
                    while k >=0 and (alt1[k] not in " \r\n\t"):
                        k-=1
                        
#                    print "==>:%s:" % alt1[k+1:(len(alt1)-1)]
                    if (alt1[k+1:(len(alt1)-1)]) == _EMPTY_ALT_CTOR:
                        alts.append("")
                    else: 
                        print "FAIL"
                        sys.exit(1)
    
#                print "-----"
            i-=1
        
        return alts
      
    def parse(self, cfg):
        i=len(_CFG_CTOR)
        bz_rules=[]
        while i < len(cfg):
    	    i = self._ws(cfg,i)
    	    j, name = self._id(cfg,i)
    	    if name == _EMPTY_RULE_CTOR:
    	        bz_rules.append(name)
    	        i = self._ws(cfg,j)
    	    elif cfg[j] == "(":
    	        # we have (Rule1
    	        i, rule = self._match_bkt(cfg,j)
    	        bz_rules.append(rule)
    	    else:
    	        print "FAIL: Rule has to start with an %s or an %s" % (_EMPTY_RULE_CTOR,"(")
    	        sys.exit(1)
    
        #print "==>\n\n"
        #print "bz_rules: %s \n\n" % bz_rules
        rules=[]
        for bz_rule in bz_rules:
            bz_alts = self.rule_alts(bz_rule)
            alts=[]
            for bz_alt in bz_alts:
                alt = bz_alt.replace("(AltSyms","").replace("(NonTerm","").replace("(Term","").replace(")",""). replace("EmptyAlt","")
                alt_list= alt.split()
                alt_str=" ".join(sym for sym in alt_list)
                alts.append(alt_str)
            
            rules.append(" | ".join(_alt for _alt in alts))
        
#        for _i,_r in enumerate(bz_rules):
##            print "bz_rule: %s \n===> rule: %s\n\n" % (bz_rules[_i],rules[_i])
#            print "==> rule: %s\n" % (rules[_i])
            
        return rules
        

def parse(cfg):
    return _ParseCfg().parse(cfg)


if __name__ == "__main__":
    print "---"
    import sys
    _rules=parse(sys.argv[1]) 
    
