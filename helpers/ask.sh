# Prompts input question
# - askAndRemoveBranch : requires git-utils.sh


# DIR="${BASH_SOURCE%/*}"
# if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

# source "$DIR/git-utils.sh"


#
# Prompts yes/no input question.
#
# Arguments
#   #1  <string>  Question
# Returns:
#   1 for 'no' and 0 'yes'.
# Globals
#   answer        represents user answer ('y' or 'n' value)
#
function ask() {
  local yn
  ret=1
  stty sane
  while true; do
    echo -e "${log_PREFIX}$1"
    printf "${log_PREFIX}"
    read -p "(y/n) " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) break;;
        * ) echo -e "Please answer yes [y] or no [n].${log_RESET}"
        ;;
    esac
  done
  yn=$( echo "$yn" | tr '[:upper:]' '[:lower:]' )
  answer="$yn"
  if [[ $yn == "y" ]]; then
    ret=0
  fi
  return $ret;
}

#
# Ask for to confirm branch removal.
# If then given branch exists it will ask to user if can be removed.
#
# Arguments:
#   #1 [REQUIRED]  <string>  Branch name to be removed
#   #2             <string>  Checkout branch name
#
function askAndRemoveBranch() {
  local branchToRemove=$1
  local branchToCheckout=$2

  if ! existsLocalBranch "$branchToRemove"; then
    warn "Branch '$branchToRemove' already exists."
    if ! ask "Do you want to remove the $branchToRemove branch to continue the release process?"; then
      ret_stderr="To continue the release process, the local branch '$branchToRemove' should not exists.\n"
      return 2;
    fi
    removeBranch "$branchToRemove" "$branchToCheckout"
  fi
}