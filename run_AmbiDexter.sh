#!/bin/bash

bdir=$(dirname $0)
echo $bdir
. $bdir/toolparams.sh

echo "$(hostname)::($basename $0) $cwd $wrkdir"

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
    for log in $(ls $logdir/*.log)
    do
        ratio=$(grep "^Harmless productions" $log | cut -d: -f2)
        if [ ! -z "$ratio" ]
        then 
            tot=$(echo $tot+$ratio | bc -l)
            ((fltcnt+=1))
        fi
        ((cnt+=1))
    done
    avgratio="n/a"
    [ $fltcnt != 0 ] && avgratio=$(echo $tot/$fltcnt | bc -l)
    summary="no of filtered grammars=$fltcnt[of $cnt]\nAvg filter ratio=$avgratio"
    echo -e "$summary \n--"
}

acc_to_yacc(){
    gacc="$1"
    gy="$2"
    cat $gacc | grep  "%token" | sed -e 's/,//g' -e 's/;$//' > $gy
    echo "" >> $gy
    cat $gacc | grep -v '%token' | sed -e 's/%nodefault/\n%%/' >> $gy
}

run_randomcfg() {
    rsltdir="$resultsdir/ambidexter/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    cnt=0
    ambcnt=0    
    for randomsize in $randomcfgsizes
    do
        for g in $(seq 1 $nrandom)
        do
            tmp=$(mktemp -d)
            glog="$tmp/${randomsize}_${g}.log"
            gacc="$grandom/$randomsize/$g.acc"
            gy="$tmp/$g.y"
            ((cnt+=1))
            acc_to_yacc $gacc $gy
            $ambdxtcmd -s $gy > $glog 2>&1
            msg=$(cat $glog | egrep -i 'Grammar contains injection cycle' | cut -d: -f2,3)
            if [ "$msg" != "" ]
            then
                echo "$randomsize/$g,yes" | tee -a $gsetlog
                mv $glog $rsltdir/
                ((ambcnt+=1))
                rm -Rf $tmp
                continue
            fi
            msg=$(cat $glog | egrep -i 'Unproductive start symbol' | cut -d: -f2,3)
            if [ "$msg" != "" ]
            then 
                echo "$randomsize/$g," | tee -a $gsetlog
                mv $glog $rsltdir/
                rm -Rf $tmp
                continue
            fi
            out="$randomsize/$g,"
            timeout ${timelimit}s $bdir/AmbiDexter.sh -g $gy -l $glog $options
            amb=$(egrep -o 'Grammar contains injection cycle|Ambiguous string found' $glog)
            # all productions harmless
            ratio=$(grep '^Harmless productions' $glog | cut -d: -f2| bc)
            if [ "$amb" != "" ] || [ "$ratio" == "1" ]
            then
                ((ambcnt+=1))
                out="$randomsize/$g,yes"
            fi
            echo $out | tee -a $gsetlog
            echo $tmp
            mv $glog $rsltdir/
            rm -Rf $tmp
        done
    done
    print_summary $ambcnt $cnt
    print_filter_summary $rsltdir
}

run_lang() {
    rsltdir="$resultsdir/ambidexter/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    cnt=0
    ambcnt=0
    for g in $lgrammars
    do
        for i in $(seq 1 $nlang)
        do
            tmp=$(mktemp -d)
            glog="$tmp/${g}_${i}.log"
            gacc="$glang/acc/$g.$i.acc"
            gy="$tmp/$g.$i.y"
            ((cnt+=1))
            acc_to_yacc $gacc $gy
            $ambdxtcmd -s $gy > $glog 2>&1
            msg=$(cat $glog | egrep -i 'Grammar contains injection cycle' | cut -d: -f2,3)
            if [ "$msg" != "" ]
            then
                echo "$g.$i,yes" | tee -a $gsetlog
                mv $glog $rsltdir/
                ((ambcnt+=1))
                rm -Rf $tmp
                continue
            fi
            msg=$(cat $glog | egrep -i 'Unproductive start symbol' | cut -d: -f2,3)
            if [ "$msg" != "" ]
            then 
                echo "$g.$i," | tee -a $gsetlog
                mv $glog $rsltdir/
                rm -Rf $tmp
                continue
            fi
            out="$g.$i,"
            timeout ${timelimit}s $bdir/AmbiDexter.sh -g $gy -l $glog $options
            amb=$(egrep -o 'Grammar contains injection cycle|Ambiguous string found' $glog)
            # all productions harmless
            ratio=$(grep '^Harmless productions' $glog | cut -d: -f2| bc)
            if [ "$amb" != "" ] || [ "$ratio" == "1" ]
            then
                ((ambcnt+=1))
                out="$g.$i,yes"
            fi
            echo $out | tee -a $gsetlog
            echo $tmp
            mv $glog $rsltdir/
            rm -Rf $tmp
        done
    done
    print_summary $ambcnt $cnt
    print_filter_summary $rsltdir
}


run_mutlang() {
    for type in $mutypes
    do
        for g in $lgrammars
        do
            rsltdir="$resultsdir/ambidexter/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')/$type/$g"
            mkdir -p $rsltdir
            echo "result ==> $rsltdir"
            gsetlog="$rsltdir/log"
            cp /dev/null $gsetlog
            cnt=0
            ambcnt=0        
            for n in $(seq 1 $nmutations)
            do
                tmp=$(mktemp -d)
                echo $tmp
                glog="$tmp/${g}.0_${n}.log"
                gacc="$gmutlang/acc/$type/$g/$g.0_$n.acc"
                gy="$tmp/$g.0_$n.y"
                ((cnt+=1))
                acc_to_yacc $gacc $gy
                $ambdxtcmd -s $gy > $glog 2>&1
                msg=$(cat $glog | egrep -i 'Grammar contains injection cycle' | cut -d: -f2,3)
                if [ "$msg" != "" ]
                then
                    echo "$g.0_$n,yes" | tee -a $gsetlog
                    mv $glog $rsltdir/
                    ((ambcnt+=1))
                    rm -Rf $tmp
                    continue
                fi
                msg=$(cat $glog | egrep -i 'Unproductive start symbol' | cut -d: -f2,3)
                if [ "$msg" != "" ]
                then 
                    echo "$g.0_$n," | tee -a $gsetlog
                    mv $glog $rsltdir/
                    rm -Rf $tmp
                    continue
                fi            
                out="$g.0_$n,"
                timeout ${timelimit}s $bdir/AmbiDexter.sh -g $gy -l $glog $options
                amb=$(egrep -o 'Grammar contains injection cycle|Ambiguous string found' $glog)
                # all productions harmless
                ratio=$(grep '^Harmless productions' $glog | cut -d: -f2| bc)
                if [ "$amb" != "" ] || [ "$ratio" == "1" ]
                then
                    ((ambcnt+=1))
                    out="$g.0_$n,yes"
                fi
                echo $out | tee -a $gsetlog
                mv $glog $rsltdir/
                rm -Rf $tmp            
          done
          print_summary $ambcnt $cnt
          print_filter_summary $rsltdir
       done
    done
}

run_boltzcfg() {
    rsltdir="$resultsdir/ambidexter/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    cnt=0
    ambcnt=0
    for boltzsize in $boltzcfgsizes
    do
        for g in $(seq 1 $nboltz)
        do
            tmp=$(mktemp -d)
            glog="$tmp/${boltzsize}_${g}.log"
            gacc="$gboltz/$boltzsize/$g.acc"
            gy="$tmp/$g.y"
            ((cnt+=1))
            acc_to_yacc $gacc $gy
            $ambdxtcmd -s $gy > $glog 2>&1
            msg=$(cat $glog | egrep -i 'Grammar contains injection cycle' | cut -d: -f2,3)
            if [ "$msg" != "" ]
            then
                echo "$boltzsize/$g,yes" | tee -a $gsetlog
                mv $glog $rsltdir/
                ((ambcnt+=1))
                rm -Rf $tmp
                continue
            fi
            msg=$(cat $glog | egrep -i 'Unproductive start symbol' | cut -d: -f2,3)
            if [ "$msg" != "" ]
            then 
                echo "$boltzsize/$g," | tee -a $gsetlog
                mv $glog $rsltdir/
                rm -Rf $tmp
                continue
            fi
            out="$boltzsize/$g,"
            timeout ${timelimit}s $bdir/AmbiDexter.sh -g $gy -l $glog $options
            amb=$(egrep -o 'Grammar contains injection cycle|Ambiguous string found' $glog)
            # all productions harmless
            ratio=$(grep '^Harmless productions' $glog | cut -d: -f2| bc)
            if [ "$amb" != "" ] || [ "$ratio" == "1" ]
            then
                ((ambcnt+=1))
                out="$boltzsize/$g,yes"
            fi
            echo $out | tee -a $gsetlog
            echo $tmp
            mv $glog $rsltdir/
            rm -Rf $tmp
        done
    done
    print_summary $ambcnt $cnt
    print_filter_summary $rsltdir
}


run_test() {
    rsltdir="$resultsdir/ambidexter/$gset/${timelimit}s_$(echo $options | sed -e 's/ /_/g')"
    mkdir -p $rsltdir
    echo "result ==> $rsltdir"
    gsetlog="$rsltdir/log"
    cp /dev/null $gsetlog
    cnt=0
    ambcnt=0
    tmp=$(mktemp -d)
    for g in $testgrammars
    do
        gacc="$grammardir/test/$g/$g.acc"
        gy="$grammardir/test/$g/$g.y"
        glog="$tmp/${g}_${g}.log"
        acc_to_yacc $gacc $gy
        timeout ${timelimit}s $bdir/AmbiDexter.sh -g $gy -l $glog $options || exit $?
        amb=$(grep -o 'Ambiguous string found' $glog)
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

ambdxtcmd="java -Xss8m -Xmx$memlimit -jar $wrkdir/ambidexter/build/AmbiDexter.jar"
export ambdxtcmd 
echo "==> [$gset] t=$timelimit,options=$options"
run_$gset
