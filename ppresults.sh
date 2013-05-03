#!/bin/bash

pp_acla() {
    g="$1"
    aclarow=""
    for timelimit in $timelimits
    do
        result="$resultsdir/acla/$g/${timelimit}s"
        [ ! -z "$2" ] && result="$resultsdir/acla/$g/${2}_${timelimit}s"
        n_amb_acla=$(grep -c "yes" $result)
        aclarow="$aclarow | ($timelimit,$n_amb_acla) "
    done
    printf '%-20s %-200s\n' "ACLA [$g ${2}]" "$aclarow"
}

pp_amber_ex() {
    g="$1"
    for amberex in $amber_n_examples
    do
        amberexrow=""
        amberellexrow=""
        for timelimit in $timelimits
        do
            result="$resultsdir/amber/$g/${timelimit}s_`echo "examples $amberex" | sed -e 's/\s/_/g'`"
            [ ! -z "$2" ] && result="$resultsdir/amber/$g/${2}_${timelimit}s_`echo "examples $amberex" | sed -e 's/\s/_/g'`"
            result_ell="$resultsdir/amber/$g/${timelimit}s_`echo "ellipsis examples $amberex" | sed -e 's/\s/_/g'`"
            [ ! -z "$2" ] && result_ell="$resultsdir/amber/$g/${2}_${timelimit}s_`echo "ellipsis examples $amberex" | sed -e 's/\s/_/g'`"
            n_amb_amber_ex=$(grep -c "yes" $result)
            n_amb_amber_ell_ex=$(grep -c "yes" $result_ell)
            amberexrow="$amberexrow | ($timelimit,$n_amb_amber_ex)"
            amberellexrow="$amberellexrow | ($timelimit,$n_amb_amber_ell_ex)"
        done
        printf '%-20s %-200s\n' "Amber [$g ${2}] [ex $amberex]" "$amberexrow"
        printf '%-20s %-200s\n' "Amber [$g ${2}] [ell ex $amberex]" "$amberellexrow"
    done
}

pp_amber_len() {
    g="$1"
    for amberlen in $amber_n_length
    do
        amberlenrow=""
        amberelllenrow=""
        for timelimit in $timelimits
        do
            result="$resultsdir/amber/$g/${timelimit}s_`echo "length $amberlen" | sed -e 's/\s/_/g'`"
            [ ! -z "$2" ] && result="$resultsdir/amber/$g/${2}_${timelimit}s_`echo "length $amberlen" | sed -e 's/\s/_/g'`"
            result_ell="$resultsdir/amber/$g/${timelimit}s_`echo "ellipsis length $amberlen" | sed -e 's/\s/_/g'`"
            [ ! -z "$2" ] && result_ell="$resultsdir/amber/$g/${2}_${timelimit}s_`echo "ellipsis length $amberlen" | sed -e 's/\s/_/g'`"
            n_amb_amber_len=$(grep -c "yes" $result)
            n_amb_amber_ell_len=$(grep -c "yes" $result_ell)
            amberlenrow="$amberlenrow | ($timelimit,$n_amb_amber_len)"
            amberelllenrow="$amberelllenrow | ($timelimit,$n_amb_amber_ell_len)"
        done
        printf '%-20s %-200s\n' "Amber [$g ${2}] [len $amberlen]" "$amberlenrow"
        printf '%-20s %-200s\n' "Amber [$g ${2}] [ell len $amberlen]" "$amberelllenrow"        
    done
}

pp_ambidexter_len() {
    g="$1"
    for ambilen in $ambidexter_n_length
    do
        frow=""
        slr1frow=""
	lr0frow=""
	lr1frow=""
        lalr1frow=""
        koptions="-q_-pg_-k_${ambilen}"
        for timelimit in $timelimits
        do
            result="$resultsdir/ambidexter/$g/${timelimit}s_f_${memlimit}_${koptions}"
            [ ! -z "$2" ] && result="$resultsdir/ambidexter/$g/${2}_${timelimit}s_f_${memlimit}_${koptions}"
            n_amb_ambidexter_f_k=$(grep -c "yes" $result)

            result_slr1="$resultsdir/ambidexter/$g/${timelimit}s_slr1f_${memlimit}_${koptions}"
            [ ! -z "$2" ] && result_slr1="$resultsdir/ambidexter/$g/${2}_${timelimit}s_slr1f_${memlimit}_${koptions}"
            n_amb_ambidexter_slr1f_k=$(grep -c "yes" $result_slr1)

            result_lr0="$resultsdir/ambidexter/$g/${timelimit}s_lr0f_${memlimit}_${koptions}"
            [ ! -z "$2" ] && result_lr0="$resultsdir/ambidexter/$g/${2}_${timelimit}s_lr0f_${memlimit}_${koptions}"
            n_amb_ambidexter_lr0f_k=$(grep -c "yes" $result_lr0)

            result_lr1="$resultsdir/ambidexter/$g/${timelimit}s_lr1f_${memlimit}_${koptions}"
            [ ! -z "$2" ] && result_lr1="$resultsdir/ambidexter/$g/${2}_${timelimit}s_lr1f_${memlimit}_${koptions}"
            n_amb_ambidexter_lr1f_k=$(grep -c "yes" $result_lr1)

            result_lalr1="$resultsdir/ambidexter/$g/${timelimit}s_lalr1f_${memlimit}_${koptions}"
            [ ! -z "$2" ] && result_lalr1="$resultsdir/ambidexter/$g/${2}_${timelimit}s_lalr1f_${memlimit}_${koptions}"
            n_amb_ambidexter_lalr1f_k=$(grep -c "yes" $result_lalr1)

            frow="$frow | ($timelimit,$n_amb_ambidexter_f_k)"
            slr1frow="$slr1frow | ($timelimit,$n_amb_ambidexter_slr1f_k)"
            lr0frow="$lr0frow | ($timelimit,$n_amb_ambidexter_lr0f_k)"
            lr1frow="$lr1frow | ($timelimit,$n_amb_ambidexter_lr1f_k)"
            lalr1frow="$lalr1frow | ($timelimit,$n_amb_ambidexter_lalr1f_k)"                
        done
        printf '%-20s %-200s\n' "AmbiDexter [$g ${2}] [len $ambilen, filter: n/a]" "$frow"
        printf '%-20s %-200s\n' "AmbiDexter [$g ${2}] [len $ambilen, filter: slr1]" "$slr1frow"
        printf '%-20s %-200s\n' "AmbiDexter [$g ${2}] [len $ambilen, filter: lr0]" "$lr0frow"
        printf '%-20s %-200s\n' "AmbiDexter [$g ${2}] [len $ambilen, filter: lr1]" "$lr1frow"
        printf '%-20s %-200s\n' "AmbiDexter [$g ${2}] [len $ambilen, filter: lalr1]" "$lalr1frow"             
    done
}

pp_ambidexter_inclen() {
    g="$1"
    ik_frow=""
    ik_slr1frow=""
    ik_lr0frow=""
    ik_lr1frow=""
    ik_lalr1frow=""
    ikoptions="-q_-pg_-ik_0"
    for timelimit in $timelimits
    do
        result="$resultsdir/ambidexter/$g/${timelimit}s_f_${memlimit}_${ikoptions}"
        [ ! -z "$2" ] && result="$resultsdir/ambidexter/$g/${2}_${timelimit}s_f_${memlimit}_${ikoptions}"
        n_amb_ambidexter_f_ik=$(grep -c "yes" $result)

        result_slr1="$resultsdir/ambidexter/$g/${timelimit}s_slr1f_${memlimit}_${ikoptions}"
        [ ! -z "$2" ] && result_slr1="$resultsdir/ambidexter/$g/${2}_${timelimit}s_slr1f_${memlimit}_${ikoptions}"
        n_amb_ambidexter_slr1f_ik=$(grep -c "yes" $result_slr1)

        result_lr0="$resultsdir/ambidexter/$g/${timelimit}s_lr0f_${memlimit}_${ikoptions}"
        [ ! -z "$2" ] && result_lr0="$resultsdir/ambidexter/$g/${2}_${timelimit}s_lr0f_${memlimit}_${ikoptions}"
        n_amb_ambidexter_lr0f_ik=$(grep -c "yes" $result_lr0)

        result_lr1="$resultsdir/ambidexter/$g/${timelimit}s_lr1f_${memlimit}_${ikoptions}"
        [ ! -z "$2" ] && result_lr1="$resultsdir/ambidexter/$g/${2}_${timelimit}s_lr1f_${memlimit}_${ikoptions}"
        n_amb_ambidexter_lr1f_ik=$(grep -c "yes" $result_lr1)

        result_lalr1="$resultsdir/ambidexter/$g/${timelimit}s_lalr1f_${memlimit}_${ikoptions}"
        [ ! -z "$2" ] && result_lalr1="$resultsdir/ambidexter/$g/${2}_${timelimit}s_lalr1f_${memlimit}_${ikoptions}"
        n_amb_ambidexter_lalr1f_ik=$(grep -c "yes" $result_lalr1)

        ik_frow="$ik_frow | ($timelimit,$n_amb_ambidexter_f_ik)"
        ik_slr1frow="$ik_slr1frow | ($timelimit,$n_amb_ambidexter_slr1f_ik)"
        ik_lr0frow="$ik_lr0frow | ($timelimit,$n_amb_ambidexter_lr0f_ik)"
        ik_lr1frow="$ik_lr1frow | ($timelimit,$n_amb_ambidexter_lr1f_ik)"
        ik_lalr1frow="$ik_lalr1frow | ($timelimit,$n_amb_ambidexter_lalr1f_ik)"            
    done
    printf '%-20s %-200s\n' "AmbiDexter [$g ${2}] (ik, filter: n/a)" "$ik_frow"
    printf '%-20s %-200s\n' "AmbiDexter [$g ${2}] (ik, filter: slr1)" "$ik_slr1frow"
    printf '%-20s %-200s\n' "AmbiDexter [$g ${2}] (ik, filter: lr0)" "$ik_lr0frow"
    printf '%-20s %-200s\n' "AmbiDexter [$g ${2}] (ik, filter: lr1)" "$ik_slr1frow"
    printf '%-20s %-200s\n' "AmbiDexter [$g ${2}] (ik, filter: lalr1)" "$ik_lalr1frow"
}

pp_sinbad() {
    g="$1"
    prrow=""
    for timelimit in $timelimits
    do
        result="$resultsdir/sinbad/$g/purerandom_${timelimit}s"
        [ ! -z "$2" ] && result="$resultsdir/sinbad/$g/${2}_purerandom_${timelimit}s"
        n_amb_sinbad_purerandom=$(grep -c "yes" $result)
        prrow="$prrow | ($timelimit,$n_amb_sinbad_purerandom)"
    done
    printf '%-20s %-200s\n' "sinbad [$g ${2}] [purerandom]" "$prrow"

    
    for d in $Tdepths
    do
        _options="-d_$d"
        dyn1row=""
        for timelimit in $timelimits
        do
            result_dyn="$resultsdir/sinbad/$g/dynamic1_${timelimit}s_${_options}"
            [ ! -z "$2" ] && result_dyn="$resultsdir/sinbad/$g/${2}_dynamic1_${timelimit}s_${_options}"
            n_amb_sinbad_dyn=$(grep -c "yes" $result_dyn)
            dyn1row="$dyn1row | ($timelimit,$n_amb_sinbad_dyn)"
        done
        printf '%-20s %-200s\n' "sinbad [$g ${2}] [dynamic1 d=$d]" "$dyn1row"
    done
}

. ./toolparams.sh

for g in $gset
do  
    ##########  ACLA ###########
    if [ "$g" == "mutlang" ]
    then
        for type in $mutypes
        do
            pp_acla $g $type
         done
    else
        pp_acla $g
    fi

    ##########  AMBER - EXAMPLES ########### 
    if [ "$g" == "mutlang" ]
    then
        for type in $mutypes
        do
            pp_amber_ex $g $type
         done
    else
        pp_amber_ex $g
    fi
    
    ##########  AMBER - LENGTH ########### 
    if [ "$g" == "mutlang" ]
    then
        for type in $mutypes
        do
            pp_amber_len $g $type
         done
    else
        pp_amber_len $g
    fi

    ##########  AMBIDEXTER  ########### 

    ##### LENGTH #####
    if [ "$g" == "mutlang" ]
    then
        for type in $mutypes
        do
            pp_ambidexter_len $g $type
         done
    else
        pp_ambidexter_len $g
    fi

    ##### INCREMENTAL LENGTH #####
    if [ "$g" == "mutlang" ]
    then
        for type in $mutypes
        do
            pp_ambidexter_inclen $g $type
        done
    else
        pp_ambidexter_inclen $g
    fi
                
 
    ##########  SINBAD ########### 
    if [ "$g" == "mutlang" ]
    then
        for type in $mutypes
        do
            pp_sinbad $g $type
         done
    else
        pp_sinbad $g
    fi
            
done
