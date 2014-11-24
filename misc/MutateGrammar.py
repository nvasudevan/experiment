#! /usr/bin/env python

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


import getopt, random, math, hashlib 
import os, sys, tempfile, subprocess
import CFG, Lexer
import Utils, ValidGrammar

class MutateGrammar:

    def __init__(self, gp, lp, mutype, cnt, gdir):
        self.lex = Lexer.parse(open(lp, "r").read())
        self.cfg = CFG.parse(self.lex, open(gp, "r").read())
        self.mutype = mutype
        self.symbolic_tokens = []
        self.tokens = [rule.name for rule in self.cfg.rules if rule.name != 'root']
        self.tokens += self.lex.keys()
        random.shuffle(self.tokens)

        cfgf = open(gp, "r")
        lines = cfgf.readlines()
        cfgf.close()
        header = "%nodefault\n\n"
        for l in lines:
            if l.startswith("%token"):
                self.symbolic_tokens = l[6:l.index(";")].replace(" ","").split(",")
                header = "{0}\n%nodefault\n\n".format(l)
                break
        

        print "tokens: " , self.tokens
        print "sym tokens: " , self.symbolic_tokens
        gf = os.path.basename(gp)
        mu_dir = gdir + "/" + self.mutype
        if not os.path.exists(mu_dir):
            os.makedirs(mu_dir)
        
	base_md5 = hashlib.md5(open(gp,'r').read()).hexdigest()
	print "base_md5: " , base_md5
	i = 1
        while i <= cnt:
            cfg = self.modify_grammar()
            print "cfg: " , cfg
            tp = tempfile.mktemp()
            print "tp: " , tp
            tf = open(tp,"w")
            tf.write(header)
            tf.write("%s\n" % str(cfg))
            tf.close()
            
            if ValidGrammar.valid(tp, lp, 10, 0.25):
                _md5 = hashlib.md5(open(tp,'r').read()).hexdigest()
                _match = False
                # now run a md5sum on all the files for this mutation
                for p,q,r in os.walk(gdir):
                    for f in r:
                        __gp = os.path.join(p,f)
                        __gp_md5 = hashlib.md5(open(__gp,'r').read()).hexdigest()
                        # if md5 matches with the base grammar
			# or with one of the mutated grammars, then throw away this file
			if (_md5 == base_md5) or (_md5 == __gp_md5):
                             print "md5:%s:curr,base,other=%s,%s,%s" % \
			     (str(_md5),tp,gp,__gp)
			     _match = True
			     break

                    if _match:
                        break


                if not _match:
                    _gp = '%s/%s_%s.acc' % (mu_dir, os.path.splitext(gf)[0], i)
                    print "_gp: " , _gp
                    r = subprocess.call(["cp", tp, _gp])
                    if r != 0:
                        Utils.error("Copy failed.\n", r)

                    i += 1
            

    def randomTok(self):
        tok = random.choice(self.tokens)
        if tok in self.lex.keys():
            if tok in self.symbolic_tokens:
                return CFG.Sym_Term(tok)

            return CFG.Term(tok)
        else:
            return CFG.Non_Term_Ref(tok)        


    def modify_seq(self, rule):
        print "-- " , rule
        if self.mutype == 'add':
            i = random.randint(0, len(rule.seqs)-1)
            seq =  rule.seqs[i]
            # No len(seq)-1 because we can add sym at the end too
            j = random.randint(0, len(seq))
            seq.insert(j,self.randomTok())
        elif self.mutype in ['mutate','delete']:
            non_empty_seqs = []
            for i,s in enumerate(rule.seqs):
                if len(s) > 0:
                    non_empty_seqs.append(i)

            seq = rule.seqs[random.choice(non_empty_seqs)]
            j = random.randint(0, len(seq)-1)

            if self.mutype == 'mutate':
                seq[j] = self.randomTok()
            elif self.mutype == 'delete':
                del seq[j]
        elif self.mutype == 'switchadj':
            seqs = [x for x in rule.seqs if len(x) >= 2]
            seq = random.choice(seqs)
            i = random.randint(0, len(seq)-2)
            j = i+1
            # switch the tokens seq[i] <-> seq[j]
            t = seq[i]
            seq[i] = seq[j]
            seq[j] = t
        elif self.mutype == 'switchany':
            seqs = [x for x in rule.seqs if len(x) >= 2]
            seq = random.choice(seqs)
            i,j = random.sample(xrange(len(seq)),2)
            # switch the tokens seq[i] <-> seq[j]
            t = seq[i]
            seq[i] = seq[j]
            seq[j] = t

        print "++ " , rule
            
    
    def modify_grammar(self):
        """ Grammar is modified in one of the ways:
            1) empty - identify rule with no empty alts, and pick a rule randonly
               and add an empty alt
            2) mutate - pick a rule randonly, pick one of its alts randomly, 
               and pick one its symbols and mutate
            3) insert - same as 'mutate' but insert a symbol at a random position
            4) delete - same as 'mutate' but delete a symbol at a random position
            5) swithcadj - same as 'mutate' but pick only alts with at least 
               two symbols, and switch adjacent symbols.
            6) swithcany - same as 'switchadj' but switch any two symbols in an alt
        """
        _cfg = self.cfg.clone()
        if self.mutype == 'empty':
            # identify rules with no empty alts
            non_empty_keys = []
            for r in _cfg.rules:
                _empty = False
                for _seq in r.seqs:
                    if len(_seq) == 0:
                        _empty = True
                        break
                        
                if not _empty:
                    non_empty_keys.append(r.name)
                        
            print "non_empty_keys: " , non_empty_keys
            key = random.choice(non_empty_keys)
            rule = _cfg.get_rule(key)
            print "-- " , rule
            rule.seqs.append([])
            print "++ " , rule
        elif self.mutype in ['mutate','add','delete']:
            keys = [rule.name for rule in _cfg.rules]
            key = random.choice(keys)
            rule = _cfg.get_rule(key)
            self.modify_seq(rule)
        elif self.mutype in ['switchadj','switchany']:
            keys = []
            for r in _cfg.rules:
                _switch = False
                for seq in r.seqs:
                    if len(seq) >= 2:
                        _switch = True
                        break
                        
                if _switch:
                    keys.append(r.name)
                        
            key = random.choice(keys)
            rule = _cfg.get_rule(key)
            self.modify_seq(rule)    
        else:
            assert "mutation type '%s' is not supported" % self.mutype
            
        return _cfg




def generate(cfg, lex, mutype, cnt, gdir):
    MutateGrammar(cfg, lex, mutype, cnt, gdir)
    

def usage(msg=None):
    if msg is not None:
        sys.stderr.write(msg)
        
    sys.stderr.write("MutateGrammar.py " \
    "-d <where to create grammars> " \
    "-t <type of mutation> " \
    "-n <number of variations to generate> <grammar> <lexer> " \
    "\n\n - type of mutation can be one of the following: " \
    "\n   - empty - add empty alternative" \
    "\n   - mutate - mutate symbol" \
    "\n   - add - add a symbol" \
    "\n   - delete - remove a symbol" \
    "\n   - switchadj - switch adjacent symbols" \
    "\n   - switchany - switch any two symbols in an alternative\n\n")
    sys.exit(1)
    
    
if __name__ == "__main__":
    opts, args = getopt.getopt(sys.argv[1 : ], "hn:t:d:")
    mutype,cnt,gdir = None,None,None

    if len(args) != 2:
        usage()
    for opt in opts:
        if opt[0] == "-t":
            mutype = opt[1]
        elif opt[0] == "-n":
            cnt = int(opt[1])
        elif opt[0] == "-d":
            gdir = opt[1]
        
    if mutype == None:
        usage("\nProvide -t <type of mutation> \n\n")
    elif mutype not in ['empty','mutate','add','delete','switchadj','switchany']:
        usage("\nIncorrect mutation type. See usage.\n\n")
    elif cnt == None:
        usage("\nProvide -n <no of variants to generate> \n\n")
    elif gdir == None:
        usage("\nProvide a directory for creating grammars \n\n")
        
        
    generate(args[0], args[1], mutype, cnt, gdir)
