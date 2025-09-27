#! /bin/bash

# set-form must be called to set things correctly for SIMPLIFIED



RN_MAX_MODERN=3999           # M for '1000' was not in use until the Medieval period).
RN_MAX_VINCULUM=999999999    # Groups of xxx,yyy,zzz
declare -a units_modern=(I X C M)
declare -a halfs_modern=(S V L D)

RN_MAX_EARLY=899             # DCCCIXIX --- No M but a D ???
RN_MAX_APOSTROPHUS=399999    # Based upon Etruscan numbers
declare -a units_apostrophus=( I X C "(I)" "((I))" "(((I)))" )
declare -a halfs_apostrophus=( S V L  "I)"   "I))"    "I)))" )

declare -a units=( ${units_modern[@]} )
declare -a halfs=( ${halfs_modern[@]} )

RN_OFS=" "


RN_STYLE=MODERN
# MODERN, VINCULUM, EARLY, APOSTROPHUS

RN_MAX=${RN_MAX_MODERN}
RN_MAX_DIGIT_VALUE=100000    # APOSTROPHUS: (((I)))

RN_FORM=STANDARD
RN_MAX_SIMPLIFIED=4               
# STANDARD, ADDITIVE_ONLY, SIMPLIFIED

declare MAX_DENOMINATOR_DEFAULT=10
declare MAX_DENOMINATOR=10        
declare -a DENOMINATORS=( 1000 500 200 100 50 20 10 )
declare -a EXCEL_DENOMINATORS=( 1000 200 100 20 10 )
  # The denominator is used to determine how aggressive the subtractive form is applied
  # Excel Form range: 0..4
  # 0:    9 => IX  |  1/10   * 10   = 1   | (-1 + 10   =   9)
  # 1:   95 => VC  |  1/20   * 100  = 5   | (-5 + 100  =  95)
  # 2:   99 => IC  |  1/100  * 100  = 1   | (-1 + 100  =  99)
  # 3:  995 => VM  |  1/200  * 1000 = 5   | (-5 + 1000 = 995)
  # 4:  999 => IM  |  1/1000 * 1000 = 1   | (-1 + 1000 = 999)
  #
  # https://support.microsoft.com/en-us/office/roman-function-d6b0b99e-de46-4704-a518-b45a0f8b56f5

# Format Variants: These are the DEFAULTS
HALF_FORM=TRUE                 # TRUE ->  V, L, D
SUBTRACTIVE_FORM=TRUE
  SUBTRACTIVE_FORM_4=TRUE      # TRUE= "IV",   otherwise:   "IIII"
  SUBTRACTIVE_FORM_8=FALSE     # FALSE="VIII", otherwise:    "IIX"
  SUBTRACTIVE_FORM_9=TRUE      # TRUE= "IX",   otherwise:  "VIIII"


# Values associated with various forms:
#
# 1. STANDARD, CLASSIC 
#    - SUBTRACTIVE_FORM=TRUE
#    - HALF_FORM=TRUE
#    - MAX_DENOMINATOR=10
#    - SUBTRACTIVE_FORM_8=FALSE
#
# 2. ADDITIVE_ONLY
#    - SUBTRACTIVE_FORM=FALSE
#    - HALF_FORM=TRUE
#    - MAX_DENOMINATOR=10
#
# 3. SIMPLIFIED=4
#    - SUBRACTIVE_FORM=TRUE
#    - HALF_FORM=TRUE
#    - MAX_DENOMINATOR=1000    # as computed
#      * ${EXCEL_DENOMINATORS[4-${RN_MAX_SIMPLIFIED}]}
#
# FREE ENVIRONMENT VARABLES
#    SUBTRACTIVE_FORM_4=TRUE      # 4 = IV
#    SUBTRACTIVE_FORM_8=TRUE      # 8 = IIX
#    SUBTRACTIVE_FORM_9=TRUE      # 9 = IX 



# roman_digit          # roman_digit
# roman value [form]   # arabic2roman_algorithm
# arabic2roman


function roman() {
  local value="${1:-0}"
  local simplified="${2:-0}"

  MAX_DENOMINATOR=${EXCEL_DENOMINATORS[4-${simplified}]}

  local lower
  local upper
  local half

  if (( value > RN_MAX )) ; then
    echo "Error: $value > $RN_MAX" >2
    return 1
  fi

  for ((lower = RN_MAX_DIGIT_VALUE; lower > 1 ; lower = lower / 10 )); do
    local denominator
    local i

    if (( lower > value )) ; then
      continue
    fi

    (( upper = lower * 10 ))
    (( half  = lower * 5  ))


    # Following handles the Subtractive forms
    if [[ SUBTRACTIVE_FORM == TRUE ]] ; then 
      for denominator in ${DENOMINATORS[@]} ; do
        (( denominator > MAX_DENOMINATOR )) && continue 
        # skip over non-applicable denominators
        case "${denominator:0:1}" in
          1 )
            :
            ;;
          2 )  # 1/2xxxx
            [[ ${HALF_FORM} == FALSE ]] && continue
            ;;
          5 )  # 1/5xxxx
            [[ ${SUBTRACTIVE_FORM_8} == FALSE ]] && continue
            ;;
          * )
            echo \*
            return 1
            ;;
        esac

        (( i = upper / denominator ))
        (( i >= lower)) && break 1

        if ((value + i >= upper )); then
          roman_digit ${i:0:1} ${#i} 
          roman_digit 1 ${#upper} 

          (( value = value - (upper - i) ))
          continue 2
        fi

        if [[ ${HALF_FORM} == TRUE ]] && ((value < half)) ; then
         if ((value + i >= half )); then
           roman_digit ${i:0:1} ${#i} 
           roman_digit 5 ${#half} 

           (( value = value - (half - i) ))
           continue 2
         fi
        fi
      done
    fi

    roman_digit ${value:0:1} ${#value}
    (( value = value % lower ))
  done

  # This is the signal digit or zero
  roman_digit ${value:0:1} ${#value}

  echo
}


function arabic2roman(){
  # Converts an arabic number to a roman number

  local number="${1:-0}"
  local simplified="${2:-0}"

  if (( ${simplified} != 0 )) ; then
    set_form SIMPLIFIED ${simplified}
  fi

  local group3 group2 group1
  
  if ((number > ${RN_MAX})) ; then
    { echo "Current Syntax: ${RN_STYLE}" ;
      echo "Maximum Number: ${RN_MAX}" ;
    } > /dev/stderr
    return 2
  fi
  if ((number == 0)) ; then
    echo nila
    return 1
  fi


  case ${RN_STYLE} in

    ( "EARLY"  | "MODERN" ) 
      roman ${number} ${simplified}
      ;;

    ( "VINCULUM" )
      (( group3 = number / 1000 / 1000 ))
      (( group2 = number / 1000 % 1000 ))
      (( group1 = number % 1000 ))

      local RN_MAX=999
      if (( group3 > 0 )) ; then
        echo -n "<vinculum>|"
        roman ${group3} ${simplified}

        echo -n "|<\vinculum>"
      fi 
      if (( group2 > 0 )) ; then
        echo -n "<vinculum>"
        roman ${group2} ${simplified}
        echo -n "<\vinculum>"
      fi  
      roman ${group1} ${simplified}
      ;;
  
    ( "APOSTROPHUS" )
      declare -a units=( ${units_apostrophus[@]} )
      declare -a halfs=( ${halfs_apostrophus[@]} )

      roman ${number} ${simplified}

      declare -a units=( ${units_modern[@]} )
      declare -a halfs=( ${halfs_modern[@]} )      
      ;;

  esac
  echo
  return 0
}


function set_form () {
  local _form="${1:-STANDARD}"
  local _number="${2:-${RN_MAX_SIMPLIFIED}}"

  if (( _number > ${RN_MAX_SIMPLIFIED} )) ; then
    echo "ERROR" >&2
    return 1
  fi

  RN_FORM=${_form}
  if [[ ${RN_FORM} == "SIMPLIFIED" ]] ; then
    MAX_DENOMINATOR=${EXCEL_DENOMINATORS[4-${_number}]}
  else
    MAX_DENOMINATOR=${MAX_DENOMINATOR_DEFAULT}
  fi
}

# MODERN, VINCULUM, EARLY, APOSTROPHUS
function set_style() {
  local _style="${1:-MODERN}"
  
  RN_STYLE=${_style}

  local _max="RN_MAX_${_style}"
  RN_MAX=${!_max}
}


function set_defaults() {
  set_half_form TRUE
  set_subtractive_form TRUE
  set_style MODERN
  set_form STANDARD
}

function set_subtractive_form() {
  local _value="$1"

  SUBTRACTIVE_FORM=TRUE      
  SUBTRACTIVE_FORM_4=TRUE      # 4 = IV
  SUBTRACTIVE_FORM_8=FALSE     # 8 = VIII
  SUBTRACTIVE_FORM_9=TRUE      # 9 = IX 
  if [[ $_value == FALSE ]] ; then
    SUBTRACTIVE_FORM=FALSE      
    SUBTRACTIVE_FORM_4=FALSE   # 4 = IIII
    SUBTRACTIVE_FORM_8=FALSE   # 8 = VIII
    SUBTRACTIVE_FORM_9=FALSE   # 9 = VIIII
  fi 
}

function set_half_form() {
  local _value="$1"

  HALF_FORM=TRUE
  if [[ $_value == FALSE ]] ; then
    HALF_FORM=FALSE
    SUBRACTIVE_FORM_4=FALSE   # IV is not valid
  fi
}


set_defaults


function roman_digit() {
  local digit=$1
  local place=$2

  if [[ -z ${place} ]] ; then
    place=1
  fi

  local unit=${units[place-1]}           
  local half=${halfs[place]}
  local full=${units[place]}

  if [[ ${HALF_FORM} == FALSE ]] ; then
    half="${unit}${unit}${unit}${unit}${unit}"
  fi

  case ${digit} in
    1|2|3 )
      local i
      for ((i = digit; i>0; i--)) ; do
        echo -n "${unit}"
      done
      ;;

    4 )
      if [[ ${SUBTRACTIVE_FORM_4} == TRUE ]] ; then 
        echo -n "${unit}${half}"
      else
        echo -n "${unit}${unit}${unit}${unit}"
      fi
      ;;

    5 )
      echo -n "${half}"
      ;;

    6 | 7 )
      echo -n "${half}${unit}"
      if (( digit == 7 )) ; then
        echo -n "${unit}"
      fi
      ;;

    8 )
      if [[ ${SUBTRACTIVE_FORM_8} == TRUE ]] ; then
        echo -n "${unit}${unit}${full}" 
      else
        echo -n "${half}${unit}${unit}${unit}"
      fi
        ;; 

    9 )
      if [[ ${SUBTRACTIVE_FORM_9} == TRUE ]] ; then 
        echo -n "${unit}${full}"
      else
        echo -n "${half}${unit}${unit}${unit}${unit}"
      fi
      ;;
  esac
}



# arabic2roman:  by digits
function arabic2roman_xxx() {
  local number="$1"
  local count=${#number}

  local c d
  for ((c=0, d=${count}; c < ${count}; c++, d--)) ; do
    local digit=${number:$c:1}
    roman_digit $digit d
  done
}

function arabic2roman_yyy() {
  local number="$1"

  while [[ -n "${number:0}" ]] ; do
    roman_digit ${number:0:1} ${#number}
    number=${number:1}
  done
  echo
}


function list2roman_xxx (){
  local count=${#}
  for num in "${@}" ; do
     arabic2roman_xxx ${num}
     echo -n "${RN_OFS}"
  done
  echo 
}

