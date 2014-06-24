#! /usr/bin/env python

import os, subprocess, sys
import getopt
import MetaUtils
from sets import Set
import random

TIMELIMIT = 30
WGTSTEP = 0.01

class Hillclimb:

    def __init__(self, expdir, gset, backend, depth, timelimit):
        self.expdir = expdir
        self.gset = gset
        self.backend = backend
        self.depth = depth
        self.timelimit = timelimit

        sinbadx =  "%s/run_SinBAD.sh" % (self.expdir)
        self.cmd = [sinbadx,"-g",self.gset,"-t",str(self.timelimit),"-b",self.backend,"-d",str(depth)]
        self.logdirprefix = "%ss_-b_%s" % (self.timelimit,backend)
        
        self.hillclimb()


    def fitness(self, depth, weight):
        """ fitness -> number of ambiguities found """
   
        logdir = "%s_-d_%s" % (self.logdirprefix,depth)
        if weight is not None:
            logdir = "%s_-w_%s" % (logdir,weight)

        log =  "%s/results/%s/%s/%s/log" % (self.expdir, "sinbad", self.gset, logdir) 

        return MetaUtils.ambtotal(log)


    def sinbad(self, depth, weight):
        """ Run the ambiguity checker tool from the experimental suite """
        sinbadx =  "%s/run_SinBAD.sh" % (self.expdir)
        cmd = [sinbadx,"-g",self.gset,"-t",str(self.timelimit),"-b",self.backend,"-d",str(depth)]
        if weight is not None:
            cmd.append("-w")
            cmd.append(str(weight))

        MetaUtils.runtool(cmd)
        return self.fitness(depth, weight)


    def neighwgt(self, w, values):
        if len(values) < 3:
            return w + WGTSTEP 

        if len(values) >= 10:
            recent10 = values[-10:]
            sdev10 = MetaUtils.stddev(recent10)
            MetaUtils.write("[wgt]recent10: %s, sdev10: %s \n" % (recent10,sdev10))
            if sdev10 < 3:
                return w + (10 * WGTSTEP)
            
        recent3 = values[-3:]
        MetaUtils.write("[wgt]recent3: %s  \n" % (recent3))
        sdev3 = MetaUtils.stddev(recent3)
        MetaUtils.write("[wgt]recent3: %s, sdev3: %s \n" % (recent3,sdev3))

        if sdev3 < 3:
                return w + (3 * WGTSTEP)
        else:
            return w + WGTSTEP



    def run_weights(self, d):
        w_values = []
        # start from w=0.0
        currw = 0.0
        currfit = self.sinbad(d, currw)
        w_values.append(currfit)
        while True:
            neighw = self.neighwgt(currw, w_values)           
            neighfit = self.sinbad(d, neighw)
            if len(w_values) >= 2:
                if (neighfit < w_values[-1]) and (neighfit < w_values[-2]):
                    MetaUtils.write("neighfit[%s] < currfit[%s]" % (str(neighfit),str(currfit)))
                    return currfit 

            currfit = neighfit
            currw = neighw
            w_values.append(currfit)



    def neighbour(self, d, values):
        if len(values) < 3:
            return d + 1

        if len(values) >= 10:
            recent10 = values[-10:]
            sdev10 = MetaUtils.stddev(recent10)
            MetaUtils.write("[d]recent10: %s, sdev10: %s \n" % (recent10,sdev10))
            if sdev10 < 3:
                return d + 10
            
        recent3 = values[-3:]
        MetaUtils.write("[d]recent3: %s  \n" % (recent3))
        sdev3 = MetaUtils.stddev(recent3)
        MetaUtils.write("[d]recent3: %s, sdev3: %s \n" % (recent3,sdev3))

        if sdev3 < 3:
                return  d + 3
        else:
            return d + 1
            


    def hillclimb(self):
        d_values = []
        currd = self.depth
        currfit = self.run_weights(currd)
        d_values.append(currfit)
         
        while True:
            neighd = self.neighbour(currd, d_values)
            neighfit = self.run_weights(neighd)
            d_values.append(neighfit)
            MetaUtils.write("\nneighd: %s, neighfit: %s \n" % (str(neighd),str(neighfit)))

            if newfit >= currfit:
                currd = neighd
                currfit = neighfit
            else:
                MetaUtils.write("\n==> LOCAL MAXIMA!. depth,fitness: %s,%s\n" % \
                                   (str(currd),str(currfit)))
                sys.exit(0)


def usage(msg=None):
    if msg is not None:
        MetaUtils.write(msg)
        
    MetaUtils.write("Metasearch.py -x <experiment directory> " \
    "-g <grammar set> -b <backend to run> -d <initial depth>")
    sys.exit(1)
    

if __name__ == "__main__": 
    opts, args = getopt.getopt(sys.argv[1 : ], "x:g:b:d:")   
    expdir, gset, backend, depth = None, None, None, None
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

    if (expdir == None) or (gset == None) or (backend == None) or (depth == None):
        usage("Missing arguments!")

    Hillclimb(expdir, gset, backend, depth, TIMELIMIT)
    
