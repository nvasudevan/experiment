#!/bin/sh

torun="$1"
shift
fitness="$1"
shift
timelimit="${1}s"
shift
depthoptions=""
[ "$1" != "" ] && depthoptions="-d $*"

sinbaddir="$wrkdir/sinbad/src"

run_random1000() {
	result="$resultsdir/sinbad/$torun/${fitness}_${timelimit}"
	[ "$depthoptions" != "" ] && result="${result}_`echo $depthoptions | sed -e 's/\s/_/g'`"
	cp /dev/null $result
    tmp="`mktemp -d`"
    for g in `seq 1 $Nrandom`
    do
        timeout $timelimit ${PYTHON} $sinbaddir/sinbad -b $fitness $depthoptions $grandom/$g/$g.acc $lexdir/general.lex > $tmp/$g.log 2>&1
        amb="`grep -o 'Grammar ambiguity detected' $tmp/$g.log`"
        [ "$amb" != "" ] && echo "$g,yes" | tee -a $result && continue
        echo "$g," | tee -a $result
    done
    rm -Rf $tmp
}

run_lang() {
	result="$resultsdir/sinbad/$torun/${fitness}_${timelimit}"
	[ "$depthoptions" != "" ] && result="${result}_`echo $depthoptions | sed -e 's/\s/_/g'`"
	cp /dev/null $result
    tmp="`mktemp -d`"
    for g in $lgrammars
    do
        for i in `seq 1 $Nlang`
        do
            timeout $timelimit ${PYTHON} $sinbaddir/sinbad -b $fitness $depthoptions $glang/acc/$g.$i.acc $lexdir/$g.lex > $tmp/${g}_${i}.log 2>&1
            amb="`grep -o 'Grammar ambiguity detected' $tmp/${g}_${i}.log`"
            [ "$amb" != "" ] && echo "$g.$i,yes" | tee -a $result && continue
            echo "$g.$i," | tee -a $result
        done
    done
    rm -Rf $tmp
}

run_mutlang(){
    tmp="`mktemp -d`"
    for type in $mutypes
    do
       result="$resultsdir/sinbad/$torun/${type}_${fitness}_${timelimit}"
       [ "$depthoptions" != "" ] && result="${result}_`echo $depthoptions | sed -e 's/\s/_/g'`"
       cp /dev/null $result
       echo "===> $type, result - $result"
       for g in $mugrammars
       do
         for n in `seq 1 $Nmutations`
         do
            timeout $timelimit ${PYTHON} $sinbaddir/sinbad -b $fitness $depthoptions $gmutlang/acc/$type/${g}.0_${n}.acc $lexdir/$g.lex > $tmp/${g}_${n}.log 2>&1
            amb="`grep -o 'Grammar ambiguity detected' $tmp/${g}_${n}.log`"
            [ "$amb" != "" ] && echo "${g}.0_${n},yes" | tee -a $result && continue
            echo "${g}.0_${n}," | tee -a $result
         done
       done
    done
    rm -Rf $tmp
}

run_test() {
	result="$resultsdir/sinbad/$torun/${fitness}_${timelimit}"
	[ "$depthoptions" != "" ] && result="${result}_`echo $depthoptions | sed -e 's/\s/_/g'`"
	cp /dev/null $result
	for g in $testgrammars
	do
		gacc="$grammardir/test/$g/$g.acc"
		tmp="`mktemp -d`"
		${PYTHON} $sinbaddir/sinbad -b $fitness $depthoptions $gacc $lexdir/general.lex > $tmp/$g.log 2>&1
		amb="`grep -o 'Grammar ambiguity detected' $tmp/$g.log`"
		[ "$amb" != "" ] && echo "$g,yes" | tee -a $result
		rm -Rf $tmp
    done
}

main() {
    for i in $*
    do
    	[ ! -d $resultsdir/sinbad/$torun ] && mkdir -p $resultsdir/sinbad/$torun && echo "$resultsdir/sinbad/$torun created!"
    	echo "[$torun fitness=$fitness, time=$timelimit, depth options=$depthoptions]"
        run_$i
    done  
}

main $torun

