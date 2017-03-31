#!/bin/bash

. $expdir/env.sh

export gset="test"
export grammardir="$expdir/grammars"
export lexdir="$grammardir/lex"

export testgrammars="amb2"
export memlimit="512m"
export resultsdir="$expdir/results"

export glang="$grammardir/lang"
export lgrammars="Pascal"
export nlang="1"
