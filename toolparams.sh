#!/bin/bash

testgrammars="amb2 amb3"
gset="random1000 lang mutlang boltzcfg"

nrandom="100"
nlang="5"
nmutations="10"
nboltz="100"

lgrammars="Pascal SQL Java C"

mugrammars="Pascal SQL Java C"
mutypes="type1 type2 type3 type4"
export testgrammars nrandom nlang nmutations nboltz lgrammars mugrammars mutypes

memlimit="1024m"
timelimits="10 30 60 120 240" # 120 240
export memlimit timelimits

### SETTING VALUES FOR EACH TOOL ###

#ACLA

#Amber
amber_n_examples="10000000000 1000000000000000000000000000000"
amber_n_length="50 100"
export amber_n_examples amber_n_length

#AmbiDexter
ambidexter_n_length="50 100"
filtertimeratios="0.25 0.5"
export ambidexter_n_length filtertimeratios

#SinBAD
Tdepths="10 15 20"
export Tdepths

grammardir="$cwd/grammars"
lexdir="$grammardir/lex"
grandom="$grammardir/random1000"
glang="$grammardir/lang"
gmutlang="$grammardir/mutlang"
gboltz="$grammardir/boltzcfg"
resultsdir="$cwd/results"
ppresults="$cwd/ppresults.txt"

export grammardir lexdir grandom glang gmutlang gboltz resultsdir ppresults

randomlex="$lexdir/random.lex"
boltzlex="$lexdir/boltz.lex"
export randomlex boltzlex

export accentdir="$wrkdir/accent"
# required for SinBAD
export ACCENT_DIR=$accentdir
