#!/bin/bash

# This script will launch the genBoltzProg in parallel. 

boltzprog="./genBoltzCfg"
grammardir=""
n_samples=""
sprec=""
vprec=""
n_nt=""
n_t=""
n_inst=""

if ([ -z "$BOLTZ_DIR" ] || [ -z "$BOLTZ_SPEC" ]  || [ -z "$SINBAD_DIR" ])
then
    echo "BOLTZ_DIR, BOLTZ_SPEC, and SINBAD_DIR need to be set first"
    exit 1
fi

export PYTHONPATH=$PYTHONPATH:$SINBAD_DIR

set -- $(getopt d:N:p:v:n:t:i: "$@")

while [ $# -gt 0 ]
do
  case "$1" in 
   -d) grammardir=$2 ; shift;;
   -N) n_samples=$2 ; shift;;
   -p) sprec=$2 ; shift;;
   -v) vprec=$2 ; shift;;
   -n) n_nt=$2 ; shift;;
   -t) n_t=$2 ; shift;;
   -i) n_inst=$2 ; shift;;
  (--) shift; break;;
  (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
  (*)  break;;  
  esac
  shift
done

usage() {
    echo "Usage: "
    echo "$0 -d <grammar dir> -N <no of samples> -p <singular precision> " \
         "-v <value precision> -n <no of nonterminals> -t <no of terminals> " \
         "-i <no of parallel generators>"
    exit 1
}

genBoltzSpec() {
    rule_str=""
    for i in $(seq 1 $n_nt)
    do
        rule_str="$rule_str Rule"
    done
    nt_str=$(cat $grammardir/nonterms)
    terms_str=$(cat $grammardir/terms)
    echo -e "nt: $nt_str \nterms_str: $terms_str"
    header1="{-# LANGUAGE DeriveDataTypeable #-}"
    header2="module Cfg where"
    header3="import Data.Generics"
    prog_rule="data Cfg = Cfg $rule_str deriving (Typeable, Data, Show)"
    rule_rule="data Rule = SingleAlt Alt | RuleAlts1 Rule Alt deriving (Typeable, Data, Show)"
    alt_rule="data Alt = EmptyAltSyms | SingleAltSyms1 Symbol | AltSyms1 Alt Symbol deriving (Typeable, Data, Show) "
    symbol_rule="data Symbol = NonTerm NonTerm | Term Term deriving (Typeable, Data, Show)"
    nt_rule="data NonTerm = $nt_str deriving (Typeable, Data, Show)"
    t_rule="data Term = $terms_str deriving (Typeable, Data, Show)"
    echo -e "$header1 \n$header2 \n$header3 \n\n$prog_rule \n$rule_rule \n$alt_rule" \
    " \n$symbol_rule \n$nt_rule \n$t_rule\n" > $BOLTZ_SPEC
    cwd=$(pwd)
    cd $BOLTZ_DIR
    make clean || exit $?
    make || exit $?
    cd $cwd
}

([ -z "$grammardir" ] || [ -z "$n_samples" ] || [ -z "$sprec" ] || [ -z "$vprec" ] ||\
 [ -z "$n_nt" ] || [ -z "$n_t" ]) && usage

echo "$grammardir, $n_samples ($i_samples), $sprec, $vprec, $n_nt, $n_t, $n_inst"

bstart=$(date +%s)

if [ -z "$n_inst" ]
then
    $boltzprog -d $grammardir -N $n_samples -p $sprec -v $vprec -n $n_nt -t $n_t -l || exit $?
    genBoltzSpec
    export BOLTZ_PROG="${BOLTZ_DIR}/test/prog"
    $boltzprog -d $grammardir -N $n_samples -p $sprec -v $vprec -n $n_nt -t $n_t -L
else
    echo "generate lex first, and make"
    $boltzprog -d $grammardir -N $n_samples -p $sprec -v $vprec -n $n_nt -t $n_t -l || exit $?
    genBoltzSpec
    
    i_samples=$(python -c "from math import ceil; print int(ceil(($n_samples * 1.0)/$n_inst))")
    echo "Invoking $n_inst instances of genBoltzCfg. Each instance to generate $i_samples samples"

    for i in $(seq 1 $n_inst)
    do
        subdir="${grammardir}/$i"
        mkdir -p $subdir
        cp $BOLTZ_DIR/test/prog $subdir
        (export BOLTZ_PROG="$subdir/prog";$boltzprog -d $grammardir -N $i_samples -p $sprec -v $vprec -n $n_nt -t $n_t -i $i -L) &
        sleep 2
    done

fi
wait
bend=$(date +%s)
belapsed=$(($bend - $bstart))

echo "time taken: $belapsed seconds"
