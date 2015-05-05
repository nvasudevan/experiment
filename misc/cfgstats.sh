#!/bin/bash

gset=""
tlen=""

set -- $(getopt g:l: "$@")

while [ $# -gt 0 ]
do
    case "$1" in 
     -g) gset=$2 ; shift;;
     -l) tlen=$2 ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
     (*) break;;  
    esac
    shift
done

usage(){
    echo "$0 -g <boltzcfg|mutlang> -l <threshold length of alternative>"
    exit 1
}

[ -z "$gset" ] && usage

boltzcfg() {
  cd $expdir/grammars/$gset
  echo "g, rules, alts, empty, alts (> $tlen), longest, nonterms, terms, cycles"
  for i in $boltzcfgsizes; do
    for j in $(seq 1 $nboltz); do
      out=$(python $prog $i/${j}.acc $i/lex $tlen | cut -d: -f2)
      echo "$i/$j,$out"
    done
  done
}

mutlang() {
  cd $expdir/grammars/$gset/acc
  echo "g, rules, alts, empty, alts (> $tlen), longest, nonterms, terms, cycles"
  for t in $mutypes; do
    for l in $mugrammars; do
      for j in $(find ${t}/${l} -name "*.acc" | cut -d_ -f 2 | sort -h | cut -d. -f1 | head -${nmutations}); do
        lex="../../lex/${l}.lex"
        g="${t}/${l}/${l}.0_${j}.acc"
        out=$(python $prog $g $lex $tlen | cut -d: -f2)
        echo "${t}/${l}/${l}.0_${j},$out"
      done
    done
  done
}

# path to cfg program
expdir="$HOME/codespace/experiment"
prog="$expdir/misc/GrammarInfo.py"
boltzcfgsizes=$(seq 10 75)
nboltz="100"

mugrammars="Pascal SQL Java C CSS"
mutypes="empty add mutate delete switchadj switchany"
nmutations="100"

[ "$gset" == "boltzcfg" ] && boltzcfg
[ "$gset" == "mutlang" ] && mutlang
