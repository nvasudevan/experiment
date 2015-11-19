#! /usr/bin/env python

import sys, tempfile
import getopt
import math
import MetaUtils

"""
Run metasearch for AMBER tool for either of these options:
 - length (+ optionally ellipsis)
 - examples (+ optionally ellipsis)

Additionally pass timelimit, grammar, and the experiment directory
"""

TIMELIMIT = 10
EX_STEP1 = 1.05
EX_STEP2 = 1.1
EX_STEP3 = 1.2
LEN_STEP1 = 1
LEN_STEP2 = 3
LEN_STEP3 = 5
STDDEV_CNT = 3
STDDEV = 3

class Hillclimb:

    def __init__(self, expdir, gset, examples, length, ellipsis, timelimit):
        self.k_values = []
        self.logd = "%s/results/amber/%s/%ss" % (expdir, gset, timelimit)

        amberx =  "%s/run_Amber.sh" % (expdir)
        self.cmd = [amberx, "-g", gset, "-t", str(timelimit)]

        if ellipsis:
            self.cmd.append("-e")
            self.logd += "_ellipsis"

        if examples is not None:
            self.switch = "-n"
            self.initval = examples
            self.logd += "_examples"
        else:
            self.switch = "-l"
            self.initval = length
            self.logd += "_length"

        self.run()


    def neighbour(self, v):
        fits = [f for _,f in self.k_values]
        if self.switch == "-n":
            if MetaUtils.move_by_step1(fits, STDDEV_CNT, STDDEV):
                return int(math.ceil(v * EX_STEP1))

            return int(math.ceil(v * EX_STEP2))

        if MetaUtils.move_by_step1(fits, STDDEV_CNT, STDDEV):
            return v + LEN_STEP1

        return v + LEN_STEP2


    def run(self):
        currval = self.initval
        amberoptcmd = [self.switch, str(currval)]
        MetaUtils.runtool(self.cmd + amberoptcmd)
        currfit = MetaUtils.fitness("%s_%s/log" % (self.logd, currval))
        self.k_values.append((currval,currfit))

        while True:
            sys.stderr.write("\n==> current value: %s, fitness: %s\n" \
                             % (str(currval),str(currfit)))
            neighval = self.neighbour(currval)
            sys.stderr.write("neighval: %s" % (str(neighval)))
            amberoptcmd = [self.switch, str(neighval)]
            MetaUtils.runtool(self.cmd + amberoptcmd)
            neighfit = MetaUtils.fitness("%s_%s/log" % (self.logd, neighval))
            sys.stderr.write("new fitness: %s " % str(neighfit))
            self.k_values.append((neighval,neighfit))

            fitvals = [f for _,f in self.k_values]
            if MetaUtils.localmax(fitvals, 3):
                MetaUtils.report(self.k_values)
                sys.exit(0)

            currval = neighval
            currfit = neighfit



def usage(msg=None):
    if msg is not None:
        sys.stderr.write(msg)

    sys.stderr.write("MetasearchAmber.py -x <experiment directory> " \
    "-g <grammar set> -n <number of examples> -l <initial length> " \
    "-t <time limit> -e\n")
    sys.exit(1)


if __name__ == "__main__":
    opts, args = getopt.getopt(sys.argv[1 : ], "x:g:n:l:t:e")
    expdir = None
    gset = None
    length = None
    examples = None
    ellipsis = False
    timelimit = None
    for opt in opts:
        if opt[0] == "-x":
            expdir = opt[1]
        elif opt[0] == "-g":
            gset = opt[1]
        elif opt[0] == "-n":
            examples = int(opt[1])
        elif opt[0] == "-l":
            length = int(opt[1])
        elif opt[0] == "-t":
            timelimit = int(opt[1])
        elif opt[0] == "-e":
            ellipsis = True
        else:
            usage("Unknown argument '%s'" % opt[0])

    if (expdir is None) or (gset is None):
        usage()

    if (examples is None) and (length is None):
        usage()

    print opts, args
    Hillclimb(expdir, gset, examples, length, ellipsis, timelimit)

