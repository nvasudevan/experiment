#!/bin/bash

. $expdir/toolparams.sh

cfgset="${1}"

usage() {
  echo "$0 <lang|boltz|mutlang>"
  exit 1
}

[ -z "$cfgset" ] && usage

sinbad="/home/krish/codespace/sinbad/src/sinbad"
ambidexter_jar="${wrkdir}/ambidexter/build/AmbiDexter.jar"

lang() {
  for l in $lgrammars; do
    for i in $(seq $nlang); do
      min1td="/var/tmp/min1_${l}_${i}"
      min4td="/var/tmp/min4_${l}_${i}"
      rm -rf $min1td $min4td 
      cfg="${grammardir}/lang/acc/${l}.${i}.acc"
      lex="${grammardir}/lex/${l}.lex"
      $min1_cmd -x $min1td $cfg $lex > /dev/null 2>&1
      if [ -f $min1td/log ]; then
        finalmin1=$(tail -1 $min1td/log)
        _acc=$(echo $finalmin1 | cut -d, -f1)
        _lex=$(echo $finalmin1 | cut -d, -f2)
        $min4_cmd -x $min4td $_acc $_lex >/dev/null 2>&1
        from_min1=$(tail -1 $min1td/log | cut -d, -f5-7)
        from_min4=''
        [ -f $min4td/log ] && from_min4=$(tail -1 $min4td/log | cut -d, -f5-7)
        echo "$(head -1 $min1td/log | cut -d, -f1,5-7),,${from_min1},,${from_min4}"
      else
        echo "$cfg,,,"
      fi
    done
  done
}

boltz() {
  for g in $boltzcfgsizes; do
    for i in $(seq $nboltz); do 
      min1td="/var/tmp/min1_${g}_${i}"
      min4td="/var/tmp/min4_${g}_${i}"
      rm -rf $min1td $min4td 
      mkdir -p $min1td $min4td 
      cfg="${grammardir}/boltzcfg/${g}/${i}.acc"
      lex="${grammardir}/boltzcfg/${g}/lex"
      $min1_cmd -x $min1td $cfg $lex > /dev/null 2>&1
      if [ -f $min1td/log ]; then
        finalmin1=$(tail -1 $min1td/log)
        _acc=$(echo $finalmin1 | cut -d, -f1)
        _lex=$(echo $finalmin1 | cut -d, -f2)
        $min4_cmd -x $min4td $_acc $_lex >${min4td}/min4.log 2>&1
        from_min1=$(tail -1 $min1td/log | cut -d, -f5-7)
        from_min4=''
        [ -f $min4td/log ] && from_min4=$(tail -1 $min4td/log | cut -d, -f5-7)
        echo "$(head -1 $min1td/log | cut -d, -f1,5-7),,${from_min1},,${from_min4}"
      else
        echo "$cfg,,,,"
      fi
    done
    rm -rf /tmp/tmp*
  done
}

mutlang() {
  for t in $mutypes; do
    for l in $mugrammars; do
      glist=$(find $gmutlang/acc/$t/$l -name "*.acc" | cut -d_ -f2 | sort -h | cut -d. -f1 | head -${nmutations})
      for n in $glist
      do
        min1td="/var/tmp/min1_${t}_${l}_${n}"
        min4td="/var/tmp/min4_${t}_${l}_${n}"
        rm -rf $min1td $min4td 
        cfg="$gmutlang/acc/$t/$l/${l}.0_${n}.acc"
        lex="${grammardir}/lex/${l}.lex"
        $min1_cmd -x $min1td $cfg $lex > /dev/null 2>&1
        if [ -f $min1td/log ]; then
          finalmin1=$(tail -1 $min1td/log)
          _acc=$(echo $finalmin1 | cut -d, -f1)
          _lex=$(echo $finalmin1 | cut -d, -f2)
          $min4_cmd -x $min4td $_acc $_lex >/dev/null 2>&1
          from_min1=$(tail -1 $min1td/log | cut -d, -f5-7)
          from_min4=''
          [ -f $min4td/log ] && from_min4=$(tail -1 $min4td/log | cut -d, -f5-7)
          echo "$(head -1 $min1td/log | cut -d, -f1,5-7),,${from_min1},,${from_min4}"
        else
          echo "$cfg,,,"
        fi
      done
    done
  done
}

if [ $cfgset == 'boltz' ]; then
  b='dynamic3'
  D='13'
  cmd="python $sinbad -b $b -d $D"
  min1_cmd="/usr/bin/timeout 10s ${cmd} -m min1"
  min4_cmd="/usr/bin/timeout 30s ${cmd} -m min4 -j ${ambidexter_jar} -T 30 -X 4G"
  boltz
elif [ $cfgset == 'lang' ]; then 
  b='dynamic3'
  D='11'
  cmd="python $sinbad -b $b -d $D"
  min1_cmd="/usr/bin/timeout 10s ${cmd} -m min1"
  min4_cmd="/usr/bin/timeout 30s ${cmd} -m min4 -j ${ambidexter_jar} -T 30 -X 4G"
  lang
elif [ $cfgset == 'mutlang' ]; then
  b='dynamic2rws'
  D='20'
  W='0.036382'
  cmd="python $sinbad -b ${b} -d ${D} -w ${W}"
  min1_cmd="/usr/bin/timeout 10s ${cmd} -m min1"
  min4_cmd="/usr/bin/timeout 30s ${cmd} -m min4 -j ${ambidexter_jar} -T 30 -X 4G"
  mutlang
fi
