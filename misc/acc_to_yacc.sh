#!/bin/sh

# convert ACCENT grammar to YACC version

acc_to_yacc(){
    gacc="$1"
    gy="$2"
    cat $gacc | grep  "%token" | sed -e 's/,//g' -e 's/;$//' > $gy
    cat $gacc | grep -v '%token' | sed -e 's/%nodefault/\n%%/' >> $gy
}

acc_to_yacc $1 $2
