#!/usr/bin/env python

import sys
import getopt
import MetaUtils
import Depth1, Weight1, Weight2, Weight3

"""
Run metasearch for SinBAD tool for options depth and weight:
 - backend
 - depth
 - weight (where applicable)
 - Three different heuristics for exploring the `weight` option.
   - Weight1 or Weight2 or Weight3
Additionally pass timelimit, grammar, and the experiment directory
"""

RUN_SINBAD = "scripts/run_sinbad.sh"

class Hillclimb:

    def __init__(self, expdir, gset, backend, depth, wgt, timelimit, mtype):

        sinbadx =  "%s/%s" % (expdir, RUN_SINBAD)
        cmd = [sinbadx, "-g", gset, "-t", str(timelimit), "-b", backend]
        logd = "%s/results/sinbad/%s/%ss_-b_%s" % (expdir, gset, timelimit, backend)

        if mtype == 'Depth1':
            m = Depth1.run(cmd, logd, depth)
        elif mtype == 'Weight1':
            m = Weight1.run(cmd, logd, depth)
        elif mtype == 'Weight2':
            m = Weight2.run(cmd, logd, depth)
        elif mtype == 'Weight3':
            if wgt is None:
                usage('Need a value for Weight')

            m = Weight3.run(cmd, logd, depth, wgt)


def usage(msg=None):
    if msg is not None:
        sys.stderr.write("** %s **\n" % msg)

    sys.stderr.write("Metasearch.py -x <experiment directory> -g <grammar set> " \
                     "-b <backend to run> -d <initial depth> -t <time limit> " \
                     "-T <search type for weight> -w <wgt>\n")
    sys.exit(1)


if __name__ == "__main__":
    opts, args = getopt.getopt(sys.argv[1 : ], "x:g:b:d:w:t:T:")
    expdir, gset, backend, depth, wgt = None, None, None, None, None
    timelimit = None
    mtype = None
    for opt in opts:
        if opt[0] == "-x":
            expdir = opt[1]
        elif opt[0] == "-g":
            gset = opt[1]
        elif opt[0] == "-b":
            backend = opt[1]
        elif opt[0] == "-d":
            depth = int(opt[1])
        elif opt[0] == "-t":
            timelimit = int(opt[1])
        elif opt[0] == "-w":
            wgt = float(opt[1])
        elif opt[0] == "-T":
            mtype = opt[1]
        else:
            usage("Unknown argument '%s'" % opt[0])

    if (expdir == None) or (gset == None) or (backend == None) or (depth == None):
        usage("Missing arguments!")

    Hillclimb(expdir, gset, backend, depth, wgt, timelimit, mtype)

