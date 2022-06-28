# Helper to draw progress bar
# TODO: improve documentation

# Vars
PROGRESS_BAR_COLOR="\x1B[92m"
PROGRESS_BAR_CHAR="\x1B[47m "
PROGRESS_BAR_CHAR_EMPTY="\x1B[49m "
PROGRESS_BAR_OFFSET="           "
PROGRESS_BAR_SIZE=24
PROGRESS_BAR_CURRENT=0
PROGRESS_BAR_ANIMATE=1

#
# Convert value to percentage
#
function toPercentage() {
  ret=$(echo "("$1"/"$2")*100" | bc -l)
  ret=$(echo "("$ret"+0.5)/1" | bc)
}

# Private function to draw progress bar
function __drawProgressBar() {
  local num_of_progress_items=$2
  printf "\r$PROGRESS_BAR_OFFSET"
  printf "〚 "
  printf "$PROGRESS_BAR_COLOR"

  for i in $(seq 0 $PROGRESS_BAR_SIZE)
  do
    if [[ $i -le $num_of_progress_items ]] && [[ $num_of_progress_items -gt 0 ]]; then
      printf "$PROGRESS_BAR_CHAR"
    else
      printf "$PROGRESS_BAR_CHAR_EMPTY"
    fi
  done

  printf "\x1B[0m"
  printf " 〛"
  if [[ $1 -gt 9 ]] && [[ $1 -lt 99 ]]; then
    printf " "
  elif [[ $1 -lt 10 ]]; then
    printf "  "
  fi

  printf "$1%%  "
  tput el
}


#
# Prints progress bar
#
function progressBar() {
  local timesToRedraw=1
  local step_size=$(( 100/$PROGRESS_BAR_SIZE ))
  local diff
  local num_of_progress_items

  if [[ $PROGRESS_BAR_ANIMATE -ne 0 ]]; then
    diff=$(( $1-$PROGRESS_BAR_CURRENT ))
    timesToRedraw=$(( ($diff/$step_size) + 1 ))
    if [[ $timesToRedraw -le 0 ]]; then
      timesToRedraw=1
    fi
  else
    PROGRESS_BAR_CURRENT=$1
  fi

  while [[ $timesToRedraw -ne 0 ]]; do
    # animated progression
    if [[ $PROGRESS_BAR_ANIMATE -ne 0 ]]; then
      if [[ $diff -gt 0 ]]; then
        PROGRESS_BAR_CURRENT=$(($PROGRESS_BAR_CURRENT+$step_size))
        if [[ $PROGRESS_BAR_CURRENT -gt $1 ]]; then
          PROGRESS_BAR_CURRENT=$1
          timesToRedraw=1
        fi
      fi
    fi

    num_of_progress_items=$(( $PROGRESS_BAR_CURRENT/$step_size ))  
    __drawProgressBar "$PROGRESS_BAR_CURRENT" "$num_of_progress_items"
    (( timesToRedraw -= 1 ))
    if [[ $PROGRESS_BAR_ANIMATE -ne 0 ]]; then
      sleep 0.016 # for animation only
    fi
  done
  
  PROGRESS_BAR_CURRENT=$1
}

#
# Clear progress bar
#
function endProgressBar() {
  PROGRESS_BAR_CURRENT=0
  printf "\r%s\n" "$@"
}