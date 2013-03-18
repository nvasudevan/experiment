#!/bin/sh

testgrammars="amb2 amb3"
Nrandom="100"
lgrammars="Pascal SQL Java C"
Nlang="5"
mugrammars="Pascal SQL Java C"
nboltz="10"
Nmutations="10"
mutypes="type1 type2 type3 type4"
Tdepths="25 30 35 40 45 50"

memlimit="128m"
timelimits="10 30 120 240 480"
filtertimeratios="0.25 0.5"
gset="random1000 lang mutlang boltzcfg"


export testgrammars Nrandom lgrammars Nlang mugrammars Nmutations mutypes nboltz Tdepths
export memlimit timelimit

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

grammardir="$cwd/grammars"
lexdir="$grammardir/lex"
grandom="$grammardir/random1000"
glang="$grammardir/lang"
gmutlang="$grammardir/mutlang"
gboltz="$grammardir/boltzcfg"
resultsdir="$cwd/results"
scriptlist="./scriptlist"
cp /dev/null $scriptlist

export grammardir lexdir grandom glang gmutlang gboltz resultsdir

export accentdir="$wrkdir/accent"

[ ! -d $resultsdir ] && mkdir $resultsdir

# Run each tool now on three sets of grammars

echo -e "\\n===> ACLA \\n"
cd $cwd

for g in $gset
do  
    _start=$(date +%s) 
	for timelimit in $timelimits
	do
	    echo -e "\n===> [$g]:: time limit: $timelimit \n"
		echo "./run_ACLA.sh $g $timelimit || exit \$?" >> $scriptlist
	done
	_end=$(date +%s)
	elapsed=$(($_end - $_start))
	echo "ACLA:$g:elapsed=$elapsed"
done

echo -e "\n===> Amber \\n"
cd $cwd

for g in $gset
do
    _start=$(date +%s)
	for timelimit in $timelimits
	do
	    echo -e "\n===> [$g]:: time limit: $timelimit \n"
		echo "./run_Amber.sh $g $timelimit examples 10000000000 || exit \$?" >> $scriptlist
		echo "./run_Amber.sh $g $timelimit examples 100000000000000000000 || exit $?" >> $scriptlist
		echo "./run_Amber.sh $g $timelimit examples 1000000000000000000000000000000 || exit \$?" >> $scriptlist	
		echo "./run_Amber.sh $g $timelimit silent examples 10000000000 || exit $?" >> $scriptlist
		echo "./run_Amber.sh $g $timelimit silent examples 100000000000000000000 || exit $?" >> $scriptlist
		echo "./run_Amber.sh $g $timelimit silent examples 1000000000000000000000000000000 || exit $?" >> $scriptlist

		echo "./run_Amber.sh $g $timelimit ellipsis examples 10000000000 || exit \$?" >> $scriptlist
		echo "./run_Amber.sh $g $timelimit ellipsis examples 100000000000000000000 || exit $?" >> $scriptlist
		echo "./run_Amber.sh $g $timelimit ellipsis examples 1000000000000000000000000000000 || exit \$?" >> $scriptlist	
		echo "./run_Amber.sh $g $timelimit silent ellipsis examples 10000000000 || exit $?" >> $scriptlist
		echo "./run_Amber.sh $g $timelimit silent ellipsis examples 100000000000000000000 || exit $?" >> $scriptlist
		echo "./run_Amber.sh $g $timelimit silent ellipsis examples 1000000000000000000000000000000 || exit $?" >> $scriptlist

		echo "./run_Amber.sh $g $timelimit length 50 || exit $?" >> $scriptlist
		echo "./run_Amber.sh $g $timelimit length 100 || exit $?" >> $scriptlist
		echo "./run_Amber.sh $g $timelimit length 1000 || exit \$?" >> $scriptlist
		echo "./run_Amber.sh $g $timelimit silent length 50 || exit $?" >> $scriptlist
		echo "./run_Amber.sh $g $timelimit silent length 100 || exit $?" >> $scriptlist
		echo "./run_Amber.sh $g $timelimit silent length 1000 || exit $?" >> $scriptlist

		echo "./run_Amber.sh $g $timelimit ellipsis length 50 || exit $?" >> $scriptlist
		echo "./run_Amber.sh $g $timelimit ellipsis length 100 || exit $?" >> $scriptlist
		echo "./run_Amber.sh $g $timelimit ellipsis length 1000 || exit \$?" >> $scriptlist
		echo "./run_Amber.sh $g $timelimit silent ellipsis length 50 || exit $?" >> $scriptlist
		echo "./run_Amber.sh $g $timelimit silent ellipsis length 100 || exit $?" >> $scriptlist
		echo "./run_Amber.sh $g $timelimit silent ellipsis length 1000 || exit $?" >> $scriptlist
    done
	_end=$(date +%s)
	elapsed=$(($_end - $_start))
	echo "Amber:$g:elapsed=$elapsed"	
done

echo -e "\n===> AmbiDexter \\n"
cd $cwd

for g in $gset
do
    _start=$(date +%s)
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
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s -q -pg -k 50 || exit $?" >> $scriptlist
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s -q -pg -k 100 || exit $?" >> $scriptlist
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s -q -pg -k 1000 || exit \$?" >> $scriptlist
		
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s slr1 -q -pg -k 50 || exit $?" >> $scriptlist
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s slr1 -q -pg -k 100 || exit $?" >> $scriptlist
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s slr1 -q -pg -k 1000 || exit \$?" >> $scriptlist
		
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s lr0 -q -pg -k 50 || exit $?" >> $scriptlist
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s lr0 -q -pg -k 100 || exit $?" >> $scriptlist
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s lr0 -q -pg -k 1000 || exit $?" >> $scriptlist
		
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s lr1 -q -pg -k 50 || exit $?" >> $scriptlist
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s lr1 -q -pg -k 100 || exit $?" >> $scriptlist
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s lr1 -q -pg -k 1000 || exit $?" >> $scriptlist
		
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s lalr1 -q -pg -k 50 || exit $?" >> $scriptlist
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s lalr1 -q -pg -k 100 || exit $?" >> $scriptlist
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s lalr1 -q -pg -k 1000 || exit \$?" >> $scriptlist			
		
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s -q -pg -ik 0 || exit \$?" >> $scriptlist
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s slr1 -q -pg -ik 0 || exit \$?" >> $scriptlist
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s lr0 -q -pg -ik 0 || exit $?" >> $scriptlist
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s lr1 -q -pg -ik 0 || exit $?" >> $scriptlist
			echo "./run_AmbiDexter.sh $g $timelimit ${ftime}s lalr1 -q -pg -ik 0 || exit \$?" >> $scriptlist
	    done
	done
	_end=$(date +%s)
	elapsed=$(($_end - $_start))
	echo "AmbiDexter:$g:elapsed=$elapsed"	
done

echo -e "\n===> SinBAD \\n"
cd $cwd

for g in $gset
do
    _start=$(date +%s)
    for timelimit in $timelimits
    do
        echo -e "\n===> [$g]::[purerandom] time limit: $timelimit \n"
        echo "./run_SinBAD.sh $g purerandom $timelimit || exit \$?" >> $scriptlist
        
        for backend in dynamic1 dynamic2
        do
            for d in $Tdepths
            do
                echo -e "\n===> [$g]::[$backend]::[depth=$d] time limit: $timelimit \n"
                echo "./run_SinBAD.sh $g $backend $timelimit $d || exit \$?" >> $scriptlist
            done
        done
    done
	_end=$(date +%s)
	elapsed=$(($_end - $_start))
	echo "SinBAD:$g:elapsed=$elapsed"
done

echo "list of scripts: "
cat $scriptlist
echo "running them in parallel..."

expstart=$(date +%s)
cat scriptlist | parallel
expend=$(date +%s)
expelapsed=$(($expend - $expstart))

echo -e "\\n===> experiment complete in $expelapsed seconds \n"

cd $cwd
gtar czf results.tar.gz results
echo -e "\\n===> results - results.tar.gz \\n"

