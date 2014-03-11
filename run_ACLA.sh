#!/bin/bash

bdir=$(dirname $0)
echo $bdir
. $bdir/toolparams.sh

echo "$(hostname)::($basename $0) $cwd $wrkdir"

torun="$1"
timelimit="${2}s"
cmd="`which java` -Xmx$memlimit -jar $wrkdir/ACLA/grammar.modified.jar"

printrec() {
    result="$1"
    _out="$2"
    _g="$3"
    amb=$(echo $_out | grep -o 'ambiguous string' | uniq)
    if [ "$amb" == "ambiguous string" ]
    then 
        ambstr=$(echo $out | awk -F': ' '{print $2}')
        echo "$_g,yes,-,$ambstr,$(echo $ambstr | wc -c)" | tee -a $result
    else
        amb=$(echo $_out | grep -o 'unambiguous\!')
        if [ "$amb" == "unambiguous!" ]
        then
            echo "$_g,unambiguous,,," | tee -a $result
        else
            echo "$_g,,,," | tee -a $result
        fi    
    fi
}

run_randomcfg() {
    result="$resultsdir/acla/$torun/$timelimit"
    cp /dev/null $result
    for randomsize in $randomcfgsizes
    do
        for g in  $(seq 1 $nrandom)
        do
            # first convert accent format to cfg format
            gacc="$grandom/$randomsize/$g.acc"
            _gcfg="$grandom/$randomsize/$g.cfg"    
	        gcfg=$(mktemp ${_gcfg}.XXXXXX)
            cat $gacc | egrep -v "^%nodefault|^%token" | sed -e "s/'/\"/g" -e 's/;$//' > $gcfg
            tokenlist=$(grep '%token' $gacc | sed -e 's/%token //' | tr -d ';,')
            for token in $tokenlist
            do
                sed -i -e "s/\b$token\b/\"$token\"/g" -e "s/'/\"/g" $gcfg
            done
            out=$(timeout $timelimit $cmd -a $gcfg| egrep 'unambiguous\!|ambiguous string')
            rm $gcfg
            printrec "$result" "$out" "$randomsize - $g"
        done
    done
}

run_lang() {
    result="$resultsdir/acla/$torun/$timelimit"
    cp /dev/null $result
    for g in $lgrammars
    do
        for i in $(seq 1 $nlang)
        do
            # convert yacc grammars from AmbiDexter to ACLA format
            gacc="$glang/acc/$g.$i.acc"
            _gcfg="$grammardir/cfg/$g.$i.cfg"
            [ ! -d $grammardir/cfg ] && mkdir -p $grammardir/cfg    
	        gcfg=$(mktemp ${_gcfg}.XXXXXX)
            cat $gacc | egrep -v "^\s*;|^%nodefault|^%token " > $gcfg
            tokenlist=$(grep '%token' $gacc | sed -e 's/%token //' | tr -d ';,')
            for token in $tokenlist
            do
                sed -i -e "s/\b$token\b/\"$token\"/g" -e "s/'/\"/g" $gcfg
            done            
            out=$(timeout $timelimit $cmd -a $gcfg | egrep 'unambiguous\!|ambiguous string')
	        rm $gcfg
            printrec "$result" "$out" "$g.$i" 
        done
    done
}

run_mutlang() {
    for type in $mutypes
    do
        result="$resultsdir/acla/$torun/${type}_${timelimit}"
        cp /dev/null $result
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
                done
                out=$(timeout $timelimit $cmd -a $gcfg | egrep 'unambiguous\!|ambiguous string')
	            rm $gcfg
	            printrec "$result" "$out" "$g.0_$n"
            done
        done
    done    
}

run_boltzcfg() {
    result="$resultsdir/acla/$torun/$timelimit"
    cp /dev/null $result
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
            out=$(timeout $timelimit $cmd -a $gcfg | egrep 'unambiguous\!|ambiguous string')
	        rm $gcfg
            printrec "$result" "$out" "$boltzsize - $g"
        done
    done
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
        out=$(timeout $timelimit $cmd -a $gcfg | egrep 'unambiguous\!|ambiguous string')
        rm $gcfg
        printrec "$result" "$out" "$g"
    done
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

