
import MetaUtils
import sys

D_STEP1 = 1
D_STEP2 = 3
WGT_STEP1 = 1.05
WGT_STEP2 = 1.1

NNEIGH = 3
STDDEV = 3
NBEST = 3

"""
For a given depth, explore weight from a initial value.
"""

class Weight4:

    def __init__(self, cmd, logd, depth, wgt):
        self.cmd = cmd
        self.logd = logd
        self.k_values = []

        currd = depth
        fitw, currf = self.sinbad(currd, wgt)

        print "------"
        print "Ambiguities found: " , currf
        print "fit wgts: %s" , fitw


    def best_w(self, vals):
        fitvals = [f for k,f in vals]
        maxfit = max(fitvals)

        fitkeys = []
        for k,f in vals:
            if f == maxfit:
                fitkeys.append(k)

        return fitkeys, maxfit


    def best(self, vals):
        fitvals = [f for _,_,f in vals]
        maxfit = max(fitvals)

        fitdw = []
        for d,w,f in vals:
            if f == maxfit:
                fitdw.append((d,w))

        return fitdw, maxfit


    def neighbourd(self, key_fits, d):
        fits = [f for _,_,f in key_fits]
        if MetaUtils.move_by_step1(fits, NNEIGH, STDDEV):
            return d + D_STEP1

        return d + D_STEP2


    def neighbourw(self, key_fits, w):
        fits = [f for _,f in key_fits]
        if MetaUtils.move_by_step1(fits, NNEIGH, STDDEV):
            return (w * WGT_STEP1)

        return (w * WGT_STEP2)


    def sinbad(self, d, wgt):
        w = wgt
        d_cmd = ["-d", str(d)]
        w_cmd = ["-w", str(w)]
        MetaUtils.runtool(self.cmd + d_cmd + w_cmd)

        logp = "%s_-d_%s_-w_%s/log" % (self.logd, d, w)
        f = MetaUtils.fitness(logp)
        w_values = [(w,f)]

        while True:
            sys.stderr.write("\n(d, w, f) => (%s, %s, %s)\n" % \
                            (str(d), str(w), str(f)))
            neighw = self.neighbourw(w_values, w)
            w_cmd = ["-w", str(neighw)]
            MetaUtils.runtool(self.cmd + d_cmd + w_cmd)
            logp = "%s_-d_%s_-w_%s/log" % (self.logd, d, neighw)
            neighf = MetaUtils.fitness(logp)
            w_values.append((neighw,neighf))
            fits = [f for _,f in w_values]

            if MetaUtils.localmax(fits):
                for k,f in w_values:
                    print "(%s,%s)" % (k,f)

                fitw,maxf = self.best_w(w_values)
                msg = "\n%s ambiguities found" % maxf
                msg += "\nd=%s, w=%s\n" % (d, fitw)
                sys.stderr.write(msg)

                return fitw, maxf

            w, f = neighw, neighf



def run(cmd, logd, depth, weight):
    Weight4(cmd, logd, depth, weight)

