#!/bin/bash

bdir=$(dirname $0)
echo $bdir
. $bdir/toolparams.sh

echo "$(hostname)::($basename $0) $cwd $wrkdir"

gset=""
timelimit=""
examples=""
length=""
ellipsis="no"

accent="$wrkdir/accent/accent/accent"
ambersrc="$wrkdir/accent/amber/amber.c"
lex=$(which flex)
cc=$(which cc)

run_randomcfg() {
    rsltdir="$resultsdir/amber/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    ambcnt=0
    cnt=0
    cwd=$(pwd)
    for randomsize in $randomcfgsizes
    do
        for g in $(seq 1 $nrandom)
        do
            tmp=$(mktemp -d)
            cd $tmp
            glog="${randomsize}_${g}.log"
            $accent $grandom/$randomsize/$g.acc || exit $?
            $lex $grandom/$randomsize/lex || exit $?
            $cc -w -o amber -O3 yygrammar.c $ambersrc
            $ambercmd 2> /dev/null > $glog
            ((cnt+=1))
            amb=$(grep -o 'Grammar ambiguity detected' $glog)
            out="$randomsize/$g," 
            if [ "$amb" != "" ]
            then
                ((ambcnt+=1))
                out="$randomsize/$g,yes"
                mv $glog $rsltdir/
            fi
            echo $out | tee -a $gsetlog
            cd $cwd
            rm -Rf $tmp
        done
    done
    print_summary $ambcnt $cnt
}

run_lang() {
    rsltdir="$resultsdir/amber/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    ambcnt=0
    cnt=0
    for g in $lgrammars
    do
        for i in $(seq 1 $nlang)
        do
            tmp=$(mktemp -d)
            cd $tmp
            glog="${g}_${i}.log"
            $accent $glang/acc/$g.$i.acc || exit $?
            $lex $lexdir/$g.lex || exit $?
            $cc -w -o amber -O3 yygrammar.c $ambersrc
            $ambercmd 2> /dev/null > $glog
            ((cnt+=1))
            amb=$(grep -o 'Grammar ambiguity detected' $glog)
            out="$g.$i," 
            if [ "$amb" != "" ]
            then
                ((ambcnt+=1))
                out="$g.$i,yes"
                mv $glog $rsltdir/
            fi
            echo $out| tee -a $gsetlog
            cd $cwd
            rm -Rf $tmp
        done
    done 
    print_summary $ambcnt $cnt 
}

run_mutlang() {
    for type in $mutypes
    do
       for g in $mugrammars
       do
         rsltdir="$resultsdir/amber/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')/$type/$g"
         mkdir -p $rsltdir
         echo "result ==> $rsltdir"
         ambcnt=0
         cnt=0
         gsetlog="$rsltdir/log"
         cp /dev/null $gsetlog
         for n in $(seq 1 $nmutations)
         do
             tmp=$(mktemp -d)
             cd $tmp
             glog="${g}.0_${n}.log"
             $accent $gmutlang/acc/${type}/$g/$g.0_${n}.acc || exit $?
             $lex $lexdir/$g.lex || exit $?
             $cc -w -o amber -O3 yygrammar.c $ambersrc
             $ambercmd 2> /dev/null > $glog
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
             cd $cwd
             rm -Rf $tmp
         done
         print_summary $ambcnt $cnt        
       done
    done
}

run_boltzcfg() {
    rsltdir="$resultsdir/amber/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    ambcnt=0
    cnt=0
    for boltzsize in $boltzcfgsizes
    do
        for g in $(seq 1 $nboltz)
        do
            tmp=$(mktemp -d)
            cd $tmp
            glog="${boltzsize}_${g}.log"
            $accent $gboltz/$boltzsize/$g.acc || exit $?
            $lex $gboltz/$boltzsize/lex || exit $?
            $cc -w -o amber -O3 yygrammar.c $ambersrc
            $ambercmd 2> /dev/null > $glog
            ((cnt+=1))
            amb=$(grep -o 'Grammar ambiguity detected' $glog)
            out="$boltzsize/$g,"
            if [ "$amb" != "" ]
            then
                ((ambcnt+=1))
                out="$boltzsize/$g,yes"
                mv $glog $rsltdir/
            fi
            echo $out | tee -a $gsetlog
            cd $cwd
            rm -Rf $tmp
        done
    done
    print_summary $ambcnt $cnt
}

run_test() {
    rsltdir="$resultsdir/amber/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    ambcnt=0
    cnt=0
    for g in $testgrammars
    do
        tmp=$(mktemp -d)
        cd $tmp
        glog="${g}_${g}.log"
        $accent $grammardir/test/$g/$g.acc || exit $?
        $lex $lexdir/general.lex || exit $?
        $cc -w -o amber -O3 yygrammar.c $ambersrc
        $ambercmd 2> /dev/null > $glog
        ((cnt+=1))
        amb=$(grep -o 'Grammar ambiguity detected' $glog)
        out="$g,"
        if [ "$amb" != "" ]
        then
            ((ambcnt+=1))
            out="$g,yes"
            mv $glog $rsltdir/
        fi
        echo "$out" | tee -a $gsetlog
        cd $cwd
        rm -Rf $tmp  
    done
    print_summary $ambcnt $cnt
}

set -- $(getopt g:t:n:l:e "$@")

while [ $# -gt 0 ]
do
    case "$1" in 
     -g) gset=$2 ; shift;;
     -t) timelimit=$2 ; shift;;
     -n) examples=$2 ; shift;;
     -l) length="$2" ; shift;;
     -e) ellipsis=yes ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
     (*) break;;  
    esac
    shift
done

options=""
if [ "$examples" != "" ]; then
    options="${options} examples $examples"
fi

if [ "$length" != "" ]; then
    options="${options} length $length"
fi

if [ "$ellipsis" == "yes" ]; then
    options="${options} ellipsis"
fi

if [ -z "$options" ]; then
    echo "No options provided for Amber. Exiting."
    exit 1
fi

ambercmd="timeout ${timelimit}s ./amber $options"
echo "==> [$gset] t=$timelimit,options=$options"
cwd=$(pwd)
run_$gset

