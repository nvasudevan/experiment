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
wget -O grammars.zip https://sites.google.com/site/basbasten/files/grammars.zip
unzip -q grammars.zip
mv grammars lang

cd $cwd

# sets up values for our experiment
. ./toolparams.sh

[ ! -d $resultsdir ] && mkdir $resultsdir

scriptlist="./scriptlist"
cp /dev/null $scriptlist

# Run each tool now on three sets of grammars

echo -e "\\n===> ACLA \\n"
cd $cwd

for g in $gset
do  
	for timelimit in $timelimits
	do
	    echo -e "\n===> [$g]:: time limit: $timelimit \n"
		echo "./run_ACLA.sh $g $timelimit || exit \$?" >> $scriptlist
	done
done

echo -e "\n===> Amber \\n"
cd $cwd

for g in $gset
do
	for timelimit in $timelimits
	do
	    echo -e "\n===> [$g]:: time limit: $timelimit \n"
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

echo -e "\n===> AmbiDexter \\n"
cd $cwd

for g in $gset
do
    for timelimit in $timelimits
    do
	    filtertimes=""
	    for fratio in $filtertimeratios
	    do
		    _ftime=$(python -c "from math import ceil; print int(ceil($timelimit * $fratio))")
		    filtertimes="$filtertimes $_ftime"
	    done	  
	    echo "filter times: $filtertimes"
	    
	    for ftime in $filtertimes
	    do
	        echo -e "\n===> [$g]:: time limit: $timelimit, ftime: $ftime \n"
	        for ambilen in $ambidexter_n_length
	        do
	            echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s -q -pg -k $ambilen || exit $?" >> $scriptlist
			    echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s slr1 -q -pg -k $ambilen || exit $?" >> $scriptlist
			    echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s lalr1 -q -pg -k $ambilen || exit $?" >> $scriptlist
		    done
		    
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s -q -pg -ik 0 || exit \$?" >> $scriptlist
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s slr1 -q -pg -ik 0 || exit \$?" >> $scriptlist
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s lalr1 -q -pg -ik 0 || exit \$?" >> $scriptlist
	    done
	done
done

echo -e "\n===> SinBAD \\n"
cd $cwd

for g in $gset
do
    for timelimit in $timelimits
    do
        echo -e "\n===> [$g]::[purerandom] time limit: $timelimit \n"
        echo "./run_SinBAD.sh $g purerandom $timelimit || exit \$?" >> $scriptlist
        
        for backend in dynamic1
        do
            for d in $Tdepths
            do
                echo -e "\n===> [$g]::[$backend]::[depth=$d] time limit: $timelimit \n"
                echo "./run_SinBAD.sh $g $backend $timelimit $d || exit \$?" >> $scriptlist
            done
        done
    done
done

echo "Generated list of scripts ($scriptlist); running them in parallel ..."

expstart=$(date +%s)
cat scriptlist | parallel --progress -u -j -1
expend=$(date +%s)
expelapsed=$(($expend - $expstart))

echo -e "\\n===> experiment complete in $expelapsed seconds \n"

cd $cwd
tar czf results.tar.gz results
echo -e "\\n===> results - results.tar.gz \\n"

echo -e "\\n pretty printing results to $ppresults \\n"
./ppresults.sh > $ppresults 2>&1
