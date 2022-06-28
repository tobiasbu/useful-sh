# Helper script to parse arguments 

#
# Read arguments and parse to global vars.
# Unnamed arguments will be append by position.
#
# - ARGS = list of passed arguments
# - ARGS_VALUES = values of argument defined with = sign (ex: myarg=someValue)
# - ARGS_LENGTH = arguments length
#
function parseArgs() {
  local args=("$@")
  local arg=${args[0]}
  local nextArg=
  local counter=0
  ARGS_LENGTH=${#args[@]}
  local regex="^--?([^[:space:]]*)"
  ARGS=()
  ARGS_VALUES=()
  while [ $counter -lt $ARGS_LENGTH ]; do
    arg=${args[counter]}
    
    if [[ ${arg:0:1} == "-" ]]; then
      if [[ $arg =~ $regex ]]; then
        ARGS+=("${BASH_REMATCH[1]}")
      else
        ARGS+=("$arg")
      fi
      nextArg=${args[(( counter+1 ))]}
      if [[ ${nextArg:0:1} != "-" ]]; then
        ARGS_VALUES+=("$nextArg")
        (( counter+=2 ))
      else
        ARGS_VALUES+=("")
        (( counter+=1 ))
      fi
    else
      ARGS+=($counter)
      ARGS_VALUES+=("$arg")
      (( counter+=1 ))
    fi
  done
  ARGS_LENGTH=${#ARGS[@]}
}

#
# Convenience function to pass each parsed argument and call user-defined function.
#
function eachArg() {
  local parseFn=$1
  for (( i=0; i<=$ARGS_LENGTH; i++ )); do
    $parseFn "${ARGS[i]}" "${ARGS_VALUES[i]}" "$i"
  done
}