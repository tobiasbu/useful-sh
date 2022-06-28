# Helpers to run commands without outputing to console messages or/and catching only errors

#
# Execute command with stdout and stderr indirection.
# Command will not print messages or errors
#
# Arguments:
#   #1 [REQUIRED]  <string | ...args[]>  The command to be execute silently
# Returns:  
#   If command fails returns 1, otherwise 0.
# Globals:
#   ret           Same has return value
#   ret_std       Represents the command stdout, stderr or both.
#
function runSilently() {
  ret_std=""
  local commandExec=
  if [ "$#" -gt 1 ]; then
    commandExec=("$@")
    if ret_std=$(${commandExec[@]} 2>&1); then
      ret=0
    else
      ret=1
    fi
  else
    commandExec="$1"
    if ret_std=$($commandExec 2>&1); then
      ret=0
    else
      ret=1
    fi
  fi

  return $ret;
}

#
# Execute command with stderr indirection.
# Command will print messages but no errors
#
# Arguments:
#   #1 [REQUIRED]  <string | ...args[]>  The command to be execute silently
# Returns:  
#   If command fails returns 1, otherwise 0.
# Globals:
#   ret           Same has return value
#   ret_std       Represents the command stderr.
#
function runAndCatch() {
  ret_std=""
  local commandExec="$1"
  if [ "$#" -gt 1 ]; then
    commandExec=("$@")
    if { ret_std=$(${commandExec[@]} 2>&1 >&3 3>&-); } 3>&1; then
      ret=0
    else
      ret=1
    fi
  else
    commandExec="$1"
    if { ret_std=$($commandExec 2>&1 >&3 3>&-); } 3>&1; then
      ret=0
    else
      ret=1
    fi
  fi

  return $ret;
}

#
# Execute command with stderr indirection
# Command will not print any messages
#
# Arguments:
#   #1 [REQUIRED]  <string | ...args[]>  The command to be execute silently
# Returns:  
#   If command fails returns 1, otherwise 0.
# Globals:
#   ret           Same has return value
#   ret_std       Represents the command stderr.
#
function runAndCatchOnly() {
  ret_std=""
  local commandExec="$1"
  if [ "$#" -gt 1 ]; then
    commandExec=("$@")
    if ret_std=$(${commandExec[@]} 2>&1 >/dev/null); then
      ret=0
    else
      ret=1
    fi
  else
    commandExec="$1"
    if ret_std=$($commandExec 2>&1 >/dev/null); then
      ret=0
    else
      ret=1
    fi
  fi

  return $ret;
}