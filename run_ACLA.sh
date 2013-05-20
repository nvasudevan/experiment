#!/bin/bash

bdir=$(dirname $0)
echo $bdir
. $bdir/toolparams.sh

echo "$(hostname)::($basename $0) $cwd $wrkdir"

torun="$1"
timelimit="${2}s"
cmd="`which java` -Xmx$memlimit -jar $wrkdir/ACLA/grammar.modified.jar"

print_summary() {
    summary="Ambiguous count=$1[of $2]"
    echo -e "\nSummary: $summary \n--"
}

run_randomcfg() {
    result="$resultsdir/acla/$torun/$timelimit"
    cp /dev/null $result
    ambcnt=0
    cnt=0    
    for randomsize in $randomcfgsizes
    do
        for g in  $(seq 1 $nrandom)
        do
            # first convert accent format to cfg format
            gacc="$grandom/$randomsize/$g.acc"
            _gcfg="$grandom/$randomsize/$g.cfg"    
	    gcfg=$(mktemp ${_gcfg}.XXXXXX)
            cat $gacc | egrep -v "^%nodefault|^%token" | sed -e "s/'/\"/g" -e 's/;$//' > $gcfg
            sentence=$(timeout $timelimit $cmd -a $gcfg| egrep -o 'unambiguous\!|ambiguous string' | uniq)
	    rm $gcfg
            ((cnt+=1))
            if [ "$sentence" == "ambiguous string" ]
            then 
                ((ambcnt+=1))
                echo "$randomsize - $g,yes" | tee -a $result
                continue
            fi
            [ "$sentence" == "unambiguous!" ] && echo "$randomsize - $g,no" | tee -a $result  && continue
            echo "$randomsize - $g," | tee -a $result
        done
    done
    print_summary $ambcnt $cnt
}

run_lang() {
    result="$resultsdir/acla/$torun/$timelimit"
    cp /dev/null $result
    ambcnt=0
    cnt=0
    for g in $lgrammars
    do
        for i in $(seq 1 $nlang)
        do
            # convert yacc grammars from AmbiDexter to ACLA format
            gacc="$glang/acc/$g.$i.acc"
            _gcfg="$grammardir/cfg/$g.$i.cfg"
            [ ! -d $grammardir/cfg ] && mkdir -p $grammardir/cfg    
	    gcfg=$(mktemp ${_gcfg}.XXXXXX)
	    echo "$gcfg"
            cat $gacc | egrep -v "^\s*;|^%nodefault|^%token " > $gcfg
            tokenlist=$(grep '%token' $gacc | sed -e 's/%token //' | tr -d ';,')
            for token in $tokenlist
            do
                sed -i -e "s/\b$token\b/\"$token\"/g" -e "s/'/\"/g" $gcfg
#                if [ "${grammar}" == "Pascal" ]
#                then 
#                    sed -i -e 's/"UNSIGNED_INT"/"1"/g' ${CFG_GRAMMAR_FILE}
#                    sed -i -e 's/"UNSIGNED_REAL"/"1.0"/g' ${CFG_GRAMMAR_FILE}
#                    sed -i -e 's/"STRING"/"st"/g' ${CFG_GRAMMAR_FILE}
#                    sed -i -e 's/"IDENTIFIER"/"id"/g' ${CFG_GRAMMAR_FILE}
#                fi
            done            
            sentence=$(timeout $timelimit $cmd -a $gcfg | egrep -o 'unambiguous\!|ambiguous string' | uniq)
	    #rm $gcfg
            ((cnt+=1))
            if [ "$sentence" == "ambiguous string" ]
            then 
                ((ambcnt+=1))
                echo "$g.$i,yes" | tee -a $result
                continue
            fi
            [ "$sentence" == "unambiguous!" ] && echo "$g.$i,no" | tee -a $result  && continue
            echo "$g.$i," | tee -a $result
        done
    done
    print_summary $ambcnt $cnt
}

run_mutlang() {
    for type in $mutypes
    do
           result="$resultsdir/acla/$torun/${type}_${timelimit}"
          cp /dev/null $result
          ambcnt=0
          cnt=0
          echo "===> $type, result - $result"
           for g in $mugrammars
           do
          for n in $(seq 1 $nmutations)
          do
             # convert grammar to cfg format
             gacc="$gmutlang/acc/$type/$g.0_$n.acc"
             _gcfg="$gmutlang/cfg/$type/$g.0_$n.cfg"
             [ ! -d $gmutlang/cfg/$type ] && mkdir -p $gmutlang/cfg/$type
	     gcfg=$(mktemp ${_gcfg}.XXXXXX)
             cat $gacc | egrep -v "^\s*;|^%nodefault|^%token " > $gcfg
             tokenlist=$(grep '%token' $gacc | sed -e 's/%token //' | tr -d ';,')
             for token in $tokenlist
             do
                sed -i -e "s/\b${token}\b/\"${token}\"/g" -e "s/'/\"/g" $gcfg
#                if [ "${grammar}" == "Pascal" ]
#                then 
#                    sed -i -e 's/"UNSIGNED_INT"/"1"/g' ${CFG_GRAMMAR_FILE}
#                    sed -i -e 's/"UNSIGNED_REAL"/"1.0"/g' ${CFG_GRAMMAR_FILE}
#                    sed -i -e 's/"STRING"/"st"/g' ${CFG_GRAMMAR_FILE}
#                    sed -i -e 's/"IDENTIFIER"/"id"/g' ${CFG_GRAMMAR_FILE}
#                fi                
             done
             sentence=$(timeout $timelimit $cmd -a $gcfg | egrep -o 'unambiguous\!|ambiguous string' | uniq)
	     rm $gcfg
             ((cnt+=1))
             if [ "$sentence" == "ambiguous string" ]
             then
                 ((ambcnt+=1))
                 echo "$g.0_$n,yes" | tee -a $result
                 continue
             fi
             [ "$sentence" == "unambiguous!" ] && echo "$g.0_$n,no" | tee -a $result  && continue
             echo "$g.0_$n," | tee -a $result            
          done
           done
           print_summary $ambcnt $cnt
    done    
}

run_boltzcfg() {
    result="$resultsdir/acla/$torun/$timelimit"
    cp /dev/null $result
    ambcnt=0
    cnt=0
    for boltzsize in $boltzcfgsizes
    do    
        for g in  $(seq 1 $nboltz)
        do
            # first convert accent format to cfg format
            gacc="$gboltz/$boltzsize/$g.acc"
            _gcfg="$gboltz/$boltzsize/$g.cfg"    
	    gcfg=$(mktemp ${_gcfg}.XXXXXX)
            cat $gacc | egrep -v "^\s*;|^%nodefault|^%token " | sed -e 's/;$//g' > $gcfg
            tokenlist=$(grep '%token' $gacc | sed -e 's/%token //' | tr -d ';,')
            for token in $tokenlist
            do
               sed -i -e "s/\b${token}\b/\"${token}\"/g" -e "s/'/\"/g" $gcfg
            done        
            sentence=$(timeout $timelimit $cmd -a $gcfg| egrep -o 'unambiguous\!|ambiguous string' | uniq)
	    rm $gcfg
            ((cnt+=1))
            if [ "$sentence" == "ambiguous string" ]
            then 
                ((ambcnt+=1))
                echo "$boltzsize - $g,yes" | tee -a $result
                continue
            fi
            [ "$sentence" == "unambiguous!" ] && echo "$boltzsize - $g,no" | tee -a $result  && continue
            echo "$boltzsize - $g," | tee -a $result
        done
    done
    print_summary $ambcnt $cnt
}

run_test() {
    result="$resultsdir/acla/$torun/$timelimit"
    cp /dev/null $result
    ambcnt=0
    cnt=0
    for g in $testgrammars
    do
        gacc="$grammardir/test/$g/$g.acc"
        gcfg="$grammardir/test/$g/$g.cfg"    
        cat $gacc | egrep -v "^%nodefault|^;" | sed -e "s/'/\"/g" > $gcfg
        sentence=$(timeout $timelimit $cmd -a $gcfg | egrep -o 'unambiguous\!|ambiguous string' | uniq)
        ((cnt+=1))
        if [ "$sentence" == "ambiguous string" ]
        then
            ((ambcnt+=1))
            echo "$g,yes" | tee -a $result
            continue
        fi
        [ "$sentence" == "unambiguous!" ] && echo "$g,no" | tee -a $result  && continue
        echo "$g," | tee -a $result
    done
    print_summary $ambcnt $cnt
}

main() {
    for i in $*
    do
        [ ! -d $resultsdir/acla/$torun ] && mkdir -p $resultsdir/acla/$torun && echo "$resultsdir/acla/$torun created!"
        echo "[$torun time=$timelimit, memory max=$memlimit]"
        run_$i
    done  
}

main $torun

