#!/bin/bash

# This script will launch the genBoltzProg in parallel. 

boltzprog="./genBoltzCfg"
grammardir=""
boltzlexdir=""
n_samples=""
sprec=""
vprec=""
n_nt=""
n_t=""
n_inst=""

export BOLTZ_DIR="$HOME/codespace/boltzmann/current"
export BOLTZ_SPEC="${BOLTZ_DIR}/test/Cfg.hs"
export SINBAD_DIR="$HOME/codespace/sinbad/src"
export PYTHONPATH=$PYTHONPATH:$SINBAD_DIR

if ([ -z "$BOLTZ_DIR" ] || [ -z "$BOLTZ_SPEC" ]  || [ -z "$SINBAD_DIR" ])
then
    echo "BOLTZ_DIR, BOLTZ_SPEC, and SINBAD_DIR need to be set first"
    exit 1
fi

export PYTHONPATH=$PYTHONPATH:$SINBAD_DIR

set -- $(getopt d:D:N:p:v:n:t:i: "$@")

while [ $# -gt 0 ]
do
  case "$1" in 
   -d) grammardir=$2 ; shift;;
   -D) boltzlexdir=$2 ; shift;;
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
    echo -e "\nUsage: \n\n$0 [options]\n" \
         "options include: \n\n" \
         " -d <directory where grammars will be generated>\n" \
         " -N <no of samples to generate>\n" \
         " -n <no of non-terminal symbols>\n" \
         " -t <no of terminal symbols>\n" \
         " -D <directory containing lex related files for symbols>\n" \
         "     (option OVERRIDES values of -n and -t, if provided)\n" \
         " -i <no of parallel generators>\n"
    exit 1
}

genBoltzSpec() {
    if [ "$1" == "-D" ]
    then
        # use existing boltz stuff
        nt_str=$(cat $boltzlexdir/nonterms)
        terms_str=$(cat $boltzlexdir/terms)
        n_rules=$(echo $nt_str | sed -e 's/|//g' | wc -w)
        n_rules=$(($n_rules + 1))
    else
        nt_str=$(cat $grammardir/nonterms)
        terms_str=$(cat $grammardir/terms)   
        n_rules=$n_nt
    fi
    echo -e "nt: $nt_str \nterms_str: $terms_str"
    
    rule_str=""
    for i in $(seq 1 $n_rules)
    do
        rule_str="$rule_str Rule"
    done
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
    make clean > /dev/null 2>&1|| exit $?
    make > /dev/null 2>&1|| exit $?
    cd $cwd
}

launch(){
    times="$1"
    samples="$2"
    boltz="$3"
    for i in $(seq 1 $times)
    do
        subdir="${grammardir}/$i"
        mkdir -p $subdir
        cp $BOLTZ_DIR/test/prog $subdir
        xtraoptions="-n $n_nt -t $n_t"
        if [ "$boltz" == "-D" ]
        then
            xtraoptions=""
            cp $boltzlexdir/nonterms $grammardir/
            cp $boltzlexdir/terms $grammardir/
            cp $boltzlexdir/lexterms $grammardir/
            cp $boltzlexdir/lexterms_multi $grammardir/
            cp $boltzlexdir/lex $grammardir/
        fi
        (export BOLTZ_PROG="$subdir/prog";$boltzprog -d $grammardir -N $samples -p $sprec -v $vprec $xtraoptions -i $i -L) &
        sleep 2
    done    
}

([ -z "$grammardir" ] || [ -z "$n_samples" ] || [ -z "$sprec" ] || [ -z "$vprec" ]) && usage

if ([ -z "$boltzlexdir" ]) && ([ -z "$n_nt" ] || [ -z "$n_t" ])
then
  echo -e "\n**Either provide -D option or (-n and -t) options. See usage.**"
  usage
fi

if [ -z "$n_inst" ]
then
    i_samples="$n_samples"
    n_inst="1"
else
    i_samples=$(python -c "from math import ceil; print int(ceil(($n_samples * 1.0)/$n_inst))")
    echo "Invoking $n_inst instances of genBoltzCfg. Each instance to generate $i_samples samples"
fi

echo "$grammardir, $n_samples ($i_samples), $sprec, $vprec, $n_inst"
bstart=$(date +%s)

if [ -z "$boltzlexdir" ] 
then
  echo "nonterms/terms: $n_nt, $n_t"
  echo "generate lex first, and make"
  $boltzprog -d $grammardir -N $n_samples -p $sprec -v $vprec -n $n_nt -t $n_t -l || exit $?
  genBoltzSpec
  launch $n_inst $i_samples
else
  echo "boltzlexdir: $boltzlexdir"
  genBoltzSpec -D
  launch $n_inst $i_samples -D
fi

wait

bend=$(date +%s)
belapsed=$(($bend - $bstart))

echo "time taken: $belapsed seconds"
