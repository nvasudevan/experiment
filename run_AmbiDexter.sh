#!/bin/bash

bdir=$(dirname $0)
echo $bdir
. $bdir/toolparams.sh

echo "$(hostname)::($basename $0) $cwd $wrkdir"

torun="$1"
shift
timelimit="${1}s"
shift
filter=""
if [ "$1" == "slr1" ] || [ "$1" == "lr0" ] || [ "$1" == "lr1" ] || [ "$1" == "lalr1" ]
then 
 filter="$1"
 shift
 ambidexteroptions="$*"
else
 ambidexteroptions="$*"
fi

cmd="`which java` -Xss8m -Xmx$memlimit -jar $wrkdir/ambidexter/build/AmbiDexter.jar"
export cmd 

print_summary() {
    summary="Ambiguous count=$1[of $2]"
    if [ "$filter" != "" ]
    then
        avgratio=0
        [ "$3" != 0 ] && avgratio=$(echo "scale=3; $4/$3" | bc)
        summary="$summary, how many generated=$3[of $2], avg harmless=$avgratio"
    fi
    echo -e "\nSummary: $summary \n--"
}

run_random1000() {
    result="$resultsdir/ambidexter/$torun/${timelimit}_${filter}f_${memlimit}_`echo $ambidexteroptions | sed -e 's/\s/_/g'`"
    cp /dev/null $result
    cnt=0
    fcnt=0
    ratiocnt=0.0
    ambcnt=0
    avgratio=0    
    for g in `seq 1 $nrandom`
    do
        # first convert accent format to yacc format
        gacc="$grandom/$g.acc"
        gy="$grandom/$g.y"
        cat $gacc | sed -e 's/%nodefault/%start root\n\n%%/' > $gy
        tmp="`mktemp`"
        $cmd -s $gy > $tmp 2>&1
        message="`cat $tmp | egrep -i 'Grammar contains injection cycle' | cut -d: -f2,3`"
        if [ "$message" != "" ]
        then
            if [ "$filter" == "" ]
            then
                echo "$g,yes" | tee -a $result
            else
                echo "$g,,,yes" | tee -a $result
            fi
            ((ambcnt+=1))
            continue
        fi
            
        message="`cat $tmp | egrep -i 'Unproductive start symbol' | cut -d: -f2,3`"
        if [ "$message" != "" ]
        then 
            if [ "$filter" == "" ]
            then 
                echo "$g," | tee -a $result  && continue
            else
                echo "$g,,," | tee -a $result && continue
            fi
        fi
        rm $tmp
        output=$($bdir/AmbiDexter.sh $timelimit $gy $filter $ambidexteroptions | tr '\n' ',') || exit $?
        if [ "$filter" != "" ]
        then
            harmless=$(echo $output | cut -d, -f1)
            if [ "$harmless" != "" ]
            then
                ratio=$(echo "scale=3;$harmless" | bc)
                ratiocnt=$(echo "$ratiocnt + $ratio" | bc)
                ((fcnt+=1))
            fi
        fi        
        ((cnt+=1))
        amb=$(echo $output | awk -F, '{print $NF}')
        [ "$amb" == "yes" ] && ((ambcnt+=1))
        echo "$g,$output" | tee -a $result        
    done
    print_summary $ambcnt $cnt $fcnt $ratiocnt
}

run_lang() {
    result="$resultsdir/ambidexter/$torun/${timelimit}_${filter}f_${memlimit}_`echo $ambidexteroptions | sed -e 's/\s/_/g'`"
    cp /dev/null $result
    cnt=0
    fcnt=0
    ratiocnt=0.0
    ambcnt=0
    avgratio=0        
    for g in $lgrammars
    do
        for i in `seq 1 $nlang`
        do
            gacc="$glang/acc/$g.$i.acc"
            gy="$glang/y/$g.$i.y"
            tmp="`mktemp`"
            $cmd -s $gy > $tmp 2>&1
            message=$(cat $tmp | egrep -i 'Grammar contains injection cycle' | cut -d: -f2,3)
            if [ "$message" != "" ]
            then
                if [ "$filter" == "" ]
                then
                    echo "$g.$i,yes" | tee -a $result
                else
                    echo "$g.$i,,,yes" | tee -a $result
                fi
                ((ambcnt+=1))
                continue
            fi
            
            message=$(cat $tmp | egrep -i 'Unproductive start symbol' | cut -d: -f2,3)
            if [ "$message" != "" ]
            then 
                if [ "$filter" == "" ]
                then 
                    echo "$g.$i," | tee -a $result  && continue
                else
                    echo "$g.$i,,," | tee -a $result && continue
                fi
            fi
            
            rm $tmp
            output=$($bdir/AmbiDexter.sh $timelimit $gy $filter $ambidexteroptions | tr '\n' ',') || exit $?
            if [ "$filter" != "" ]
            then
                harmless=$(echo $output | cut -d, -f1)
                if [ "$harmless" != "" ]
                then
                    ratio=$(echo "scale=3;$harmless" | bc)
                    ratiocnt=$(echo "$ratiocnt + $ratio" | bc)
                    ((fcnt+=1))
                fi
            fi        
            ((cnt+=1))
            amb=$(echo $output | awk -F, '{print $NF}')
            [ "$amb" == "yes" ] && ((ambcnt+=1))
            echo "$g.$i,$output" | tee -a $result           
        done
    done
    print_summary $ambcnt $cnt $fcnt $ratiocnt
}


run_mutlang() {
    for type in $mutypes
    do
        result="$resultsdir/ambidexter/$torun/${type}_${timelimit}_${filter}f_${memlimit}_`echo $ambidexteroptions | sed -e 's/\s/_/g'`"
        cp /dev/null $result
        cnt=0
        fcnt=0
        ratiocnt=0.0
        ambcnt=0
        avgratio=0    
        echo "===> $type, result - $result"
        for g in $lgrammars
        do
          for n in `seq 1 $nmutations`
          do
            # convert grammar to yacc format
            gacc="$gmutlang/acc/$type/$g.0_$n.acc"
            gy="$gmutlang/y/$type/$g.0_$n.y"
            [ ! -d "$gmutlang/y/$type" ] && mkdir -p $gmutlang/y/$type
            # add %token lines from grammar.0.y to the yacc one
            grep "^%token" $glang/y/$g.0.y > $gy
            printf "\n%%%%\n" >> $gy
            egrep -v "^%token|^%nodefault" $gacc >> $gy
            tmp="`mktemp`"
            $cmd -s $gy > $tmp 2>&1
            message="`cat $tmp | egrep -i 'Grammar contains injection cycle' | cut -d: -f2,3`"
            if [ "$message" != "" ]
            then
                if [ "$filter" == "" ]
                then
                    echo "$g.0_$n,yes" | tee -a $result
                else
                    echo "$g.0_$n,,,yes" | tee -a $result
                fi
                ((ambcnt+=1))
                continue                
            fi
            
            message="`cat $tmp | egrep -i 'Unproductive start symbol' | cut -d: -f2,3`"
            if [ "$message" != "" ]
            then 
                if [ "$filter" == "" ]
                then 
                    echo "$g.0_$n," | tee -a $result  && continue
                else
                    echo "$g.0_$n,,," | tee -a $result && continue
                fi
            fi
            
            rm $tmp
            output=$($bdir/AmbiDexter.sh $timelimit $gy $filter $ambidexteroptions | tr '\n' ',') || exit $?
            if [ "$filter" != "" ]
            then
                harmless=$(echo $output | cut -d, -f1)
                if [ "$harmless" != "" ]
                then
                    ratio=$(echo "scale=3;$harmless" | bc)
                    ratiocnt=$(echo "$ratiocnt + $ratio" | bc)
                    ((fcnt+=1))
                fi
            fi        
            ((cnt+=1))
            amb=$(echo $output | awk -F, '{print $NF}')
            [ "$amb" == "yes" ] && ((ambcnt+=1))
            echo "$g.0_$n,$output" | tee -a $result
          done
       done
       print_summary $ambcnt $cnt $fcnt $ratiocnt
    done
}

run_boltzcfg() {
    result="$resultsdir/ambidexter/$torun/${timelimit}_${filter}f_${memlimit}_`echo $ambidexteroptions | sed -e 's/\s/_/g'`"
    cp /dev/null $result
    cnt=0
    fcnt=0
    ratiocnt=0.0
    ambcnt=0
    avgratio=0    
    for g in `seq 1 $nboltz`
    do
        # first convert accent format to yacc format
        gacc="$gboltz/$g.acc"
        gy="$gboltz/$g.y"
        cat $gacc | sed -e 's/%nodefault/%start root\n\n%%/' > $gy
        tmp="`mktemp`"
        $cmd -s $gy > $tmp 2>&1
        message="`cat $tmp | egrep -i 'Grammar contains injection cycle' | cut -d: -f2,3`"
        if [ "$message" != "" ]
        then
            if [ "$filter" == "" ]
            then
                echo "$g,yes" | tee -a $result
            else
                echo "$g,,,yes" | tee -a $result
            fi
            ((ambcnt+=1))
            continue
        fi
            
        message="`cat $tmp | egrep -i 'Unproductive start symbol' | cut -d: -f2,3`"
        if [ "$message" != "" ]
        then 
            if [ "$filter" == "" ]
            then 
                echo "$g," | tee -a $result  && continue
            else
                echo "$g,,," | tee -a $result && continue
            fi
        fi
        rm $tmp
        output=$($bdir/AmbiDexter.sh $timelimit $gy $filter $ambidexteroptions | tr '\n' ',') || exit $?
        if [ "$filter" != "" ]
        then
            harmless=$(echo $output | cut -d, -f1)
            if [ "$harmless" != "" ]
            then
                ratio=$(echo "scale=3;$harmless" | bc)
                ratiocnt=$(echo "$ratiocnt + $ratio" | bc)
                ((fcnt+=1))
            fi
        fi        
        ((cnt+=1))
        amb=$(echo $output | awk -F, '{print $NF}')
        [ "$amb" == "yes" ] && ((ambcnt+=1))
        echo "$g,$output" | tee -a $result        
    done
    print_summary $ambcnt $cnt $fcnt $ratiocnt
}


run_test() {
    result="$resultsdir/ambidexter/$torun/${timelimit}_${filter}f_${memlimit}_`echo $ambidexteroptions | sed -e 's/\s/_/g'`"
    cp /dev/null $result
    cnt=0
    fcnt=0
    ratiocnt=0.0
    ambcnt=0
    avgratio=0
    for g in $testgrammars
    do
        gacc="$grammardir/test/$g/$g.acc"
        gy="$grammardir/test/$g/$g.y"
        cat $gacc | sed -e 's/%nodefault/%start root\n\n%%/' > $gy
        output=$($bdir/AmbiDexter.sh $timelimit $gy $filter $ambidexteroptions | tr '\n' ',') || exit $?
        if [ "$filter" != "" ]
        then
            harmless=$(echo $output | cut -d, -f1)
            if [ "$harmless" != "" ]
            then
                ratio=$(echo "scale=3;$harmless" | bc)
                ratiocnt=$(echo "$ratiocnt + $ratio" | bc)
                ((fcnt+=1))
            fi
        fi
        ((cnt+=1))
        amb=$(echo $output | awk -F, '{print $NF}')
        [ "$amb" == "yes" ] && ((ambcnt+=1))
        echo "$g,$output" | tee -a $result
    done
    print_summary $ambcnt $cnt $fcnt $ratiocnt
}

main() {
    for i in $*
    do
        [ ! -d $resultsdir/ambidexter/$torun ] && mkdir -p $resultsdir/ambidexter/$torun && echo "$resultsdir/ambidexter/$torun created!"
        echo "[$torun filter=$filter, time=$timelimit, memory max=$memlimit, options=$ambidexteroptions]"
        run_$i || exit $?
    done  
}

main $torun

