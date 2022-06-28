# Git utilities 
# Requires run.sh

#
# Get current branch name
#
# Returns:  
#   If operation was successful returns 0, otherwise 1.
#
# Globals:
#   ret     Branch name
#
function getCurrentBranch() {
  if ret=$(git symbolic-ref --short -q HEAD); then
    return 0;
  fi
  return 1;
}

#
# Check if the HEAD pointer is detached
#
# Returns:  
#   If is detached returns 0, otherwise 1.
#
# Globals:
#   ret     Branch name. 'HEAD' indicates detached head
#
# See: https://www.git-tower.com/learn/git/faq/detached-head-when-checkout-commit/
#
function isDetachedHead() {
  ret=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)
  if [[ "$ret" -eq "HEAD" ]]; then
    return 0;
  fi
  return 1;
}

#
# Create a branch based in given base branch
# If operation fails the program will be aborted.
#
# Arguments:
#   #1 [REQUIRED]  <string>  Branch name to create
#   #2 [REQUIRED]  <string>  Base branch name
#
function createBranch() {
  local branchToCreate=$1
  local baseBranch=$2
  if ! runSilently "git branch "$branchToCreate" "$baseBranch" --quiet"; then
    ret_std="Could not create '$branchToCreate' branch:\n${ret_std}"
    return 1
  fi
}


# Check if local repository a branch exists
function existsLocalBranch() {
  local branch=$1
  if [ -n "`git branch --list $branch`" ]; then
    return 1
  fi
  return 0
}

# Check if in local repository an remote ref branch exists
# Consider first call 'git fetch --prune' before this command
function existsRemoteBranchLocally() {
  local branch=$1
  ret_std=$(git branch -r -l "$branch")
  if [ -z $ret_std ]; then
    return 1
  fi
  return 0
}

# Check if remote origin exists given branch
function existsRemoteBranch() {
  local branch=$1
  git ls-remote --exit-code --heads origin ${branch}
  # Exit with status "2" when no matching refs are found in the remote repository
  local branchExists=$?
  if [[ "$branchExists" -eq "2" ]]; then
    return 0
  fi
  return 1  
}

#
# Remove a branch.
# If the HEAD is pointing to the branch that will be removed,
# it will checkout to "develop".
#
# Arguments:
#   #1 [REQUIRED]  <string>  Branch name to be removed
#   #2             <string>  Checkout branch name (default: "developer")
#
function removeBranch() {
  local branchToRemove=$1
  local branchToCheckout=$2

  if ! existsLocalBranch "$branchToRemove"; then
    if [[ ! -z branchToCheckout ]]; then
      branchToCheckout="develop"
    fi

    getCurrentBranch
    if [[ "$ret" == "$branchToRemove" ]]; then
      if ! runSilently "git checkout $branchToCheckout"; then
        ret_stderr="Could not checkout to '$branchToCheckout'"
        return 1;
      fi
    fi
    if ! runSilently "git branch -D "$branchToRemove""; then
      ret_stderr="Unexpected error happened while removing '$branchToRemove' branch"
      return 1;
    fi
  fi
}

