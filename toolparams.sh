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
randomcfgsizes="10 11 12"
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
boltzcfgsizes="10 11 12"
nboltz="10"

export gboltz boltzcfgsizes nboltz 

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
export ambidexter_n_length 

#SinBAD
backends="dynamic1 dynamic3"
wgtbackends="dynamic4 dynamic5"
weights="0.025 0.05"
Tdepths="10 15 20"
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

