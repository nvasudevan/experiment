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


import getopt, random, math
import os, sys, tempfile, subprocess
import CFG, Lexer
import Utils, ValidGrammar, CompareCFG
import Mutation


class MutateGrammar:

    def __init__(self, gp, lp, mutype, cnt, gdir):
        lex = Lexer.parse(open(lp, "r").read())
        self.cfg = CFG.parse(lex, open(gp, "r").read())
        self.header = Utils.cfg_header(gp)
        self.run(gp, lp, gdir, mutype, cnt)


    def check_duplicate_cfg(self, gdir, gp, lp):
        """ Avoid duplicate cfg's """
        for dir, subdirs, files in os.walk(gdir):
            for f in files:
                tgp = os.path.join(dir, f)
                if CompareCFG.compare(gp, tgp, lp):
                    print "CFG: %s == %s" % (gp, tgp)
                    return True

        return False


    def run(self, gp, lp, gdir, mutype, cnt):
        gname = os.path.splitext(os.path.basename(gp))[0]
        i = 1
        while i <= cnt:
            cfg = Mutation.mutate_cfg(gp, lp, mutype)
            tp = tempfile.mktemp()
            tf = open(tp, "w")
            tf.write(self.header)
            tf.write("%s\n" % str(cfg))
            tf.close()
            
            if ValidGrammar.valid(tp, lp):
                if not self.check_duplicate_cfg(gdir, tp, lp):
                    _gp = '%s/%s_%s.acc' % (gdir, gname, i)
                    r = subprocess.call(["cp", tp, _gp])
                    if r != 0:
                        Utils.error("Copy failed.\n", r)

                    i += 1
                    sys.stderr.write('.')

                if os.path.exists(tp):
                    os.remove(tp)



def usage(msg=None):
    if msg is not None:
        sys.stderr.write(msg)
        
    sys.stderr.write("MutateGrammar.py " \
    "-d <where to create grammars> " \
    "-n <number of variations to generate> <grammar> <lexer> " \
    "-t <type of mutation> " \
    "\n\n - type of mutation can be one of the following: " \
    "\n   - empty  - add empty alternative" \
    "\n   - mutate - mutate symbol" \
    "\n   - add    - add a symbol" \
    "\n   - delete - remove a symbol" \
    "\n   - switch - switch any two symbols\n\n")
    sys.exit(1)
    
    
if __name__ == "__main__":
    opts, args = getopt.getopt(sys.argv[1 : ], "hn:t:d:")
    mutype, cnt, gdir = None, None, None

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

    gp, lp = args[0], args[1]
    if not os.path.exists(gdir):
        os.makedirs(gdir)

    MutateGrammar(gp, lp, mutype, cnt, gdir)

