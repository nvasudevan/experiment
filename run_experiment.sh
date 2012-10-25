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
./build.sh ${wrkdir}

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
RANDOM1000="${GRAMMAR_DIR}/random1000"
LANG="${GRAMMAR_DIR}/lang"
MUTLANG="${GRAMMAR_DIR}/mutlang"
NO_MUTATIONS="250"
MEMLIMIT="256m"
TIMELIMITS="10 30 60 90 180 300"
RESULTS_DIR="$CWD/results"

export GRAMMAR_DIR RANDOM1000 LANG MUTLANG NO_MUTATIONS MEMLIMIT TIMELIMITS RESULTS_DIR

# Run each tool now 
# -- for time limits: 10, 30, 60, 90, 180 and 300 seconds
# -- on Random , PL and mutated PL grammars

echo -e "\\n===> Doing a test run of each tool \\n"

echo -e "\\n===> ACLA \\n"
cd $CWD

./run_ACLA.sh test 5 ${MEMLIMIT} || exit $?
#./run_ACLA.sh random1000 5 ${MEMLIMIT} || exit $?
#./run_ACLA.sh lang 5 ${MEMLIMIT} || exit $?

echo -e "\n===> Amber \\n"
cd $CWD

./run_Amber.sh test 5 examples 10000 || exit $?


echo -e "\n===> AmbiDexter \\n"
cd $CWD

./run_AmbiDexter.sh test 5 ${MEMLIMIT}  || exit $?
./run_AmbiDexter.sh test 5 ${MEMLIMIT} slr1 || exit $?

echo -e "\n===> SinBAD \\n"
cd $CWD

./run_SinBAD.sh test dynamic1 10 10 || exit $?

#echo -e "\n===> ACLA \\n"

#for grammarset in random1000 lang mutlang
#do 
#    for timelimit in ${TIMELIMITS}
#    do
#    ./run_ACLA.sh ${grammarset} ${timelimit} ${MEMLIMIT}
#    done 
#done


cd $CWD
gtar czf results.tar.gz results
echo -e "\\n===> results - results.tar.gz \\n"
   
