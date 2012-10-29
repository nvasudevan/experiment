#!/bin/sh

TO_RUN="${1}"
TIME="${2}s"
MEM_MAX="-Xmx${3}"
CMD="`which java` ${MEM_MAX} -jar ${wrkdir}/ACLA/grammar.modified.jar"

run_random1000() {
    for grammar in  `seq 1 5` 
    do
        # first convert accent format to cfg format
        ACC_GRAMMAR_FILE="${RANDOM1000}/${grammar}/${grammar}.acc"
        CFG_GRAMMAR_FILE="${RANDOM1000}/${grammar}/${grammar}.cfg"    
        cat ${ACC_GRAMMAR_FILE} | egrep -v "^%nodefault|^;" | sed -e "s/'/\"/g" > ${CFG_GRAMMAR_FILE}
        sentence="`timeout ${TIME} ${CMD} -a ${CFG_GRAMMAR_FILE} | egrep -o 'unambiguous\!|ambiguous string' | uniq`"
        [ "${sentence}" == "ambiguous string" ] && echo "${grammar},yes" | tee -a ${RESULT}  && continue
        [ "${sentence}" == "unambiguous!" ] && echo "${grammar},no" | tee -a ${RESULT}  && continue
        echo "${grammar}," | tee -a ${RESULT}
    done
}

run_lang() {
    for grammar in Pascal SQL Java C
    do
        for i in `seq 1 5`
        do
            # convert yacc grammars from AmbiDexter to ACLA format
            ACC_GRAMMAR_FILE="${LANG}/acc/${grammar}.${i}.acc"
            CFG_GRAMMAR_FILE="${GRAMMAR_DIR}/cfg/${grammar}.${i}.cfg"
            [ ! -d ${GRAMMAR_DIR}/cfg ] && mkdir -p ${GRAMMAR_DIR}/cfg    
            cat ${ACC_GRAMMAR_FILE} | egrep -v "^\s*;|^%nodefault|^%token " > ${CFG_GRAMMAR_FILE}
            token_list="`grep '%token' ${ACC_GRAMMAR_FILE} | sed -e 's/%token //' | tr -d ';,'`"
            for token in $token_list
            do
                sed -i -e "s/\b${token}\b/\"${token}\"/g" -e "s/'/\"/g" ${CFG_GRAMMAR_FILE}
#                if [ "${grammar}" == "Pascal" ]
#                then 
#                    sed -i -e 's/"UNSIGNED_INT"/"1"/g' ${CFG_GRAMMAR_FILE}
#                    sed -i -e 's/"UNSIGNED_REAL"/"1.0"/g' ${CFG_GRAMMAR_FILE}
#                    sed -i -e 's/"STRING"/"st"/g' ${CFG_GRAMMAR_FILE}
#                    sed -i -e 's/"IDENTIFIER"/"id"/g' ${CFG_GRAMMAR_FILE}
#                fi
            done            
            sentence="`timeout ${TIME} ${CMD} -a ${CFG_GRAMMAR_FILE} | egrep -o 'unambiguous\!|ambiguous string' | uniq`"
            [ "${sentence}" == "ambiguous string" ] && echo "${grammar}.${i},yes" | tee -a ${RESULT}  && continue
            [ "${sentence}" == "unambiguous!" ] && echo "${grammar}.${i},no" | tee -a ${RESULT}  && continue
            echo "${grammar}.${i}," | tee -a ${RESULT}
        done
    done
}

run_mutlang() {
    for grammar in Pascal SQL Java C
    do
       for type in ${MUTYPES}
       do
          cp /dev/null ${RESULT}_${type}
          echo "===> ${RESULT}_${type}"
          for n in `seq 1 ${NO_MUTATIONS}`
          do
             # convert grammar to cfg format
             ACC_GRAMMAR_FILE="${MUTLANG}/acc/${type}/${grammar}.0_${n}.acc"
             CFG_GRAMMAR_FILE="${MUTLANG}/cfg/${type}/${grammar}.0_${n}.cfg"
             [ ! -d ${MUTLANG}/cfg/${type} ] && mkdir -p ${MUTLANG}/cfg/${type}    
             cat ${ACC_GRAMMAR_FILE} | egrep -v "^\s*;|^%nodefault|^%token " > ${CFG_GRAMMAR_FILE}
             token_list="`grep '%token' ${ACC_GRAMMAR_FILE} | sed -e 's/%token //' | tr -d ';,'`"
             for token in $token_list
             do
                sed -i -e "s/\b${token}\b/\"${token}\"/g" -e "s/'/\"/g" ${CFG_GRAMMAR_FILE}
#                if [ "${grammar}" == "Pascal" ]
#                then 
#                    sed -i -e 's/"UNSIGNED_INT"/"1"/g' ${CFG_GRAMMAR_FILE}
#                    sed -i -e 's/"UNSIGNED_REAL"/"1.0"/g' ${CFG_GRAMMAR_FILE}
#                    sed -i -e 's/"STRING"/"st"/g' ${CFG_GRAMMAR_FILE}
#                    sed -i -e 's/"IDENTIFIER"/"id"/g' ${CFG_GRAMMAR_FILE}
#                fi                
             done
             sentence="`timeout ${TIME} ${CMD} -a ${CFG_GRAMMAR_FILE} | egrep -o 'unambiguous\!|ambiguous string' | uniq`"
             [ "${sentence}" == "ambiguous string" ] && echo "${grammar}.0_${n},yes" | tee -a ${RESULT}_${type}  && continue
             [ "${sentence}" == "unambiguous!" ] && echo "${grammar}.0_${n},no" | tee -a ${RESULT}_${type}  && continue
             echo "${grammar}.0_${n}," | tee -a ${RESULT}_${type}            
          done
       done
    done    
}

run_test() {
    grammar="amb2"
    ACC_GRAMMAR_FILE="${GRAMMAR_DIR}/test/${grammar}/${grammar}.acc"
    CFG_GRAMMAR_FILE="${GRAMMAR_DIR}/test/${grammar}/${grammar}.cfg"    
    cat ${ACC_GRAMMAR_FILE} | egrep -v "^%nodefault|^;" | sed -e "s/'/\"/g" > ${CFG_GRAMMAR_FILE}
    sentence="`timeout ${TIME} ${CMD} -a ${CFG_GRAMMAR_FILE} | egrep -o 'unambiguous\!|ambiguous string' | uniq`"
    [ "${sentence}" == "ambiguous string" ] && echo "${grammar},yes" | tee -a ${RESULT}  && return
    [ "${sentence}" == "unambiguous!" ] && echo "${grammar},no" | tee -a ${RESULT}  && return
    echo "${grammar}," | tee -a ${RESULT}
}

main() {
    for i in $*
    do
    	[ ! -d ${RESULTS_DIR}/acla/${TO_RUN} ] && mkdir -p ${RESULTS_DIR}/acla/${TO_RUN} && echo "${RESULTS_DIR}/acla/${TO_RUN} created!"
    	RESULT="${RESULTS_DIR}/acla/${TO_RUN}/${TIME}t"
    	echo "[${TO_RUN} time=${TIME}, memory max=${MEM_MAX}], Result -- ${RESULT}"
    	cp /dev/null ${RESULT}
        run_${i}
    done  
}

main ${TO_RUN}

