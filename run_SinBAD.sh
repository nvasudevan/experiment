#!/bin/bash

bdir=$(dirname $0)
echo $bdir
. $bdir/toolparams.sh

echo "$(hostname)::($basename $0) $cwd $wrkdir"

gset=""
backend=""
timelimit=""
depth=""
wgt=""
sinbaddir="$wrkdir/sinbad/src"

print_summary() {
    summary="Ambiguous count=$1[of $2]"
    echo -e "\nSummary: $summary \n--"
}

run_randomcfg() {
    rsltdir="$resultsdir/sinbad/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    ambcnt=0
    cnt=0
    for randomsize in $randomcfgsizes
    do
        tmp=$(mktemp -d)
        _lex="$grandom/$randomsize/lex"
        for g in $(seq 1 $nrandom)
        do
            _acc="$grandom/$randomsize/$g.acc"
            glog="$tmp/${randomsize}_${g}.log"
            $sinbadcmd ${_acc} ${_lex} > $glog 2>&1
            amb=$(grep -o 'Grammar ambiguity detected' $glog)
            ((cnt+=1))
            out="$randomsize/$g,"
            if [ "$amb" != "" ]
            then 
                ((ambcnt+=1))
                out="$randomsize/$g,yes"
                mv $glog $rsltdir/
            fi
            echo $out | tee -a $gsetlog
        done
        rm -Rf $tmp
    done
    print_summary $ambcnt $cnt
}

run_mutlang(){
    for type in $mutypes
    do
       for g in $mugrammars
       do
         rsltdir="$resultsdir/sinbad/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')/$type/$g"
         mkdir -p $rsltdir
         echo "result ==> $rsltdir"
         tmp=$(mktemp -d)
         ambcnt=0
         cnt=0
         gsetlog="$rsltdir/log"
         cp /dev/null $gsetlog
         _lex="$lexdir/$g.lex"
         for n in $(seq 1 $nmutations)
         do
            _acc="$gmutlang/acc/$type/$g/${g}.0_${n}.acc"
            glog="$tmp/${g}.0_${n}.log"
            $sinbadcmd ${_acc} ${_lex} > $glog 2>&1
            amb=$(grep -o 'Grammar ambiguity detected' $glog)
            ((cnt+=1))
            out="${g}.0_${n},"
            if [ "$amb" != "" ]
            then
                ((ambcnt+=1))
                out="${g}.0_${n},yes"
                mv $glog $rsltdir/
            fi
            echo $out | tee -a $gsetlog
         done
         rm -Rf $tmp
         print_summary $ambcnt $cnt        
       done
    done
}

run_boltzcfg(){
    rsltdir="$resultsdir/sinbad/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    ambcnt=0
    cnt=0
    for boltzsize in $boltzcfgsizes
    do
        tmp=$(mktemp -d)
        _lex="$gboltz/$boltzsize/lex"
        for g in $(seq 1 $nboltz)
        do
            _acc="$gboltz/$boltzsize/$g.acc"
            glog="$tmp/${boltzsize}_${g}.log"
            $sinbadcmd ${_acc} ${_lex}  > $glog 2>&1
            amb=$(grep -o 'Grammar ambiguity detected' $glog)
            ((cnt+=1))
            out="$boltzsize/$g,"
            if [ "$amb" != "" ]
            then 
                ((ambcnt+=1))
                out="$boltzsize/$g,yes"
                mv $glog $rsltdir/
            fi
            echo $out | tee -a $gsetlog
        done
        rm -Rf $tmp        
    done
    print_summary $ambcnt $cnt   
}

run_lang() {
    rsltdir="$resultsdir/sinbad/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    ambcnt=0
    cnt=0
    tmp=$(mktemp -d)
    for g in $lgrammars
    do
        _lex="$lexdir/$g.lex"
        for i in $(seq 1 $nlang)
        do
            _acc="$glang/acc/$g.$i.acc"
            glog="$tmp/${g}_${i}.log"
            $sinbadcmd ${_acc} ${_lex} > $glog 2>&1
            amb=$(grep -o 'Grammar ambiguity detected' $glog)
            ((cnt+=1))
            out="$g.$i,"
            if [ "$amb" != "" ]
            then
                ((ambcnt+=1))
                out="$g.$i,yes"
                mv $glog $rsltdir/
            fi
            echo $out | tee -a $gsetlog
        done
    done
    rm -Rf $tmp
    print_summary $ambcnt $cnt    
}

run_test() {
    rsltdir="$resultsdir/sinbad/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    ambcnt=0
    cnt=0
    tmp=$(mktemp -d)
    _lex="$lexdir/general.lex"
    for g in $testgrammars
    do
        _acc="$grammardir/test/$g/$g.acc"
        glog="$tmp/${g}_${g}.log"
        $sinbadcmd ${_acc} ${_lex} > $glog 2>&1
        amb=$(grep -o 'Grammar ambiguity detected' $glog)
        ((cnt+=1))
        out="$g,"
        if [ "$amb" != "" ]
        then
            ((ambcnt+=1))
            out="$g,yes"
            mv $glog $rsltdir/
        fi
        echo $out | tee -a $gsetlog
    done
    rm -Rf $tmp
    print_summary $ambcnt $cnt   
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

echo "==> [$gset] t=$timelimit,options=$options"
run_$gset

