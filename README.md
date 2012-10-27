experiment
==========

This repository contains all the artifacts required for comparing various 
ambiguity detection tools

grammars 

- Contains different sets of grammars: 1000 random grammars and some test grammars

patches  

- Contains patches required for our experiment.  For ACLA and AmbiDexter, we 
had to create a tiny patch: to stop search when an ambiguity is found

build.sh

- To download and build tools: ACLA, Amber, AmbiDexter, SinBAD

run_experiment.sh

- Runs the build.sh first, and then invokes each tool for different sets of grammars.
./run_experiment.sh <working directory>
