#!/bin/sh

TO_RUN="${1}"
shift
TIME="${1}s"
shift
MEM_MAX="${1}"
shift
FILTER=""
if [ "${1}" == "slr1" ]
then 
 FILTER="slr1"
 shift
 AMBIDEXTER_OPTIONS="$*"
else
 AMBIDEXTER_OPTIONS="$*"
fi

run() {
    _GRAMMAR="${1}"
    if [ "${FILTER}" == "" ]
    then
	    #_sentence="`timeout ${TIME} ${CMD} -q -pg -ik 0 ${_GRAMMAR} 2>/dev/null | grep 'Ambiguous string found'`"
        _sentence="`timeout ${TIME} ${CMD} ${AMBIDEXTER_OPTIONS} ${_GRAMMAR} 2>/dev/null | grep 'Ambiguous string found'`"
    else
        exported_harmless="`${CMD} -h -${FILTER} -oy ${_GRAMMAR} 2> /dev/null | egrep '^Harmless productions|^Exporting' | sed -e 's/Harmless productions://' -e 's/Exporting grammar to/,/' | tr -d ' '`"
        harmless="`echo $exported_harmless | awk -F, '{print $1}'`"
        exported="`echo $exported_harmless | awk -F, '{print $2}'`"
        if [ "${exported}" == "" ]
        then
            _sentence="`timeout ${TIME} ${CMD} ${AMBIDEXTER_OPTIONS} ${_GRAMMAR} 2>/dev/null | grep 'Ambiguous string found'`"
        else
            _sentence="`timeout ${TIME} ${CMD} ${AMBIDEXTER_OPTIONS} ${exported} 2> /dev/null | grep 'Ambiguous string found'`"
        fi        
    fi
    
    if [ "${_sentence}" != "" ]
    then
        _result="yes,${harmless}"
    else
        _result=",${harmless}"
    fi     
    echo ${_result}
}

run_random1000() {
	cp /dev/null ${RESULT}
    for grammar in `seq 1 5`
    do
        # first convert accent format to yacc format
        ACC_GRAMMAR_FILE="${RANDOM1000}/${grammar}/${grammar}.acc"
        YACC_GRAMMAR_FILE="${RANDOM1000}/${grammar}/${grammar}.y"
        cat ${ACC_GRAMMAR_FILE} | sed -e 's/%nodefault/%start root\n\n%%/' > ${YACC_GRAMMAR_FILE}
        tmp_file="`mktemp`"
        ${CMD} -s ${YACC_GRAMMAR_FILE} > ${tmp_file} 2>&1
        message="`cat ${tmp_file} | egrep -i 'Grammar contains injection cycle' | cut -d: -f2,3`"
        [ "${message}" != "" ] && echo "${grammar},yes," | tee -a ${RESULT} && continue
        message="`cat ${tmp_file} | egrep -i 'Unproductive start symbol' | cut -d: -f2,3`"
        [ "${message}" != "" ] && echo "${grammar},," | tee -a ${RESULT}  && continue
        result=$(run ${YACC_GRAMMAR_FILE})
        echo "${grammar},${result}" | tee -a ${RESULT}
    done

}

run_lang() {
	cp /dev/null ${RESULT}
    [ ! -d ${LANG}/y.generated ] && mkdir ${LANG}/y.generated
    for grammar in Pascal SQL Java C
    do
        for i in `seq 1 5`
        do
        	ACC_GRAMMAR_FILE="${LANG}/acc/${grammar}.${i}.acc"
            YACC_GRAMMAR_FILE="${LANG}/y/${grammar}.${i}.y"
            tmp_file="`mktemp`"
            ${CMD} -s ${YACC_GRAMMAR_FILE} > ${tmp_file} 2>&1
            message="`cat ${tmp_file} | egrep -i 'Grammar contains injection cycle' | cut -d: -f2,3`"
            [ "${message}" != "" ] && echo "${grammar},yes," | tee -a ${RESULT} && continue
            message="`cat ${tmp_file} | egrep -i 'Unproductive start symbol' | cut -d: -f2,3`"
            [ "${message}" != "" ] && echo "${grammar},," | tee -a ${RESULT}  && continue
            result=$(run ${YACC_GRAMMAR_FILE})
            echo "${grammar}.${i},${result}" | tee -a ${RESULT}
        done
    done
}


run_mutlang() {
    for grammar in Pascal SQL Java C
    do
       for type in ${MUTYPES}
       do
          cp /dev/null ${RESULT}_${type}
          for n in `seq 1 ${NO_MUTATIONS}`
          do
            # convert grammar to yacc format
            ACC_GRAMMAR_FILE="${MUTLANG}/acc/${type}/${grammar}.0_${n}.acc"
            YACC_GRAMMAR_FILE="${MUTLANG}/y/${type}/${grammar}.0_${n}.y"
            [ ! -d "${MUTLANG}/y/${type}" ] && mkdir -p ${MUTLANG}/y/${type}
            # add %token lines from grammar.0.y to the yacc one
            grep "^%token" ${LANG}/y/${grammar}.0.y > ${YACC_GRAMMAR_FILE}
            printf "\n%%%%\n" >> ${YACC_GRAMMAR_FILE}
            egrep -v "^%token|^%nodefault" ${ACC_GRAMMAR_FILE} >> ${YACC_GRAMMAR_FILE}
            result=$(run ${YACC_GRAMMAR_FILE})
            echo "${grammar}.0_${n},${result}" | tee -a ${RESULT}_${type}
          done
       done
    done
}


run_test() {
    grammar="amb2"
    ACC_GRAMMAR_FILE="${GRAMMAR_DIR}/test/${grammar}/${grammar}.acc"
    YACC_GRAMMAR_FILE="${GRAMMAR_DIR}/test/${grammar}/${grammar}.y"
    cat ${ACC_GRAMMAR_FILE} | sed -e 's/%nodefault/%start root\n\n%%/' > ${YACC_GRAMMAR_FILE}
    result=$(run ${YACC_GRAMMAR_FILE})
    echo "${grammar},${result}" | tee -a ${RESULT}
}

main() {
    for i in $*
    do
    	[ ! -d ${RESULTS_DIR}/ambidexter/${TO_RUN} ] && mkdir -p ${RESULTS_DIR}/ambidexter/${TO_RUN} && echo "${RESULTS_DIR}/ambidexter/${TO_RUN} created!"
    	RESULT="${RESULTS_DIR}/ambidexter/${TO_RUN}/${TIME}t_${FILTER}f_${MEM_MAX}_`echo ${AMBIDEXTER_OPTIONS} | sed -e 's/\s/_/g'`"
    	echo "[${TO_RUN} filter=${FILTER}, time=${TIME}, memory max=${MEM_MAX}, options=${AMBIDEXTER_OPTIONS}], Result -- ${RESULT}"
    	CMD="`which java` -Xss8m -Xmx${MEM_MAX} -jar ${wrkdir}/ambidexter/build/AmbiDexter.jar"
        run_${i}
    done  
}

main ${TO_RUN}

