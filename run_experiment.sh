#!/bin/bash

wrkdir=""
exp=""

set -- $(getopt d:x: "$@")

while [ $# -gt 0 ]
do
    case "$1" in 
     -d) wrkdir=$2 ; shift;;
     -x) exp=$2 ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
     (*) break;;  
    esac
    shift
done

usage(){
    echo "$0 -d <work dir> -x <travis|crude_dim|main_dim|mini|main|validation>"
    exit 1
}

[ -z "$wrkdir" ] && usage
[ -z "$exp" ] && usage

expdir=$(cd $(dirname $0); pwd)
echo -e "===> Experiment dir is $expdir"
echo -e "===> Tools are setup in $wrkdir"
mkdir -p $wrkdir
export expdir wrkdir

> $expdir/env.sh
echo "export expdir=$expdir" >> $expdir/env.sh
echo "export wrkdir=$wrkdir" >> $expdir/env.sh

export scriptsdir=$expdir/scripts
[ -z "$scriptsdir" ] && echo "*scriptsdir* is not set! exiting..." && exit 1
[ ! -d "$scriptsdir" ] && echo "*scriptsdir* does not exist! exiting..." && exit 1

# setup common stuff
. $scriptsdir/base_params.sh

# setup experiment related stuff
ln -sf $scriptsdir/${exp}_toolparams.sh $expdir/toolparams.sh
. ./toolparams.sh

# download grammars that come with ambidexter
$scriptsdir/download_grammars.sh

# now run build.sh to build your tools
./build.sh || exit $?

[ ! -d $resultsdir ] && mkdir $resultsdir

# for travis: run the tools on test grammars
if [ "$exp" == "travis" ]; then
  for g in test lang; do
    $scriptsdir/run_acla.sh -g $g -t 10 -k
    [ $(grep -c yes $resultsdir/acla/$g/10s_-k/log) == 1 ] || exit 1

    $scriptsdir/run_amber.sh -g $g -t 10 -l 10
    [ $(grep -c yes $resultsdir/amber/$g/10s_length_10/log) == 1 ] || exit 1

    $scriptsdir/run_ambidexter.sh -g $g -t 10 -k 10
    [ $(grep -c yes $resultsdir/ambidexter/$g/10s_-k_10/log) == 1 ] || exit 1

    $scriptsdir/run_ambidexter.sh -g $g -t 10 -f slr1 -k 10
    [ $(grep -c yes $resultsdir/ambidexter/$g/10s_-f_slr1_-k_10/log) == 1 ] || exit 1

    $scriptsdir/run_sinbad.sh -g $g -b dynamic1 -t 10 -d 10
    [ $(grep -c yes $resultsdir/sinbad/$g/10s_-b_dynamic1_-d_10/log) == 1 ] || exit 1

    $scriptsdir/run_sinbad.sh -g $g -b dynamic4 -t 10 -d 10 -w 0.1
    [ $(grep -c yes $resultsdir/sinbad/$g/10s_-b_dynamic4_-d_10_-w_0.1/log) == 1 ] || exit 1
  done
  exit 0
fi

scriptlist="$expdir/scriptlist"
> $scriptlist

for g in $gset; do
  for timelimit in $timelimits; do
      echo "$scriptsdir/run_acla.sh -g $g -t $timelimit || exit \$?" >> $scriptlist
  done
done

for g in $gset; do
  for timelimit in $timelimits; do
    for amberex in $amber_n_examples; do
      echo "$scriptsdir/run_amber.sh -g $g -t $timelimit -n $amberex || exit \$?" >> $scriptlist
      echo "$scriptsdir/run_amber.sh -g $g -t $timelimit -n $amberex -e || exit \$?" >> $scriptlist
    done

    for amberlen in $amber_n_length; do
      echo "$scriptsdir/run_amber.sh -g $g -t $timelimit -l $amberlen || exit \$?" >> $scriptlist
      echo "$scriptsdir/run_amber.sh -g $g -t $timelimit -l $amberlen -e || exit \$?" >> $scriptlist
    done
  done
done

for g in $gset; do
  for timelimit in $timelimits; do
    for ambilen in $ambidexter_n_length; do
      echo "$scriptsdir/run_ambidexter.sh -g $g -t $timelimit -k $ambilen || exit \$?" >> $scriptlist
      echo "$scriptsdir/run_ambidexter.sh -g $g -t $timelimit -f slr1 -k $ambilen || exit \$?" >> $scriptlist
      echo "$scriptsdir/run_ambidexter.sh -g $g -t $timelimit -f lalr1 -k $ambilen || exit \$?" >> $scriptlist
      echo "$scriptsdir/run_ambidexter.sh -g $g -t $timelimit -f lr0 -k $ambilen || exit \$?" >> $scriptlist
      echo "$scriptsdir/run_ambidexter.sh -g $g -t $timelimit -f lr1 -k $ambilen || exit \$?" >> $scriptlist
    done

    echo "$scriptsdir/run_ambidexter.sh -g $g -t $timelimit -i 0 || exit \$?" >> $scriptlist
    echo "$scriptsdir/run_ambidexter.sh -g $g -t $timelimit -f slr1 -i 0 || exit \$?" >> $scriptlist
    echo "$scriptsdir/run_ambidexter.sh -g $g -t $timelimit -f lalr1 -i 0 || exit \$?" >> $scriptlist
    echo "$scriptsdir/run_ambidexter.sh -g $g -t $timelimit -f lr0 -i 0 || exit \$?" >> $scriptlist
    echo "$scriptsdir/run_ambidexter.sh -g $g -t $timelimit -f lr1 -i 0 || exit \$?" >> $scriptlist
  done
done

for g in $gset; do
  for timelimit in $timelimits; do
    echo "$scriptsdir/run_sinbad.sh -g $g -b purerandom -t $timelimit || exit \$?" >> $scriptlist

    for backend in $backends; do
      for d in $Tdepths; do
        echo "$scriptsdir/run_sinbad.sh -g $g -b $backend -t $timelimit -d $d || exit \$?" >> $scriptlist
      done
    done

    for backend in $wgtbackends; do
      for d in $Tdepths; do
        for wgt in $weights; do
          echo "$scriptsdir/run_sinbad.sh -g $g -b $backend -t $timelimit -d $d -w $wgt || exit \$?" >> $scriptlist
        done
      done
    done

  done
done

echo "$scriptlist generated. Running them in parallel ..."

[ ! -f ~/machinefile ] && echo "I need ~/machinefile with list of hosts to run jobs"
nodelist=""
for host in $(cat ~/machinefile)
do
    nodelist="$cores_per_host/$host,$nodelist"
done
pllnodes=$(echo $nodelist | sed -e 's/,$//')

echo $pllnodes

cat $scriptlist | parallel -u -S $pllnodes

echo -e "\\n===> Experiment finished"
#tar czf results.tar.gz results
#echo -e "\\n===> results - results.tar.gz \\n"
#echo -e "\\n pretty printing results to $ppresults \\n"
#$scriptsdir/ppresults.sh > $ppresults 2>&1
