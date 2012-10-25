#!/bin/sh

TO_RUN="${1}"
FITNESS="${2}"
TIME="${3}"
DEPTH="${4}"
SINBAD="${wrkdir}/sinbad/src"
PYTHON="`which python`"

run_random1000() {
    TMP="`mktemp -d`"
    for grammar in `seq 1 1000`
    do
        ${PYTHON} ${SINBAD}/sinbad -b ${FITNESS} -t ${TIME} -d ${DEPTH} ${RANDOM1000}/${grammar}/${grammar}.acc ${RANDOM1000}/general.lex > ${TMP}/${grammar}.log 2>&1
        _amb="`grep -o 'Grammar ambiguity detected' ${TMP}/${grammar}.log`"
        [ "${_amb}" != "" ] && echo "${grammar},yes" | tee -a ${RESULT} && continue
        echo "${grammar}," | tee -a ${RESULT}
        #_iter="`cat ${GRAMMAR_DIR}/${grammar}/sinbad_${FITNESS}_${DEPTH}d_${TIME}t.log | grep  '^\.' | wc -c`"
    done
    rm -Rf ${TMP}
}

run_lang() {
    TMP="`mktemp -d`"
    for grammar in Pascal SQL Java C
    do
        for i in `seq 1 5`
        do
            ${PYTHON} ${SINBAD}/sinbad -b ${FITNESS} -t ${TIME} -d ${DEPTH} ${LANGUAGE}/acc/${grammar}.${i}.acc ${LANGUAGE}/${grammar}.lex > ${TMP}/${grammar}_${i}.log 2>&1
            _amb="`grep -o 'Grammar ambiguity detected' ${TMP}/${grammar}_${i}.log`"
            [ "${_amb}" != "" ] && echo "${grammar}.${i},yes" | tee -a ${RESULT} && continue
            echo "${grammar}.${i}," | tee -a ${RESULT}
        done
    done
    rm -Rf ${TMP}
}

run_mutlang(){
    TMP="`mktemp -d`"
    for grammar in Pascal SQL Java C
    do
        for n in `seq 1 $NO_MUTATIONS`
        do
            ${PYTHON} ${SINBAD}/sinbad -b ${FITNESS} -t ${TIME} -d ${DEPTH} ${MUTATED_LANGUAGES}/acc/${grammar}/${grammar}.0_${n}.acc ${MUTATED_LANGUAGES}/${grammar}.lex > ${TMP}/${grammar}_${n}.log 2>&1
            _amb="`grep -o 'Grammar ambiguity detected' ${TMP}/${grammar}_${n}.log`"
            [ "${_amb}" != "" ] && echo "${grammar}.0_${n},yes" | tee -a ${RESULT} && continue
            echo "${grammar}.0_${n}," | tee -a ${RESULT}
        done
    done
    rm -Rf ${TMP}
}

run_test() {
    grammar="amb2"
    TMP="`mktemp -d`"
    ${PYTHON} ${SINBAD}/sinbad -b ${FITNESS} -t ${TIME} -d ${DEPTH} ${GRAMMAR_DIR}/test/${grammar}/${grammar}.acc ${RANDOM1000}/general.lex > ${TMP}/${grammar}.log 2>&1
    _amb="`grep -o 'Grammar ambiguity detected' ${TMP}/${grammar}.log`"
    [ "${_amb}" != "" ] && echo "${grammar},yes" | tee -a ${RESULT}
    #_iter="`cat ${GRAMMAR_DIR}/${grammar}/sinbad_${FITNESS}_${DEPTH}d_${TIME}t.log | grep  '^\.' | wc -c`"  
    rm -Rf ${TMP}
}

main() {
    for i in $*
    do
    	[ ! -d ${RESULTS_DIR}/sinbad/${TO_RUN} ] && mkdir -p ${RESULTS_DIR}/sinbad/${TO_RUN} && echo "${RESULTS_DIR}/sinbad/${TO_RUN} created!"
    	RESULT="${RESULTS_DIR}/sinbad/${TO_RUN}/${FITNESS}_${TIME}t_${DEPTH}d"
    	echo "[${TO_RUN} fitness=${FITNESS}, time=${TIME}, depth=${DEPTH}], Result -- ${RESULT}"
    	cp /dev/null ${RESULT}
        run_${i}
    done  
}

main ${TO_RUN}

