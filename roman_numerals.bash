#! /bin/bash

RN_MAX_MODERN=3999           # M for '1000' was not in use until the Medieval period).
RN_MAX_VINCULUM=999999999    # Groups of xxx,yyy,zzz
declare -a units_modern=(I X C M)
declare -a halfs_modern=(S V L D)

RN_MAX_EARLY=899             # DCCCIXIX --- No M but a D ???
RN_MAX_APOSTROPHUS=399999    # Based upon Etruscan numbers
declare -a units_apostrophus=( I X C "(I)" "((I))" "(((I)))" )
declare -a halfs_apostrophus=( S V D  "I)"   "I))"    "I)))" )


declare -a units=( ${units_modern[@]} )
declare -a halfs=( ${halfs_modern[@]} )

RN_STYLE=MODERN
# MODERN, VINCULUM, EARLY, APOSTROPHUS

RN_MAX=${RN_MAX_MODERN}
RN_MAX_DIGIT_VALUE=100000    # APOSTROPHUS: (((I)))

RN_FORMAT=STANDARD
# STANDARD, ADDITIVE_ONLY, OPTIMAL=


# Format Variants: These are the DEFAULTS
HALF_FORM=TRUE                 # TRUE ->  V, L, D
SUBTRACTIVE_FORM=TRUE
  SUBTRACTIVE_FORM_4=TRUE      # TRUE= "IV", otherwise:   "IIII"
  SUBTRACTIVE_FORM_8=FALSE     # FALSE="VIII", otherwise:  "IIX"
  SUBTRACTIVE_FORM_9=TRUE      # TRUE= "IX", otherwise:  "VIIII"

  # Distance: 1/10, 1/20, 1/100, 1/200, 1/1000
  SUBTRACTIVE_FORM_DISTANCE=1  # (1: 1/10, 3: 1/100, 5: 1/1000)
    # Distance is used to determine how aggressive we use the subtractive form
    # 1:  999 => CM XL IX  (-100 + 1000) + (-10 + 100) + (-1 + 10)
    # 2:  999 => XM IC     (-10 + 1000) + (-1 + 100)
    # 3:  999 => IM        (-1 + 1000)
  SUBTRACTIVE_FORM_HALF=FALSE
    # 1:  499 => CD XL IX  (-100 + 500) + (-10 + 100) + (-1 + 10)
    # 2:  499 => XD IX     (-10 + 500)  + (-1 + 10)
    # 3:  499 -> ID        (-1 + 500)

EXCEL_FORM=
#0: SUBTRACTIVE_FORM_HALF=MUTE  SUBTRACTIVE_FORM_DISTANCE=1
#1: SUBTRACTIVE_FORM_HALF=TRUE  SUBTRACTIVE_FORM_DISTANCE=1
#2: SUBTRACTIVE_FORM_HALF=FALSE SUBTRACTIVE_FORM_DISTANCE=2
#3: SUBTRACTIVE_FORM_HALF=TRUE  SUBTRACTIVE_FORM_DISTANCE=2
#4: SUBTRACTIVE_FORM_HALF=TRUE  SUBTRACTIVE_FORM_DISTANCE=3




RN_OFS=" "
# 1. STANDARD, CLASSIC 
#    - SUBTRACTIVE_FORM=TRUE
#    - HALF_FORM=TRUE
#    - SUBTRACTIVE_FORM_DISTANCE= {0, 1}
#    - SUBTRACTIVE_FORM_8=FALSE
# 2. ADDITIVE_ONLY
#    - SUBTRACTIVE_FORM=FALSE
#    - HALF_FORM=TRUE
#    - SUBTRACTIVE_FORM_DISTANCE= {0,1}
# 3. OPTIMAL= (SIMPLIED == OPTIMAL=4)
#    - SUBRACTIVE_FORM=TRUE
#    - HALF_FORM=TRUE
#    - SUBTRACTIVE_FORM_DISTANCE=

# FREE ENVIRONMENT VARABLES
#    SUBTRACTIVE_FORM_4=TRUE      # 4 = IV
#    SUBTRACTIVE_FORM_8=TRUE      # 8 = IIX
#    SUBTRACTIVE_FORM_9=TRUE      # 9 = IX 


function list2roman_xxx (){
  local count=${#}
  for num in "${@}" ; do
     arabic2roman_xxx ${num}
     echo -n "${RN_OFS}"
  done
  echo 
}


# arabic2roman:  by digits
function arabic2roman_xxx() {
  local number="$1"
  local count=${#number}

  local c d
  for ((c=0, d=${count}; c < ${count}; c++, d--)) ; do
    local digit=${number:$c:1}
    digit2roman $digit d
  done
}


function arabic2roman_algorithm() {
  local value="$1"

  local lower
  local upper
  local half
  local i
  local place

  for ((lower = RN_MAX_DIGIT_VALUE; lower > 1 ; lower = lower / 10 )); do
    if (( lower > value )) ; then
      continue
    fi

    (( upper = lower * 10 ))
    (( half  = lower * 5  ))
    
    (( place = 1 ))

    if [[ -n ${EXTENDED_SUBRACTION} ]] ; then
#   if ((DISTRANCE > 0))
#                        4   3   2  1  0
#     local distance=(1000 200 100 20 10)      
#     
#     max = distance[4 - DISTANCE]
#     for(( index=first, index <=1, index-- ))
#         i=distance[index]
#     ${max:0:1} != 1  -- for the FORM_8
#     local distance=(1000 500 200 100 50 20 10)
#
#    if [[ ${SUBTRACTIVE_FORM_8} == TRUE ]]
#        distance=(1000 500 200 100 50 20 10)
#        max=distance[6 - DISTANCE]
#    else
#        distance=(1000 200 100 20 10)
#                     4   3   2  1  0
#                ->   6   4   3  1  0
#        max = distance[4 - DISTANCE]
#    fi

# now an issue with HALF_FORM...
#

      # distance
      #        4  2   0 
      for i in 1 10 100  ; do

#        for j in ${distance[@]} ; do
#           if ((j > max_distance)) ; then
#             continue
#           fi
#           ((i = upper / j))

        if ((i >= lower)) ; then
          break 1
        fi

        if ((value + i >= upper )); then
          digit2roman 1 ${place} 
          digit2roman 1 ${#upper} 

          (( value = value - (upper - i) ))
          continue 2
        fi


        if [[ ${SUBTRACTIVE_FORM_8} == TRUE ]] ; then
          if ((value + i*2 >= upper )); then
            digit2roman 2 ${place} 
            digit2roman 1 ${#upper} 

            (( value = value - (upper - i*2) ))
            continue 2
          fi
        fi


        if (( value + i * 5 >= upper)) ; then 
          digit2roman 5 ${place}
          digit2roman 1 ${#upper}; 
          (( value = value - (upper - i*5) ))
          continue 2
        fi
       

        ##############################################
        if [[ HALF_FORM == TRUE ]] && ((value < half)) ; then
          if ((value + i >= half )); then
            digit2roman 1 ${place} 
            digit2roman 5 ${#half}

            (( value = value - (half - i) ))
            continue 2
          fi

          if [[ ${SUBTRACTIVE_FORM_8} == TRUE ]] ; then
            if ((value + i*2 >= half )); then
              digit2roman 2 ${place} 
              digit2roman 5 ${#half} 

              (( value = value - (half - i*2) ))
              continue 2
            fi
          fi

          if (( value + i * 5 >= half)) ; then 
#            echo $value $i $half $place $upper
            digit2roman 5 ${place}
            digit2roman 5 ${#half}
            (( value = value - (half - i * 5) ))
            continue 2
          fi
        fi
        ##############################################

        (( place ++ ))
      done
    fi

    digit2roman ${value:0:1} ${#value}
    (( value = value % lower ))
  done
  # This is the last digit, or zero
  digit2roman ${value:0:1} ${#value}
  # (( value = value % lower ))
  echo
}




function arabic2roman(){
  # Converts an arabic number to a roman number

  local number="$1"
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
      arabic2roman_algorithm ${number}
      ;;

    ( "VINCULUM" )
      (( group3 = number / 1000 / 1000 ))
      (( group2 = number / 1000 % 1000 ))
      (( group1 = number % 1000 ))

      local RN_MAX=999
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
      ;;
  
    ( "APOSTROPHUS" )
      declare -a units=( ${units_apostrophus[@]} )
      declare -a halfs=( ${halfs_apostrophus[@]} )

      arabic2roman_xxx ${number}

      declare -a units=( ${units_modern[@]} )
      declare -a halfs=( ${halfs_modern[@]} )      
      ;;

  esac
  echo
  return 0
}


function set_format () {
  local _format="$1"

  [[ -z ${_format} ]] && _format=STANDARD
  RN_FORMAT=${_format}
}

# MODERN, VINCULUM, EARLY, APOSTROPHUS
function set_style() {
  local _style="$1"
  
  [[ -z ${_style} ]] && _style=MODERN 

  RN_STYLE=${_style}

  local _max="RN_MAX_${_style}"
  RN_MAX=${!_max}
}


function set_defaults() {
  set_half_form TRUE
  set_subtractive_form TRUE
  set_style MODERN
  set_format 
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


function digit2roman() {
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





