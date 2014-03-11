#!/bin/bash

bdir=$(dirname $0)
. $bdir/env.sh

gset="randomcfg lang mutlang boltzcfg"
grammardir="$cwd/grammars"
lexdir="$grammardir/lex"
export gset grammardir lexdir

testgrammars="amb2 amb3"
export testgrammars

grandom="$grammardir/randomcfg"
randomcfgsizes=$(seq 10 50)
nrandom="10"
export grandom randomcfgsizes nrandom 

glang="$grammardir/lang"
lgrammars="Pascal SQL Java C"
nlang="5"
export glang lgrammars nlang 

gmutlang="$grammardir/mutlang"
mugrammars="Pascal SQL Java C CSS Python Csharp"
mutypes="empty add mutate delete switchadj switchany"
nmutations="10"
export gmutlang mugrammars mutypes nmutations 

gboltz="$grammardir/boltzcfg"
boltzcfgsizes=$(seq 10 65)
nboltz="10"

export gboltz boltzcfgsizes nboltz 

memlimit="1024m"
timelimits="10 30 60"
export memlimit timelimits

### SETTING VALUES FOR EACH TOOL ###

#ACLA

#Amber
amber_n_examples="10000000000 100000000000000000000 1000000000000000000000000000000"
amber_n_length="10 25 50 100"
export amber_n_examples amber_n_length

#AmbiDexter
ambidexter_n_length="10 25 50 100"
export ambidexter_n_length 

#SinBAD
backends="dynamic1 dynamic2 dynamic3"
wgtbackends="dynamic4 dynamic5 dynamic10"
weights="0.025 0.05 0.1 0.15 0.2"
Tdepths="10 15 20"
export backends wgtbackends weights Tdepths 

resultsdir="$cwd/results"
ppresults="$cwd/ppresults.txt"
export resultsdir ppresults

export accentdir="$wrkdir/accent"
export ACCENT_DIR=$accentdir
