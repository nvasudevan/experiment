#!/bin/bash

# This script will launch the genBoltzProg in parallel. 

boltzprog="./genBoltzCfg"
grammardir=""
n_samples=""
prec=""
n_nt=""
n_t=""
sym_type=""
n_inst=""

[ -z "$BOLTZ_DIR" ] && (echo "BOLTZ_DIR should point to Boltzmann source directory";exit 1)
[ -z "$SINBAD_DIR" ] && (echo "SINBAD_DIR should point to SinBAD repo";exit 1)

echo "BOLTZ_DIR: $BOLTZ_DIR"
echo "SINBAD_DIR: $SINBAD_DIR"

BOLTZ_SPEC="${BOLTZ_DIR}/test/Cfg.hs"
export PYTHONPATH=$PYTHONPATH:$SINBAD_DIR

export BOLTZ_SPEC

set -- $(getopt d:N:p:n:t:m:i: "$@")

while [ $# -gt 0 ]
do
  case "$1" in 
   -d) grammardir=$2 ; shift;;
   -N) n_samples=$2 ; shift;;
   -p) prec=$2 ; shift;;
   -n) n_nt=$2 ; shift;;
   -t) n_t=$2 ; shift;;
   -m) sym_type=$2 ; shift;;
   -i) n_inst=$2 ; shift;;
  (--) shift; break;;
  (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
  (*)  break;;  
  esac
  shift
done

usage() {
    echo "Usage: "
    echo "$0 -d <grammar dir> -N <no of samples> -p <precision> " \
         "-n <no of nonterminals> -t <no of terminals> " \
         "-m <short|long> -i <no of parallel generators>"
    exit 1
}

# check for Haskell 7.6.1 version
# check for cabal -- if not point to cabal download
# cabal install syb
# cabal install QuickCheck
download() {
td=$(mktemp -d)
cd $td
wget -O boltz.tgz "http://genal.algo-prog.info/?p=syb_qc;a=snapshot;h=bc1ccc3b855fde726a16c5979b9f686624327a5c;sf=tgz"
# to be completed
}

genBoltzSpec() {
    #n_rule=$((n_nt+1))
    rule_str=""
    for i in $(seq 1 $n_nt)
    do
        rule_str="$rule_str Rule"
    done
    nt_str=$(cat $grammardir/nonterms)
    t_str=$(cat $grammardir/terms)
    echo -e "nt: $nt_str \nt_str: $t_str"
    header1="{-# LANGUAGE DeriveDataTypeable #-}"
    header2="module Cfg where"
    header3="import Data.Generics"
    prog_rule="data Cfg = Cfg $rule_str deriving (Typeable, Data, Show)"
    rule_rule="data Rule = EmptyRule | RuleAlts Rule Alt deriving (Typeable, Data, Show)"
    alt_rule="data Alt = EmptyAlt | AltSyms Alt Symbol deriving (Typeable, Data, Show) "
    symbol_rule="data Symbol = NonTerm NonTerm | Term Term deriving (Typeable, Data, Show)"
    nt_rule="data NonTerm = $nt_str deriving (Typeable, Data, Show)"
    t_rule="data Term = $t_str deriving (Typeable, Data, Show)"
    echo -e "$header1 \n$header2 \n$header3 \n\n$prog_rule \n$rule_rule \n$alt_rule" \
    " \n$symbol_rule \n$nt_rule \n$t_rule\n" > $BOLTZ_SPEC
    cwd=$(pwd)
    cd $BOLTZ_DIR
    make clean || exit $?
    make || exit $?
    cd $cwd
}

([ -z "$grammardir" ] || [ -z "$n_samples" ] || [ -z "$prec" ] || \
 [ -z "$n_nt" ] || [ -z "$n_t" ] || [ -z "$sym_type" ]) && usage

echo "$grammardir, $n_samples ($i_samples), $prec, $n_nt, $n_t, $sym_type, $n_inst"

bstart=$(date +%s)

if [ -z "$n_inst" ]
then
    $boltzprog -d $grammardir -N $n_samples -p $prec -n $n_nt -t $n_t -m $sym_type -l || exit $?
    genBoltzSpec
    export BOLTZ_PROG="${BOLTZ_DIR}/test/prog"
    $boltzprog -d $grammardir -N $n_samples -p $prec -n $n_nt -t $n_t -m $sym_type
else
    scriptlist="./scriptlist"
    cp /dev/null $scriptlist

    echo "generate lex first, and make"
    $boltzprog -d $grammardir -N $n_samples -p $prec -n $n_nt -t $n_t -m $sym_type -l || exit $?
    genBoltzSpec
    
    i_samples=$(python -c "from math import ceil; print int(ceil(($n_samples * 1.0)/$n_inst))")
    echo "Invoking $n_inst instances of genBoltzCfg. Each instance to generate $i_samples samples"

    for i in $(seq 1 $n_inst)
    do
        subdir="${grammardir}/$i"
        mkdir -p $subdir
        cp $BOLTZ_DIR/test/prog $subdir
        (export BOLTZ_PROG="$subdir/prog";$boltzprog -d $grammardir -N $i_samples -p $prec -n $n_nt -t $n_t -m $sym_type -i $i -L) &
    done
fi
wait
bend=$(date +%s)
belapsed=$(($bend - $bstart))

echo "time taken: $belapsed seconds"

