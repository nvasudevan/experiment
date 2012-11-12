#!/bin/sh

torun="$1"
shift 
timelimit="${1}s"
shift
amberoptions="$*"
accent="$wrkdir/accent/accent/accent"
ambersrc="$wrkdir/accent/amber/amber.c"
lex="`which flex`"
cc="`which cc`"

run_random1000() {
	result="$resultsdir/amber/$torun/${timelimit}_`echo $amberoptions | sed -e 's/\s/_/g'`"	
	cp /dev/null $result
    cwd="`pwd`"
    for g in `seq 1 $Nrandom`
    do
        tmp="`mktemp -d`"
        cd $tmp
        $accent $grandom/$g/$g.acc || exit $?
        $lex $lexdir/general.lex || exit $?
        $cc -w -o amber -O3 yygrammar.c $ambersrc
        output="`timeout $timelimit ./amber $amberoptions 2> /dev/null | egrep 'tick|Grammar ambiguity detected' | paste - - `"
        sentence="`echo $output | grep -o 'Grammar ambiguity detected'`"
        ticks="`echo $output | grep -o "tick: [0-9]*" | sed -e 's/tick: //'`"
        [ "$sentence" != "" ] && (echo "$g,yes,${ticks}" | tee -a $result;cd $cwd;rm -Rf $tmp)  && continue
        echo "$g,,$ticks" | tee -a $result
        cd $cwd
        rm -Rf $tmp
    done
}

run_lang() {
	result="$resultsdir/amber/$torun/${timelimit}_`echo $amberoptions | sed -e 's/\s/_/g'`"
	cp /dev/null $result
    cwd="`pwd`"
    for g in $lgrammars
    do
        for i in `seq 1 $Nlang`
        do
            tmp="`mktemp -d`"
            cd $tmp
            $accent $glang/acc/$g.$i.acc || exit $?
            $lex $lexdir/$g.lex || exit $?
            $cc -w -o amber -O3 yygrammar.c $ambersrc
            output="`timeout $timelimit ./amber $amberoptions 2> /dev/null | egrep 'tick|Grammar ambiguity detected' | paste - - `"
            sentence="`echo $output | grep -o 'Grammar ambiguity detected'`"
            ticks="`echo $output | grep -o "tick: [0-9]*" | sed -e 's/tick: //'`"
            [ "$sentence" != "" ] && (echo "$g.$i,yes,$ticks" | tee -a $result;cd $cwd;rm -Rf $tmp)  && continue
            echo "$g.$i,,$ticks" | tee -a $result;cd $cwd;rm -Rf $tmp
        done
    done  
}

run_mutlang() {
    cwd="`pwd`"
    tmp="`mktemp -d`"
    for type in $mutypes
    do
       result="$resultsdir/amber/$torun/${type}_${timelimit}_`echo $amberoptions | sed -e 's/\s/_/g'`"
       cp /dev/null $result
	   echo "===> $type, result - $result"
       for g in $mugrammars
       do
          for n in `seq 1 $Nmutations`
          do
             tmp="`mktemp -d`"
             cd $tmp
             $accent $gmutlang/acc/${type}/$g.0_${n}.acc || exit $?
             $lex $lexdir/$g.lex || exit $?
             $cc -w -o amber -O3 yygrammar.c $ambersrc
             output="`timeout $timelimit ./amber $amberoptions 2> /dev/null | egrep 'tick|Grammar ambiguity detected' | paste - - `"
             sentence="`echo $output | grep -o 'Grammar ambiguity detected'`"
             ticks="`echo $output | grep -o "tick: [0-9]*" | sed -e 's/tick: //'`"
             [ "$sentence" != "" ] && (echo "$g.0_$n,yes,$ticks" | tee -a $result;cd $cwd;rm -Rf $tmp)  && continue
             echo "$g.0_$n,,$ticks" | tee -a $result;cd $cwd;rm -Rf $tmp
          done
       done
    done
}

run_test() {
	for g in $testgrammars
	do
		tmp="`mktemp -d`"
		cd $tmp
		$accent $grammardir/test/$g/$g.acc || exit $?
		$lex $lexdir/general.lex || exit $?
		$cc -w -o amber -O3 yygrammar.c $ambersrc
		output="`timeout $timelimit ./amber $amberoptions 2> /dev/null | egrep 'tick|Grammar ambiguity detected' | paste - - `"
		sentence="`echo $output | grep -o 'Grammar ambiguity detected'`"
		ticks="`echo $output | grep -o "tick: [0-9]*" | sed -e 's/tick: //'`"
		[ "$sentence" != "" ] && (echo "$g,yes,$ticks" | tee -a $result;cd $cwd;rm -Rf $tmp) && continue
		echo "$g,,$ticks" | tee -a $result
		cd $cwd
		rm -Rf $tmp  
    done  
}

main() {
    for i in $*
    do
    	[ ! -d $resultsdir/amber/$torun ] && mkdir -p $resultsdir/amber/$torun && echo "$resultsdir/amber/$torun created!"
    	echo "[$torun time=$timelimit, options=$amberoptions]"
        run_$i
    done  
}

main $torun

