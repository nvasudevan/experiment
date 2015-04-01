#!/bin/bash

[ -z "$1" ] && usage 

usage() {
  echo "$0 <amber|ambidexter>"
  exit 1
}

tool="$1"
expdir="${HOME}/codespace/experiment"
logdir="${expdir}/results"

amber_parse() {
  g=$1
  opt=$2
  echo -e "\n=> g: $g , opt: $opt"
  cd $logdir/$tool/$g
  grep -c yes 10s_${opt}_*/log | grep -v ellipsis | sort -t_ -k3,3 -h | sed -e "s/10s_${opt}_//" -e 's/\/log//' > ${out}.${g}
  grep -c yes 10s_${opt}_*/log | grep ellipsis | sort -t_ -k3,3 -h | sed -e "s/10s_${opt}_//" -e 's/_ellipsis//' -e 's/\/log//' > ${out}.${g}.e

  lsort=$(cat ${out}.${g} ${out}.${g}.e | cut -d: -f1 | sort -h | uniq)
  for i in $lsort; do 
      v1=$(grep -w ^$i ${out}.${g} | cut -d: -f2)
      v2=$(grep -w ^$i ${out}.${g}.e | cut -d: -f2)
      echo "$i,$v1,$v2"
  done
}

ambidexter_parse() {
  g=$1
  echo -e "\n=> g: $g , opt: $opt"
  cd $logdir/$tool/$g
  grep -c yes 10s_-k_*/log | sort -t_ -k3,3 -h | sed -e "s/10s_-k_//" -e 's/\/log//' > ${out}.${g}

  lsort=$(cat ${out}.${g} | cut -d: -f1 | sort -h)
  for i in $lsort; do 
      v1=$(grep -w ^$i ${out}.${g} | cut -d: -f2)
      echo "$i,$v1"
  done
}

out="/tmp/$tool"

if [ "$tool" == "amber" ]; then
  amber_parse boltzcfg length
  amber_parse boltzcfg examples
  amber_parse mutlang length 
  amber_parse mutlang examples 
else
  ambidexter_parse boltzcfg 
fi
