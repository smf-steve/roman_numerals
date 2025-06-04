#! /bin/bash


declare -a roman_numeral_values=( 1000 500 100 50 10 5 1 )
declare -a roman_numeral_glyphs=( M D C L X V I )

# Least Nearest Value
# Returns -1 if there is no appropriate value
function nearest_values () {
  local value="$1" ; shift
  local table=( "$@" )

  [[ -z "${table}" ]] && table=( "${roman_numeral_glyphs[@]}" )

  table_size=${#table[@]}

  lnv=-1;

  local i
  for ((i=0; i < ${table_size}; i++ )); do
    if [[ value -le table[i] ]] ; then
      break;
    fi
    lnv=${table[i]}
  done
  if (( i == table_size )) ; then
    gnv=-1  # $value
  else
    gnv=${table[i]}
  fi

  if ((gnv == value)) ; then
    lnv=$value
  fi
  echo "$lnv $gnv"
}


# Subtractive only
# Additive only
# Optimal

# This is a combined... well almost
# interatively drive
#   - obtain the biggest box that is smaller than needed
function greedy () {
  local value="$1"
  local t

  while ((value > 10)) ; do
    t=${value:1}
    if (( t == 0 )) ; then
      digit2roman ${value:0:1} ${#value}
      break 
    fi 2>/dev/null

    t=( $(nearest_values $value) )
    (( A = value - t[0] ))
    (( B = t[1] - value ))
    #echo ${t[0]}, $A : ${t[1]} $B
    value=$A

    digit2roman ${t[0]:0:1} ${#t[0]}
  done
  digit2roman ${value}
  echo

}


function simpler_1 () {
  local value="$1"

  local i
  for i in 1000 500 100 50 10 ; do
    if (( i > value )) ; then
      continue
    fi
    while (( value >= i )) ; do
      if (( i == 0 )) ; then
        return;
      fi

      t=${value:1}
      # Need a better way to determine if the 
      # value = 10 ^n
      # If t = "0000" then it is
      # if t = "002" then it is not
      # if t = "09" then t is not a valid number
      if (( t == 0 )) ; then
        # If it is zero we can use the extended_subractive form
        # if it is ! zero, only do this if we have extended subtractive form as true
        digit2roman ${value:0:1} ${#value}
        (( value = 0 )) 
        # here we are done
        # we could short circuit or
        # do a better control flow
      else
        digit2roman ${i:0:1} ${#i} 
        (( value = value - i ))
      fi 2>/dev/null
    done
  done
  if (( value != 0 )) ; then 
    # We must have used a extended subtractive form..
    digit2roman $value
  fi

  echo
}



function simpler_2 () {
  local value="$1"

  local i
  local j
  i=1000
  for j in 1000 500 100 50 10 ; do
    if (( i > value )) ; then
      continue
    fi
    while (( value >= i )) ; do
      if (( i == 0 )) ; then
        return;
      fi

      t=${value:1}
      if (( t == 0 )) ; then
        digit2roman ${value:0:1} ${#value}
      else
        digit2roman ${i:0:1} ${#i} 
      fi


      (( value = value - i ))
      i=$j
    done
  done
  digit2roman ${value}
  echo
}

