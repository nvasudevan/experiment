#!/bin/bash

. $expdir/scripts/base_params.sh
. $expdir/toolparams.sh

gset=""
timelimit=""
filter=""
length=""
inclength=""

print_filter_summary() {
    logdir="$1"
    tot=0.0
    cnt=0
    fltcnt=0
    unambcnt=0
    totflttime=0
    for log in $(ls $logdir/*.log.gz)
    do
        flttime=$(zgrep "^filter time" $log | cut -d: -f2)
        if [ ! -z "$flttime" ]
        then
            totflttime=$(echo $totflttime+$flttime | bc)
            ((fltcnt+=1))
            ratio=$(zgrep "^Harmless productions" $log | cut -d: -f2)
            if [ ! -z "$ratio" ]
            then 
                hfrac=$(echo $ratio | bc -l)
                tot=$(echo $tot+$hfrac | bc -l)
                unamb=$(echo $ratio | bc)
                [ $unamb == 1 ] && ((unambcnt+=1))
            fi
        fi
        cnt=$((cnt+1))
    done
    avgratio="n/a"
    avgflttime="n/a"
    if [ $fltcnt != 0 ]; then
        avgratio=$(echo "scale=4;($tot/$fltcnt)*100" | bc -l)
        avgflttime=$(echo "scale=4;$totflttime/$fltcnt" | bc -l)
    fi
    summary="no of filtered grammars=$fltcnt [of $cnt]\
    \navg harmless [%]=${avgratio}\
    \nno of unambiguous grammars=$unambcnt [of $cnt]\
    \navg filter time [millisecs]=$avgflttime"
    echo -e "$summary \n--"
}

run_randomcfg() {
    tmp=$(mktemp -d)
    for randomsize in $randomcfgsizes
    do
        for g in $(seq 1 $nrandom)
        do
            glog="$rsltdir/${randomsize}_${g}.log"
            gacc="$grandom/$randomsize/$g.acc"
            gy="$tmp/${randomsize}_${g}.y"
            acc_to_yacc $gacc $gy
            $ambdxtcmd -s $gy > $glog 2>&1
            msg=$(cat $glog | egrep -i 'Grammar contains injection cycle' | cut -d: -f2,3)
            if [ "$msg" != "" ]
            then
                echo "$randomsize/$g,yes" | tee -a $gsetlog
                continue
            fi
            msg=$(cat $glog | egrep -i 'Unproductive start symbol' | cut -d: -f2,3)
            if [ "$msg" != "" ]
            then 
                echo "$randomsize/$g," | tee -a $gsetlog
                continue
            fi
            out="$randomsize/$g,"
            timeout ${timelimit}s $expdir/scripts/ambidexter.sh -g $gy -l $glog $options
            amb=$(egrep -o 'Grammar contains injection cycle|Ambiguous string found' $glog)
            if [ "$amb" != "" ]
            then
                out="$randomsize/$g,yes"
            fi
            echo $out | tee -a $gsetlog
            [ -f $glog ] && gzip -f $glog
        done
    done
    rm -Rf $tmp
}

run_lang() {
    tmp=$(mktemp -d)
    for g in $lgrammars
    do
        for i in $(seq 1 $nlang)
        do
            glog="$rsltdir/${g}_${i}.log"
            gacc="$glang/acc/$g.$i.acc"
            gy="$tmp/${g}.${i}.y"
            acc_to_yacc $gacc $gy
            $ambdxtcmd -s $gy > $glog 2>&1
            msg=$(cat $glog | egrep -i 'Grammar contains injection cycle' | cut -d: -f2,3)
            if [ "$msg" != "" ]
            then
                echo "${g}.${i},yes" | tee -a $gsetlog
                continue
            fi
            msg=$(cat $glog | egrep -i 'Unproductive start symbol' | cut -d: -f2,3)
            if [ "$msg" != "" ]
            then 
                echo "${g}.${i}," | tee -a $gsetlog
                continue
            fi
            out="${g}.${i},"
            timeout ${timelimit}s $expdir/scripts/ambidexter.sh -g $gy -l $glog $options
            amb=$(egrep -o 'Grammar contains injection cycle|Ambiguous string found' $glog)
            if [ "$amb" != "" ]
            then
                out="${g}.${i},yes"
            fi
            echo $out | tee -a $gsetlog
            [ -f $glog ] && gzip -f $glog
        done
    done
    rm -Rf $tmp
}

run_mutlang() {
    for type in $mutypes
    do
       tmp=$(mktemp -d)
       for g in $mugrammars
       do
           t_rsltdir="$resultsdir/ambidexter/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')/$type/$g"
           mkdir -p $t_rsltdir
           t_gsetlog="$t_rsltdir/log"
           echo "$type result log ==> $t_gsetlog"
           cp /dev/null $t_gsetlog
           glist=$(find $gmutlang/acc/$type/$g -name "*.acc" | cut -d_ -f2 | sort -h | cut -d. -f1 | head -${nmutations})
           for n in $glist
           do
               glog="$t_rsltdir/${g}.0_${n}.log"
               gacc="$gmutlang/acc/$type/$g/$g.0_$n.acc"
               gy="$tmp/${g}.0_${n}.y"
               acc_to_yacc $gacc $gy
               $ambdxtcmd -s $gy > $glog 2>&1
               msg=$(cat $glog | egrep -i 'Grammar contains injection cycle' | cut -d: -f2,3)
               if [ "$msg" != "" ]
               then
                   echo "${g}.0_$n,yes" | tee -a $t_gsetlog
                   continue
               fi
               msg=$(cat $glog | egrep -i 'Unproductive start symbol' | cut -d: -f2,3)
               if [ "$msg" != "" ]
               then
                   echo "${g}.0_$n," | tee -a $t_gsetlog
                   continue
               fi
               out="${g}.0_$n,"
               timeout ${timelimit}s $expdir/scripts/ambidexter.sh -g $gy -l $glog $options
               amb=$(egrep -o 'Grammar contains injection cycle|Ambiguous string found' $glog)
               if [ "$amb" != "" ]
               then
                   out="${g}.0_$n,yes"
               fi
               echo $out | tee -a $t_gsetlog
               [ -f $glog ] && gzip -f $glog
           done
           cat $t_gsetlog | sed -e "s/^/${type}\//" >> $gsetlog
       done
       rm -Rf $tmp
    done
}

run_boltzcfg() {
    tmp=$(mktemp -d)
    for boltzsize in $boltzcfgsizes
    do
        for g in $(seq 1 $nboltz)
        do
            glog="$rsltdir/${boltzsize}_${g}.log"
            gacc="$gboltz/$boltzsize/$g.acc"
            gy="$tmp/${boltzsize}_$g.y"
            acc_to_yacc $gacc $gy
            $ambdxtcmd -s $gy > $glog 2>&1
            msg=$(cat $glog | egrep -i 'Grammar contains injection cycle' | cut -d: -f2,3)
            if [ "$msg" != "" ]
            then
                echo "$boltzsize/$g,yes" | tee -a $gsetlog
                continue
            fi
            msg=$(cat $glog | egrep -i 'Unproductive start symbol' | cut -d: -f2,3)
            if [ "$msg" != "" ]
            then 
                echo "$boltzsize/$g," | tee -a $gsetlog
                continue
            fi
            out="$boltzsize/$g,"
            timeout ${timelimit}s $expdir/scripts/ambidexter.sh -g $gy -l $glog $options
            amb=$(egrep -o 'Grammar contains injection cycle|Ambiguous string found' $glog)
            if [ "$amb" != "" ]
            then
                out="$boltzsize/$g,yes"
            fi
            echo $out | tee -a $gsetlog
            [ -f $glog ] && gzip -f $glog
        done
    done
    rm -Rf $tmp
}


run_test() {
    tmp=$(mktemp -d)
    for g in $testgrammars
    do
        gacc="$grammardir/test/$g/$g.acc"
        gy="$tmp/$g.y"
        glog="$rsltdir/${g}_${g}.log"
        acc_to_yacc $gacc $gy
        timeout ${timelimit}s $expdir/scripts/ambidexter.sh -g $gy -l $glog $options
        amb=$(grep -o 'Ambiguous string found' $glog)
        out="$g,"
        if [ "$amb" != "" ]
        then
            out="$g,yes"
        fi
        echo $out | tee -a $gsetlog
    done
    [ -f $glog ] && gzip -f $glog
    rm -Rf $tmp
}

usage() {
  echo "$0 -t <time limit (secs)> [-f (lr0|slr1|lalr1|lr1)] <-i 0|-k N> -g <grammar>"
  exit 1
}

set -- $(getopt g:t:f:k:i: "$@")

inclength=""

while [ $# -gt 0 ]
do
    case "$1" in 
     -g) gset=$2 ; shift;;
     -t) timelimit=$2 ; shift;;
     -f) filter=$2 ; shift;;
     -k) length=$2 ; shift;;
     -i) inclength=$2 ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
     (*) break;;  
    esac
    shift
done

options=""
[ "$filter" != "" ] && options="$options -f $filter"
[ "$length" != "" ] && options="$options -k $length"
[ "$inclength" != "" ] && options="$options -i $inclength"

if [ -z "$options" ] || [ -z "$timelimit" ]; then
  echo "Some of the options are missing. See usage"
  usage
fi

ambdxtcmd="java -Xss8m -Xmx$memlimit -jar $wrkdir/ambidexter/build/AmbiDexter.jar"
export ambdxtcmd 

echo "==> ($basename $0) [$gset] t=$timelimit,options=$options"

rsltdir="$resultsdir/ambidexter/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
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
cnt=$(wc -l $gsetlog | awk '{print $1}')
ambcnt=$(grep -c yes $gsetlog)

echo "amb count: ${ambcnt}/${cnt}, running time: ${runelapsed} secs" > ${rsltdir}/summary.txt
cat ${rsltdir}/summary.txt
print_filter_summary $rsltdir >> ${rsltdir}/summary.txt
