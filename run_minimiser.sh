#!/bin/sh

bolzdir="${HOME}/codespace/experiment/grammars/boltzcfg"
mutdir="${HOME}/codespace/experiment/grammars/mutlang/acc"
lexdir="${HOME}/codespace/experiment/grammars/lex"
backend=""
depth=
weight=""
minimiser=""
gset=""
nmin=""
tmin=""
tout=""
savecfg=""

set -- $(getopt m:g:n:t:b:w:d:T:s "$@")

usage(){
    echo "$0 
            -m <minimiser> 
            -b <backend> 
            -d <depth> 
	    -w <(applicable for dynamic4) weight> 
            -g <grammar set> 
            -T <total time for minimisation>
	    -n <(applicable for min1) no of minimisations> 
	    -t <(applicable for min2) search time when a rule is removed>
	    -c <(applicable for min1a) reset counter: no of times to keep 
	        running minimiser in the hope there will be further reduction
	    -s <save the minimised cfg .m extension>
	 "
    exit 1
}


while [ $# -gt 0 ]
do
    case "$1" in 
     -m) minimiser=$2 ; shift;;
     -b) backend=$2 ; shift;;
     -d) depth=$2 ; shift;;
     -w) weight=$2 ; shift;;
     -g) gset=$2 ; shift;;
     -n) nmin=$2 ; shift;;
     -c) cmin=$2 ; shift;;
     -t) tmin=$2 ; shift;;
     -T) tout=$2 ; shift;;
     -s) savecfg="-s" ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; usage; exit 1;;
     (*) break;;  
    esac
    shift
done

# checks
[ -z "$backend" ] && usage
[ -z "$depth" ] && usage
[ -z "$minimiser" ] && usage
[ -z "$gset" ] && usage
[ -z "$tout" ] && usage
[ "$minimiser" == "min1" ]   && [ -z "$nmin" ] && usage
[ "$minimiser" == "min2" ]   && [ -z "$tmin" ] && usage
[ "$minimiser" == "min1a" ]  && [ -z "$cmin" ] && usage
[ "$backend" == "dynamic4" ] && [ -z "$weight" ] && usage

# build cmd
cmd="timeout ${tout}s python AmbiMin.py -b $bend -d $d -m $minimiser"
[ "$minimiser" == "min1" ]   && cmd="$cmd -n $nmin"
[ "$minimiser" == "min1a" ]  && cmd="$cmd -c $cmin"
[ "$minimiser" == "min2" ]   && cmd="$cmd -t $tmin"
[ "$backend" == "dynamic4" ] && cmd="$cmd -w $weight"
[ ! -z "$savecfg" ] && cmd="$cmd -s"

logd="$(pwd)/log/$minimiser/$gset"
[ ! -d $logd ] && mkdir -p $logd

# TODO: download and setup up accent in workdir
setup_accent() {
  export ACCENT_DIR=$HOME/codespace/accent
}

boltz() {
  for g in $(seq 10 65); do
    for i in $(seq 10); do 
      gacc="$bolzdir/$g/${i}.acc"
      lex="$bolzdir/$g/lex"
      $cmd $gacc $lex > $logd/${g}_${i}.log 
      gzip $logd/${g}_${i}.log
      sizes=$(zgrep ^stats $logd/${g}_${i}.log.gz | cut -d: -f3) 
      echo "$g/$i,$(echo $sizes | sed -e 's/ /,/g')" 
    done
  done
}

mutlang() {
  echo "=> $m"
  for t in empty add mutate delete switchadj switchany; do 
    mkdir -p $logd/$t
    for l in Pascal SQL Java C CSS; do 
      for i in $(seq 10); do
        gacc="$mutdir/$t/${l}/${l}.0_${i}.acc"
        lex="$lexdir/${l}.lex"
        $cmd $gacc $lex > $logd/$t/${l}_${i}.log 
        gzip $logd/$t/${l}_${i}.log
        sizes=$(zgrep ^stats $logd/$t/${l}_${i}.log.gz | cut -d: -f3) 
        echo "$t/${l}_$i,$(echo $sizes | sed -e 's/ /,/g')"
      done
     done
  done
}

setup_accent

case "$gset" in
    boltz)
      boltz | tee boltz.${minimiser}.csv
      ;;
    mutlang)
      mutlang | tee mutlang.${minimiser}.csv
      ;;
esac

