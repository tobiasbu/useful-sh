# Logger Helpers

###############################################################
# Constants
log_RESET="\x1B[0m"
log_BOLD="\x1B[1m"
log_DIM="\x1B[2m"
log_UNDERLINE="""\x1B[4m"

log_BLACK="\x1B[30m"
log_RED="\x1B[31m"
log_YELLOW="\x1B[33m"
log_BLUE="\x1B[34m"
log_MAGENTA="\x1B[35m"
log_CYAN="\x1B[36m"
log_GRAY="\x1B[37m"
log_DEFAULT="\x1B[39m"

log_LIGHT_GREEN="\x1B[92m"
log_LIGHT_YELLOW="\x1B[93m"
log_LIGHT_BLUE="\x1B[94m"
log_LIGHT_CYAN="\x1B[96m"
log_WHITE="\x1B[97m"

log_BG_RESET="\x1B[49m"
log_BG_CYAN="\x1B[46m"
log_BG_LIGHT_GRAY="\x1B[47m"
log_BG_DARK_GRAY="\x1B[100m"
log_BG_LIGHT_GREEN="\x1B[102m"
log_BG_WHITE="\x1B[107m"

log_PREFIX_TEXT="[log] "
log_PREFIX="${log_MAGENTA}${log_PREFIX_TEXT}${log_RESET}${log_BG_RESET}"
log_PREFIX_SPACER=$(repeat " " ${#log_PREFIX_TEXT})
log_LAST_MESSAGE=
log_LAST_LOG=
log_LAST_MESSAGE_TYPE=

answer=

###############################################################
# Implementation

# Stderr echo
function print_error() { 
  if [[ ! -z $2 ]]; then
    >&2 echo -ne "\r$1"
  else
    >&2 echo -e "$1"; 
  fi
  tput el
}

# Stdout echo
function print() { 
   if [[ ! -z $2 ]]; then
    echo -ne "\r$1"
  else
    echo -e "$1"
  fi
  tput el
}

# Reset logger prefix
function resetLogPrefix() {
  log_PREFIX="${log_MAGENTA}[log]${log_RESET}${log_BG_RESET}"
}

#
# Helper function to get a valid color.
# In case the color does not exist, it will return the default color.
#
# Arguments
#   #1  [REQUIRED]  <string>  Default color
#   #2  [REQUIRED]  <string>  Desired color
#
function getColor() {
  ret=$2
  if [[ ! -z "$1" ]]; then
    ret="log_$( echo "$1" | tr a-z A-Z )"
  fi
  if [[ -z "${!ret}" ]]; then
    ret=$2
  else
    ret=${!ret}
  fi
}

#
# Set logger prefix
#
# Arguments
#   #1 [REQUIRED]   <string>    Prefix string
#   #2              <string>    Prefix color
#
function setLogPrefix() {
  log_PREFIX_TEXT="$1"
  if [[ $2 -eq -1 ]]; then
    log_PREFIX="$log_PREFIX_TEXT"
  else
    getColor $2 $log_MAGENTA
    log_PREFIX="${ret}$log_PREFIX_TEXT${log_RESET}${log_BG_RESET}"
  fi
  log_PREFIX_SPACER=$(repeat " " ${#log_PREFIX_TEXT})
}

#
# Private - Common function to log messages
#
# Arguments
#   #1  <string>  Message
#   #2  <1 or 0>  Should use carriage return for console replacement?
#   #3  <string>  Prefix Style
#
function __loggerPrinter() {
  local prefixStyle=$3
  local isStderr=$4
  local suffixStyle="${log_RESET}${log_BG_RESET}"
  local msg="${log_PREFIX}${prefixStyle}$1${suffixStyle}"
  if [[ ! -z $isStderr ]]; then
    print_error "${msg}" "$2"
  else
    print "${msg}" "$2"
  fi
  log_LAST_MESSAGE=$1
  log_LAST_LOG=$msg
}

#
# Info/Debug log function
#
# Arguments
#   #1  <string>    Message
#   #2  <1 or 0>    Should use carriage return for console replacement?
#
function log() {
  __loggerPrinter "$1" "$2" ""
  log_LAST_MESSAGE_TYPE="log"
}

#
# Error log function
#
# Arguments
#   #1  <string>  Message
#   #2  <1 or 0>    Should use carriage return for console replacement?
#
function error() {
  local prefix=
  if [[ $log_LAST_MESSAGE_TYPE != "error" ]]; then
    prefix="${log_RED}${log_BOLD}ERROR: "
    log_LAST_MESSAGE_TYPE="error"
  else
    prefix="${log_RED}"
  fi

  __loggerPrinter "$1" "$2" "$prefix" 1
  
}

#
# Same as error function, but with no prefix
#
function errorNoPrefix() {
  __loggerPrinter "$1" "$2" "${log_RED}" 1
}

#
# Warning log function
#
# Arguments
#   #1  <string>  Message
#
function warn() {
  local prefix=
  if [[ $log_LAST_MESSAGE_TYPE != "warn" ]]; then
    prefix="${log_LIGHT_YELLOW}WARNING: "
    log_LAST_MESSAGE_TYPE='warn'
  else
    prefix="${log_LIGHT_YELLOW}"
  fi
  __loggerPrinter "$1" "$2" "${prefix}"
}

#
# Success log function
#
# Arguments
#   #1  <string>  Message
#
function success() {
  __loggerPrinter "$1" "$2" "${log_LIGHT_GREEN}"
  log_LAST_MESSAGE_TYPE='success'
}

#
# Print given string nth times
#
# Arguments:
#   #1 [REQUIRED]  <string>  String to be printed
#   #2 [REQUIRED]  <number>  Times to print
#
function repeat() {
  for (( i=0; i<$2; i++ )); do echo -ne "$1"; done 
}

function clearConsole() {
  tput clear
}

function saveCursor() {
  tput sc
}

function restoreCursor() {
  tput rc
}

