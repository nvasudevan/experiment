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

# for validation
EMPTY_ALTS_RATIO = 0.25
MAXALTS = 10


class MutateGrammar:

    def __init__(self, gp, lp, mutype, cnt, gdir):
        self.lex = Lexer.parse(open(lp, "r").read())
        self.cfg = CFG.parse(self.lex, open(gp, "r").read())
        self.mutype = mutype
        self.gdir = gdir
        self.tokens = self.lex.keys()
        for rule in self.cfg.rules:
            if rule.name != 'root']:
                self.tokens.append(rule.name)

        random.shuffle(self.tokens)

        self.header = Utils.cfg_header(gp)
        self.symbolic_tokens = Utils.sym_tokens(gp)

        mu_dir = self.gdir + "/" + self.mutype
        if not os.path.exists(mu_dir):
            os.makedirs(mu_dir)
        
        self.run(cnt)


    def check_duplicate_cfg(self):
        """ Avoid duplicate cfg's """
        for dir, subdirs, files in os.walk("%s/%s" % (self.gdir, self.mutype)):
            for f in files:
                tgp = os.path.join(dir, f)
                if CompareCFG.compare(gp, tgp):
                    print "%s == %s" % (gp, tgp)
                    return True

        return False


    def run(self, cnt):
        i = 1
        while i <= cnt:
            cfg = self.mutate_grammar()
            tp = tempfile.mktemp()
            tf = open(tp,"w")
            tf.write(self.header)
            tf.write("%s\n" % str(cfg))
            tf.close()
            
            if ValidGrammar.valid(tp, lp, MAXALTS, EMPTY_ALTS_RATIO):
                if not _match:
                    _gp = '%s/%s_%s.acc' % (mu_dir, os.path.splitext(gf)[0], i)
                    r = subprocess.call(["cp", tp, _gp])
                    if r != 0:
                        Utils.error("Copy failed.\n", r)

                    i += 1

                if os.path.exists(tp):
                    os.remove(tp)


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
        elif self.mutype == 'switch':
            seqs = [x for x in rule.seqs if len(x) >= 2]
            seq = random.choice(seqs)
            i,j = random.sample(xrange(len(seq)),2)
            # switch the tokens seq[i] <-> seq[j]
            t = seq[i]
            seq[i] = seq[j]
            seq[j] = t

        print "++ " , rule
            
    
    def mutate_grammar(self):
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
        elif self.mutype in ['switch']:
            keys = []
            for r in _cfg.rules:
                for seq in r.seqs:
                    if len(seq) >= 2:
                        keys.append(r.name)
                        break

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
    "\n   - empty  - add empty alternative" \
    "\n   - mutate - mutate symbol" \
    "\n   - add    - add a symbol" \
    "\n   - delete - remove a symbol" \
    "\n   - switch - switch any two symbols\n\n")
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
    elif mutype not in ['empty', 'mutate', 'add', 'delete', 'switch']:
        usage("\nIncorrect mutation type. See usage.\n\n")
    elif cnt == None:
        usage("\nProvide -n <no of variants to generate> \n\n")
    elif gdir == None:
        usage("\nProvide a directory for creating grammars \n\n")

    generate(args[0], args[1], mutype, cnt, gdir)
