#!/bin/sh

accent_to_yacc(){
    gacc="$1"
    gy="$2"
    cat $gacc | grep  "%token" | sed -e 's/,//g' -e 's/;$//' > $gy
    echo "" >> $gy
    # don't think start root need to be specified for boltz grammars
    #cat $gacc | grep -v '%token' | sed -e 's/%nodefault/%start root\n\n%%/' >> $gy
    cat $gacc | grep -v '%token' | sed -e 's/%nodefault/\n%%/' >> $gy
}

yacc_to_accent(){
    gy="$1"
    gacc="$2"
    tklist=""
    for tk in $(grep '%token' $gy | sed -e 's/%token//')
    do
      tklist="$tklist, $tk"
    done
    tkstr=$(echo $tklist | sed -e 's/^,/%token/' -e 's/$/;/')
    echo "$tkstr" > $gacc
    cat $gy | grep -v '%token' | sed -e 's/%%/%nodefault/' >> $gacc
}

switch="$1"
from="$2"
to="$3"

if [ "$switch" == "-y" ]
then
  accent_to_yacc "$from" "$to"
else
  yacc_to_accent "$from" "$to"
fi
