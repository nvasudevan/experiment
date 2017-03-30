#!/bin/bash

bdir=$(dirname $0)
. $bdir/env.sh

export scriptsdir=$cwd/scripts

gset="lang mutlang boltzcfg"
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
mugrammars="Pascal SQL Java C CSS"
mutypes="empty add mutate delete switch"
nmutations="20"
export gmutlang mugrammars mutypes nmutations 

gboltz="$grammardir/boltzcfg"
boltzcfgsizes=$(seq 10 75)
nboltz="10"

export gboltz boltzcfgsizes nboltz 

memlimit="2048m"
timelimits="10 30 60 120"
cores_per_host="3"
export memlimit timelimits cores_per_host


### SETTING VALUES FOR EACH TOOL ###

#ACLA

#Amber
amber_n_examples="10000000000 1000000000000000 100000000000000000000 1000000000000000000000000000000"
amber_n_length="5 10 15 20 25 50 100"
export amber_n_examples amber_n_length

#AmbiDexter
ambidexter_n_length="5 10 15 20 25 50 100"
export ambidexter_n_length 

#SinBAD
backends="dynamic1 dynamic2 dynamic3"
wgtbackends="dynamic4 dynamic5 dynamic10"
weights="0.0125 0.025 0.05 0.1 0.15 0.2"
Tdepths="5 10 15 20 25"
export backends wgtbackends weights Tdepths 

resultsdir="$cwd/results"
ppresults="$cwd/ppresults.txt"
export resultsdir ppresults

export accentdir="$wrkdir/accent"
export ACCENT_DIR=$accentdir

print_summary() {
    summary="Ambiguous count=$1 [of $2]"
    echo -e "\nSummary: $summary \n--"
}

acc_to_cfg(){
    gacc="$1"
    gcfg="$2"
    cat $gacc | egrep -v "^\s*;|^%nodefault|^%token " | sed -e 's/;$//g' -e "s/'/\"/g" > $gcfg
    tokenlist=$(grep '%token' $gacc | sed -e 's/%token //' | tr -d ';,')
    for token in $tokenlist
    do
       sed -i -e "s/\b${token}\b/\"${token}\"/g" -e "s/'/\"/g" $gcfg
    done    
}

acc_to_yacc(){
    gacc="$1"
    gy="$2"
    cat $gacc | grep  "%token" | sed -e 's/,//g' -e 's/;$//' > $gy
    echo "" >> $gy
    cat $gacc | grep -v '%token' | sed -e 's/%nodefault/\n%%/' >> $gy
}
