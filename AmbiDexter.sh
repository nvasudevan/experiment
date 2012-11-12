#!/bin/sh

g="$1"
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
result=""

if [ "$filter" == "" ]
then
    sentence="`$cmd $ambidexteroptions $g 2>/dev/null | grep 'Ambiguous string found'`"
else
    exported_harmless="`$cmd -h -$filter -oy $g 2> /dev/null | egrep '^Harmless productions|^Exporting' | sed -e 's/Harmless productions://' -e 's/Exporting grammar to/,/' | tr -d ' '`"
    harmless="`echo $exported_harmless | awk -F, '{print $1}'`"
    exported="`echo $exported_harmless | awk -F, '{print $2}'`"
    echo $harmless, $exported
    if [ "$exported" == "" ]
    then
        sentence="`$cmd $ambidexteroptions $g 2>/dev/null | grep 'Ambiguous string found'`"
    else
        sentence="`$cmd $ambidexteroptions $exported 2> /dev/null | grep 'Ambiguous string found'`"
    fi       
fi

[ "$sentence" != "" ] && result="yes"
printf "$result"
