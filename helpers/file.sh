
#
# Reads stdin into a variable, accounting for trailing newlines. Avoids
# needing a subshell or command substitution.
# Note that NUL bytes are still unsupported, as Bash variables don't allow NULs.
# See: https://stackoverflow.com/a/22607352/113632
#
# Arguments:
#   #1 [REQUIRED]  <VAR>    Variable to save content
#
function readFile() {
  # Use unusual variable names to avoid colliding with a variable name
  # the user might pass in (notably "contents")
  : "${1:?Must provide a variable to read into}"
  if [[ "$1" == '_line' || "$1" == '_contents' ]]; then
    echo "Cannot store contents to $1, use a different name." >&2
    return 1
  fi

  local _line _contents=()
   while IFS='' read -r _line; do
     _contents+=("$_line"$'\n')
   done
   # include $_line once more to capture any content after the last newline
   printf -v "$1" '%s' "${_contents[@]}" "$_line"
}

# Get last modification timestamp of file given file
function getLastModificationTime() {
  local modTimeFmt=
  if uname | grep -q "Darwin"; then
    modTimeFmt="-f %m"
  else
    modTimeFmt="-c %Y"
  fi
  ret=$(stat $modTimeFmt "$1")
}

# Get full elapsed time since last file modification divided into hours, minutes and seconds
function getModificationElapsedTime() {
  local currentTimeStamp=
  local diff=0
  hour=0
  minutes=0
  seconds=0

  getLastModificationTime "$1"
  currentTimeStamp=$(date +"%s") 
  
  (( diff=$currentTimeStamp-$ret ))
  hour=$((diff /60/60))
  minutes=$(((diff/60) % 60))
  seconds=$(($diff % 60))
}