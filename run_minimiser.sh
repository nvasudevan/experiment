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
fltr=""
outf=""
tout="60"

export ACCENT_DIR=$HOME/codespace/accent

set -- $(getopt b:m:g:n:t:d:w:f:o: "$@")

usage(){
    echo "$0 
            -b <backend> 
            -d <depth> 
            -w <weight> 
            -m <minimiser> 
            -g <grammar set> 
            -n <no of minimisations (for min1)> 
            -t <time to search for ambiguity (for min2)>
            -f <filter to apply (for min4)>
            -o <output format for minimised grammar (for min4)>"
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

cmd="timeout ${tout}s python $ambiminp -b $backend -w $weight -d $depth -m $minimiser"
logd="$(pwd)/log/$minimiser/$gset"
[ ! -d $logd ] && mkdir -p $logd

case "$minimiser" in
    min1) 
      if [ -z "$nmin" ]; then
        echo "min1 requires -n <no of minimisations>"
        usage
      fi
      cmd="$cmd -n $nmin -s"
    ;;
    min1a) 
      # TO DO
    ;;
    min2|minad) 
      if [ -z "$tmin" ]; then
        echo "min{2|ad} requires -t <time to search for ambiguity>"
        usage
      fi
      cmd="$cmd -t $tmin -s"
    ;;
    min3) 
      if [ -z "$nmin" ]; then
        echo "min3 requires -n <no of minimisations>"
        usage
      fi
      if [ -z "$tmin" ]; then
        echo "min3 requires -t <time to search for ambiguity>"
        usage
      fi
      cmd="$cmd -n $nmin -t $tmin -s"
    ;;
    min4) 
      if [ -z "$nmin" ]; then
        echo "min4 requires -n <no of minimisations>"
        usage
      fi
      if [ -z "$tmin" ]; then
        echo "min4 requires -t <time to search for ambiguity>"
        usage
      fi
      if [ -z "$fltr" ]; then
        echo "min4 requires -f <filter to apply for ambidexter>"
        usage
      fi
      if [ -z "$outf" ]; then
        echo "min4 requires -t <output format for ambidexter>"
        usage
      fi
      cmd="$cmd -n $nmin -t $tmin -f $fltr -o $outf -s"
    ;;
esac

boltz() {
  for g in $(seq 10 75); do
    for i in $(seq 10); do 
      gacc="$bolzdir/$g/${i}.acc"
      lex="$bolzdir/$g/lex"
      log="/tmp/${g}_${i}.${minimiser}"
      stats=$($cmd -l $log $gacc $lex)
      echo "$g/$i,$(cat $log)"
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
      echo "${l}.$i,$(cat $log)"
      rm $log
    done
   done
}

mutlang() {
  for t in empty add mutate delete switch; do 
    mkdir -p $logd/$t
    for l in Pascal SQL Java C CSS; do 
      for i in $(seq 10); do
        gacc="$mutdir/$t/${l}/${l}.0_${i}.acc"
        lex="$lexdir/${l}.lex"
        log="/tmp/${t}_${l}_${i}.${minimiser}"
        stats=$($cmd -l $log $gacc $lex)
        echo "$t/${l}.$i,$(cat $log)"
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

