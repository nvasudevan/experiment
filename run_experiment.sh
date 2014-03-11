#!/bin/bash

cwd=$(pwd)

if [ $# -eq 0 ]; then
    wrkdir=$(pwd)
elif [ $# -eq 1 ]; then
    wrkdir=$1
    if [ "`dirname $wrkdir`" == "." ]; then 
        _wrkdir="`pwd`/`basename $wrkdir`"
        wrkdir = "$_wrkdir"
    fi
    echo "full path - $wrkdir"
    mkdir -p $wrkdir
else
    echo "$0 [<full path to working directory>]"
    exit 1
fi
echo -e "===> Working in $wrkdir"
export cwd wrkdir

cp /dev/null $cwd/env.sh
echo "export cwd=$cwd" >> $cwd/env.sh
echo "export wrkdir=$wrkdir" >> $cwd/env.sh

# now run build.sh to build your tools
./build.sh $wrkdir || exit $?

echo "Build complete"

# Download AmbiDexter grammars

echo -e "\\n===> Fetching AmbiDexter grammars\\n"

cd $cwd/grammars
wget -O grammars.zip http://sites.google.com/site/basbasten/files/grammars.zip
unzip -q grammars.zip
mv grammars lang

cd $cwd

# sets up values for our experiment
. ./toolparams.sh

[ ! -d $resultsdir ] && mkdir $resultsdir

scriptlist="./scriptlist"
cp /dev/null $scriptlist

for g in $gset
do  
    for timelimit in $timelimits
    do
        echo "$cwd/run_ACLA.sh -g $g -t $timelimit || exit \$?" >> $scriptlist
    done
done

cd $cwd

for g in $gset
do
    for timelimit in $timelimits
    do
        for amberex in $amber_n_examples
        do
            echo "$cwd/run_Amber.sh -g $g -t $timelimit -n $amberex || exit \$?" >> $scriptlist
            echo "$cwd/run_Amber.sh -g $g -t $timelimit -n $amberex -e || exit \$?" >> $scriptlist
        done

        for amberlen in $amber_n_length
        do
            echo "$cwd/run_Amber.sh -g $g -t $timelimit -l $amberlen || exit \$?" >> $scriptlist
            echo "$cwd/run_Amber.sh -g $g -t $timelimit -l $amberlen -e || exit \$?" >> $scriptlist
        done
    done
done

cd $cwd

for g in $gset
do
    for timelimit in $timelimits
    do
        for ambilen in $ambidexter_n_length
        do
            echo "$cwd/run_AmbiDexter.sh -g $g -t $timelimit -k $ambilen || exit \$?" >> $scriptlist
            echo "$cwd/run_AmbiDexter.sh -g $g -t $timelimit -f slr1 -k $ambilen || exit \$?" >> $scriptlist
            echo "$cwd/run_AmbiDexter.sh -g $g -t $timelimit -f lalr1 -k $ambilen || exit \$?" >> $scriptlist
            echo "$cwd/run_AmbiDexter.sh -g $g -t $timelimit -f lr0 -k $ambilen || exit \$?" >> $scriptlist
            echo "$cwd/run_AmbiDexter.sh -g $g -t $timelimit -f lr1 -k $ambilen || exit \$?" >> $scriptlist
        done
            
        echo "$cwd/run_AmbiDexter.sh -g $g -t $timelimit -i 0 || exit \$?" >> $scriptlist
        echo "$cwd/run_AmbiDexter.sh -g $g -t $timelimit -f slr1 -i 0 || exit \$?" >> $scriptlist
        echo "$cwd/run_AmbiDexter.sh -g $g -t $timelimit -f lalr1 -i 0 || exit \$?" >> $scriptlist
        echo "$cwd/run_AmbiDexter.sh -g $g -t $timelimit -f lr0 -i 0 || exit \$?" >> $scriptlist
        echo "$cwd/run_AmbiDexter.sh -g $g -t $timelimit -f lr1 -i 0 || exit \$?" >> $scriptlist
    done
done

cd $cwd

for g in $gset
do
    for timelimit in $timelimits
    do
        echo "$cwd/run_SinBAD.sh -g $g -b purerandom -t $timelimit || exit \$?" >> $scriptlist

        for backend in $backends
        do
            for d in $Tdepths
            do
                echo "$cwd/run_SinBAD.sh -g $g -b $backend -t $timelimit -d $d || exit \$?" >> $scriptlist
            done
        done

        for backend in $wgtbackends
        do
            for d in $Tdepths
            do
                for wgt in $weights
                do
                    echo "$cwd/run_SinBAD.sh -g $g -b $backend -t $timelimit -d $d -w $wgt || exit \$?" >> $scriptlist
                done
            done
        done
    done
done

echo "Generated list of scripts ($scriptlist); running them in parallel ..."

nodelist=""
for host in $(cat ~/machinefile)
do 
    nodelist="8/$host,$nodelist"
done
pllnodes=$(echo $nodelist | sed -e 's/,$//')

echo $pllnodes

expstart=$(date +%s)
cat $scriptlist | parallel -u -S $pllnodes
expend=$(date +%s)
expelapsed=$(($expend - $expstart))

echo -e "\\n===> experiment complete in $expelapsed seconds \n"

cd $cwd
tar czf results.tar.gz results
echo -e "\\n===> results - results.tar.gz \\n"

echo -e "\\n pretty printing results to $ppresults \\n"
./ppresults.sh > $ppresults 2>&1
