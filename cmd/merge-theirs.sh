#! /bin/bash

#
# Git Merge -theirs strategy
#
# Example usage:
#   ./merge-theirs.sh develop main 
#   ./merge-theirs.sh develop main --commit "Beautiful merge commit message"
#
# Arguments:
#   #1 [REQUIRED]  <string>  Source branch
#   #2 [REQUIRED]  <string>  Target branch
#   #3             <string>  Merge commit message
#
# Adapted from: https://stackoverflow.com/questions/173919/is-there-a-theirs-version-of-git-merge-s-ours/4969679#4969679
#

###############################################################
# Includes
SCRIPT_DIR_NAME=`dirname "$0"`
source "$SCRIPT_DIR_NAME/../helpers/args.sh"
source "$SCRIPT_DIR_NAME/../helpers/git-utils.sh"
source "$SCRIPT_DIR_NAME/../helpers/run.sh"

function usage() {
    echo "usage: merge-theirs <SOURCE_BRANCH> <TARGET_BRANCH> [-c <commit message>]"
    echo ""
    echo "  <SOURCE_BRANCH>  - #1 required argument"
    echo "      Specifies the source branch name"
    echo "  <TARGET_BRANCH>  - #2 required argument"
    echo "      Specifies the target branch name"
    echo "  -c <message>, --commit <message>"
    echo "      Defines custom commit message"
    echo "  -h, --help"
    echo "      Print this message"
}

function parseArgs() {
  case $1 in
    0 )           SOURCE_BRANCH="$2";;
    1 )           TARGET_BRANCH="$2";;
    c | commit )  COMMIT_MESSAGE="$2";;
    h | help )    usage
                  exit
                  ;;
  esac
}

argsparse parseArgs "$@"

if [[ -z "$SOURCE_BRANCH" ]]; then
  >&2 echo "Argument SOURCE_BRANCH is undefined";
  exit 1
fi

if [[ -z "$TARGET_BRANCH" ]]; then
  >&2 echo "Argument TARGET_BRANCH is undefined";
  exit 1
fi

if [[ -z "$COMMIT_MESSAGE" ]]; then
  COMMIT_MESSAGE="Merge '"$SOURCE_BRANCH"' into '"$TARGET_BRANCH"'"
fi

###############################################################
# Implementation
TEMP_SOURCE_BRANCH="local/temp/$SOURCE_BRANCH"

#
# Execute command
# If command fails abort program
#
function executeCommand() {
  if ! runSilently "$1"; then
    local errorMessage="Command "\"$1\"" failed:\n"$ret_std""
    >&2 echo -e "$errorMessage";

    # Before exiting, remove temp branch if exists
    removeBranch "$TEMP_SOURCE_BRANCH" "$TARGET_BRANCH"

    exit 1
  fi
  return $ret;
}

# Remove temp branch if exists
# Check if has local/temp/SOURCE_BRANCH branches
# We don't care about temp branch, so we can remove without asking
removeBranch "$TEMP_SOURCE_BRANCH" "$TARGET_BRANCH"

# Create a temp branch derived from SOURCE branch
executeCommand "createBranch "$TEMP_SOURCE_BRANCH" "$SOURCE_BRANCH""

# In case TARGET_BRANCH is not our current branch
executeCommand "git checkout "$TARGET_BRANCH" -q" 

# Do a merge commit. The content of this commit does not matter,
# so use a strategy that never fails.
# Note: This advances branchA.
executeCommand "git merge -s ours "$SOURCE_BRANCH" --no-edit -q" # B

# Change working tree and index to desired content.
# --detach ensures branchB will not move when doing the reset in the next step.
executeCommand "git checkout --detach "$SOURCE_BRANCH" -q" # B

# Move HEAD to branchA without changing contents of working tree and index.
executeCommand "git reset --soft "$TARGET_BRANCH" -q" # A

# 'attach' HEAD to branchA.
# This ensures branchA will move when doing 'commit --amend'.
executeCommand "git checkout "$TARGET_BRANCH" -q" # A

# Change content of merge commit to current index (i.e. content of branchB).
git commit -m "$COMMIT_MESSAGE" --no-verify -q

# Clean up
removeBranch "$TEMP_SOURCE_BRANCH" "$SOURCE_BRANCH"
