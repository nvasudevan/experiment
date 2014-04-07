#! /usr/bin/env python

import os, subprocess, sys, tempfile
import getopt
import math


TOLERANCE = 0.01
TIMELIMIT = 30

class Hillclimb:

    def __init__(self, expdir, gset, backend, depth, timelimit):
        self.expdir = expdir
        self.gset = gset
        self.backend = backend
        self.depth = depth
        self.timelimit = timelimit
        self.run()
        

    def fitness(self, currd):
        """ fitness -> number of ambiguities found """
        log =  "%s/results/%s/%s/%s/log" % (self.expdir, "sinbad", self.gset, "%ss_-b_%s_-d_%s" % (timelimit,backend,currd)) 
        f = open(log)
        results = f.read()
        totallines = sum(1 for line in open(log))
        f.close()
        return results.count('yes'),totallines


    def sinbad(self, currd):
        """ Run the ambiguity checker tool from the experimental suite """
        sinbadx =  "%s/run_SinBAD.sh" % (self.expdir)
        cmd = [sinbadx,"-g",gset,"-t",str(timelimit),"-b",backend,"-d",str(currd)]
        print "cmd: %s" % " ".join(cmd)
        r = subprocess.call(cmd)
        if r != 0:
            sys.stderr.write("SinBAD failed for backend %s [depth=%s]" % (backend,str(currd)))
            sys.exit(1)
        

    def run(self):
        """Perform hill climb. Since SinBAD is nondeterministic, there is bound
           to be minor variations in the results from run to run. So to be sure 
           we are not terminating our hill climb prematurely, we add tolarance (small value) 
           to the neighbour's fitness. This will allow the hill climb to progress until we 
           start hitting less fit individuals consistenly. """
        currd = self.depth
        self.sinbad(currd)
        currfit,_ = self.fitness(currd)
    
        while True:
            print "current depth: %s, fitness: %s" % (str(currd),str(currfit))
            neighd = currd + 1
            self.sinbad(neighd)
            newfit,lines = self.fitness(neighd)
            print "newfit: " , str(newfit)
            # add tolerance as a percentage of number of grammars
            newfittol = newfit + math.ceil(TOLERANCE * lines)
            print "newfit: %s, newfittol: %s" % (str(newfit),str(newfittol))
            if newfittol >= currfit:
                currd = neighd
                currfit = newfit
            else:
                print "==> LOCAL MAXIMA!. depth: (%s), and fitness: %s" % (str(currd),str(currfit))
                sys.exit(0)
            

def usage(msg=None):
    if msg is not None:
        sys.stderr.write(msg)
        
    sys.stderr.write("Metasearch.py -x <experiment directory> " \
    "-g <grammar set> -b <backend to run> -d <initial depth>")
    sys.exit(1)
    


if __name__ == "__main__": 
    opts, args = getopt.getopt(sys.argv[1 : ], "x:g:b:d:")   
    print opts, args
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
            
    Hillclimb(expdir, gset, backend, depth, TIMELIMIT)
    
