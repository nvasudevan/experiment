#! /usr/bin/env python

import sys, tempfile
import getopt
import math
import MetaUtils

TIMELIMIT = 10

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

        self.k_values = []
        self.run()


    def fitness(self, optval):
        """ fitness -> number of ambiguities found """
        logdir = "%s_-k_%s" % (self.logdirprefix, optval)
        log =  "%s/results/%s/%s/%s/log" % (self.expdir, "ambidexter", self.gset, logdir) 
        return MetaUtils.ambtotal(log)



    def neighbour(self, l):
        """ if the last 3 values are roughly the same, the return +3 
            otherwise, + 1"""
        if len(self.k_values) < 3:
            return l + 1

        recent3 = self.k_values[-3:]
        recent10 = self.k_values[-10:]
        recent3vals,recent10vals = [],[]
        for k,v in recent3:
            recent3vals.append(v)
        
        for k,v in recent10:
            recent10vals.append(v)
        
        sdev3 = MetaUtils.stddev(recent3vals)
        sdev10 = MetaUtils.stddev(recent10vals)
        
        sys.stderr.write("recent10vals: %s, sdev3: %s, sdev10: %s \n" % (recent10vals,sdev3,sdev10))
        if sdev3 < 3:
            if sdev10 < 3:
                return l + 10
            else:
                return l + 3
        else:
            return l + 1



    def run(self):
        currlen = self.length
        ambidextoptcmd = ["-k",str(currlen)]
        MetaUtils.runtool(self.cmd + ambidextoptcmd)
        currfit = self.fitness(currlen)
        self.k_values.append((currlen,currfit))

        while True:
            sys.stderr.write("\n==> current length: %s, fitness: %s\n" % (str(currlen),str(currfit)))
            neighlen = self.neighbour(currlen)
            ambidextoptcmd = ["-k",str(neighlen)]
            MetaUtils.runtool(self.cmd + ambidextoptcmd)
            newfit = self.fitness(neighlen)
            self.k_values.append((neighlen,newfit))
            
            sys.stderr.write("new fitness: %s " % str(newfit))

            if newfit >= currfit:
                currlen = neighlen
                currfit = newfit
            else:
                sys.stderr.write("\n** Reached maxima! length: %s ambiguities found: %s **\n" % (str(currlen), str(currfit)))
                for k,v in self.k_values:
                    print "%s,%s" % (k,v)
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
    
