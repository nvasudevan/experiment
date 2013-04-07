#!/bin/bash

timelimit="$1"
shift
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
    sentence=$(timeout $timelimit $cmd $ambidexteroptions $g 2>/dev/null | grep 'Ambiguous string found') || exit $?
else
    exported_harmless=$(timeout $timelimit $cmd -h -$filter -oy $g 2> /dev/null | egrep '^Harmless productions|^Exporting' | sed -e 's/Harmless productions://' -e 's/Exporting grammar to/,/' | tr -d ' ')
    harmless="`echo $exported_harmless | awk -F, '{print $1}'`"
    exported="`echo $exported_harmless | awk -F, '{print $2}'`"
    echo $harmless, $exported
    if [ ! -z "$exported" ]
    then
        sentence=$(timeout $timelimit $cmd $ambidexteroptions $exported 2> /dev/null | grep 'Ambiguous string found') || exit $?
    fi
fi

[ "$sentence" != "" ] && result="yes"
printf "$result"
