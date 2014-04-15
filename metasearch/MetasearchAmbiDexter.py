#! /usr/bin/env python

import sys, tempfile
import getopt
import math
import MetaUtils

TIMELIMIT = 30

class Hillclimb:

    def __init__(self, expdir, gset, length, filter, timelimit):
        self.expdir = expdir
        self.gset = gset
        self.length = length
        self.filter = filter
        self.timelimit = timelimit

        ambidextx =  "%s/run_AmbiDexter.sh" % (self.expdir)
        self.cmd = [ambidextx,"-g",self.gset,"-t",str(self.timelimit)]

        if self.filter is not None:
            self.cmd += ["-f",self.filter]
            self.logdirprefix = "%ss_-f_%s" % (self.timelimit,self.filter)
        else:
            self.logdirprefix = "%ss" % (self.timelimit)

        self.run()


    def fitness(self, optval):
        """ fitness -> number of ambiguities found """
        logdir = "%s_-k_%s" % (self.logdirprefix, optval)
        log =  "%s/results/%s/%s/%s/log" % (self.expdir, "ambidexter", self.gset, logdir) 
        return MetaUtils.ambtotal(log)


    def run(self):
        currlen = self.length
        ambidextoptcmd = ["-k",str(currlen)]
        MetaUtils.runtool(self.cmd + ambidextoptcmd)
        currfit = self.fitness(currlen)

        while True:
            sys.stderr.write("\n==> current length: %s, fitness: %s\n" % (str(currlen),str(currfit)))
            neighlen = currlen + 1
            ambidextoptcmd = ["-k",str(neighlen)]
            MetaUtils.runtool(self.cmd + ambidextoptcmd)
            newfit = self.fitness(neighlen)
            
            sys.stderr.write("new fitness: %s " % str(newfit))

            if newfit >= currfit:
                currlen = neighlen
                currfit = newfit
            else:
                sys.stderr.write("\n** Reached maxima! length: %s ambiguities found: %s **\n" % (str(currlen), str(currfit)))
                sys.exit(0) 


def usage(msg=None):
    if msg is not None:
        sys.stderr.write(msg)
        
    sys.stderr.write("MetasearchAmbiDexter.py -x <experiment directory> " \
    "-g <grammar set> -k <initial length>")
    sys.exit(1)
    


if __name__ == "__main__": 
    opts, args = getopt.getopt(sys.argv[1 : ], "x:g:k:f:")
    print opts, args
    length = None
    filter = None
    for opt in opts:
        if opt[0] == "-x":
            expdir = opt[1]
        elif opt[0] == "-g":
            gset = opt[1]
        elif opt[0] == "-f":
            filter = opt[1]
        elif opt[0] == "-k":
            length = int(opt[1])
        else: 
            usage("Unknown argument '%s'" % opt[0])   

    Hillclimb(expdir, gset, length, filter, TIMELIMIT)
    
