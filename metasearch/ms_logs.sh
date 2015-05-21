#!/bin/bash

usage() {
  msg="$1"
  [ ! -z "$msg" ] && echo $msg
  echo "Usage: $0 -d <log results directory> -t <amber|ambidexter|sinbad> -g <boltzcfg|lang|mutlang>"
  exit 1
}

logdir=""
tool=""
gset=""

set -- $(getopt d:t:g: "$@")

while [ $# -gt 0 ]
do
    case "$1" in 
     -d) logdir=$2 ; shift;;
     -t) tool=$2 ; shift;;
     -g) gset=$2 ; shift;;
    (--) shift; break;;
    (-*) usage "$0: error - unrecognized option $1" 1>&2; ;;
     (*) break;;  
    esac
    shift
done

out="/tmp/$tool"

filters="lr0 slr1 lalr1 lr1"
backends="dynamic1 dynamic2 dynamic3"
wgtbackends="dynamic4 dynamic7"

amber() {
  g=$1
  opt=$2
  echo -e "\n=> g: $g [$opt]"
  echo "len/ex, $opt, ${opt}+ell"
  if [ -d $logdir/$tool/$g ]; then
    cd $logdir/$tool/$g
    grep -c yes 10s_${opt}_*/log \
            | sort -t_ -k3,3 -h \
            | sed -e "s/10s_${opt}_//" -e 's/\/log//' \
            > ${out}.${g}
    grep -c yes 10s_ellipsis_${opt}_*/log \
            | sort -t_ -k3,3 -h \
            | sed -e "s/10s_ellipsis_${opt}_//" -e 's/\/log//' \
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
  echo -e "\n=> g: $g"
  echo "length/inc, len, len+lr0, len+slr1, len+lalr1, len+lr1"
  if [ -d $logdir/$tool/$g ]; then
    cd $logdir/$tool/$g
    # incremental length
    inc=$(grep -c yes 10s_-i_0/log 2>/dev/null)
    inc_lr0=$(grep -c yes 10s_-f_lr0_-i_0/log)
    inc_slr1=$(grep -c yes 10s_-f_slr1_-i_0/log)
    inc_lalr1=$(grep -c yes 10s_-f_lalr1_-i_0/log)
    inc_lr1=$(grep -c yes 10s_-f_lr1_-i_0/log)
    echo "0,$inc,$inc_lr0,$inc_slr1,$inc_lalr1,$inc_lr1"
    echo ",,,,"
    # fixed length
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

sinbad_gen_summary() {
  g=$1
  b=$2
  grep -c yes 10s_-b_${b}_*/log 2>/dev/null \
        | sort -t_ -k5,5 -k7,7 -h \
        | sed -e "s/10s_-b_${b}_-d_//" -e 's/_-w_/,/' -e 's/\/log:/,/' > ${out}.${g}.${b}

  > ${out}.${g}.${b}.rec
  dirs=$(find . -name "10s_-b_${b}_*" -type d -print | cut -d/ -f2 | sort -t_ -k5,5 -k7,7 -h)
  for dir in $dirs; do 
    cnt=$(zegrep -o -w 'r:1' $dir/*.log.gz | wc -l)
    d_w=$(echo $dir | sed -e "s/10s_-b_${b}_-d_//" -e 's/_-w_/,/')
    echo "$d_w,$cnt" >> ${out}.${g}.${b}.rec
  done

}

sinbad() {
  g=$1
  echo -e "\n=> g: $g"
  if [ -d $logdir/$tool/$g ]; then
    cd $logdir/$tool/$g
    for bend in $backends $wgtbackends; do 
      echo "processing $bend ..."
      sinbad_gen_summary $gset $bend
    done
    dyns=$(echo $backends $wgtbackends | sed -e 's/dynamic//g' | tr -d ' ')
    dsort=$(cat ${out}.${g}.dynamic[${dyns}] | cut -d, -f1 | sort -h | uniq)
    echo ",${backends// /,,},,${wgtbackends// /,,}"
    echo "depth,ambiguities,recursion,ambiguities,recursion,ambiguities,recursion,ambiguities,recursion"
    for d in $dsort; do 
      pout="$d"
      for bend in $backends; do 
        dynout=$(grep -w ^$d ${out}.${g}.$bend | cut -d, -f2)
        recout=$(grep -w ^$d ${out}.${g}.${bend}.rec | cut -d, -f2)
        pout="$pout,$dynout,$recout"
      done
      for bend in $wgtbackends; do 
        dynw=$(grep -w ^$d ${out}.${g}.$bend | sort -t, -k3,3 -h | tail -1 | cut -d, -f2)
        dynout=$(grep -w "^${d},${dynw}" ${out}.${g}.$bend | cut -d, -f3)
        recout=$(grep -w "^${d},${dynw}" ${out}.${g}.${bend}.rec | cut -d, -f3)
        pout="$pout,$dynout,$recout"
      done
      echo "$pout"
    done
  fi
}


case "$tool" in
 amber)
   amber $gset length
   amber $gset examples
   ;;
 ambidexter)
   ambidexter $gset
   ;;
 sinbad)
   sinbad $gset
   ;;
 *) 
   usage "Error - unrecognized option for tool: $tool" 
   ;;
esac
