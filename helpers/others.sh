# Other functions

#
# Resolve relative path to absolute
#
function dirResolve() {
  # cd to desired directory; if fail, quell any error messages but return exit status
  cd "$1" 2>/dev/null || return $? 
  # output full, link-resolved path
  echo "`pwd -P`" h
}

#
# Get package.json version
#
# Globals:
#   ret           The package.json version
#
function getPackageVersion() {
  ret=$(cat package.json | grep version | head -1 | awk -F: '{ print $2 }' | sed 's/[\",]//g' | sed 's/ //g')
}
