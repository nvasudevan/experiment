#!/bin/bash

[ -z "$1" ] && usage 

usage() {
  echo "$0 <amber|ambidexter>"
  exit 1
}

tool="$1"
expdir="${HOME}/codespace/experiment"
logdir="${expdir}/results"
out="/tmp/$tool"

amber_parse() {
  g=$1
  opt=$2
  echo -e "\n=> g: $g , opt: $opt"
  cd $logdir/$tool/$g
  grep -c yes 10s_${opt}_*/log \
          | grep -v ellipsis \
          | sort -t_ -k3,3 -h \
          | sed -e "s/10s_${opt}_//" -e 's/\/log//' \
          > ${out}.${g}
  grep -c yes 10s_${opt}_*/log \
          | grep ellipsis \
          | sort -t_ -k3,3 -h \
          | sed -e "s/10s_${opt}_//" -e 's/_ellipsis//' -e 's/\/log//' \
          > ${out}.${g}.e

  lsort=$(cat ${out}.${g} ${out}.${g}.e | cut -d: -f1 | sort -h | uniq)
  for i in $lsort; do 
      v=$(grep -w ^$i ${out}.${g} | cut -d: -f2)
      v_ell=$(grep -w ^$i ${out}.${g}.e | cut -d: -f2)
      echo "$i,$v,$v_ell"
  done
}

ambidexter_parse() {
  g=$1
  echo -e "\n=> g: $g , opt: $opt"
  cd $logdir/$tool/$g
  grep -c yes 10s_-k_*/log 2>/dev/null \
          | sort -t_ -k3,3 -h \
          | sed -e "s/10s_-k_//" -e 's/\/log//' > ${out}.${g}
  for f in lr0 slr1 lalr1 lr1; do
    grep -c yes 10s_-f_${f}_-k_*/log 2>/dev/null \
          | sort -t_ -k5,5 -h \
          | sed -e "s/10s_-f_${f}_-k_//" -e 's/\/log//' > ${out}.${g}.${f}
  done

  lsort=$(cat ${out}.${g} ${out}.${g}.*| cut -d: -f1 | sort -h | uniq)
  for i in $lsort; do 
      v=$(grep -w ^$i ${out}.${g} | cut -d: -f2)
      v_lr0=$(grep -w ^$i ${out}.${g}.lr0 | cut -d: -f2)
      v_slr1=$(grep -w ^$i ${out}.${g}.slr1| cut -d: -f2)
      v_lalr1=$(grep -w ^$i ${out}.${g}.lalr1 | cut -d: -f2)
      v_lr1=$(grep -w ^$i ${out}.${g}.lr1 | cut -d: -f2)
      echo "$i,$v,$v_lr0,$v_slr1,$v_lalr1,$v_lr1"
  done
}

if [ "$tool" == "amber" ]; then
  amber_parse boltzcfg length
  amber_parse boltzcfg examples
  amber_parse mutlang length 
  amber_parse mutlang examples 
else
  ambidexter_parse boltzcfg 
  #ambidexter_parse mutlang 
fi
