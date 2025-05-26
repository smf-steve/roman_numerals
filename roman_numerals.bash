#! /bin/bash

SYNTAX=MODERN
# EARLY, MODERN, VINCULUM, APOSTROPHUS

FORMAT=CLASSIC
# Akin to conversion algorithm
# 0. CLASSIC (digit by digit)
# Order of Letters:  MDCLXVI
#   1. largest closest L
#   2. largest closest X
#   3. largest closest V
#   4. largest closest I


MAX_EARLY_ROMAN_NUMBER=899
MAX_MODERN_ROMAN_NUMBER=3999
MAX_VINCULUM_ROMAN_NUMBER=999999999
MAX_APOSTROPHUS_ROMAN_NUMBER=0


declare -a roman_array=(
  "I--"  "XVI"  "CLX"  "MDC" "--M"
)


#155,3999
#
#(((I)))I)))I))


# arabic2roman_classic
function arabic2roman_xxx() {
  number="$1"

  count=${#number}
  for ((c=0, d=${count}; c < ${count}; c++, d--)) ; do
    digit=${number:$c:1}
    digit2roman $digit ${roman_array[d]}
  done
}

function arabic2roman(){
  # Classical Form

  number="$1"
  
  if ((number > ${MAX_ROMAN_NUMBER})) ; then
    { echo "Current Syntax: ${SYNTAX}" ;
      echo "Maximum Number: ${MAX_ROMAN_NUMBER}" ;
    } > /dev/stderr
    return 2
  fi
  if ((number == 0)) ; then
    echo nila
    return 1
  fi

  if [[ ${SYNTAX} == EARLY ]] ||
     [[ ${SYNTAX} == MODERN ]] ; then
    arabic2roman_xxx ${number}
  fi

  if [[ ${SYNTAX} == VINCULUM ]] ; then 
    (( group3 = number / 1000 / 1000 ))
    (( group2 = number / 1000 % 1000 ))
    (( group1 = number % 1000 ))

    if (( group3 > 0 )) ; then
      echo -n "<vinculum>|"
      arabic2roman_xxx $group3
      echo -n "|<\vinculum>"
    fi 
    if (( group2 > 0 )) ; then
      echo -n "<vinculum>"
      arabic2roman_xxx $group2
      echo -n "<\vinculum>"
    fi  
    arabic2roman_xxx $group1
  fi
    echo
  return 0
}

# CLASSIC,
function set_format () {
  FORMAT="$1"

  [[ -z ${FORMAT} ]] && SYNTAX=CLASSIC

}

# EARLY, MODERN, VINCULUM, APOSTROPHUS
function set_syntax() {
  SYNTAX="$1"
  
  [[ -z ${SYNTAX} ]] && SYNTAX=MODERN 

  case ${SYNTAX} in
    EARLY )
      MAX_ROMAN_NUMBER=${MAX_EARLY_ROMAN_NUMBER}
      ;;

    MODERN )
      MAX_ROMAN_NUMBER=${MAX_MODERN_ROMAN_NUMBER}
      ;;

    VINCULUM )
      set_format CLASSIC
      MAX_ROMAN_NUMBER=${MAX_VINCULUM_ROMAN_NUMBER}
      ;;

    APOSTROPHUS )
      MAX_ROMAN_NUMBER=${MAX_VINCULUM_ROMAN_NUMBER}
      ;;
  esac
}

function set_defaults() {
  set_half_form TRUE
  set_subtractive_form TRUE
  set_syntax MODERN
  set_format 
}

function set_subtractive_form() {
  _value="$1"

  subtractive_form=TRUE      
  subtractive_form_4=TRUE   # IV -versus- IIII
  subtractive_form_8=FALSE  # VIII -versus-  IIX
  subtractive_form_9=TRUE   # IX -versus- VIIII 
  if [[ $_value == FALSE ]] ; then
    subtractive_form=FALSE      
    subtractive_form_4=FALSE   # IV -versus- IIII
    subtractive_form_8=FALSE   # VIII -versus-  IIX
    subtractive_form_9=FALSE   # IX -versus- VIIII
  fi 
}

function set_half_form() {
  _value="$1"

  half_form=TRUE
  if [[ $_value == FALSE ]] ; then
    half_form=FALSE
    subtractive_form_4=FALSE
  fi
}

# Note it is an error/inconsistency if
#   half_form == FALSE and subtractive_form_4 == TRUE
#
# Hence, subtractive_form_4 is ignored in half_form


set_defaults


function digit2roman() {
  digit=$1
  place=$2
  if [[ -z ${place} ]] ; then
    place=${roman_array[1]}
  fi

  unit=${place:0:1}           
  half=${place:1:1}
  base=${place:2:1}

  if [[ ${half_form} == FALSE ]] ; then
    half="${base}${base}${base}${base}${base}"
  fi

  case ${digit} in
    1|2|3 )
      for ((i = digit; i>0; i--)) ; do
        echo -n "${base}"
      done
      ;;

    4 )
      echo -n "${base}"
      if [[ ${subtractive_form_4} == TRUE ]] ; then 
        echo -n "${half}"
      else
        echo -n "${base}${base}${base}"
      fi
      ;;

    5 )
      echo -n "${half}"
      ;;

    6 | 7 )
      echo -n "${half}${base}"
      if (( digit == 7 )) ; then
        echo -n "${base}"
      fi
      ;;

    8 )
      if [[ ${subtractive_form_8} == FALSE ]] ; then
        echo -n "${half}${base}${base}${base}"
      else
        echo -n "${base}${base}${unit}" 
      fi
        ;; 

    9 )
      echo -n "${base}"
      if [[ ${subtractive_form_9} == TRUE ]] ; then 
        echo -n "${unit}"
      else
        echo -n "${base}${base}${base}"
      fi
      ;;
  esac

}





