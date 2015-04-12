#! /usr/bin/env python

import os, subprocess, sys
import getopt
import MetaUtils
from sets import Set
import random

TIMELIMIT = 10
LEN_STEP1 = 1
LEN_STEP2 = 3
LEN_STEP3 = 5

class Hillclimb:

    def __init__(self, expdir, gset, backend, depth, timelimit):
        self.depth = depth
        self.timelimit = timelimit
        self.logd = "%s/results/sinbad/%s/%ss_-b_%s_-d" % (expdir, gset, timelimit, backend)

        sinbadx =  "%s/run_SinBAD.sh" % (expdir)
        self.cmd = [sinbadx,"-g", gset, "-t", str(timelimit), "-b", backend]
        
        self.k_values = []
        self.run()


    def neighbour(self, v):
        return MetaUtils.neighbour(self.k_values,
                                   v+LEN_STEP1,
                                   v+LEN_STEP2,
                                   v+LEN_STEP3)


    def run(self):
        currd = self.depth
        sinbadoptcmd = ["-d", str(currd)]
        MetaUtils.runtool(self.cmd + sinbadoptcmd)
        currfit = MetaUtils.fitness("%s_%s/log" % (self.logd, currd))
        self.k_values.append((currd, currfit))
         
        while True:
            sys.stderr.write("\n==> current depth: %s, fitness: %s\n" \
                            % (str(currd),str(currfit)))
            neighd = self.neighbour(currd)
            sinbadoptcmd = ["-d", str(neighd)]
            MetaUtils.runtool(self.cmd + sinbadoptcmd)
            neighfit = MetaUtils.fitness("%s_%s/log" % (self.logd, neighd))
            self.k_values.append((neighd, neighfit))
            sys.stderr.write("\nneighd: %s, neighfit: %s \n" \
                            % (str(neighd),str(neighfit)))

            if MetaUtils.keep_running(self.k_values):
                currd = neighd
                currfit = neighfit


def usage(msg=None):
    if msg is not None:
        sys.stderr.write("** %s **\n" % msg)
        
    sys.stderr.write("Metasearch.py -x <experiment directory> " \
    "-g <grammar set> -b <backend to run> -d <initial depth>\n")
    sys.exit(1)
    

if __name__ == "__main__": 
    opts, args = getopt.getopt(sys.argv[1 : ], "x:g:b:d:")   
    expdir, gset, backend, depth = None, None, None, None
    for opt in opts:
        if opt[0] == "-x":
            expdir = opt[1]
        elif opt[0] == "-g":
            gset = opt[1]
        elif opt[0] == "-b":
            backend = opt[1]
        elif opt[0] == "-d":
            depth = int(opt[1])
        else: 
            usage("Unknown argument '%s'" % opt[0])   

    if (expdir == None) or (gset == None) or (backend == None) or (depth == None):
        usage("Missing arguments!")

    Hillclimb(expdir, gset, backend, depth, TIMELIMIT)
    
