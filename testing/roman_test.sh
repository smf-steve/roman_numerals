#! /bin/bash

_form=${1:-0}

source ../roman_numerals.bash 

for (( i=1; i <= 3999 ; i++ )) ; do
   roman $i $_form
done >results.${_form}

diff  answers.${_form} results.${_form}
