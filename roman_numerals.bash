#! /bin/bash

# lookup the glyphs for D, S, etc.

# Description:
#      This file contains a number of routines to support the 
# conversion of an Arabic number into its equivalent Roman
# number. The primary routine, "roman", is modeled after the 
# Microsoft's Excels "roman" function.

function print_usage_roman() {

  cat <<EOF
  roman [option] number [form]
    Converts "number" to classical (modern) Roman Numeral.
      (For other styles of Roman Numerals, see "arabic2roman".)
    Options:
      -h    Exclude the half forms: V, L, D, etc
      -4    Exclude the subtractive form for 4 (IV, XL, CD)
      -8    Include the subtractive form for 8 (IIX, IIC, IIM)
      -9    Exclude the subtractive form for 9 (IX, IC, IM)
    Number: 0..3,999, where max is dependent on the "style".
    Form: a number in the range 0..4, that specifies how
      aggressive the subtractive forms are used.
        0: a subtractive value can be   1/10 of the base, e.g., IX
        1: a subtractive value can be   1/20 of the base, e.g., VC
        2: a subtractive value can be  1/100 of the base, e.g., IC
        3: a subtractive value can be  1/200 of the base, e.g., VM
        4: a subtractive value can be 1/1000 of the base, e.g., IM

EOF

}



# An additional routine "arabic2roman" is included to provide
# additional styles of roman numerals.  The set of styles include:
#   Modern Roman Numerals (1..3999)
#   Vinculum Roman Numerals (1..999,999,999)
#   Early Roman Numerals (1..899)
#     - predates the introduction of M for 1000
#   Apostrophus Roman Numerals (1..399,999)
#     - an extension of early roman numbers
#     - the extension is based upon Etruscan numbers
#

function print_usage_arabic2roman() {

  cat <<EOF

  arabic2roman [option] number [form]
    Options:
      -s style 
            style = {modern, vinculum, early, apostrophus}
      -h    Exclude the half forms: V, L, D, etc
      -4    Exclude the subtractive form for 4 (IV, XL, CD)
      -8    Include the subtractive form for 8 (IIX, IIC, IIM)
      -9    Exclude the subtractive form for 9 (IX, IC, IM)
    Number: 0..max, where max is dependent on the "style"
      modern:      3,999
      vinculum:    999,999,999
      early:       899
      apostrophus: 399,999
    Form: a number in the range 0..4, that specifies how
      aggressive the subtractive forms are used.   
        0: a subtractive value can be   1/10 of the base, e.g., IX
        1: a subtractive value can be   1/20 of the base, e.g., VC
        2: a subtractive value can be  1/100 of the base, e.g., IC
        3: a subtractive value can be  1/200 of the base, e.g., VM
        4: a subtractive value can be 1/1000 of the base, e.g., IM
EOF

}

# We also include the routine, "roman_classic", which is a simpler
# implementation of the routine "roman".  The "roman" routine 
# provides additional support for more concise roman numbers.

function roman_classic() {
  local number="$1"

  while [[ -n "${number:0}" ]] ; do
    roman_digit ${number:0:1} ${#number}
    number=${number:1}
  done
  echo
}



## LIST of PRIMARY subroutines
#
# arabic2roman [options] number [form=0]
# roman number [form=0]
# roman_digit digit [place=0]
# roman_classic number

## LIST of SUPPORT routines
#
# roman_internal number
# roman_defaults_set
# roman_form_half_set
# roman_form_subtractive_set (TRUE | FALSE)
# roman_form_set  ( STANDARD | SIMPLIFIED ) [ number ]
#    roman_form_set STANDARD    == SIMPLIFIED=0
#    roman_form_set SIMPLIFIED  == SIMPLIFIED=4
# roman_style_set style


## STYLE-Dependent Information
RN_MAX_MODERN=3999           # M for '1000' was not in use until the Medieval period).
RN_MAX_VINCULUM=999999999    # Groups of xxx,yyy,zzz
declare -a units_text_modern=(           I           X           C          M    error)
declare -a units_glyphs_modern=( "&#x2160;"  "&#x2169;"  "&#x216D;"  "&#x216F;"  error)

declare -a halfs_text_modern=(           S           V           L          D    error)
declare -a halfs_glyphs_modern=(         S   "&#x2164;"  "&#x216C;"  "&#x216E;"  error)


RN_MAX_EARLY=899             
RN_MAX_APOSTROPHUS=399999    # Based upon Etruscan numbers
# APOSTROPHUS: "D",  a symbol resembling a reversed letter C used to denote large numbers

declare -a units_text_apostrophus=(           I          X          C        "(I)"    "((I))"  "(((I)))" error )
declare -a units_glyphs_apostrophus=( "&#x2160;" "&#x2169;" "&#x216D;"  "&#x2180;" "&#x2182;" "&#x2188;" error )
declare -a halfs_text_apostrophus=(           S          V          L         "I)"      "I))"     "I)))" error )
declare -a halfs_glyphs_apostrophus=(         S " &#x2164;" "&#x216C;"          D  "&#x2181;" "&#x2187;" error )


## STYLE-Independent Information
#
RN_STYLE=MODERN              # MODERN, VINCULUM, EARLY, APOSTROPHUS
RN_MAX=${RN_MAX_MODERN}
RN_MAX_DIGIT_VALUE=100000    # APOSTROPHUS: (((I)))

RN_FORM=STANDARD             # STANDARD, SIMPLIFIED
RN_MAX_SIMPLIFIED=4               

declare -a units=( ${units_text_modern[@]} )
declare -a halfs=( ${halfs_text_modern[@]} )
declare -a units_glyphs=( ${units_glyphs_modern[@]} )
declare -a halfs_glyphs=( ${halfs_glyphs_modern[@]} )

declare RN_MAX_DENOMINATOR_DEFAULT=10
declare RN_MAX_DENOMINATOR=${RN_MAX_DENOMINATOR_DEFAULT}
declare -a RN_DENOMINATORS=( 1000 500 200 100 50 20 10 )
declare -a RN_EXCEL_DENOMINATORS=( 1000 200 100 20 10 )
  # The denominator is used to determine how aggressive the subtractive form is applied
  # Excel Form range: 0..4
  # ---------
  # 0: 10   |   9 => IX  |  1/10   * 10   = 1   | (-1 + 10   =   9)  [DEFAULT]
  # 1: 20   |  95 => VC  |  1/20   * 100  = 5   | (-5 + 100  =  95)
  # -:      |  98 => IIC |  1/50   * 100 = 2    | (-2 + 100  =  98)
  # 2: 100  |  99 => IC  |  1/100  * 100  = 1   | (-1 + 100  =  99)
  # 3: 200  | 995 => VM  |  1/200  * 1000 = 5   | (-5 + 1000 = 995)
  # -:      | 998 => IIM |  1/500  * 1000 = 2   | (-2 + 1000 = 998)
  # 4: 1000 | 999 => IM  |  1/1000 * 1000 = 1   | (-1 + 1000 = 999)
  #
  # https://support.microsoft.com/en-us/office/roman-function-d6b0b99e-de46-4704-a518-b45a0f8b56f5
  #

# Format Variants: These are the DEFAULTS
RN_HALF_FORM=TRUE                 # TRUE ->  V, L, D
RN_SUBTRACTIVE_FORM=TRUE
  RN_SUBTRACTIVE_FORM_4=TRUE      # TRUE= "IV",   otherwise:   "IIII"
  RN_SUBTRACTIVE_FORM_8=FALSE     # FALSE="VIII", otherwise:    "IIX"
  RN_SUBTRACTIVE_FORM_9=TRUE      # TRUE= "IX",   otherwise:  "VIIII"



function roman() {

  OPTIND=1   # Restart getopts
  while getopts h489 option ; do
    case ${option} in
      (h) roman_form_half_set FALSE   ;;
      (4) RN_SUBTRACTIVE_FORM_4=FALSE ;;
      (8) RN_SUBTRACTIVE_FORM_8=TRUE  ;;
      (9) RN_SUBTRACTIVE_FORM_9=FALSE ;;
      (\?) { 
             echo "Error: Invalid option" ;
             print_usage_roman ;
           } > /dev/stderr
           return 1
           ;;
    esac
  done
  shift $(( OPTIND - 1 ))

  local number="${1:-0}"
  local form="${2:-0}"

  if (( number > ${RN_MAX} )) ; then
    {
      echo "Error: Given number is too large"
      echo "Style: $RN_STYLE"
      echo "Max:   $RN_MAX"
    } > /dev/stderr
  fi

  RN_MAX_DENOMINATOR=${RN_EXCEL_DENOMINATORS[4-${form}]}

  roman_internal ${number}
  echo
  return 0
}


function roman_internal() {
  local value="${1:-0}"

  local lower
  local upper
  local half

  for ((lower = RN_MAX_DIGIT_VALUE; lower > 1 ; lower = lower / 10 )); do
    local denominator
    local i

    if (( lower > value )) ; then
      continue
    fi

    (( upper = lower * 10 ))
    (( half  = lower * 5  ))


    # Following handles the Extended Subtractive forms
    if (( ${RN_MAX_DENOMINATOR} > 0 )) ; then 
      for denominator in ${RN_DENOMINATORS[@]} ; do
        (( denominator > RN_MAX_DENOMINATOR )) && continue 

        # skip over non-applicable denominators
        case "${denominator:0:1}" in
          1 ) :                                                   ;; # 1/10xxx
          2 ) [[ ${RN_HALF_FORM} == FALSE ]] && continue          ;; # 1/2xxxx
          5 ) [[ ${RN_SUBTRACTIVE_FORM_8} == FALSE ]] && continue ;; # 1/5xxxx
          * ) { 
                echo "Internal Error: unsupported denominator: ${denominator}"
              } > /dev/stderr
              return 2
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

        if [[ ${RN_HALF_FORM} == TRUE ]] && ((value < half)) ; then
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

  # This is the remaining single digit or zero
  roman_digit ${value:0:1} ${#value}
}



function arabic2roman(){
  # Converts an arabic number to a roman number

  local option
  OPTIND=1   # Restart getopts
  while getopts s:mveah489 option ; do
    case ${option} in
      ( s | m | v | e | a )
          [[ ${option} == "s" ]] && option=${OPTARG}
          case ${option} in
            (m | modern)       roman_style_set MODERN      ;;
            (v | vinculum)     roman_style_set VINCULUM    ;;
            (e | early)        roman_style_set EARLY       ;;
            (a | apostrophus)  roman_style_set APOSTROPHUS ;;
            (*) { echo "Error: Unknown style" ;
                  echo "Usage: -s ( modern | vinculum | early | apostrophus )" ;
                  echo "       -m  # For modern" ;
                  echo "       -v  # For vinculum" ;
                  echo "       -e  # For early" ;
                  echo "       -a  # For apostrophus" ;
                } > /dev/stderr
                return 1 
                ;;
          esac
          ;;
      ( h ) roman_form_half_set FALSE   ;;
      ( 4 ) RN_SUBTRACTIVE_FORM_4=FALSE ;;
      ( 8 ) RN_SUBTRACTIVE_FORM_8=TRUE  ;;
      ( 9 ) RN_SUBTRACTIVE_FORM_9=FALSE ;;
      ( \ ?) { 
             echo "Error: Invalid option" ;
             print_usage_arabic2roman ;
           } > /dev/stderr
           return 1
           ;;
    esac
  done
  shift $(( OPTIND - 1 ))

  local number=${1}
  local form="${2:-0}"

  [[ -z ${number} ]] && { print_usage_arabic2roman  > /dev/stderr ; return 1 ; }
  (( ${form} != 0 )) && 
    roman_form_set SIMPLIFIED ${form}

  if ((number > RN_MAX)) ; then
    { 
      echo "Error: Given number exceeds max for ${RN_STYLE} style"
      echo "Maximum Number: ${RN_MAX}" ;
    } > /dev/stderr
    return 1
  fi
  if ((number == 0)) ; then
    echo nila
    return 1
  fi


  local group3 group2 group1
  case ${RN_STYLE} in
    ( "EARLY"  | "MODERN" ) 
      roman_internal ${number} ${form}
      ;;

    ( "VINCULUM" )
      #  vinculum: &#x305;
      #  vertical bar: &#x7c;
      #  <vinculum>|xxxx|<vinculum>  <vinculum>yyy<vinculum> zzz

      (( group3 = number / 1000 / 1000 ))
      (( group2 = number / 1000 % 1000 ))
      (( group1 = number % 1000 ))

      local RN_MAX=999
      if (( group3 > 0 )) ; then
        echo -n "<vinculum>|"
        echo -n $(roman_internal ${group3} ${form})
        echo -n "|<\vinculum>"
        echo -n " "
      fi 
      if (( group2 > 0 )) ; then
        echo -n "<vinculum>"
        echo -n $(roman_internal ${group2} ${form})
        echo -n "<\vinculum>"
        echo -n " "
      fi  
      roman_internal ${group1} ${form}
      ;;
  
    ( "APOSTROPHUS" )
      # "D" a symbol resembling a reversed letter C used in Roman numerals to denote large numbers

      declare -a units=( ${units_text_apostrophus[@]} )
      declare -a halfs=( ${halfs_text_apostrophus[@]} )

      roman_internal ${number} ${form}

      declare -a units=( ${units_text_modern[@]} )
      declare -a halfs=( ${halfs_text_modern[@]} )      
      ;;
      
    ( * )
      {
        echo "Internal Error: Unknown styler" ;
      } > /dev/stderr
      return 2
      ;;
  esac
  echo
  return 0
}


#####################
# Support Routines
#####################
function roman_defaults_set() {
  roman_form_subtractive_set TRUE
  roman_form_half_set        TRUE
  roman_form_set             STANDARD
  roman_style_set            MODERN
}

function roman_form_half_set() {
  local value="$1"

  RN_HALF_FORM=TRUE
  if [[ $value == FALSE ]] ; then
    RN_HALF_FORM=FALSE
    RN_SUBTRACTIVE_FORM_4=FALSE   # IV is not valid
  fi
}

function roman_form_subtractive_set() {
  local value="${1}"

  RN_SUBTRACTIVE_FORM=TRUE      
  RN_SUBTRACTIVE_FORM_4=TRUE      # 4 = IV
  RN_SUBTRACTIVE_FORM_8=FALSE     # 8 = VIII
  RN_SUBTRACTIVE_FORM_9=TRUE      # 9 = IX 
  if [[ ${value} == FALSE ]] ; then
    RN_SUBTRACTIVE_FORM=FALSE      
    RN_SUBTRACTIVE_FORM_4=FALSE   # 4 = IIII
    RN_SUBTRACTIVE_FORM_8=FALSE   # 8 = VIII
    RN_SUBTRACTIVE_FORM_9=FALSE   # 9 = VIIII
  fi 
}

function roman_form_set() {
  local form="${1:-STANDARD}"
  local number="${2:-${RN_MAX_SIMPLIFIED}}"

  case $form in
    ( STANDARD | CLASSIC )
      number=0;
      ;;
    ( SIMPLIFIED ) 
      ;;
    ( * )
      { echo "Error: Invalid form" ;
        echo "Usage: roman_form_set (STANDARD | SIMPLIFIED)" ;
      } > /dev/stderr
      return 1
      ;;
  esac
  if (( number > RN_MAX_SIMPLIFIED )) ; then
    {  echo "Error: Invalid number" ;
       echo "Usage: roman_form_set SIMPLIFIED (0..4)" ;
    } > /dev/stderr
    return 1
  fi

  RN_FORM=${form}
  if [[ ${RN_FORM} == "SIMPLIFIED" ]] ; then
    local index
    (( index = RN_MAX_SIMPLIFIED - number))
    RN_MAX_DENOMINATOR=${RN_EXCEL_DENOMINATORS[index]}
  else
    RN_MAX_DENOMINATOR=${RN_MAX_DENOMINATOR_DEFAULT}
  fi
}

# MODERN, VINCULUM, EARLY, APOSTROPHUS
function roman_style_set() {
  local style="${1:-MODERN}"
  
  case "$style" in
    ( MODERN | VINCULUM | EARLY | APOSTROPHUS )
        RN_STYLE=${style}
        ;;
    ( * )
      { echo "Error: Invalid style" ;
        echo -n "Usage: roman_style_set" ;
        echo    " ( MODERN | VINCULUM | EARLY | APOSTROPHUS )" ;
      } > /dev/stderr
      return 1
      ;;
  esac

  local max="RN_MAX_${style}"
  RN_MAX=${!max}
}



roman_defaults_set


function roman_digit() {
  local digit=$1
  local place=$2

  if [[ -z ${place} ]] ; then
    place=1
  fi

  local full=${units[place]}
  local half=${halfs[place]}
  local unit=${units[place-1]}

  if [[ ${RN_HALF_FORM} == FALSE ]] ; then
    half="${unit}${unit}${unit}${unit}${unit}"
  fi

  case ${digit} in
    ( 1|2|3 )
      local i
      for ((i = digit; i>0; i--)) ; do
        echo -n "${unit}"
      done
      ;;

    ( 4 )
      if [[ ${RN_SUBTRACTIVE_FORM_4} == FALSE ]] || [[ ${RN_HALF_FORM} == FALSE ]]  ; then 
        echo -n "${unit}${unit}${unit}${unit}"
      else
        echo -n "${unit}${half}"        
      fi
      ;;

    ( 5 )
      echo -n "${half}"
      ;;

    ( 6 | 7 )
      echo -n "${half}${unit}"
      if (( digit == 7 )) ; then
        echo -n "${unit}"
      fi
      ;;

    ( 8 )
      if [[ ${RN_SUBTRACTIVE_FORM_8} == TRUE ]] ; then
        echo -n "${unit}${unit}${full}" 
      else
        echo -n "${half}${unit}${unit}${unit}"
      fi
        ;; 

    ( 9 )
      if [[ ${RN_SUBTRACTIVE_FORM_9} == TRUE ]] ; then 
        echo -n "${unit}${full}"
      else
        echo -n "${half}${unit}${unit}${unit}${unit}"
      fi
      ;;
    ( * )
      {
        echo "Internal Error: Invalid digit" ;
      } > /dev/stderr
      ;; 
  esac
}



