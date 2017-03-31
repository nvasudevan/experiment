#!/bin/bash

. $expdir/toolparams.sh

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
    for randomsize in $randomcfgsizes
    do
        for g in $(seq 1 $nrandom)
        do
            tmp=$(mktemp -d)
            glog="$rsltdir/${randomsize}_${g}.log"
            cd $tmp
            $accent $grandom/$randomsize/$g.acc || exit $?
            $lex $grandom/$randomsize/lex || exit $?
            $cc -w -o amber -O3 yygrammar.c $ambersrc
            $ambercmd 2> /dev/null > $glog
            amb=$(grep -o 'Grammar ambiguity detected' $glog)
            out="$randomsize/$g," 
            if [ "$amb" != "" ]
            then
                out="$randomsize/$g,yes"
            fi
            echo $out | tee -a $gsetlog
            [ -f $glog ] && gzip -f $glog
            cd $cwd
            rm -Rf $tmp
        done
    done
}

run_lang() {
    for g in $lgrammars
    do
        for i in $(seq 1 $nlang)
        do
            tmp=$(mktemp -d)
            glog="$rsltdir/${g}_${i}.log"
            cd $tmp
            $accent $glang/acc/$g.$i.acc || exit $?
            $lex $lexdir/$g.lex || exit $?
            $cc -w -o amber -O3 yygrammar.c $ambersrc
            #$ambercmd 2> /dev/null > $glog
            $ambercmd > $glog 2>&1
            cnt=$((cnt+1))
            amb=$(grep -o 'Grammar ambiguity detected' $glog)
            out="$g.$i," 
            if [ "$amb" != "" ]
            then
                ambcnt=$((ambcnt+1))
                out="$g.$i,yes"
            fi
            echo $out| tee -a $gsetlog
            [ -f $glog ] && gzip -f $glog
            cd $cwd
            rm -Rf $tmp
        done
    done 
    print_summary $ambcnt $cnt > $rsltdir/summary 
}

run_mutlang() {
    for type in $mutypes
    do
       for g in $mugrammars
       do
         t_rsltdir="$resultsdir/amber/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')/$type/$g"
         mkdir -p $t_rsltdir
         t_gsetlog="$t_rsltdir/log"
         echo "$type result log ==> $t_gsetlog"
         cp /dev/null $t_gsetlog
         glist=$(find $gmutlang/acc/$type/$g -name "*.acc" | cut -d_ -f2 | sort -h | cut -d. -f1 | head -${nmutations})
         for n in $glist
         do
             tmp=$(mktemp -d)
             glog="$rsltdir/${g}.0_${n}.log"
             cd $tmp
             $accent $gmutlang/acc/${type}/$g/$g.0_${n}.acc || exit $?
             $lex $lexdir/$g.lex || exit $?
             $cc -w -o amber -O3 yygrammar.c $ambersrc
             $ambercmd 2> /dev/null > $glog
             amb=$(grep -o 'Grammar ambiguity detected' $glog)
             out="${g}.0_${n},"
             if [ "$amb" != "" ]
             then
                 out="${g}.0_${n},yes"
             fi
             echo $out | tee -a $gsetlog
             [ -f $glog ] && gzip -f $glog
             cd $cwd
             rm -Rf $tmp
         done
         cat $t_gsetlog | sed -e "s/^/${type}\//" >> $gsetlog
       done
    done
}

run_boltzcfg() {
    for boltzsize in $boltzcfgsizes
    do
        for g in $(seq 1 $nboltz)
        do
            tmp=$(mktemp -d)
            glog="$rsltdir/${boltzsize}_${g}.log"
            cd $tmp
            $accent $gboltz/$boltzsize/$g.acc || exit $?
            $lex $gboltz/$boltzsize/lex || exit $?
            $cc -w -o amber -O3 yygrammar.c $ambersrc
            $ambercmd 2> /dev/null > $glog
            amb=$(grep -o 'Grammar ambiguity detected' $glog)
            out="$boltzsize/$g,"
            if [ "$amb" != "" ]
            then
                out="$boltzsize/$g,yes"
            fi
            echo $out | tee -a $gsetlog
            [ -f $glog ] && gzip -f $glog
            cd $expdir
            rm -Rf $tmp
        done
    done
}

run_test() {
    for g in $testgrammars
    do
        tmp=$(mktemp -d)
        glog="$rsltdir/${g}_${g}.log"
        cd $tmp
        $accent $grammardir/test/$g/$g.acc || exit $?
        $lex $lexdir/general.lex || exit $?
        $cc -w -o amber -O3 yygrammar.c $ambersrc
        $ambercmd 2> /dev/null > $glog
        amb=$(grep -o 'Grammar ambiguity detected' $glog)
        out="$g,"
        if [ "$amb" != "" ]
        then
            out="$g,yes"
        fi
        echo "$out" | tee -a $gsetlog
        [ -f $glog ] && gzip -f $glog
        cd $expdir
        rm -Rf $tmp  
    done
}

usage() {
  echo "$0 -t <time limit (secs)> -g <grammar set> <-n|-l> [-e]"
  exit 1
}

set -- $(getopt g:t:n:l:e "$@")

while [ $# -gt 0 ]
do
    case "$1" in 
     -g) gset=$2 ; shift;;
     -t) timelimit=$2 ; shift;;
     -n) examples=$2 ; shift;;
     -l) length="$2" ; shift;;
     -e) ellipsis="yes" ;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
     (*) break;;  
    esac
    shift
done

options=""
[ "$ellipsis" = "yes" ] && options="${options} ellipsis"
[ "$examples" != "" ] && options="${options} examples $examples"
[ "$length" != "" ] && options="${options} length $length"

if [ -z "$options" ] || [ -z "$timelimit" ]; then
    echo "Some of the options were not provided for running Amber. see usage"
    usage
fi

ambercmd="timeout ${timelimit}s ./amber $options"

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
runelapsed=$(($expend - $expstart))
cnt=$(wc -l $gsetlog)
ambcnt=$(grep -c yes $gsetlog)

echo "amb count: ${ambcnt}/${cnt}, running time: ${runelapsed} secs" > ${rsltdir}/summary.txt
cat ${rsltdir}/summary.txt
