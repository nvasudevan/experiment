#!/bin/bash

gset=""

set -- $(getopt g: "$@")

while [ $# -gt 0 ]
do
    case "$1" in 
     -g) gset=$2 ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
     (*) break;;  
    esac
    shift
done

usage(){
    echo "$0 -g <boltz|mutlang>"
    exit 1
}

[ -z "$gset" ] && usage

boltzcfg() {
  for i in $(seq 10 65); do 
    for j in $(find $i -name "*.acc" | cut -d/ -f 2 | sort -h); do 
      for k in $(find $i -name "*.acc" | cut -d/ -f 2 | sort -h); do 
        if [ $j != $k ]; then
          lex="$i/lex"
          srcg="$i/$j"
          tgtg="$i/$k"
          out=$(python $cfgp $lex $srcg $tgtg | tail -1)
          echo "$srcg - $tgtg,$out"
        fi
      done
    done
  done
}

mutlang() {
  cd acc
  for t in empty add mutate delete switchadj switchany; do  
    for l in Pascal SQL Java C CSS; do 
      for bg in $(find ${t}/${l} -name "*.acc" | cut -d_ -f 2 | sort -h); do 
        for tg in $(find ${t}/${l} -name "*.acc" | cut -d_ -f 2 | sort -h); do 
          if [ $bg != $tg ]; then
            lex="../../lex/${l}.lex"
            srcg="${t}/${l}/${l}.0_$bg"
            tgtg="${t}/${l}/${l}.0_$tg"
	        out=$(python $cfgp $lex $srcg $tgtg | tail -1)
            echo "$srcg - $tgtg,$out"
          fi
        done
      done
    done
  done
}

# path to cfg program
expdir="$HOME/codespace/experiment"
cfgp="$expdir/misc/CompareCFG.py"

cd $expdir/grammars/$gset
[ "$gset" == "boltzcfg" ] && boltzcfg
[ "$gset" == "mutlang" ] && mutlang
