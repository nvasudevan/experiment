#!/bin/sh

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

memlimit="4096m"
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
resultsdir="/home/user/codespace/experiment/_results"
ppresults="$cwd/ppresults.txt"

scriptlist="./scriptlist"
cp /dev/null $scriptlist

export grammardir lexdir grandom glang gmutlang gboltz resultsdir ppresults

randomlex="/home/user/codespace/experiment/random.1/lex"
boltzlex="/home/user/codespace/experiment/boltz.6.001_n15_t15_f1234/lex"
export randomlex boltzlex

export accentdir="$wrkdir/accent"
