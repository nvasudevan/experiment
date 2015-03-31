#! /usr/bin/env python

import sys, tempfile
import getopt
import math
import MetaUtils

TIMELIMIT = 10
EXAMPLES_INCREMENT = 1.1
EXAMPLES_INCREMENT_LVAL = 1.3
EXAMPLES_INCREMENT_HVAL = 2.0
LENGTH_LVAL = 3
LENGTH_HVAL = 10

class Hillclimb:

    def __init__(self, expdir, gset, examples, length, ellipsis, timelimit):
        self.expdir = expdir
        self.gset = gset
        self.examples = examples
        self.length = length
        self.ellipsis = ellipsis
        self.timelimit = timelimit
        self.k_values = []

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


    def neighbour(self, neigh, sdev3neigh, sdev10neigh):
        if len(self.k_values) < 3:
            sys.stderr.write("recent: %s" % self.k_values)
            return  neigh

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
            return sdev3neigh
            #if sdev10 < 3:
            #    return sdev10neigh
            #else:
            #    return sdev3neigh
        else:
            return neigh


    def neighbourlen(self, l):
        return self.neighbour(l+1, l+3, l+10)
        

    def neighbourex(self, n):
        return self.neighbour(int(math.ceil(n * EXAMPLES_INCREMENT)), 
                  int(math.ceil(n * EXAMPLES_INCREMENT_LVAL)), 
                  int(math.ceil(n * EXAMPLES_INCREMENT_HVAL))) 


    def keep_running(self):
        """ if we see a downward trend for the last 3 values, stop """
        if len(self.k_values) > 3:
            _, fit = self.k_values[-1]
            _, _fit = self.k_values[-2]
            _, __fit = self.k_values[-3]
            _, ___fit = self.k_values[-4]
            if (fit <= _fit) and (_fit <= __fit) and (__fit <= ___fit):
                return False

        return True


    def finish(self):
        fitvals = [f for k,f in self.k_values]
        fitkeys = []
        for k,f in self.k_values:
            if f == max(fitvals):
                fitkeys.append(k)

        print "\n** Reached (local) maxima! **\n"
        for k,f in self.k_values:
            print "(%s,%s)" % (k,f)

        msg = "Options %s found %s ambiguities **\n" % (fitkeys,max(fitvals))
        sys.stderr.write(msg)
        sys.exit(0) 


    def run_examples(self):
        currex = self.examples
        amberoptcmd = ["-n",str(currex)]
        MetaUtils.runtool(self.cmd + amberoptcmd)
        currfit = self.fitness(currex)
        self.k_values.append((currex,currfit))

        while True:
            sys.stderr.write("\n==> current examples count: %s, fitness: %s\n" % (str(currex),str(currfit)))
            neighex = self.neighbourex(currex)
            sys.stderr.write("neighex: %s" % (str(neighex)))
            amberoptcmd = ["-n",str(neighex)]
            MetaUtils.runtool(self.cmd + amberoptcmd)
            newfit = self.fitness(neighex)
            self.k_values.append((neighex,newfit))            
            
            sys.stderr.write("new fitness: %s " % str(newfit))

            if self.keep_running():
                currex = neighex
                currfit = newfit
            else:
                self.finish()


    def run_length(self):
        currlen = self.length
        amberoptcmd = ["-l",str(currlen)]
        MetaUtils.runtool(self.cmd + amberoptcmd)
        currfit = self.fitness(currlen)
        self.k_values.append((currlen,currfit))

        while True:
            sys.stderr.write("\n==> current length: %s, fitness: %s\n" % (str(currlen),str(currfit)))
            neighlen = self.neighbourlen(currlen)
            amberoptcmd = ["-l",str(neighlen)]
            MetaUtils.runtool(self.cmd + amberoptcmd)
            newfit = self.fitness(neighlen)
            self.k_values.append((neighlen,newfit))            

            sys.stderr.write("new fitness: %s " % str(newfit))

            if self.keep_running():
                currlen = neighlen
                currfit = newfit
            else:
                self.finish()


def usage(msg=None):
    if msg is not None:
        sys.stderr.write(msg)
        
    sys.stderr.write("Metasearch.py -x <experiment directory> " \
    "-g <grammar set> -n <number of examples> -l <initial length -e>\n")
    sys.exit(1)
    


if __name__ == "__main__": 
    opts, args = getopt.getopt(sys.argv[1 : ], "x:g:n:l:e")   
    expdir = None
    gset = None
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

    if (expdir is None) or (gset is None):
        usage()

    if (examples is None) and (length is None):
        usage()

    print opts, args
    Hillclimb(expdir, gset, examples, length, ellipsis, TIMELIMIT)
    
