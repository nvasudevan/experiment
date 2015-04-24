#!/bin/bash

[ -z "$1" ] && usage

usage() {
  msg="$1"
  [ ! -z "$msg" ] && echo $msg
  echo "Usage: $0 <amber|ambidexter|sinbad>"
  exit 1
}

tool="$1"
expdir="${HOME}/codespace/experiment"
logdir="${expdir}/results"
out="/tmp/$tool"

filters="lr0 slr1 lalr1 lr1"
backends="dynamic1 dynamic2 dynamic3"
wgtbackends="dynamic4"

amber() {
  g=$1
  opt=$2
  echo -e "\n=> g: $g , opt: $opt"
  if [ -d $logdir/$tool/$g ]; then
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
  fi
}

ambidexter() {
  g=$1
  echo -e "\n=> g: $g , opt: $opt"
  if [ -d $logdir/$tool/$g ]; then
    cd $logdir/$tool/$g
    grep -c yes 10s_-k_*/log 2>/dev/null \
            | sort -t_ -k3,3 -h \
            | sed -e "s/10s_-k_//" -e 's/\/log//' > ${out}.${g}
    for f in $filters; do
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
  fi
}

sinbad() {
  g=$1
  echo -e "\n=> g: $g"
  if [ -d $logdir/$tool/$g ]; then
    cd $logdir/$tool/$g
    for b in $backends $wgtbackends; do 
      grep -c yes 10s_-b_${b}_*/log 2>/dev/null \
            | sort -t_ -k5,5 -k7,7 -h \
            | sed -e "s/10s_-b_${b}_-d_//" -e 's/_-w_/,/' -e 's/\/log:/,/' > ${out}.${g}.${b}
    done
    dsort=$(cat ${out}.${g}.dynamic* | cut -d, -f1 | sort -h | uniq)
    for i in $dsort; do 
      dyn1=$(grep -w ^$i ${out}.${g}.dynamic1 | cut -d, -f2)
      dyn2=$(grep -w ^$i ${out}.${g}.dynamic2 | cut -d, -f2)
      dyn3=$(grep -w ^$i ${out}.${g}.dynamic3 | cut -d, -f2)
      echo "$i,$dyn1,$dyn2,$dyn3"
    done
  fi
}

case "$tool" in
 amber)
   amber boltzcfg length
   amber boltzcfg examples
   amber lang length
   amber lang examples
   amber mutlang length
   amber mutlang examples
   ;;
 ambidexter)
   ambidexter boltzcfg
   ambidexter lang
   ambidexter mutlang
   ;;
 sinbad)
   sinbad boltzcfg
   sinbad lang
   sinbad mutlang
   ;;
 *) 
   usage "Error - unrecognized option for tool: $tool" 
   ;;
esac
