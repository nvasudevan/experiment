#!/bin/sh

TO_RUN="${1}"
shift 
TIME="${1}s"
shift
AMBER_OPTIONS="$*"
ACCENT="${wrkdir}/accent/accent/accent"
AMBER_C="${wrkdir}/accent/amber/amber.c"
LEX="`which flex`"
CC="`which cc`"

run_random1000() {
    CWD="`pwd`"
    for grammar in `seq 1 1000`
    do
        TMP="`mktemp -d`"
        cd $TMP
        ${ACCENT} ${RANDOM1000}/${grammar}/${grammar}.spec
        [ $? -ne 0 ] && (echo "problem generating the yygrammar files using the ${RANDOM1000}/${grammar}/${grammar}.acc";exit 1)
        ${LEX} ${RANDOM1000}/general.lex
        [ $? -ne 0 ] && (echo "problem generating the lex code from ${RANDOM1000}/general.lex";exit 1)
        ${CC} -w -o amber -O3 yygrammar.c ${AMBER_C}
        sentence="`timeout ${TIME} ./amber ${AMBER_OPTIONS} examples ${NO_EXAMPLES} 2> /dev/null | grep 'Grammar ambiguity detected'`"
        [ "${sentence}" != "" ] && (echo "${grammar},yes" | tee -a ${RESULT};cd $CWD;rm -Rf ${TMP})  && continue
        echo "${grammar}," | tee -a ${RESULT}
        cd $CWD
        rm -Rf ${TMP}
    done
}

run_lang() {
    CWD="`pwd`"
    for grammar in Pascal SQL Java C
    do
        for i in `seq 1 5`
        do
            TMP="`mktemp -d`"
            cd $TMP
            ${ACCENT} ${LANGUAGE}/acc/${grammar}.${i}.acc
            [ $? -ne 0 ] && (echo "problem generating the yygrammar files using the ${LANGUAGE}/acc/${grammar}.${i}.acc";exit 1)
            ${LEX} ${LANGUAGE}/${grammar}.lex
            [ $? -ne 0 ] && (echo "problem generating the lex code from ${LANGUAGE}/${grammar}.lex";exit 1)
            ${CC} -w -o amber -O3 yygrammar.c ${AMBER_C}
            sentence="`timeout ${TIME} ./amber ${AMBER_OPTIONS} examples ${NO_EXAMPLES} 2> /dev/null | grep 'Grammar ambiguity detected'`"
            [ "${sentence}" != "" ] && (echo "${grammar}.${i},yes" | tee -a ${RESULT};cd $CWD;rm -Rf ${TMP})  && continue
            echo "${grammar}.${i}," | tee -a ${RESULT};cd $CWD;rm -Rf ${TMP}
        done
    done  
}

run_mutlang() {
    CWD="`pwd`"
    TMP="`mktemp -d`"
    for grammar in Pascal SQL Java C
    do
        for n in `seq 1 $NO_MUTATIONS`
        do
            TMP="`mktemp -d`"
            cd ${TMP}
            ${ACCENT} ${MUTATED_LANGUAGES}/acc/${grammar}/${grammar}.0_${n}.spec
            [ $? -ne 0 ] && (echo "problem generating the yygrammar files using the ${MUTATED_LANGUAGES}/acc/${grammar}/${grammar}.0_${n}.spec";exit 1)
            ${LEX} ${MUTATED_LANGUAGES}/${grammar}.lex
            [ $? -ne 0 ] && (echo "problem generating the lex code from ${LANGUAGE}/${grammar}.lex";exit 1)
            ${CC} -w -o amber -O3 yygrammar.c ${AMBER_C}
            sentence="`timeout ${TIME} ./amber ${AMBER_OPTIONS} examples ${NO_EXAMPLES} 2> /dev/null | grep 'Grammar ambiguity detected'`"
            [ "${sentence}" != "" ] && (echo "${grammar}.0_${n},yes" | tee -a ${RESULT};cd $CWD;rm -Rf ${TMP})  && continue
            echo "${grammar}.0_${n}," | tee -a ${RESULT};cd $CWD;rm -Rf ${TMP}
        done
    done
}

run_test() {
    grammar="amb2"
    TMP="`mktemp -d`"
    cd $TMP
    ${ACCENT} ${GRAMMAR_DIR}/test/${grammar}/${grammar}.acc || exit $?
    ${LEX} ${GRAMMAR_DIR}/test/general.lex || exit $?
    ${CC} -w -o amber -O3 yygrammar.c ${AMBER_C}
    sentence="`timeout ${TIME} ./amber ${AMBER_OPTIONS} 2> /dev/null | grep 'Grammar ambiguity detected'`"
    [ "${sentence}" != "" ] && (echo "${grammar},yes" | tee -a ${RESULT};cd $CWD;rm -Rf ${TMP})
    cd $CWD
    rm -Rf ${TMP}    
}

main() {
    for i in $*
    do
    	[ ! -d ${RESULTS_DIR}/amber/${TO_RUN} ] && mkdir -p ${RESULTS_DIR}/amber/${TO_RUN} && echo "${RESULTS_DIR}/amber/${TO_RUN} created!"
    	RESULT="${RESULTS_DIR}/amber/${TO_RUN}/${TIME}t_`echo ${AMBER_OPTIONS} | sed -e 's/\s/_/g'`"
    	echo "[${TO_RUN} time=${TIME}, options=${AMBER_OPTIONS}], Result -- ${RESULT}"
    	cp /dev/null ${RESULT}
        run_${i}
    done  
}

main ${TO_RUN}

