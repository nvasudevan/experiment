#!/bin/bash

cwd="`pwd`"

if [ $# -eq 0 ]; then
    wrkdir=`pwd`
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

# now run build.sh to build your tools
./build.sh $wrkdir || exit $?

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

cd $cwd

for g in $gset
do  
	for timelimit in $timelimits
	do
	    echo "./run_ACLA.sh $g $timelimit || exit \$?" >> $scriptlist
	done
done

cd $cwd

for g in $gset
do
	for timelimit in $timelimits
	do
	    for amberex in $amber_n_examples
	    do
	        echo "./run_Amber.sh $g $timelimit examples $amberex || exit \$?" >> $scriptlist
		    echo "./run_Amber.sh $g $timelimit ellipsis examples $amberex || exit \$?" >> $scriptlist
		done

        for amberlen in $amber_n_length
        do
		    echo "./run_Amber.sh $g $timelimit length $amberlen || exit $?" >> $scriptlist
		    echo "./run_Amber.sh $g $timelimit ellipsis length $amberlen || exit $?" >> $scriptlist
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
	        echo "./run_AmbiDexter.sh $g $timelimit -q -pg -k $ambilen || exit $?" >> $scriptlist
	        echo "./run_AmbiDexter.sh $g $timelimit slr1 -q -pg -k $ambilen || exit $?" >> $scriptlist
	        echo "./run_AmbiDexter.sh $g $timelimit lalr1 -q -pg -k $ambilen || exit $?" >> $scriptlist
		done
		    
	    echo "./run_AmbiDexter.sh $g $timelimit -q -pg -ik 0 || exit \$?" >> $scriptlist
	    echo "./run_AmbiDexter.sh $g $timelimit slr1 -q -pg -ik 0 || exit \$?" >> $scriptlist
	    echo "./run_AmbiDexter.sh $g $timelimit lalr1 -q -pg -ik 0 || exit \$?" >> $scriptlist
	done
done

cd $cwd

for g in $gset
do
    for timelimit in $timelimits
    do
        echo "./run_SinBAD.sh $g purerandom $timelimit || exit \$?" >> $scriptlist
        
        for backend in dynamic1
        do
            for d in $Tdepths
            do
                echo "./run_SinBAD.sh $g $backend $timelimit $d || exit \$?" >> $scriptlist
            done
        done
    done
done

echo "Generated list of scripts ($scriptlist); running them in parallel ..."

expstart=$(date +%s)
cat $scriptlist | parallel --progress -u -j -1
expend=$(date +%s)
expelapsed=$(($expend - $expstart))

echo -e "\\n===> experiment complete in $expelapsed seconds \n"

cd $cwd
tar czf results.tar.gz results
echo -e "\\n===> results - results.tar.gz \\n"

echo -e "\\n pretty printing results to $ppresults \\n"
./ppresults.sh > $ppresults 2>&1
