experiment
==========

This repository contains all the artifacts required for comparing various 
ambiguity detection tools

grammars 

- Contains different sets of grammars

patches  

- Contains patches required for our experiment.  For ACLA and AmbiDexter, we 
had to create a tiny patch to stop when an ambiguity is found

build.sh

- To download and build tools: ACLA, Amber, AmbiDexter, SinBAD

run_experiment.sh

- Runs the build.sh and then invokes each tool for different sets of grammars.
