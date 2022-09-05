# Helper script to parse arguments 

#
# Read arguments and parse to global vars.
# Unnamed arguments will be append by position.
#
# Arguments
#   #2  {(arg_name, arg_value, index) => void}  Optional - user-defined function to be called for ach parsed argument
#   #1  {string[]}                              Arguments to be parsed
# Globals:
#   ARGS            list of parsed arguments
#   ARGS_VALUES     values of argument defined with = sign (ex: myarg=someValue)
#   ARGS_LENGTH     arguments length
#
# Usage:
#  ```
#  #!/bin/bash
#
#  function parseMyArgs() {
#    echo "name: $1 | value: $2 | index: $3"
#  }
#
#  argsparse parseMyArgs "$@"
#  ````
#
function argsparse() {
    local args=("$@")
    local earchArgFn=
    local isFirstFunc=$(declare -F "$1" 2>/dev/null)
    
    if [[ -n $isFirstFunc ]]; then
        earchArgFn=${args[0]}
        args=("${args[@]:1}")
    fi

    local regex="^--?([^[:space:]=]*)(=([^[:space:]]*))?"
    local counter=0
    local current=
    local nextArg=
    local val

    ARGS_LENGTH=${#args[@]}
    ARGS=()
    ARGS_VALUES=()
    while [ $counter -lt $ARGS_LENGTH ]; do
        current=${args[counter]}
        
        if [[ ${current:0:1} == "-" ]]; then
            if [[ $current =~ $regex ]]; then
                ARGS+=("${BASH_REMATCH[1]}")
                if [[ -n "${BASH_REMATCH[2]}" ]]; then
                    val=${BASH_REMATCH[2]}
                    ARGS_VALUES+=(${val#"="}) # remove equal sign
                    (( counter+=1 ))
                    continue
                fi
                
            else
                ARGS+=("$current")
            fi

            nextArg=${args[(( counter+1 ))]}
            if [[ ${nextArg:0:1} != "-" ]]; then
                val="$nextArg"
                (( counter+=2 ))
            else
                val=""
                (( counter+=1 ))
            fi
            ARGS_VALUES+=("$val")
        else
            ARGS+=($counter)
            ARGS_VALUES+=("$current")
            (( counter+=1 ))
        fi
    done
    ARGS_LENGTH=${#ARGS[@]}

    if [[ -n $earchArgFn ]]; then
        for (( i=0; i<$ARGS_LENGTH; i++ )); do
            $earchArgFn "${ARGS[i]}" "${ARGS_VALUES[i]}" "$i"
        done
        return 1
    fi
    return 0
}
