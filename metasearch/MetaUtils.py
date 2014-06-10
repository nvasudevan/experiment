#! /usr/bin/env python

import  os, subprocess, sys
import math

def write(msg):
    sys.stdout.write(msg)
    sys.stdout.flush()


def ambtotal(log):  
    f = open(log)
    results = f.read()
    f.close()
    fit = results.count('yes')

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

def mean(val):
    return (sum(val) * 1.0)/len(val)


def stddev(val):
    m = mean(val)
    variance = [((v - m)**2) for v in val]
    return math.sqrt(mean(variance))

