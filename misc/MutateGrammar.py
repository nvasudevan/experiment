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


import getopt, sys, os, random, math
import CFG, Lexer

class MutateGrammar:

    def __init__(self, gf, lf, mutype, cnt):
        self.lex = Lexer.parse(open(lf, "r").read())
        self.cfg = CFG.parse(self.lex, open(gf, "r").read())
        self.mutype = mutype
        self.symbolic_tokens = []
        #create a list of all nonterminal and terminal symbols
        self.tokens = [rule.name for rule in self.cfg.rules if rule.name != 'root']
        self.tokens += self.lex.keys()
        random.shuffle(self.tokens)
        print self.tokens

        gf_lines = open(gf, "r").readlines()
        header = "%nodefault\n\n"
        for line in gf_lines:
            if line.startswith("%token"):
                self.symbolic_tokens = line[6:line.index(";")].replace(" ","").split(",")
                header = "{0}\n%nodefault\n\n".format(line)
                break
        
        g_dir, g_file = os.path.dirname(gf), os.path.basename(gf)
        mu_g_dir = g_dir + "/" + self.mutype
        if not os.path.exists(mu_g_dir):
            os.makedirs(mu_g_dir)
        
        print "type: %s, cnt: %s" % (self.mutype, cnt)
        self.variations_cnt = cnt
        i = 1
        while i <= self.variations_cnt:
            _cfg = self.modify_grammar()
            _f_file = open(('%s/%s_%s.acc' % (mu_g_dir, os.path.splitext(g_file)[0], i)),"w")
            _f_file.write(header)
            _f_file.write(self.cfg_repr(_cfg))
            _f_file.close()
            i += 1
            

    def cfg_repr(self, cfg):
        _cfg_repr = ""
        for rule in cfg.rules:
            rule_seqs = []
            for seq in rule.seqs:
                _seq = []
                for tok in seq:
                    if isinstance(tok, CFG.Term):
                        _tok = tok
                        _tok = str(_tok).replace("'","")
                        if self.symbolic_tokens.__contains__(_tok):
                            _seq.append(_tok)
                            continue

                    _seq.append(tok)
                
                rule_seqs.append(" ".join([str(x) for x in _seq]))

            _cfg_repr += (('%s : %s' % (rule.name, " | ".join(rule_seqs))) + "\n;\n")
        return _cfg_repr


    def randomTok(self):
        _tok = random.choice(self.tokens)
        if self.lex.keys().__contains__(_tok):
            return CFG.Term(_tok)
        else:
            return CFG.Non_Term_Ref(_tok)        


    def modify_seq(self, rule):
        if self.mutype == 'add':
            i_seq = random.randint(0, rule.seqs.__len__()-1)
            seq =  rule.seqs[i_seq]
            # we can also add a symbol at the end, so we don't include "-1"
            i = random.randint(0, seq.__len__())
            seq.insert(i,self.randomTok())
        elif self.mutype in ['mutate','delete']:
            i_non_empty_seqs = []
            for _ind,_seq in enumerate(rule.seqs):
                if _seq.__len__() > 0:
                    i_non_empty_seqs.append(_ind)
            seq = rule.seqs[random.choice(i_non_empty_seqs)]
            i = random.randint(0, seq.__len__() - 1)
            if self.mutype == 'mutate':
                seq[i] = self.randomTok()
            elif self.mutype == 'delete':
                del seq[i]
                
                 
    
    def modify_grammar(self):
        cloned_g = self.cfg.clone()
        if self.mutype == 'empty':
            # iterate through rules that does not have empty alts
            non_empty_keys = []
            for _rule in cloned_g.rules:
                _empty = False
                for _seq in _rule.seqs:
                    if _seq.__len__() == 0:
                        _empty = True
                        break
                        
                if _empty == False:
                    non_empty_keys.append(_rule.name)
                        
            print non_empty_keys
            key_to_modify = random.choice(non_empty_keys)
            print key_to_modify
            rule = cloned_g.get_rule(key_to_modify)
            print "++ rule: ", rule            
            rule.seqs.append([])
        elif self.mutype in ['mutate','add','delete']:
            rule_keys = [rule.name for rule in cloned_g.rules]
            key_to_modify = random.choice(rule_keys)
            rule = cloned_g.get_rule(key_to_modify)
            print "++ rule: ", rule
            self.modify_seq(rule)
        else:
            pass
            
        print "-- rule: ", rule
        
        return cloned_g


def generate(cfg, lex, mutype, cnt):
    MutateGrammar(cfg, lex, mutype, cnt)
    

def usage(msg=None):
    if msg is not None:
        sys.stderr.write(msg)
        
    sys.stderr.write("MutateGrammar.py " \
    "-t <type of mutation> " \
    "-n <number of variations to generate> <grammar> <lexer> " \
    "\n\n - type of mutation can be one of the following: " \
    "\n   - empty - add empty alternative" \
    "\n   - mutate - mutate symbol" \
    "\n   - add - add a symbol" \
    "\n   - delete - remove a symbol\n\n")
    sys.exit(1)
    
    
if __name__ == "__main__":
    opts, args = getopt.getopt(sys.argv[1 : ], "hn:t:")
    mutype,cnt = None,None

    if len(args) != 2:
        usage()
    for opt in opts:
        if opt[0] == "-t":
            mutype = opt[1]
        elif opt[0] == "-n":
            cnt = int(opt[1])
        
    if mutype == None:
        usage("\nProvide -t <type of mutation> \n\n")
    elif mutype not in ['empty','mutate','add','delete']:
        usage("\nMutation type can only be of empty or mutate or add or delete\n\n")
    elif cnt == None:
        usage("\nProvide -n <no of variants to generate> \n\n")
        
        
    generate(args[0], args[1], mutype, cnt)
