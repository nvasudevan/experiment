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
    for grammar in `seq 1 5`
    do
        TMP="`mktemp -d`"
        cd $TMP
        ${ACCENT} ${RANDOM1000}/${grammar}/${grammar}.acc || exit $?
        ${LEX} ${LEX_DIR}/general.lex || exit $?
        ${CC} -w -o amber -O3 yygrammar.c ${AMBER_C}
        output="`timeout ${TIME} ./amber ${AMBER_OPTIONS} 2> /dev/null | egrep 'tick|Grammar ambiguity detected' | paste - - `"
        sentence="`echo ${output} | grep -o 'Grammar ambiguity detected'`"
        ticks="`echo ${output} | grep -o "tick: [0-9]*" | sed -e 's/tick: //'`"
        [ "${sentence}" != "" ] && (echo "${grammar},yes,${ticks}" | tee -a ${RESULT};cd $CWD;rm -Rf ${TMP})  && continue
        echo "${grammar},,${ticks}" | tee -a ${RESULT}
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
            ${ACCENT} ${LANG}/acc/${grammar}.${i}.acc || exit $?
            ${LEX} ${LEX_DIR}/${grammar}.lex || exit $?
            ${CC} -w -o amber -O3 yygrammar.c ${AMBER_C}
            #sentence="`timeout ${TIME} ./amber ${AMBER_OPTIONS} 2> /dev/null | grep 'Grammar ambiguity detected'`"
            output="`timeout ${TIME} ./amber ${AMBER_OPTIONS} 2> /dev/null | egrep 'tick|Grammar ambiguity detected' | paste - - `"
            sentence="`echo ${output} | grep -o 'Grammar ambiguity detected'`"
            ticks="`echo ${output} | grep -o "tick: [0-9]*" | sed -e 's/tick: //'`"
            [ "${sentence}" != "" ] && (echo "${grammar}.${i},yes,${ticks}" | tee -a ${RESULT};cd $CWD;rm -Rf ${TMP})  && continue
            echo "${grammar}.${i},,${ticks}" | tee -a ${RESULT};cd $CWD;rm -Rf ${TMP}
        done
    done  
}

run_mutlang() {
    CWD="`pwd`"
    TMP="`mktemp -d`"
    for grammar in Pascal SQL Java C
    do
       for type in ${MUTYPES}
       do
          cp /dev/null ${RESULT}_${type}
          echo "===> ${type}"
          for n in `seq 1 $NO_MUTATIONS`
          do
             TMP="`mktemp -d`"
             cd ${TMP}
             ${ACCENT} ${MUTLANG}/acc/${type}/${grammar}.0_${n}.acc || exit $?
             ${LEX} ${LEX_DIR}/${grammar}.lex || exit $?
             ${CC} -w -o amber -O3 yygrammar.c ${AMBER_C}
             #sentence="`timeout ${TIME} ./amber ${AMBER_OPTIONS} 2> /dev/null | grep 'Grammar ambiguity detected'`"
             output="`timeout ${TIME} ./amber ${AMBER_OPTIONS} 2> /dev/null | egrep 'tick|Grammar ambiguity detected' | paste - - `"
             sentence="`echo ${output} | grep -o 'Grammar ambiguity detected'`"
             ticks="`echo ${output} | grep -o "tick: [0-9]*" | sed -e 's/tick: //'`"
             [ "${sentence}" != "" ] && (echo "${grammar}.0_${n},yes,${ticks}" | tee -a ${RESULT}_${type};cd $CWD;rm -Rf ${TMP})  && continue
             echo "${grammar}.0_${n},,${ticks}" | tee -a ${RESULT}_${type};cd $CWD;rm -Rf ${TMP}
          done
       done
    done
}

run_test() {
    grammar="amb2"
    TMP="`mktemp -d`"
    cd $TMP
    ${ACCENT} ${GRAMMAR_DIR}/test/${grammar}/${grammar}.acc || exit $?
    ${LEX} ${LEX_DIR}/general.lex || exit $?
    ${CC} -w -o amber -O3 yygrammar.c ${AMBER_C}
    #sentence="`timeout ${TIME} ./amber ${AMBER_OPTIONS} 2> /dev/null | grep 'Grammar ambiguity detected'`"
    output="`timeout ${TIME} ./amber ${AMBER_OPTIONS} 2> /dev/null | egrep 'tick|Grammar ambiguity detected' | paste - - `"
    sentence="`echo ${output} | grep -o 'Grammar ambiguity detected'`"
    ticks="`echo ${output} | grep -o "tick: [0-9]*" | sed -e 's/tick: //'`"
    [ "${sentence}" != "" ] && (echo "${grammar},yes,${ticks}" | tee -a ${RESULT};cd $CWD;rm -Rf ${TMP}) && return
    echo "${grammar},,${ticks}" | tee -a ${RESULT}
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

