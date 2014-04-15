#! /usr/bin/env python

import  os, subprocess, sys

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
