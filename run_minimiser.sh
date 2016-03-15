#!/bin/sh

# modify the below settings before launch
ambiminp="${HOME}/codespace/sinbad/src/AmbiMin.py"
bolzdir="${HOME}/codespace/experiment/grammars/boltzcfg"
langdir="${HOME}/codespace/experiment/grammars/lang/acc"
mutdir="${HOME}/codespace/experiment/grammars/mutlang/acc"
lexdir="${HOME}/codespace/experiment/grammars/lex"
backend=""
depth=""
weight=""
minimiser=""
gset=""
nmin=""
tmin=""
ambijarp=""
fltr=""
outf=""
tout="60"

export ACCENT_DIR=$HOME/codespace/accent

set -- $(getopt b:m:g:n:t:d:w:f:o:j: "$@")

usage(){
    echo "$0 
            -b <backend> 
            -d <depth> 
            -w <weight> 
            -m <minimiser> 
            -g <grammar set> 
            -n <no of minimisations>
            -t <time to search for ambiguity>
            -j <path to AmbiDexter jar>
            -f <filter to apply>
            -o <output format for minimised grammar>"
    exit 1
}


while [ $# -gt 0 ]
do
    case "$1" in 
     -b) backend=$2 ; shift;;
     -d) depth=$2 ; shift;;
     -w) weight=$2 ; shift;;
     -m) minimiser=$2 ; shift;;
     -g) gset=$2 ; shift;;
     -n) nmin=$2 ; shift;;
     -t) tmin=$2 ; shift;;
     -j) ambijarp=$2 ; shift;;
     -f) fltr=$2 ; shift;;
     -o) outf=$2 ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; usage; exit 1;;
     (*) break;;  
    esac
    shift
done

[ -z "$backend" ] && usage
[ -d "$depth" ] && usage
[ -z "$minimiser" ] && usage
[ -z "$gset" ] && usage

cmd="timeout ${tout}s python $ambiminp -b $backend -w $weight -d $depth -m $minimiser -s"
logd="$(pwd)/log/$minimiser/$gset"
[ ! -d $logd ] && mkdir -p $logd

case "$minimiser" in
    min1) 
      if [ -z "$nmin" ]; then
        echo "min1 requires -n <no of minimisations>"
        usage
      fi
      cmd="$cmd -n $nmin"
    ;;
    min1a) 
      # TO DO
    ;;
    min2|minad) 
      if [ -z "$tmin" ]; then
        echo "min{2|ad} requires -t <time to search for ambiguity>"
        usage
      fi
      cmd="$cmd -t $tmin"
    ;;
    min3) 
      if [ -z "$tmin" ]; then
        echo "min3 requires -t <time to search for ambiguity>"
        usage
      fi
      cmd="$cmd -t $tmin"
    ;;
    min4) 
      if [ -z "$ambijarp" ]; then
        echo "min4 requires -j <path to ambidexter jar>"
        usage
      fi
      if [ -z "$nmin" ]; then
        echo "min4 requires -n <no of minimisations>"
        usage
      fi
      if [ -z "$tmin" ]; then
        echo "min4 requires -t <time to search for ambiguity>"
        usage
      fi
      cmd="$cmd -j $ambijarp -n $nmin -t $tmin"
    ;;
    min5|min6)
      if [ -z "$nmin" ]; then
        echo "min[56] requires -n <no of minimisations>"
        usage
      fi
      if [ -z "$tmin" ]; then
        echo "min[56] requires -t <time to search for ambiguity>"
        usage
      fi
      if [ -z "$ambijarp" ]; then
        echo "min[56] requires -j <path to ambidexter jar>"
        usage
      fi
      if [ -z "$fltr" ]; then
        echo "min[56] requires -f <filter to apply for ambidexter>"
        usage
      fi
      if [ -z "$outf" ]; then
        echo "min[56] requires -t <output format for ambidexter>"
        usage
      fi
      cmd="$cmd -n $nmin -t $tmin -j $ambijarp -f $fltr -o $outf"
    ;;
esac

boltz() {
  for g in $(seq 10 75); do
    for i in $(seq 10); do 
      gacc="$bolzdir/$g/${i}.acc"
      lex="$bolzdir/$g/lex"
      log="/tmp/${g}_${i}.${minimiser}"
      stats=$($cmd -l $log $gacc $lex)
      size0=$(head -1 $log)
      sizen=",,,"
      [ $(wc -l $log | awk '{print $1}') -gt 1 ] && sizen=$(tail -1 $log)
      echo "$g/$i,${size0},,${sizen}"
      rm $log
    done
  done
}

lang() {
  for l in Pascal SQL Java C; do 
    for i in $(seq 5); do
      gacc="$langdir/${l}.${i}.acc"
      lex="$lexdir/${l}.lex"
      log="/tmp/${l}_${i}.${minimiser}"
      stats=$($cmd -l $log $gacc $lex)
      size0=$(head -1 $log)
      sizen=",,,"
      [ $(wc -l $log | awk '{print $1}') -gt 1 ] && sizen=$(tail -1 $log)
      echo "${l}.${i},${size0},,${sizen}"
      rm $log
    done
   done
}

mutlang() {
  for t in empty add mutate delete switch; do 
    mkdir -p $logd/$t
    for l in Pascal SQL Java C CSS; do 
      for i in $(seq 1); do
        gacc="$mutdir/$t/${l}/${l}.0_${i}.acc"
        lex="$lexdir/${l}.lex"
        log="/tmp/${t}_${l}_${i}.${minimiser}"
        stats=$($cmd -l $log $gacc $lex)
        size0=$(head -1 $log)
        sizen=",,,"
        [ $(wc -l $log | awk '{print $1}') -gt 1 ] && sizen=$(tail -1 $log)
        echo "$t/${l}.${i},${size0},,${sizen}"
        rm $log
      done
     done
  done
}

case "$gset" in
    boltz)
      boltz | tee boltz.${minimiser}.csv
      ;;
    lang)
      lang | tee lang.${minimiser}.csv
      ;;
    mutlang)
      mutlang | tee mutlang.${minimiser}.csv
      ;;
esac

