#! /usr/bin/env python

import os, subprocess, sys, tempfile
import getopt
import math

TOLERANCE = 0.01
RESULTSDIR="/home/nvasudev/codespace/experiment/results"

class Hillclimb:

    def __init__(self, sinbadx, gset, backend, depth, timelimit):
        self.sinbadx = sinbadx
        self.gset = gset
        self.backend = backend
        self.depth = depth
        self.timelimit = timelimit
        self.run()
        

    def fitness(self, currd):
        log =  "%s/%s/%s/%s/log" % (RESULTSDIR, "sinbad", self.gset, "%ss_-b_%s_-d_%s" % (timelimit,backend,currd)) 
        f = open(log)
        results = f.read()
        totallines = sum(1 for line in open(log))
        f.close()
        return results.count('yes'),totallines


    def sinbad(self, currd):
        cmd = [sinbadx,"-g",gset,"-t",str(timelimit),"-b",backend,"-d",str(currd)]
        print "cmd: %s" % " ".join(cmd)
        r = subprocess.call(cmd)
        if r != 0:
            sys.stderr.write("SinBAD failed for backend %s [depth=%s]" % (backend,str(currd)))
            sys.exit(1)
        

    def run(self):
        currd = self.depth
        self.sinbad(currd)
        currfit,_ = self.fitness(currd)
    
        while True:
            print "current depth: %s, fitness: %s" % (str(currd),str(currfit))
            neighd = currd + 1
            self.sinbad(neighd)
            newfit,lines = self.fitness(neighd)
            print "newfit: " , str(newfit)
            newfittol = newfit + math.ceil(TOLERANCE * lines)
            print "*newfittol: " , str(newfittol)        
            if newfittol >= currfit:
                currd = neighd
                currfit = newfit
            else:
                print "==> LOCAL MAXIMA!. depth: (%s), and fitness: %s" % (str(currd),str(currfit))
                break
            

def usage(msg=None):
    if msg is not None:
        sys.stderr.write(msg)
        
    sys.stderr.write("Metasearch.py -x <SinBAD script> " \
    "-g <grammar set> -b <backend to run> -d <initial depth>")
    sys.exit(1)
    

if __name__ == "__main__": 
    opts, args = getopt.getopt(sys.argv[1 : ], "x:g:b:d:")   
    print opts, args
    for opt in opts:
        if opt[0] == "-x":
            sinbadx = opt[1]
        elif opt[0] == "-g":
            gset = opt[1]
        elif opt[0] == "-b":
            backend = opt[1]
        elif opt[0] == "-d":
            depth = int(opt[1])
        else: 
            usage("Unknown argument '%s'" % opt[0])   
            
    timelimit = 30 
    Hillclimb(sinbadx, gset, backend, depth, timelimit)
    
