#! /usr/bin/env python

import sys, tempfile
import getopt
import math
import MetaUtils

"""
Run metasearch for AmbiDexter tool for the length option:
 - length (+ optionally filter)

Additionally pass timelimit, grammar, and the experiment directory
"""

TIMELIMIT = 10
LEN_STEP1 = 1
LEN_STEP2 = 3
LEN_STEP3 = 5
STDDEV_CNT = 3
STDDEV = 3

class Hillclimb:

    def __init__(self, expdir, gset, length, filter, timelimit):
        self.length = length
        self.logd = "%s/results/ambidexter/%s/%ss" % (expdir, gset, timelimit)

        ambidextx =  "%s/run_AmbiDexter.sh" % (expdir)
        self.cmd = [ambidextx, "-g", gset, "-t", str(timelimit)]

        if filter is not None:
            self.cmd += ["-f", filter]
            self.logd += "_-f_%s" % (filter)

        self.logd += "_-k"
        self.k_values = []
        self.run()


    def neighbour(self, l):
        fits = [f for _,f in self.k_values]
        if MetaUtils.move_by_step1(fits, STDDEV_CNT, STDDEV):
            return l + LEN_STEP1

        return l + LEN_STEP2


    def run(self):
        currlen = self.length
        ambidextoptcmd = ["-k",str(currlen)]
        MetaUtils.runtool(self.cmd + ambidextoptcmd)
        currfit = MetaUtils.fitness("%s_%s/log" % (self.logd, currlen))
        self.k_values.append((currlen,currfit))

        while True:
            sys.stderr.write("\n==> current length: %s, fitness: %s\n" \
                            % (str(currlen),str(currfit)))
            neighlen = self.neighbour(currlen)
            ambidextoptcmd = ["-k",str(neighlen)]
            MetaUtils.runtool(self.cmd + ambidextoptcmd)
            neighfit = MetaUtils.fitness("%s_%s/log" % (self.logd, neighlen))
            sys.stderr.write("new fitness: %s " % str(neighfit))
            self.k_values.append((neighlen,neighfit))

            fitvals = [f for _,f in self.k_values]
            if MetaUtils.localmax(fitvals):
                MetaUtils.report(self.k_values)
                sys.exit(0)

            currlen = neighlen
            currfit = neighfit


def usage(msg=None):
    if msg is not None:
        sys.stderr.write(msg)
        
    sys.stderr.write("MetasearchAmbiDexter.py -x <experiment directory> " \
    "-g <grammar set> -k <initial length> -t <time limit>\n")
    sys.exit(1)
    


if __name__ == "__main__": 
    opts, args = getopt.getopt(sys.argv[1 : ], "x:g:k:f:t:")
    expdir = None
    gset = None
    length = None
    filter = None
    timelimit = None
    for opt in opts:
        if opt[0] == "-x":
            expdir = opt[1]
        elif opt[0] == "-g":
            gset = opt[1]
        elif opt[0] == "-f":
            filter = opt[1]
        elif opt[0] == "-k":
            length = int(opt[1])
        elif opt[0] == "-t":
            timelimit = int(opt[1])
        else: 
            usage("Unknown argument '%s'" % opt[0])   

    if (expdir is None) or (gset is None) or (length is None):
        usage()

    print opts, args
    Hillclimb(expdir, gset, length, filter, timelimit)
    
