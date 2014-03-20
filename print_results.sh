#!/bin/sh

resultdir=""
exp=""

set -- $(getopt d:x: "$@")

while [ $# -gt 0 ]
do
    case "$1" in 
     -d) resultdir=$2 ; shift;;
     -x) exp=$2 ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
     (*) break;;  
    esac
    shift
done

usage(){
    echo "$0 -d <results dir> -x <mini|main|validation>"
    exit 1
}

[ -z "$resultdir" ] && usage
[ -z "$exp" ] && usage

if [ ! -d $resultdir ]; then
    echo "results directory $resultdir does not exist"
    exit 1
fi

if [ ! -f $resultdir/${exp}_toolparams.sh ]; then
    echo "toolparams $resultdir/${exp}_toolparams.sh does not exist"
    exit 1
fi

. $resultdir/${exp}_toolparams.sh

print(){
    log="$1"
    total=$(wc -l $resultdir/$log | awk '{print $1}')
    ambcnt=$(grep -c yes $resultdir/$log)
    echo "$ambcnt [/$total]"
}

print_acla(){
    echo "==> ACLA "
    for g in boltzcfg lang; do
        out=""
        for t in $timelimits; do
            tout=$(print "acla/$g/${t}s/log")
            out="$out,$tout"
        done
        echo "acla/$g,$out"
    done
    for type in $mutypes; do
        for lang in $mugrammars; do
            out=""
            for t in $timelimits; do
                tout=$(print "acla/mutlang/${t}s/$type/$lang/log")
                out="$out,$tout"
            done
            echo "acla/mutlang/$type/$lang,$out"
        done
    done
}

print_ambidexter(){
    for g in boltzcfg lang; do
        echo "==> AmbiDexter [$g]"
        for ambilen in $ambidexter_n_length; do
            out=""
            for t in ${timelimits}; do
                tout=$(print "ambidexter/$g/${t}s_-k_${ambilen}/log")
                out="$out,$tout"
            done
            echo "ambidexter/$g/k_${ambilen},$out"
            
            for filter in lr0 slr1 lalr1 lr1; do
                out=""
                for t in $timelimits;do
                    tout=$(print "ambidexter/$g/${t}s_-f_${filter}_-k_${ambilen}/log")
                    out="$out,$tout"
                done
                echo "ambidexter/$g/${filter}_-k_${ambilen},$out"
            done
        done
        
        out=""
        for t in ${timelimits}; do
            tout=$(print "ambidexter/$g/${t}s_-i_0/log")
            out="$out,$tout"
        done
        echo "ambidexter/$g/ik_0,$out"
        
        for filter in lr0 slr1 lalr1 lr1; do
            out=""
            for t in ${timelimits}; do
                tout=$(print "ambidexter/$g/${t}s_-f_${filter}_-i_0/log")
                out="$out,$tout"
            done
            echo "ambidexter/$g/${filter}_-ik_0,$out"
        done
    done
    
    for type in $mutypes; do
        for ambilen in $ambidexter_n_length; do
            echo "AmbiDexter [$type, k=$ambilen]"
            for lang in $mugrammars; do
                out=""
                for t in ${timelimits}; do
                    tout=$(print "ambidexter/mutlang/${t}s_-k_${ambilen}/$type/$lang/log")
                    out="$out,$tout"
                done
                echo "ambidexter/mutlang/k_${ambilen}/$type/$lang,$out"
                    
                for filter in lr0 slr1 lalr1 lr1; do
                    out=""
                    for t in $timelimits;do
                        tout=$(print "ambidexter/mutlang/${t}s_-f_${filter}_-k_${ambilen}/$type/$lang/log")
                        out="$out,$tout"
                    done
                    echo "ambidexter/mutlang/${filter}_-k_${ambilen}/$type/$lang,$out"
                done
            done
        done
        
        for lang in $mugrammars; do
            out=""
            for t in $timelimits; do
                tout=$(print "ambidexter/mutlang/${t}s_-i_0/$type/$lang/log")
                out="$out,$tout"
            done
            echo "ambidexter/mutlang/ik_0/$type/$lang,$out"
                
            for filter in lr0 slr1 lalr1 lr1; do
                out=""
                for t in ${timelimits}; do
                    tout=$(print "ambidexter/mutlang/${t}s_-f_${filter}_-i_0/$type/$lang/log")
                    out="$out,$tout"
                done
                echo "ambidexter/mutlang/${filter}_-ik_0/$type/$lang,$out"
            done
        done
    done    
}

print_acla
print_ambidexter
