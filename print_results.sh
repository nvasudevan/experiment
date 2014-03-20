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

if [ ! -f ./${exp}_toolparams.sh ]; then
    echo "toolparams ./${exp}_toolparams.sh does not exist"
    exit 1
fi

. ./${exp}_toolparams.sh

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
            alllangs="ambidexter/mutlang/k_${ambilen}_${type}.log"
            cp /dev/null $alllangs
            for t in ${timelimits}; do
                for lang in $lgrammars; do
                    cat ambidexter/mutlang/${t}s_-k_${ambilen}/$type/$lang/log >> $alllangs
                done
                tout=$(print $alllangs)
                out="$out,$tout"
            done
            echo "$alllangs,$out"

            for filter in lr0 slr1 lalr1 lr1; do
                alllangs="ambidexter/mutlang/${filter}_k_${ambilen}_${type}.log"
                cp /dev/null $alllangs
                for t in $timelimits;do
                    for lang in $lgrammars; do
                        cat "ambidexter/mutlang/${t}s_-f_${filter}_-k_${ambilen}/$type/$lang/log" >> $alllangs
                    done
                    tout=$(print $alllangs)
                    out="$out,$tout"
                done
                echo "$alllangs,$out"
            done
        done

        alllangs="ambidexter/mutlang/ik_0_${type}.log"
        cp /dev/null $alllangs
        out=""
        for t in $timelimits; do
            for lang in $mugrammars; do
                cat "ambidexter/mutlang/${t}s_-i_0/$type/$lang/log" >> $alllangs
            done
            tout=$(print $alllangs)
            out="$out,$tout"
        done
        echo "$alllangs,$out"

        for filter in lr0 slr1 lalr1 lr1; do
            alllangs="ambidexter/mutlang/${filter}_i_0_${type}.log"
            cp /dev/null $alllangs
            out=""
            for t in ${timelimits}; do
                for lang in $lgrammars; do
                    cat "ambidexter/mutlang/${t}s_-f_${filter}_-i_0/$type/$lang/log" >> $alllangs
                done
                tout=$(print $alllangs)
                out="$out,$tout"
            done
            echo "$alllangs,$out"
        done
    done
}

print_amber(){
  for g in $gset
  do
      for amberex in $amber_n_examples; do
          out=""
          ellout=""
          for t in $timelimits; do
             tout=$(print "amber/boltzcfg/${t}s_examples_${amberex}/log")
             out="$out,$tout"
             tout=$(print "amber/boltzcfg/${t}s_examples_${amberex}_ellipsis/log")
             ellout="$ellout,$tout"
          done
          echo "amber/$g/examples_${amberex},$out"
          echo "amber/$g/examples_${amberex}_ellipsis,$ellout"
      done

      for amberlen in $amber_n_length; do
          out=""
          ellout=""
          for t in $timelimits;do
             tout=$(print "amber/boltzcfg/${t}s_length_${amberlen}/log")
             out="$out,$tout"
             tout=$(print "amber/boltzcfg/${t}s_length_${amberlen}_ellipsis/log")
             ellout="$ellout,$tout"
          done
          echo "amber/$g/length_${amberlen},$out"
          echo "amber/$g/length_${amberlen}_ellipsis,$ellout"
      done
  done
}

# print_acla
# print_ambidexter
print_amber