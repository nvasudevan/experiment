#!/bin/sh

# Use bison to test unreachable rules and unambiguity

runtest=""
gdir=""

set -- $(getopt t:d: "$@")

while [ $# -gt 0 ]
do
    case "$1" in 
     -t) runtest=$2 ; shift;;
     -d) gdir=$2 ; shift;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
     (*) break;;  
    esac
    shift
done

usage(){
    echo "$0 -t <useless|lr> -d <grammar directory>"
    exit 1
}

[ -z "$runtest" ] && usage
[ -z "$gdir" ] && usage

convert_to_yacc(){
    gacc="$1"
    gy="$2"
    cat $gacc | grep  "%token" | sed -e 's/,//g' -e 's/;$//' > $gy
    echo "" >> $gy
    cat $gacc | grep -v '%token' | sed -e 's/%nodefault/\n%%/' >> $gy
}

useless_nonterminals() {
     tf=$(mktemp)
     gacc="$1"
     convert_to_yacc "$gacc" "$tf"
     bison -o ${tf}.output $tf > $tmpout 2>&1
     uselessnt=$(cat $tmpout | grep -o "warning: [0-9]* nonterminals* useless in grammar" | sed -e 's/warning: //')
     rm $tf ${tf}.output
     if [ ! -z "$uselessnt" ] 
     then
        echo "unreachable ($uselessnt)"
     else
        echo ""
     fi
}

unambiguous() {
     tf=$(mktemp)
     gacc="$1"
     convert_to_yacc "$gacc" "$tf"
     bison -o ${tf}.output $tf > $tmpout 2>&1
     # different versions of bison output slightly differently
     conflicts=$(cat $tmpout | egrep -o "conflicts.*/reduce|.*/reduce.*conflicts")
     uselessnt=$(cat $tmpout | grep -o "warning: [0-9]* nonterminals* useless in grammar" | sed -e 's/warning: //')
     rm $tf ${tf}.output
     if [ -z "$uselessnt" ] && [ -z "$conflicts" ] 
     then
        echo "unambiguous"
     else
        echo ""
     fi
}

tmpout=$(mktemp)

if [ "$runtest" == "useless" ]; then
    for g in $(find $gdir -name "*.acc" -print)
    do
        out=$(useless_nonterminals $g)
        echo "$g,$out"
    done
elif [ "$runtest" == "lr" ]; then
    for g in $(find $gdir -name "*.acc" -print)
    do
        out=$(unambiguous $g)
        echo "$g,$out"
    done
fi

rm $tmpout
