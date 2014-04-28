#! /usr/bin/env python

import os, subprocess, sys
import getopt
import MetaUtils
from sets import Set

TIMELIMIT = 30
WGTSTEP = 0.01

class Hillclimb:

    def __init__(self, expdir, gset, backend, depth, weight, timelimit):
        self.expdir = expdir
        self.gset = gset
        self.backend = backend
        self.depth = depth
        self.weight = weight
        self.timelimit = timelimit
        self.traversed = Set()
        self.hillclimb()
        

    def fitness(self, depth, weight):
        """ fitness -> number of ambiguities found """
        sinbadlogdir = "%ss_-b_%s_-d_%s" % (self.timelimit,backend,depth)
        if weight is not None:
            sinbadlogdir = "%s_-w_%s" % (sinbadlogdir,weight)

        log =  "%s/results/%s/%s/%s/log" % (self.expdir, "sinbad", self.gset, sinbadlogdir) 
        return MetaUtils.ambtotal(log)


    def sinbad(self, depth, weight):
        """ Run the ambiguity checker tool from the experimental suite """
        sinbadx =  "%s/run_SinBAD.sh" % (self.expdir)
        cmd = [sinbadx,"-g",self.gset,"-t",str(self.timelimit),"-b",self.backend,"-d",str(depth)]
        if weight is not None:
            cmd.append("-w")
            cmd.append(str(weight))

        MetaUtils.runtool(cmd)

    
    def neighbours(self, depth, weight):
         # [(d-1,w),(d,w-1),(d,w+1),(d+1,w)]
         if weight is not None:
             neighs = []
             _neighs = [(depth-1,weight), (depth,(weight - (weight * WGTSTEP))), 
                        (depth,(weight + (weight * WGTSTEP))),(depth+1,weight),]
             for _neigh in _neighs:
                 if _neigh not in self.traversed:
                     neighs.append(_neigh)
                 else:
                     print "traversed: " , self.traversed
                     print "_neigh: " , _neigh

         else:
             neighs = [(depth+1,None)]

         return neighs

    
    def run_neighs(self, neighs):
        fits = []
        for (d,w) in neighs:
            self.sinbad(d,w)
            fit = self.fitness(d,w)
            fits.append(fit)
            self.traversed.add((d,w))

        return fits


    def run(self, _depth, _wgt):
        MetaUtils.write("\n===> depth,wgt: %s,%s\n" % (str(_depth),str(_wgt)))
        neighs = self.neighbours(_depth,_wgt)
        MetaUtils.write("neighs ==> %s" % (neighs))
        fits = self.run_neighs(neighs)
        maxfit = max(fits)

        fitinds = [] 
        for (i,fit) in enumerate(fits):
            if fit == maxfit:
                fitinds.append(i)

        _neighd,_neighwgt = neighs[max(fitinds)] 

        print "neighs: %s" % neighs
        print "fits: %s" % fits
        print "neigh d,w : %s,%s" % (_neighd,_neighwgt) 

        return _neighd,_neighwgt,maxfit



    def hillclimb(self):
        """Perform hill climb. Since SinBAD is nondeterministic, there is bound
           to be minor variations in the results from run to run. So to be sure 
           we are not terminating our hill climb prematurely, we increment the
           depth and try one more time.""" 
        currd = self.depth
        currwgt = self.weight
        self.sinbad(currd,currwgt)
        self.traversed.add((currd,currwgt))
        currfit = self.fitness(currd,currwgt)
         
        while True:
            neighd,neighwgt,neighfit = self.run(currd,currwgt) 
            if neighfit >= currfit:
                MetaUtils.write("\n** depth,wgt[fitness] (%s,%s)[%s] ==>  (%s,%s)[%s] **\n" % \
                               (currd,currwgt,currfit,neighd,neighwgt,neighfit))
                currd = neighd
                currwgt = neighwgt
                currfit = neighfit
            else:
                MetaUtils.write("** trying d+1 **")
                neighd,neighwgt,neighfit = self.run(currd+1,currwgt)
                if neighfit > currfit:
                    MetaUtils.write("\n** depth,wgt[fitness] (%s,%s)[%s] ==>  (%s,%s)[%s] **\n" % \
                                   (currd,currwgt,currfit,neighd,neighwgt,neighfit))
                    currd = neighd
                    currwgt = neighwgt
                    currfit = neighfit
                else:
                    MetaUtils.write("\n==> LOCAL MAXIMA!. depth,wgt,fitness: %s,%s,%s\n" % \
                                   (str(currd),str(currwgt),str(currfit)))
                    sys.exit(0)


def usage(msg=None):
    if msg is not None:
        MetaUtils.write(msg)
        
    MetaUtils.write("Metasearch.py -x <experiment directory> " \
    "-g <grammar set> -b <backend to run> -d <initial depth>")
    sys.exit(1)
    

if __name__ == "__main__": 
    opts, args = getopt.getopt(sys.argv[1 : ], "x:g:b:d:w:")   
    expdir, gset, backend, depth, weight = None, None, None, None, None
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
            weight = float(opt[1])
        else: 
            usage("Unknown argument '%s'" % opt[0])   

    if (expdir == None) or (gset == None) or (backend == None) or (depth == None):
        usage("Missing arguments!")

    Hillclimb(expdir, gset, backend, depth, weight, TIMELIMIT)
    
