#!/bin/sh

# A simple script that uses bison to determine if a grammar contains 
# useless non-terminals and/or conflicts
# grammar is unambiguous if there are no conflicts without containing
# useless non-terminals

convert_to_yacc(){
    gacc="$1"
    gy="$2"
    cat $gacc | grep  "%token" | sed -e 's/,//g' -e 's/;$//' > $gy
    echo "" >> $gy
    # don't think start root need to be specified for boltz grammars
    #cat $gacc | grep -v '%token' | sed -e 's/%nodefault/%start root\n\n%%/' >> $gy
    cat $gacc | grep -v '%token' | sed -e 's/%nodefault/\n%%/' >> $gy
}

useless_nonterminals() {
     tf=$(mktemp)
     gacc="$1"
     convert_to_yacc "$gacc" "$tf"
     bison -o ${tf}.output $tf > $tmpout 2>&1
     uselessnt=$(cat $tmpout | grep -o "warning: [0-9]* nonterminals* useless in grammar" | sed -e 's/warning: //')
     #echo "useless non-terminals: $uselessnt"
     rm $tf ${tf}.output
     if [ ! -z "$uselessnt" ] 
     then
        echo "unreachable: yes"
     else
        echo ""
     fi
}

unambiguous() {
     tf=$(mktemp)
     gacc="$1"
     convert_to_yacc "$gacc" "$tf"
     bison -o ${tf}.output $tf > $tmpout 2>&1
     conflicts=$(cat $tmpout | grep -o "conflicts.*/reduce")
     uselessnt=$(cat $tmpout | grep -o "warning: [0-9]* nonterminals* useless in grammar" | sed -e 's/warning: //')
     #echo "conflicts: $conflicts, useless non-terminals: $uselessnt"
     rm $tf ${tf}.output
     if [ -z "$uselessnt" ] && [ -z "$conflicts" ] 
     then
        echo "unambiguous: yes"
     else
        echo ""
     fi
}

gdir="$1"
if [ -z "$gdir" ]
then
    echo "usage: $0 <grammar directory containg grammars in ACCENT format>"
    exit 1
fi

tmpout=$(mktemp)

for g in $(find $gdir -name "*.acc" -print)
do
    out=$(unambiguous $g)
    echo "$g,$out"
done

rm $tmpout
