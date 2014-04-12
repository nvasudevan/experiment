#! /usr/bin/env python

import os, subprocess, sys
import getopt
import MetaUtils

TIMELIMIT = 30

class Hillclimb:

    def __init__(self, expdir, gset, backend, depth, weight, timelimit):
        self.expdir = expdir
        self.gset = gset
        self.backend = backend
        self.depth = depth
        self.weight = weight
        self.timelimit = timelimit
        self.run()
        

    def fitness(self, depth):
        """ fitness -> number of ambiguities found """
        sinbadlogdir = "%ss_-b_%s_-d_%s" % (self.timelimit,backend,depth)
        if self.weight is not None:
            sinbadlogdir = "%s_-w_%s" % (sinbadlogdir,self.weight)

        log =  "%s/results/%s/%s/%s/log" % (self.expdir, "sinbad", self.gset, sinbadlogdir) 
        return MetaUtils.ambtotal(log)


    def sinbad(self, depth):
        """ Run the ambiguity checker tool from the experimental suite """
        sinbadx =  "%s/run_SinBAD.sh" % (self.expdir)
        cmd = [sinbadx,"-g",self.gset,"-t",str(self.timelimit),"-b",self.backend,"-d",str(depth)]
        if self.weight != None:
            cmd.append("-w")
            cmd.append(self.weight)

        MetaUtils.runtool(cmd)


    def run(self):
        """Perform hill climb. Since SinBAD is nondeterministic, there is bound
           to be minor variations in the results from run to run. So to be sure 
           we are not terminating our hill climb prematurely, we add tolarance (small value) 
           to the neighbour's fitness. This will allow the hill climb to progress until we 
           start hitting less fit individuals consistently. """
        currd = self.depth
        self.sinbad(currd)
        currfit = self.fitness(currd)
    
        while True:
            print "current depth: %s, fitness: %s" % (str(currd),str(currfit))
            neighd = currd + 1
            self.sinbad(neighd)
            newfit = self.fitness(neighd)

            print "currfit: %s, newfit: %s" % (currfit,str(newfit))
            if newfit > currfit:
                currd = neighd
                currfit = newfit
            else:
                # we try one more depth and see if there is a better fit individual
                neighd2 = neighd + 1
                print "LAST TIME: trying depth: " , str(neighd2)
                self.sinbad(neighd2)
                newfit2 = self.fitness(neighd2)

                if newfit2 > currfit:
                    currd = neighd2
                    currfit = newfit2
                else:
                    print "==> LOCAL MAXIMA!. depth: (%s), and fitness: %s" % (str(depth),str(currfit))
                    sys.exit(0)


def usage(msg=None):
    if msg is not None:
        sys.stderr.write(msg)
        
    sys.stderr.write("Metasearch.py -x <experiment directory> " \
    "-g <grammar set> -b <backend to run> -d <initial depth>")
    sys.exit(1)
    

if __name__ == "__main__": 
    opts, args = getopt.getopt(sys.argv[1 : ], "x:g:b:d:w:")   
    print opts, args
    weight = None
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
            weight = opt[1]
        else: 
            usage("Unknown argument '%s'" % opt[0])   

    Hillclimb(expdir, gset, backend, depth, weight, TIMELIMIT)
    
