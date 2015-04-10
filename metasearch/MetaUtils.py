#! /usr/bin/env python

import os, subprocess, sys
import math

def write(msg):
    sys.stdout.write(msg)
    sys.stdout.flush()


def ambtotal(log):
    f = open(log)
    results = f.read()
    f.close()
    return results.count('yes')


def fitness(log, foundall=False):
    """ fitness -> number of ambiguities found
        optionally, we can stop if all grammars are ambiguous (and detected)
    """
    fit = ambtotal(log)
    if foundall:
        gtot = sum(1 for line in open(log))
        if fit == gtot:
            sys.stderr.write("Found all ambiguities! Quitting...")
            sys.exit(0)

    return fit


def runtool(cmd):
    cmdstr = " ".join(cmd)
    sys.stderr.write("\ncmd : %s\n" % cmdstr)
    r = subprocess.call(cmd)

    if r != 0:
        sys.stderr.write("cmd: %s failed!" % (cmdstr))
        sys.exit(1)


def mean(l):
    if len(l) > 0:
        return (sum(l) * 1.0)/len(l)

    return None


def stddev(l):
    if len(l) > 0:
        m = mean(l)
        variance = [((v - m)**2) for v in l]
        return math.sqrt(mean(variance))

    return None


def neighbour(vals, neigh1, neigh2, neigh3):
    if len(vals) > 3:
        recent3 = vals[-3:]
        recent10 = vals[-10:]
        recent3vals,recent10vals = [],[]
        for k,v in recent3:
            recent3vals.append(v)

        for k,v in recent10:
            recent10vals.append(v)

        sdev3 = stddev(recent3vals)
        sdev10 = stddev(recent10vals)

        sys.stderr.write("recent10vals: %s, sdev3: %s, sdev10: %s \n" \
                         % (recent10vals, sdev3, sdev10))
        if sdev3 < 3:
            #if sdev10 < 3:
            #    return neigh3
            return neigh2

    return neigh1


def keep_running(vals):
    """ if the last 3 values are less then max, then stop """
    if len(vals) > 3:
        _, _f1 = vals[-1]
        _, _f2 = vals[-2]
        _, _f3 = vals[-3]

        fitvals = [f for k,f in vals]
        maxfit = max(fitvals)

        if (_f1 < maxfit) and (_f2 < maxfit) and (_f3 < maxfit):
            print "\n** Reached (local) maxima! **\n"
            fitkeys = []
            for k,f in vals:
                if f == maxfit:
                    fitkeys.append(k)

            for k,f in vals:
                print "(%s,%s)" % (k,f)

            msg = "Options %s found %s ambiguities **\n" % (fitkeys,maxfit)
            sys.stderr.write(msg)
            sys.exit(0)

    return True


