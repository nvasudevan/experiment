
import MetaUtils
import sys

D_STEP1 = 1
D_STEP2 = 3

STDDEV_CNT = 3
STDDEV = 3

""" Run metasearch from a given initial depth """

class Depth1:

    def __init__(self, cmd, logd, depth):
        self.cmd = cmd
        self.logd = logd
        self.k_values = []

        currd = depth
        currf = self.sinbad(currd)
        self.k_values.append((currd, currf))

        while True:
            msg = "\n==> current depth: %s, fitness: %s\n" % (currd, currf)
            sys.stderr.write(msg)
            neighd = self.neighbour(self.k_values, currd)
            neighf = self.sinbad(neighd)
            self.k_values.append((neighd, neighf))

            print "------"
            if MetaUtils.localmax([f for _,f in self.k_values]):
                fitd, maxf = self.best(self.k_values)
                print "Max ambiguities found: %s" % maxf
                print "Best depths: " , fitd
                sys.exit(0)

            currd, currf = neighd, neighf



    def best(self, vals):
        fitvals = [f for _,f in vals]
        maxfit = max(fitvals)

        fitd = []
        for d,f in vals:
            if f == maxfit:
                fitd.append(d)

        return fitd, maxfit



    def neighbour(self, key_fits, d):
        fits = [f for _,f in key_fits]
        if MetaUtils.move_by_step1(fits, STDDEV_CNT, STDDEV):
            return d + D_STEP1

        return d + D_STEP2


    def sinbad(self, d):
        MetaUtils.runtool(self.cmd + ["-d", str(d)])
        f = MetaUtils.fitness("%s_-d_%s/log" % (self.logd, d))
        return f




def run(cmd, logd, depth):
    Depth1(cmd, logd, depth)

