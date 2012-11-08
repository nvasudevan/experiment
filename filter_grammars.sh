#!/bin/sh

# - generated filtered grammmars for AmbiDexter
#   - calculate % of unambiguous rules filtered out for each filter
#   - How long it takes to generate filtered grammars (SLR1, LR0, LR1, LALR1)


cwd="`pwd`"

if [ $# -eq 0 ]; then
    wrkdir=`pwd`
elif [ $# -eq 1 ]; then
    wrkdir=$1
    if [ "`dirname $wrkdir`" == "." ]; then 
    	_wrkdir="`pwd`/`basename $wrkdir`"
    	wrkdir = "$_wrkdir"
    fi
    mkdir -p $wrkdir
else
    echo "$0 [<full path to working directory>]"
    exit 1
fi
echo -e "===> Working in $wrkdir"
export cwd wrkdir

cd $wrkdir 

grammardir="$cwd/grammars"
grandom="${grammardir}/random1000"
glang="${grammardir}/lang"
gmutlang="${grammardir}/mutlang"
Nmutations="100"
mutypes="type1 type2 type3 type4"
memlimit="2048m"
cmd="`which java` -Xss8m -Xmx${memlimit} -jar ${wrkdir}/ambidexter/build/AmbiDexter.jar"
filters="slr1 lr0 lr1 lalr1"
grammars="random1000 lan mutlang"
timelimit="300s"

export grammardir grandom glang gmultang n_mutations mutypes memlimit timelimit

# Download AmbiDexter

git clone https://github.com/cwi-swat/ambidexter.git
cd ambidexter
# As of 2nd Nov 2012, the current version is db64485ad4.
# We are reseetting it to a specific version to ensure our patch
# definitely works
git checkout db64485ad4
mkdir -p build/META-INF
echo "Main-Class: nl.cwi.sen1.AmbiDexter.Main" > build/META-INF/MANIFEST.MF
cd src
javac nl/cwi/sen1/AmbiDexter/*.java || exit $?
find . -type f -name "*.class" | cpio -pdm ../build/
cd ../build
jar cmf META-INF/MANIFEST.MF AmbiDexter.jar nl
[ ! -f $wrkdir/ambidexter/build/AmbiDexter.jar ] && echo "AmbiDexter failed to build. Check in $wrkdir/ambidexter" && exit $?

# Download AmbiDexter grammars

echo -e "\\n===> Fetching AmbiDexter grammars\\n"

cd $cwd/grammars
wget -O grammars.zip https://sites.google.com/site/basbasten/files/grammars.zip
unzip -q grammars.zip
mv grammars lang

generate() {
	gacc=$1
	yacc=$2
	filter=$3
	starttime="`date '+%s'`"
	out="`timeout $timelimit $cmd -h -$filter -oy $yacc 2> /dev/null | egrep '^Harmless productions|^Exporting' | sed -e 's/Harmless productions://' -e 's/Exporting grammar to/,/' | tr -d ' '`"
	endtime="`date '+%s'`"
	harmless="`echo $out | awk -F, '{print $1}'`"
	exported="`echo $out | awk -F, '{print $2}'`"
	if [ "$harmless" != "" ]
	then
		ratio=$(echo "scale=3; $harmless" | bc)
		((fcnt+=1))
		ratiocnt=$(echo "$ratiocnt + $ratio" | bc)
	fi
	timediff="`echo $endtime - $starttime | bc`"
	echo "`basename $gacc .acc`, $harmless [ratio=$ratio, ratiocnt=$ratiocnt], $exported, $timediff"
}

random1000(){
	echo -e "\n===> random1000 \n"
	for filter in $filters
	do
		echo -e "\n=> $filter \n"
		cnt=0
		fcnt=0
		ratiocnt=0.0
		gstarttime="`date '+%s'`"
		for g in `seq 1 1000`
		do
			cat $grandom/$g/$g.acc | sed -e 's/%nodefault/%start root\n\n%%/' > $grandom/$g/$g.y
			generate $grandom/$g/$g.acc $grandom/$g/$g.y $filter
			((cnt+=1))
		done
		gendtime="`date '+%s'`"
		avgratio=$(echo "scale=3; $ratiocnt/$fcnt" | bc)
		echo -e "\ntime taken=`expr $gendtime - $gstarttime` , how many generated=$fcnt[of $cnt], avg harmless=$avgratio"
	done
}

lang() {
	echo -e "\n===> lang \n"
	for filter in $filters
	do
		echo -e "\n=> $filter \n"
		cnt=0
		fcnt=0
		ratiocnt=0.0
		gstarttime="`date '+%s'`"
		for l in Pascal SQL Java C
		do
			for i in `seq 1 5`
			do
				generate $glang/acc/$l.$i.acc $glang/y/$l.$i.y $filter
				((cnt+=1))
			done
		done
		gendtime="`date '+%s'`"
		avgratio=$(echo "scale=3; $ratiocnt/$fcnt" | bc)
		echo -e "\ntime taken=`expr $gendtime - $gstarttime` , how many generated=$fcnt[of $cnt], avg harmless=$avgratio"			
	done
}
	
mutlang() {
	echo -e "\n===> mutlang \n"
	for filter in $filters
	do
		echo -e "\n=> $filter \n"
		cnt=0
		fcnt=0
		ratiocnt=0.0
		gstarttime="`date '+%s'`"
		for t in $mutypes
		do
			for l in Pascal SQL Java C
			do
				[ ! -d "$gmutlang/y/$t" ] && mkdir -p $gmutlang/y/$t
				for i in `seq 1 $Nmutations`
				do
            		grep "^%token" $glang/y/$l.0.y > $gmutlang/y/$t/$l.0_$i.y
            		printf "\n%%%%\n" >> $gmutlang/y/$t/$l.0_$i.y
            		egrep -v "^%token|^%nodefault" $gmutlang/acc/$t/$l.0_$i.acc >> $gmutlang/y/$t/$l.0_$i.y				
					generate $gmutlang/acc/$t/$l.0_$i.acc $gmutlang/y/$t/$l.0_$i.y $filter
					((cnt+=1))
				done
			done
		done
		gendtime="`date '+%s'`"
		avgratio=$(echo "scale=3; $ratiocnt/$fcnt" | bc)
		echo -e "\n$t, time taken=`expr $gendtime - $gstarttime` , how many generated=$fcnt[of $cnt], avg harmless=$avgratio"			
	done
}

cd $cwd

random1000
lang
mutlang
