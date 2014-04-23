#! /usr/bin/env python

import os, subprocess, sys
import getopt
import MetaUtils

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
        self.run()
        

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
         _neighs = [(depth+1,weight)]
         if weight is not None:
             _wgt = weight + (weight * WGTSTEP)
             _neighs.append((depth,_wgt))

         return _neighs

    
    def run_neighs(self, neighs):
        fits = []
        for (d,w) in neighs:
            self.sinbad(d,w)
            fit = self.fitness(d,w)
            fits.append(fit)

        return fits


    def run(self):
        """Perform hill climb. Since SinBAD is nondeterministic, there is bound
           to be minor variations in the results from run to run. So to be sure 
           we are not terminating our hill climb prematurely, we add tolarance (small value) 
           to the neighbour's fitness. This will allow the hill climb to progress until we 
           start hitting less fit individuals consistently. """
        currd = self.depth
        currwgt = self.weight
        self.sinbad(currd,currwgt)
        currfit = self.fitness(currd,currwgt)
    
        while True:
            MetaUtils.write("\n===> current depth,wgt: %s,%s, fitness: %s\n" % (str(currd),str(currwgt),str(currfit)))
            neighs = self.neighbours(currd,currwgt)
            MetaUtils.write("neighs ==> %s" % (neighs))
            fits = self.run_neighs(neighs)
            newfit = max(fits)
            if newfit >= currfit:
                d_w = neighs[fits.index(newfit)]
                MetaUtils.write("\n** depth,wgt (%s,%s) ==>  (%s) **\n" % (currd,currwgt,d_w))
                currd,currwgt = d_w 
                currfit = newfit
            else:
                MetaUtils.write("** trying d+1 **")
                neighs = self.neighbours(currd+1,currwgt)
                MetaUtils.write("neighs: %s" % (neighs))
                fits = self.run_neighs(neighs)
                newfit = max(fits)
                if newfit > currfit:
                    d_w = neighs[fits.index(newfit)]
                    MetaUtils.write("\ndepth,wgt: %s, currfit: %s, newfit: %s\n" % (d_w,currfit,str(newfit)))
                    currd,currwgt = d_w 
                    currfit = newfit
                else:
                    MetaUtils.write("\n==> LOCAL MAXIMA!. depth,wgt: (%s,%s), and fitness: %s\n" % (str(currd),str(currwgt),str(currfit)))
                    sys.exit(0)


def usage(msg=None):
    if msg is not None:
        MetaUtils.write(msg)
        
    MetaUtils.write("Metasearch.py -x <experiment directory> " \
    "-g <grammar set> -b <backend to run> -d <initial depth>")
    sys.exit(1)
    

if __name__ == "__main__": 
    opts, args = getopt.getopt(sys.argv[1 : ], "x:g:b:d:w:")   
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
            weight = float(opt[1])
        else: 
            usage("Unknown argument '%s'" % opt[0])   

    Hillclimb(expdir, gset, backend, depth, weight, TIMELIMIT)
    
