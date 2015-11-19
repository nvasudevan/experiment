#! /usr/bin/env python

import os, subprocess, sys
import math


def err(msg):
    _msg = 'Error Occurred. See below for details'
    if msg is not None:
        _msg += "\n%s\n" % msg

    sys.stderr.write(_msg)
    sys.exit(1)


def ambtotal(log):
    f = open(log)
    results = f.read()
    f.close()
    return results.count('yes')


def fitness(log, foundall=False):
    """ fitness -> number of ambiguities found
        optionally, stop if all grammars are detected as ambiguous
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


def move_by_step1(fitvals, n, s):
    if len(fitvals) < n:
        return True

    recent = fitvals[-n:]
    sdev = stddev(recent)
    sys.stderr.write("recent: %s, sdev: %s\n" % (recent, sdev))
    if sdev > s:
        return True

    return False


def localmax(fitvals, n=3):
    """ if the last n values are less then max, then stop """
    if len(fitvals) > n:
        lastn = fitvals[-n:]
        maxfit = max(fitvals[:-n])

        for v in lastn:
            if v > maxfit:
                return False

        print "\n** Reached (local) maxima! **\n"
        return True

    return False


def report(vals):
    for k,f in vals:
        print "(%s,%s)" % (k,f)

    fitvals = [f for k,f in vals]
    maxfit = max(fitvals)

    fitkeys = []
    for k,f in vals:
        if f == maxfit:
            fitkeys.append(k)

    msg = "Options %s found %s ambiguities **\n" % (fitkeys,maxfit)
    sys.stderr.write(msg)

