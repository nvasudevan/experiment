#!/bin/bash

. $expdir/toolparams.sh

gset=""
backend=""
timelimit=""
depth=""
wgt=""
sinbaddir="$wrkdir/sinbad/src"

run_randomcfg() {
    for randomsize in $randomcfgsizes
    do
        _lex="$grandom/$randomsize/lex"
        for g in $(seq 1 $nrandom)
        do
            _acc="$grandom/$randomsize/$g.acc"
            glog="$rsltdir/${randomsize}_${g}.log"
            $sinbadcmd ${_acc} ${_lex} > $glog 2>&1
            amb=$(grep -o 'Grammar ambiguity detected' $glog)
            cnt=$((cnt+1))
            out="$randomsize/$g,"
            if [ "$amb" != "" ]
            then 
                ambcnt=$((ambcnt+1))
                out="$randomsize/$g,yes"
            fi
            echo $out | tee -a $gsetlog
            [ -f $glog ] && gzip $glog
        done
    done
}

run_mutlang(){
    for type in $mutypes
    do
       for g in $mugrammars
       do
         t_rsltdir="$resultsdir/sinbad/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')/$type/$g"
         mkdir -p $t_rsltdir
         t_gsetlog="${t_rsltdir}/log"
         echo "$type result log ==> $t_gsetlog"
         cp /dev/null $t_gsetlog
         _lex="$lexdir/$g.lex"
         glist=$(find $gmutlang/acc/$type/$g -name "*.acc" | cut -d_ -f2 | sort -h | cut -d. -f1 | head -${nmutations})
         for n in $glist
         do
            _acc="$gmutlang/acc/$type/$g/${g}.0_${n}.acc"
            glog="$rsltdir/${g}.0_${n}.log"
            $sinbadcmd ${_acc} ${_lex} > $glog 2>&1
            amb=$(grep -o 'Grammar ambiguity detected' $glog)
            out="${g}.0_${n},"
            if [ "$amb" != "" ]
            then
                out="${g}.0_${n},yes"
            fi
            echo $out | tee -a $gsetlog
            [ -f $glog ] && gzip -f $glog
         done
         cat $t_gsetlog | sed -e "s/^/${type}\//" >> $gsetlog
       done
    done
}

run_boltzcfg(){
    for boltzsize in $boltzcfgsizes
    do
        _lex="$gboltz/$boltzsize/lex"
        for g in $(seq 1 $nboltz)
        do
            _acc="$gboltz/$boltzsize/$g.acc"
            glog="$rsltdir/${boltzsize}_${g}.log"
            $sinbadcmd ${_acc} ${_lex}  > $glog 2>&1
            amb=$(grep -o 'Grammar ambiguity detected' $glog)
            out="$boltzsize/$g,"
            if [ "$amb" != "" ]
            then 
                out="$boltzsize/$g,yes"
            fi
            echo $out | tee -a $gsetlog
            [ -f $glog ] && gzip -f $glog
        done
    done
}

run_lang() {
    for g in $lgrammars
    do
        _lex="$lexdir/$g.lex"
        for i in $(seq 1 $nlang)
        do
            _acc="$glang/acc/$g.$i.acc"
            glog="$rsltdir/${g}_${i}.log"
            $sinbadcmd ${_acc} ${_lex} > $glog 2>&1
            amb=$(grep -o 'Grammar ambiguity detected' $glog)
            out="$g.$i,"
            if [ "$amb" != "" ]
            then
                out="$g.$i,yes"
            fi
            echo $out | tee -a $gsetlog
            [ -f $glog ] && gzip -f $glog
        done
    done
}

run_test() {
    _lex="$lexdir/general.lex"
    for g in $testgrammars
    do
        _acc="$grammardir/test/$g/$g.acc"
        glog="$rsltdir/${g}_${g}.log"
        $sinbadcmd ${_acc} ${_lex} > $glog 2>&1
        amb=$(grep -o 'Grammar ambiguity detected' $glog)
        out="$g,"
        if [ "$amb" != "" ]
        then
            out="$g,yes"
        fi
        echo $out | tee -a $gsetlog
        [ -f $glog ] && gzip -f $glog
    done
}

usage() {
  echo "$0 -t <time limit (secs)> -g <grammar> -b <backend> [-d <depth>] [-w <weight>]>>"
  exit 1
}

set -- $(getopt g:b:t:d:w: "$@")

while [ $# -gt 0 ]
do
    case "$1" in 
     -g) gset=$2 ; shift;;
     -b) backend=$2 ; shift;;
     -t) timelimit="$2" ; shift;;
     -d) depth=$2 ; shift;;
     -w) wgt=$2 ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
     (*)  break;;  
    esac
    shift
done

options="-b $backend"
[ "$depth" != "" ] && options="$options -d $depth"
[ "$wgt" != "" ] && options="${options} -w $wgt"

echo $options
sinbadcmd="timeout ${timelimit}s $PYTHON $sinbaddir/sinbad $options"

echo "==> ($basename $0) [$gset] t=$timelimit,options=$options"

rsltdir="$resultsdir/sinbad/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
mkdir -p $rsltdir
gsetlog="$rsltdir/log"
echo "result log ==> $gsetlog"
cp /dev/null $gsetlog

runstart=$(date +%s)

case "$gset" in
      test) run_test;;
 randomcfg) run_randomcfg;;
  boltzcfg) run_boltzcfg;;
      lang) run_lang;;
   mutlang) run_mutlang;;
         *) echo "Unrecognised option ($gset). exiting ..."; exit 1;;
esac

runend=$(date +%s)
runelapsed=$(($runend - $runstart))
cnt=$(wc -l $gsetlog)
ambcnt=$(grep -c yes $gsetlog)

echo "amb count: ${ambcnt}/${cnt}, running time: ${runelapsed} secs" > ${rsltdir}/summary.txt
cat ${rsltdir}/summary.txt
