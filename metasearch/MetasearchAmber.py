#! /usr/bin/env python

import sys, tempfile
import getopt
import math
import MetaUtils

TIMELIMIT = 30

class Hillclimb:

    def __init__(self, expdir, gset, examples, length, ellipsis, timelimit):
        self.expdir = expdir
        self.gset = gset
        self.examples = examples
        self.length = length
        self.ellipsis = ellipsis
        self.timelimit = timelimit

        amberx =  "%s/run_Amber.sh" % (self.expdir)
        self.cmd = [amberx,"-g",self.gset,"-t",str(self.timelimit)]
        if self.ellipsis:
            self.cmd.append("-e")

        if self.examples is not None:
            self.logdirprefix = "%ss_examples" % (self.timelimit)
            self.run_examples()
        else:
            self.logdirprefix = "%ss_length" % (self.timelimit)
            self.run_length()


    def fitness(self, optval):
        """ fitness -> number of ambiguities found """
        amberlogdir = "%s_%s" % (self.logdirprefix, optval)

        if self.ellipsis:
            amberlogdir = "%s_ellipsis" % (amberlogdir)

        log =  "%s/results/%s/%s/%s/log" % (self.expdir, "amber", self.gset, amberlogdir) 
        return MetaUtils.ambtotal(log)



    def run_examples(self):
        currex = self.examples
        amberoptcmd = ["-n",str(currex)]
        MetaUtils.runtool(self.cmd + amberoptcmd)
        currfit = self.fitness(currex)

        while True:
            sys.stderr.write("\n==> current examples count: %s, fitness: %s\n" % (str(currex),str(currfit)))
            neighex = int(math.ceil(currex * 1.1))
            amberoptcmd = ["-n",str(neighex)]
            MetaUtils.runtool(self.cmd + amberoptcmd)
            newfit = self.fitness(neighex)
            
            sys.stderr.write("new fitness: %s " % str(newfit))

            if newfit >= currfit:
                currex = neighex
                currfit = newfit
            else:
                sys.stderr.write("\n** Reached maxima! examples: %s ambiguities found: %s *\n*" % (str(currex), str(currfit)))
                sys.exit(0) 


    def run_length(self):
        currlen = self.length
        amberoptcmd = ["-l",str(currlen)]
        MetaUtils.runtool(self.cmd + amberoptcmd)
        currfit = self.fitness(currlen)

        while True:
            sys.stderr.write("\n==> current length: %s, fitness: %s\n" % (str(currlen),str(currfit)))
            neighlen = currlen + 1
            amberoptcmd = ["-l",str(neighlen)]
            MetaUtils.runtool(self.cmd + amberoptcmd)
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
        
    sys.stderr.write("Metasearch.py -x <experiment directory> " \
    "-g <grammar set> -n <number of examples> -l <initial length -e>")
    sys.exit(1)
    


if __name__ == "__main__": 
    opts, args = getopt.getopt(sys.argv[1 : ], "x:g:n:l:e")   
    print opts, args
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

    Hillclimb(expdir, gset, examples, length, ellipsis, TIMELIMIT)
    
