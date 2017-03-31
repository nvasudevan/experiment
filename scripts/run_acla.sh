#!/bin/bash

. $expdir/scripts/base_params.sh
. $expdir/toolparams.sh

gset=""
timelimit=""

run_randomcfg() {
    tmp=$(mktemp -d)
    for randomsize in $randomcfgsizes
    do
        for g in  $(seq 1 $nrandom)
        do
            gacc="$grandom/$randomsize/$g.acc"
            gcfg="$tmp/${randomsize}_${g}.cfg"    
            glog="$rsltdir/${randomsize}_${g}.log"
            acc_to_cfg $gacc $gcfg
            $aclacmd $gcfg > $glog 2>&1
            out="${randomsize}/$g,"
            amb=$(grep -o 'ambiguous string' $glog)
            if [ "$amb" != "" ]
            then
                out="${randomsize}/$g,yes"
            fi
            echo $out | tee -a $gsetlog        
            gzip -f $glog
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
            gacc="$glang/acc/$g.$i.acc"
            gcfg="$tmp/$g.$i.cfg"
            glog="$rsltdir/${g}_${i}.log"
            acc_to_cfg $gacc $gcfg
            $aclacmd $gcfg > $glog 2>&1
            out="$g.$i,"
            amb=$(grep -o 'ambiguous string' $glog)
            if [ "$amb" != "" ]
            then
                out="$g.$i,yes"
            fi
            echo $out | tee -a $gsetlog        
            gzip -f $glog
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
            t_rsltdir="$rsltdir/$type/$g"
            mkdir -p $t_rsltdir
            t_gsetlog="${t_rsltdir}/log"
            echo "$type result log ==> $t_gsetlog"
            cp /dev/null $t_gsetlog
            glist=$(find $gmutlang/acc/$type/$g -name "*.acc" | cut -d_ -f2 | sort -h | cut -d. -f1 | head -${nmutations})
            for n in $glist
            do
                gacc="$gmutlang/acc/$type/$g/$g.0_$n.acc"
                gcfg="$tmp/$g.0_$n.cfg"
                glog="$rsltdir/${g}.0_${n}.log"
                acc_to_cfg $gacc $gcfg
                $aclacmd $gcfg > $glog 2>&1
                out="$g.0_$n,"
                amb=$(grep -o 'ambiguous string' $glog)
                if [ "$amb" != "" ]
                then
                    out="$g.0_$n,yes"
                fi
                echo $out | tee -a $t_gsetlog        
                gzip -f $glog
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
        for g in  $(seq 1 $nboltz)
        do
            gacc="$gboltz/$boltzsize/$g.acc"
            gcfg="$tmp/${boltzsize}_${g}.cfg"    
            glog="$rsltdir/${boltzsize}_${g}.log"
            acc_to_cfg $gacc $gcfg
            $aclacmd $gcfg > $glog 2>&1
            out="${boltzsize}/$g,"
            amb=$(grep -o 'ambiguous string' $glog)
            if [ "$amb" != "" ]
            then
                out="${boltzsize}/$g,yes"
            fi
            echo $out | tee -a $gsetlog        
            gzip -f $glog
        done
    done
    rm -Rf $tmp
}

run_test() {
    tmp=$(mktemp -d)
    for g in $testgrammars
    do
        gacc="$grammardir/test/$g/$g.acc"
        gcfg="$tmp/$g.cfg"
        glog="$rsltdir/${g}.log"
        acc_to_cfg $gacc $gcfg
        $aclacmd $gcfg > $glog 2>&1
        out="$g,"
        amb=$(grep -o 'ambiguous string' $glog)
        if [ "$amb" != "" ]
        then
            out="$g,yes"
        fi
        echo $out | tee -a $gsetlog        
        gzip -f $glog
    done
    rm -Rf $tmp
}

set -- $(getopt g:t: "$@")

while [ $# -gt 0 ]
do
    case "$1" in 
     -g) gset=$2 ; shift;;
     -t) timelimit="$2" ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
     (*) break;;  
    esac
    shift
done

aclacmd="timeout ${timelimit}s java -Xmx$memlimit -jar $wrkdir/ACLA/grammar.modified.jar -k -a"
export aclacmd 
echo "==> ($basename $0) [$gset] t=$timelimit"

rsltdir="$resultsdir/acla/$gset/${timelimit}s"
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
