#! /bin/bash

read num
num_digits=${#num}
c=$num_digits
value=0

for(c=$num_digits; c>=0; c--) ; do
  if (num == 0) break;
  digit = ${num:0:1}
  print_digit($digit)
done



declare -a roman_array=(
  "I--"  "XVI"  "CLX"   "MDX"
)

function roman_digit() {
  digit=$1
  array=$2
  if [[ -z ${array} ]] ; then
    place=${roman_array[1]}
  fi

  unit=${place:0:1}           
  half=${place:1:1}
  base=${place:2:1}

  case ${digit} in
    1|2|3 )
      for((i = digit; i>0; i--)) ; do
        echo -n ${base}
      done
      ;;

    4 )
      echo -n "${base}${half}"
      ;;

    5 | 6 | 7 )
        echo -n "${half}"
        for((i= digit - 5 ; i>0; i--)) ; do 
          echo -n "${base}"
        done
        ;;
    8 )
        # if !  8-subtraction
            echo -n "${half}${base}${base}${base}"
        # else
        #   echo -n "${base}${base}${unit}" 
        ;; 

    9 )
        echo -n "${base}"
        echo -n "${unit}"
        ;;
  esac

}




