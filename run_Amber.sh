#!/bin/bash

bdir=$(dirname $0)
echo $bdir
. $bdir/toolparams.sh

echo "$(hostname)::($basename $0) $cwd $wrkdir"

torun="$1"
shift 
timelimit="${1}s"
shift
amberoptions="$*"
accent="$wrkdir/accent/accent/accent"
ambersrc="$wrkdir/accent/amber/amber.c"
lex=$(which flex)
cc=$(which cc)

print_summary() {
    summary="Ambiguous count=$1[of $2]"
    echo -e "\nSummary: $summary \n--"
}

run_randomcfg() {
    result="$resultsdir/amber/$torun/${timelimit}_`echo $amberoptions | sed -e 's/\s/_/g'`"    
    cp /dev/null $result
    ambcnt=0
    cnt=0
    cwd=$(pwd)
    for randomsize in $randomcfgsizes
    do
        for g in $(seq 1 $nrandom)
        do
            tmp=$(mktemp -d)
            cd $tmp
            $accent $grandom/$randomsize/$g.acc || exit $?
            $lex $grandom/$randomsize/lex || exit $?
            $cc -w -o amber -O3 yygrammar.c $ambersrc
            output=$(timeout $timelimit ./amber $amberoptions 2> /dev/null | egrep 'tick|Grammar ambiguity detected' | paste - - )
            ((cnt+=1))
            sentence=$(echo $output | grep -o 'Grammar ambiguity detected')
            ticks=$(echo $output | grep -o "tick: [0-9]*" | sed -e 's/tick: //')
            if [ "$sentence" != "" ]
            then
                ((ambcnt+=1))
                echo "$randomsize - $g,yes,${ticks}" | tee -a $result
                cd $cwd
                rm -Rf $tmp
                continue
            fi
            echo "$randomsize - $g,,$ticks" | tee -a $result
            cd $cwd
            rm -Rf $tmp
        done
    done
    print_summary $ambcnt $cnt
}

run_lang() {
    result="$resultsdir/amber/$torun/${timelimit}_`echo $amberoptions | sed -e 's/\s/_/g'`"
    cp /dev/null $result
    ambcnt=0
    cnt=0
    cwd=$(pwd)
    for g in $lgrammars
    do
        for i in $(seq 1 $nlang)
        do
            tmp=$(mktemp -d)
            cd $tmp
            $accent $glang/acc/$g.$i.acc || exit $?
            $lex $lexdir/$g.lex || exit $?
            $cc -w -o amber -O3 yygrammar.c $ambersrc
            output=$(timeout $timelimit ./amber $amberoptions 2> /dev/null | egrep 'tick|Grammar ambiguity detected' | paste - - )
            ((cnt+=1))
            sentence=$(echo $output | grep -o 'Grammar ambiguity detected')
            ticks=$(echo $output | grep -o "tick: [0-9]*" | sed -e 's/tick: //')
            if [ "$sentence" != "" ]
            then
                ((ambcnt+=1))
                echo "$g.$i,yes,$ticks" | tee -a $result
                cd $cwd
                rm -Rf $tmp
                continue
            fi
            echo "$g.$i,,$ticks" | tee -a $result
            cd $cwd
            rm -Rf $tmp
        done
    done 
    print_summary $ambcnt $cnt 
}

run_mutlang() {
    cwd=$(pwd)
    for type in $mutypes
    do
       result="$resultsdir/amber/$torun/${type}_${timelimit}_`echo $amberoptions | sed -e 's/\s/_/g'`"
       cp /dev/null $result
       ambcnt=0
       cnt=0
       echo "===> $type, result - $result"
       for g in $mugrammars
       do
          for n in $(seq 1 $nmutations)
          do
             tmp=$(mktemp -d)
             cd $tmp
             $accent $gmutlang/acc/${type}/$g.0_${n}.acc || exit $?
             $lex $lexdir/$g.lex || exit $?
             $cc -w -o amber -O3 yygrammar.c $ambersrc
             output=$(timeout $timelimit ./amber $amberoptions 2> /dev/null | egrep 'tick|Grammar ambiguity detected' | paste - - )
             ((cnt+=1))
             sentence=$(echo $output | grep -o 'Grammar ambiguity detected')
             ticks=$(echo $output | grep -o "tick: [0-9]*" | sed -e 's/tick: //')
             if [ "$sentence" != "" ]
             then
                 ((ambcnt+=1))
                 echo "$g.0_$n,yes,$ticks" | tee -a $result
                 cd $cwd
                 rm -Rf $tmp
                 continue
             fi
             echo "$g.0_$n,,$ticks" | tee -a $result
             cd $cwd
             rm -Rf $tmp
          done
       done
       print_summary $ambcnt $cnt
    done
}

run_boltzcfg() {
    result="$resultsdir/amber/$torun/${timelimit}_`echo $amberoptions | sed -e 's/\s/_/g'`"    
    cp /dev/null $result
    ambcnt=0
    cnt=0
    cwd=$(pwd)
    for boltzsize in $boltzcfgsizes
    do
        for g in $(seq 1 $nboltz)
        do
            tmp=$(mktemp -d)
            cd $tmp
            $accent $gboltz/$boltzsize/$g.acc || exit $?
            $lex $gboltz/$boltzsize/lex || exit $?
            $cc -w -o amber -O3 yygrammar.c $ambersrc
            output=$(timeout $timelimit ./amber $amberoptions 2> /dev/null | egrep 'tick|Grammar ambiguity detected' | paste - - )
            ((cnt+=1))
            sentence=$(echo $output | grep -o 'Grammar ambiguity detected')
            ticks=$(echo $output | grep -o "tick: [0-9]*" | sed -e 's/tick: //')
            if [ "$sentence" != "" ]
            then
                ((ambcnt+=1))
                echo "$boltzsize - $g,yes,${ticks}" | tee -a $result
                cd $cwd
                rm -Rf $tmp
                continue
            fi
            echo "$boltzsize - $g,,$ticks" | tee -a $result
            cd $cwd
            rm -Rf $tmp
        done
    done
    print_summary $ambcnt $cnt
}

run_test() {
    result="$resultsdir/amber/$torun/${timelimit}_`echo $amberoptions | sed -e 's/\s/_/g'`"
    cp /dev/null $result
    ambcnt=0
    cnt=0
    for g in $testgrammars
    do
        tmp=$(mktemp -d)
        cd $tmp
        $accent $grammardir/test/$g/$g.acc || exit $?
        $lex $lexdir/general.lex || exit $?
        $cc -w -o amber -O3 yygrammar.c $ambersrc
        output=$(timeout $timelimit ./amber $amberoptions 2> /dev/null | egrep 'tick|Grammar ambiguity detected' | paste - - )
        ((cnt+=1))
        sentence=$(echo $output | grep -o 'Grammar ambiguity detected')
        ticks=$(echo $output | grep -o "tick: [0-9]*" | sed -e 's/tick: //')
        if [ "$sentence" != "" ]
        then
            ((ambcnt+=1))
            echo "$g,yes,$ticks" | tee -a $result
            cd $cwd
            rm -Rf $tmp
            continue
        fi
        echo "$g,,$ticks" | tee -a $result
        cd $cwd
        rm -Rf $tmp  
    done
    print_summary $ambcnt $cnt
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

