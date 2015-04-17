#! /usr/bin/env python

import os, subprocess, sys
import getopt
import MetaUtils
from sets import Set
import random

TIMELIMIT = 10
D_STEP1 = 1
D_STEP2 = 3
D_STEP3 = 5
WGT_STEP1 = 1.05
WGT_STEP2 = 1.1
WGT_STEP3 = 1.2
STDDEV_CNT = 3
STDDEV = 3

class Hillclimb:

    def __init__(self, expdir, gset, backend, depth, wgt, timelimit):
        self.depth = depth
        self.wgt = wgt
        self.timelimit = timelimit
        self.logd = "%s/results/sinbad/%s/%ss_-b_%s" \
                        % (expdir, gset, timelimit, backend)

        sinbadx =  "%s/run_SinBAD.sh" % (expdir)
        self.cmd = [sinbadx, "-g", gset, "-t", str(timelimit), "-b", backend]
        
        self.k_values = []
        self.run()


    def best_w(self, vals):
        for k,f in vals:
            print "(%s,%s)" % (k,f)

        fitvals = [f for k,f in vals]
        maxfit = max(fitvals)

        fitkeys = []
        for k,f in vals:
            if f == maxfit:
                fitkeys.append(k)

        return fitkeys, maxfit


    def best_dw(self):
        for j,k,f in self.k_values:
            print "(%s,%s,%s)" % (j,k,f)

        fitvals = [f for _,_,f in self.k_values]
        maxfit = max(fitvals)

        fitkeys = []
        for j,k,f in self.k_values:
            if f == maxfit:
                fitkeys.append((j,k))

        return fitkeys, maxfit


    def neighbour(self, key_fits, d, w):
        if d is not None:
            fits = [f for _,_,f in key_fits]
            if MetaUtils.move_by_step1(fits, STDDEV_CNT, STDDEV):
                return d + D_STEP1

            return d + D_STEP2

        if w is not None:
            fits = [f for _,f in key_fits]
            if MetaUtils.move_by_step1(fits, STDDEV_CNT, STDDEV):
                return (w * WGT_STEP1)

            return (w * WGT_STEP2)


    def sinbad(self, d):
        d_cmd = ["-d", str(d)]
        if self.wgt is None:
            MetaUtils.runtool(self.cmd + d_cmd)
            f = MetaUtils.fitness("%s_-d_%s/log" % (self.logd, d))
            return None, f

        w = self.wgt
        w_cmd = ["-w", str(w)]
        MetaUtils.runtool(self.cmd + d_cmd + w_cmd)
        logp = "%s_-d_%s_-w_%s/log" % (self.logd, d, w)
        f = MetaUtils.fitness(logp)
        w_values = [(w,f)]
        while True:
            sys.stderr.write("\n(d, w, f) => (%s, %s, %s)\n" % (str(d), str(w), str(f)))
            neighw = self.neighbour(w_values, None, w)
            w_cmd = ["-w", str(neighw)]
            MetaUtils.runtool(self.cmd + d_cmd + w_cmd)
            logp = "%s_-d_%s_-w_%s/log" % (self.logd, d, neighw)
            neighf = MetaUtils.fitness(logp)
            w_values.append((neighw,neighf))
            fitvals = [f for _,f in w_values]

            sys.stderr.write("\nneigh: w,f %s, %s\n" % (str(neighw),str(neighf)))
            sys.stderr.write("w_values: %s\n" % w_values)
            if MetaUtils.localmax(fitvals):
                fitkeys,maxfit = self.best_w(w_values)
                msg = "\nOptions %s found %s ambiguities **\n" % (fitkeys,maxfit)
                sys.stderr.write(msg)
                return fitkeys, maxfit

            w, f = neighw, neighf



    def run(self):
        currd = self.depth
        currw, currf = self.sinbad(currd)
        self.k_values.append((currd, currw, currf))

        while True:
            sys.stderr.write("\n==> current depth: %s, fitness: %s\n" \
                            % (str(currd),str(currf)))
            neighd = self.neighbour(self.k_values, currd, None)
            neighw, neighf = self.sinbad(neighd)
            self.k_values.append((neighd, neighw, neighf))
            fitvals = [f for _,_,f in self.k_values]

            sys.stderr.write("k_values: %s\n" % self.k_values)
            sys.stderr.write("fitvals: %s\n" % fitvals)
            if MetaUtils.localmax(fitvals):
                fitkeys, maxfit = self.best_dw()
                msg = "\nOptions %s found %s ambiguities **\n" % (fitkeys,maxfit)
                sys.stderr.write(msg)
                sys.exit(0)

            currd, currf = neighd, neighf



def usage(msg=None):
    if msg is not None:
        sys.stderr.write("** %s **\n" % msg)

    sys.stderr.write("Metasearch.py -x <experiment directory> " \
    "-g <grammar set> -b <backend to run> -d <initial depth>\n")
    sys.exit(1)


if __name__ == "__main__": 
    opts, args = getopt.getopt(sys.argv[1 : ], "x:g:b:d:w:")
    expdir, gset, backend, depth, wgt = None, None, None, None, None
    for opt in opts:
        if opt[0] == "-x":
            expdir = opt[1]
        elif opt[0] == "-g":
            gset = opt[1]
        elif opt[0] == "-b":
            backend = opt[1]
        elif opt[0] == "-d":
            depth = int(opt[1])
        elif opt[0] == "-w":
            wgt = float(opt[1])
        else: 
            usage("Unknown argument '%s'" % opt[0])

    if (expdir == None) or (gset == None) or (backend == None) or (depth == None):
        usage("Missing arguments!")

    Hillclimb(expdir, gset, backend, depth, wgt, TIMELIMIT)
    
