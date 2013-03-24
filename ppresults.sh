#!/bin/sh

pp_acla() {
    aclarow=""
	for timelimit in $timelimits
	do
	    result="$resultsdir/acla/$g/${timelimit}s"
	    [ ! -z "$1" ] && result="$resultsdir/acla/$g/${1}_${timelimit}s"
		n_amb_acla=$(grep -c "yes" $result)
		aclarow="$aclarow , ($timelimit,$n_amb_acla) "
	done
	printf '%-20s :: %-200s\n' "ACLA [${1}]" "$aclarow"
}

pp_amber_ex() {
	for amberex in $amber_n_examples
	do
	    amberexrow=""
	    amberellexrow=""
	    for timelimit in $timelimits
	    do
	        result="$resultsdir/amber/$g/${timelimit}s_`echo "examples $amberex" | sed -e 's/\s/_/g'`"
	        [ ! -z "$1" ] && result="$resultsdir/amber/$g/${1}_${timelimit}s_`echo "examples $amberex" | sed -e 's/\s/_/g'`"
	        result_ell="$resultsdir/amber/$g/${timelimit}s_`echo "ellipsis examples $amberex" | sed -e 's/\s/_/g'`"
	        [ ! -z "$1" ] && result_ell="$resultsdir/amber/$g/${1}_${timelimit}s_`echo "ellipsis examples $amberex" | sed -e 's/\s/_/g'`"
	        n_amb_amber_ex=$(grep -c "yes" $result)
	        n_amb_amber_ell_ex=$(grep -c "yes" $result_ell)
	        amberexrow="$amberexrow, ($timelimit, $n_amb_amber_ex)"
	        amberellexrow="$amberellexrow, ($timelimit, $n_amb_amber_ell_ex)"
		done
		printf '%-20s :: %-200s\n' "Amber [${1}] [ex:$amberex]" "$amberexrow"
		printf '%-20s :: %-200s\n' "Amber [${1}] [ell ex:$amberex]" "$amberellexrow"
    done
}

pp_amber_len() {
    for amberlen in $amber_n_length
    do
        amberlenrow=""
        amberelllenrow=""
        for timelimit in $timelimits
	    do
	        result="$resultsdir/amber/$g/${timelimit}s_`echo "length $amberlen" | sed -e 's/\s/_/g'`"
	        [ ! -z "$1" ] && result="$resultsdir/amber/$g/${1}_${timelimit}s_`echo "length $amberlen" | sed -e 's/\s/_/g'`"
	        result_ell="$resultsdir/amber/$g/${timelimit}s_`echo "ellipsis length $amberlen" | sed -e 's/\s/_/g'`"
	        [ ! -z "$1" ] && result_ell="$resultsdir/amber/$g/${1}_${timelimit}s_`echo "ellipsis length $amberlen" | sed -e 's/\s/_/g'`"
            n_amb_amber_len=$(grep -c "yes" $result)
            n_amb_amber_ell_len=$(grep -c "yes" $result_ell)
            amberlenrow="$amberlenrow, ($timelimit, $n_amb_amber_len)"
            amberelllenrow="$amberelllenrow, ($timelimit, $n_amb_amber_ell_len)"
        done
		printf '%-20s :: %-200s\n' "Amber [${1}] [len:$amberlen]" "$amberlenrow"
		printf '%-20s :: %-200s\n' "Amber [${1}] [ell len:$amberlen]" "$amberelllenrow"        
	done
}

pp_ambidexter_len() {
    for ambilen in $ambidexter_n_length
    do
	    frow=""
	    slr1frow=""
	    lalr1frow=""
	    koptions="-q_-pg_-k_${ambilen}"
        for timelimit in $timelimits
        do
            ftime=$(python -c "from math import ceil; print int(ceil($timelimit * $fratio))")
            
            result="$resultsdir/ambidexter/$g/${timelimit}s_f_${ftime}s_${memlimit}_${koptions}"
            [ ! -z "$1" ] && result="$resultsdir/ambidexter/$g/${1}_${timelimit}s_f_${ftime}s_${memlimit}_${koptions}"
	        n_amb_ambidexter_f_k=$(grep -c "yes" $result)
	        
	        result_slr1="$resultsdir/ambidexter/$g/${timelimit}s_slr1f_${ftime}s_${memlimit}_${koptions}"
	        [ ! -z "$1" ] && result_slr1="$resultsdir/ambidexter/$g/${1}_${timelimit}s_slr1f_${ftime}s_${memlimit}_${koptions}"
	        n_amb_ambidexter_slr1f_k=$(grep -c "yes" $result_slr1)
	        
	        result_lalr1="$resultsdir/ambidexter/$g/${timelimit}s_lalr1f_${ftime}s_${memlimit}_${koptions}"
	        [ ! -z "$1" ] && result_lalr1="$resultsdir/ambidexter/$g/${1}_${timelimit}s_lalr1f_${ftime}s_${memlimit}_${koptions}"
	        n_amb_ambidexter_lalr1f_k=$(grep -c "yes" $result_lalr1)
	        
	        frow="$frow, ($timelimit, $n_amb_ambidexter_f_k)"
	        slr1frow="$frow, ($timelimit, $n_amb_ambidexter_slr1f_k)"
	        lalr1frow="$frow, ($timelimit, $n_amb_ambidexter_lalr1f_k)"	            
        done
		printf '%-20s :: %-200s\n' "AmbiDexter [${1}] [len:$amberlen, filter: n/a, ratio: $fratio]" "$frow"
	    printf '%-20s :: %-200s\n' "AmbiDexter [${1}] [len:$amberlen, filter: slr1, ratio: $fratio]" "$slr1frow"
	    printf '%-20s :: %-200s\n' "AmbiDexter [${1}] [len:$amberlen, filter: lalr1, ratio: $fratio]" "$lalr1frow" 	        
    done
}

pp_ambidexter_inclen() {
    ik_frow=""
    ik_slr1frow=""
    ik_lalr1frow=""
    ikoptions="-q_-pg_-ik_0"
    for timelimit in $timelimits
    do
        ftime=$(python -c "from math import ceil; print int(ceil($timelimit * $fratio))")
        
        result="$resultsdir/ambidexter/$g/${timelimit}s_f_${ftime}s_${memlimit}_${ikoptions}"
        [ ! -z "$1" ] && result="$resultsdir/ambidexter/$g/${1}_${timelimit}s_f_${ftime}s_${memlimit}_${ikoptions}"
        n_amb_ambidexter_f_ik=$(grep -c "yes" $result)
        
        result_slr1="$resultsdir/ambidexter/$g/${timelimit}s_slr1f_${ftime}s_${memlimit}_${ikoptions}"
        [ ! -z "$1" ] && result_slr1="$resultsdir/ambidexter/$g/${1}_${timelimit}s_slr1f_${ftime}s_${memlimit}_${ikoptions}"
        n_amb_ambidexter_slr1f_ik=$(grep -c "yes" $result_slr1)
        
        result_lalr1="$resultsdir/ambidexter/$g/${timelimit}s_lalr1f_${ftime}s_${memlimit}_${ikoptions}"
        [ ! -z "$1" ] && result_lalr1="$resultsdir/ambidexter/$g/${1}_${timelimit}s_lalr1f_${ftime}s_${memlimit}_${ikoptions}"
        n_amb_ambidexter_lalr1f_ik=$(grep -c "yes" $result_lalr1)
        
        ik_frow="$frow, ($timelimit, $n_amb_ambidexter_f_ik)"
        ik_slr1frow="$frow, ($timelimit, $n_amb_ambidexter_slr1f_ik)"
        ik_lalr1frow="$frow, ($timelimit, $n_amb_ambidexter_lalr1f_ik)"	        
    done
    printf '%-20s :: %-200s\n' "AmbiDexter [${1}] (ik, filter: n/a, ratio: $fratio)" "$ik_frow"
    printf '%-20s :: %-200s\n' "AmbiDexter [${1}] (ik, filter: slr1, ratio: $fratio)" "$ik_slr1frow"
    printf '%-20s :: %-200s\n' "AmbiDexter [${1}] (ik, filter: lalr1, ratio: $fratio)" "$ik_lalr1frow"
}

pp_sinbad() {
    prrow=""
    for timelimit in $timelimits
    do
        result="$resultsdir/sinbad/$g/purerandom_${timelimit}s"
        [ ! -z "$1" ] && result="$resultsdir/sinbad/$g/${1}_purerandom_${timelimit}s"
        n_amb_sinbad_purerandom=$(grep -c "yes" $result)
        prrow="$prrow ($timelimit, $n_amb_sinbad_purerandom)"
    done
    printf '%-20s :: %-200s\n' "sinbad [${1}] [purerandom]" "$prrow"

    
    for d in $Tdepths
    do
        _options="-d_$d"
        dyn1row=""
        for timelimit in $timelimits
        do
            result_dyn="$resultsdir/sinbad/$g/dynamic1_${timelimit}s_${_options}"
            [ ! -z "$1" ] && result_dyn="$resultsdir/sinbad/$g/${1}_dynamic1_${timelimit}s_${_options}"
            n_amb_sinbad_dyn=$(grep -c "yes" $result_dyn)
            dyn1row="$dyn1row ($timelimit, $n_amb_sinbad_dyn)"
        done
        printf '%-20s :: %-200s\n' "sinbad [${1}] [dynamic1[d=$d]]" "$dyn1row"
    done
}


for g in random1000 mutlang #  # lang # boltzcfg
do  
    ##########  ACLA ###########
    if [ "$g" == "mutlang" ]
    then
        for type in $mutypes
        do
            pp_acla $type
         done
    else
        pp_acla
    fi

	##########  AMBER - EXAMPLES ########### 
    if [ "$g" == "mutlang" ]
    then
        for type in $mutypes
        do
            pp_amber_ex $type
         done
    else
        pp_amber_ex
    fi
    
	##########  AMBER - LENGTH ########### 
    if [ "$g" == "mutlang" ]
    then
        for type in $mutypes
        do
            pp_amber_len $type
         done
    else
        pp_amber_len
    fi

	##########  AMBIDEXTER  ########### 
	for fratio in $filtertimeratios
	do
	    echo "-- filter ratio: $fratio --"
	    ##### LENGTH #####
		if [ "$g" == "mutlang" ]
		then
		    for type in $mutypes
		    do
		        pp_ambidexter_len $type
		     done
		else
		    pp_ambidexter_len
		fi
	    
	    ##### INCREMENTAL LENGTH #####
		if [ "$g" == "mutlang" ]
		then
		    for type in $mutypes
		    do
		        pp_ambidexter_inclen $type
		     done
		else
		    pp_ambidexter_inclen
		fi
			    
	done
  
    ##########  SINBAD ########### 
    if [ "$g" == "mutlang" ]
    then
        for type in $mutypes
        do
            pp_sinbad $type
         done
    else
        pp_sinbad
    fi
            
done
