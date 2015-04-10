#! /usr/bin/env python

import sys, tempfile
import getopt
import math
import MetaUtils

TIMELIMIT = 10
EX_STEP1 = 1.05
EX_STEP2 = 1.1
EX_STEP3 = 1.2
LEN_STEP1 = 1
LEN_STEP2 = 3
LEN_STEP3 = 5

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
        if self.switch == "-n":
            return MetaUtils.neighbour(self.k_values,
                                       int(math.ceil(v * EX_STEP1)),
                                       int(math.ceil(v * EX_STEP2)),
                                       int(math.ceil(v * EX_STEP3)))
        else:
            return MetaUtils.neighbour(self.k_values,
                                       v+LEN_STEP1,
                                       v+LEN_STEP2,
                                       v+LEN_STEP3)

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
            newfit = MetaUtils.fitness("%s_%s/log" % (self.logd, neighval))
            sys.stderr.write("new fitness: %s " % str(newfit))
            self.k_values.append((neighval, newfit))

            if MetaUtils.keep_running(self.k_values):
                currval = neighval
                currfit = newfit



def usage(msg=None):
    if msg is not None:
        sys.stderr.write(msg)

    sys.stderr.write("Metasearch.py -x <experiment directory> " \
    "-g <grammar set> -n <number of examples> -l <initial length -e>\n")
    sys.exit(1)


if __name__ == "__main__":
    opts, args = getopt.getopt(sys.argv[1 : ], "x:g:n:l:e")
    expdir = None
    gset = None
    length = None
    examples = None
    ellipsis = False
    for opt in opts:
        if opt[0] == "-x":
            expdir = opt[1]
        elif opt[0] == "-g":
            gset = opt[1]
        elif opt[0] == "-n":
            examples = int(opt[1])
        elif opt[0] == "-l":
            length = int(opt[1])
        elif opt[0] == "-e":
            ellipsis = True
        else:
            usage("Unknown argument '%s'" % opt[0])

    if (expdir is None) or (gset is None):
        usage()

    if (examples is None) and (length is None):
        usage()

    print opts, args
    Hillclimb(expdir, gset, examples, length, ellipsis, TIMELIMIT)

