#!/bin/sh

CWD="`pwd`"

if [ $# -eq 0 ]; then
    wrkdir=`pwd`
elif [ $# -eq 1 ]; then
    wrkdir=$1
    mkdir -p $wrkdir
else
    echo "$0 [<full path to working directory>]"
    exit 1
fi
echo -e "===> Working in $wrkdir"
export CWD wrkdir

# now run build.sh to build your tools
./build.sh $wrkdir

# Download AmbiDexter grammars

echo -e "\\n===> Fetching AmbiDexter grammars\\n"

cd $CWD/grammars
wget -O grammars.zip https://sites.google.com/site/basbasten/files/grammars.zip
unzip -q grammars.zip
mv grammars lang

cd $CWD

# run each tool
[ ! -d $CWD/results ] && mkdir $CWD/results

GRAMMAR_DIR="$CWD/grammars"
LEX_DIR="${GRAMMAR_DIR}/lex"
RANDOM1000="${GRAMMAR_DIR}/random1000"
LANG="${GRAMMAR_DIR}/lang"
MUTLANG="${GRAMMAR_DIR}/mutlang"
NO_MUTATIONS="5"
MUTYPES="type1 type2 type3 type4"
MEMLIMIT="256m"
TIMELIMITS="10 30 60 90 180 300"
RESULTS_DIR="$CWD/results"

export GRAMMAR_DIR LEX_DIR RANDOM1000 LANG MUTLANG NO_MUTATIONS MUTYPES MEMLIMIT TIMELIMITS RESULTS_DIR
export PYTHON
export ACCENT_DIR="$wrkdir/accent"

# Run each tool now 
# -- for time limits: 10, 30, 60, 90, 180 and 300 seconds
# -- on Random , PL and mutated PL grammars

echo -e "\\n===> Doing a test run of each tool \\n"

echo -e "\\n===> ACLA \\n"
cd $CWD

./run_ACLA.sh test 5 $MEMLIMIT || exit $?
./run_ACLA.sh random1000 5 $MEMLIMIT || exit $?
./run_ACLA.sh lang 5 $MEMLIMIT || exit $?
./run_ACLA.sh mutlang 5 $MEMLIMIT || exit $?

echo -e "\n===> Amber \\n"
cd $CWD

for g in test random1000 lang mutlang
do
	./run_Amber.sh $g 60 examples 10000 || exit $?
	./run_Amber.sh $g 60 examples 1000000000000 || exit $?
	./run_Amber.sh $g 60 silent examples 10000 || exit $?
	./run_Amber.sh $g 60 silent examples 1000000000000 || exit $?

	./run_Amber.sh $g 60 ellipsis examples 10000 || exit $?
	./run_Amber.sh $g 60 ellipsis examples 1000000000000 || exit $?
	./run_Amber.sh $g 60 silent ellipsis examples 10000 || exit $?
	./run_Amber.sh $g 60 silent ellipsis examples 1000000000000 || exit $?

	./run_Amber.sh $g 60 length 100 || exit $?
	./run_Amber.sh $g 60 length 1000 || exit $?
	./run_Amber.sh $g 60 silent length 100 || exit $?
	./run_Amber.sh $g 60 silent length 1000 || exit $?

	./run_Amber.sh $g 60 ellipsis length 100 || exit $?
	./run_Amber.sh $g 60 ellipsis length 1000 || exit $?
	./run_Amber.sh $g 60 silent ellipsis length 100 || exit $?
	./run_Amber.sh $g 60 silent ellipsis length 1000 || exit $?
done

echo -e "\n===> AmbiDexter \\n"
cd $CWD

for g in test random1000 lang mutlang
do
	./run_AmbiDexter.sh $g 5 $MEMLIMIT -q -pg -k 100 || exit $?
	./run_AmbiDexter.sh $g 5 $MEMLIMIT -q -pg -k 1000 || exit $?
	./run_AmbiDexter.sh $g 5 $MEMLIMIT slr1 -q -pg -k 100 || exit $?
	./run_AmbiDexter.sh $g 5 $MEMLIMIT slr1 -q -pg -k 1000 || exit $?
	./run_AmbiDexter.sh $g 5 $MEMLIMIT -q -pg -ik 0 || exit $?
	./run_AmbiDexter.sh $g 5 $MEMLIMIT slr1 -q -pg -ik 0 || exit $?
done

cd $CWD

for backend in purerandom dynamic1
do
	echo -e "\n===> SinBAD ($g - $backend) \\n"
	for g in test random1000 lang mutlang
	do
		./run_SinBAD.sh $g $backend 10 || exit $?
		./run_SinBAD.sh $g $backend 10 || exit $?
		./run_SinBAD.sh $g $backend 10 || exit $?
		./run_SinBAD.sh $g $backend 10 || exit $?
	done
done


cd $CWD
gtar czf results.tar.gz results
echo -e "\\n===> results - results.tar.gz \\n"
   
