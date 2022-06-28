#!/bin/bash

#
# Validates application versioning based in Semantic Versioning 2.0.0
#
# Example usage:
#   ./semver.sh 7.1.2
#
# Arguments:
#   #1 [REQUIRED]  <string>  Version to be test 
#
# Returns:
#  If an exception was throw will return 1, otherwise 0.
#
# You should pass valid version following Semantic Versioning 2.0.0 format (SEMVER).
# The SEMVER format follows by MAJOR.MINOR.PATCH (ie. 7.7.4)
# For more information read: https://semver.org/
#

# Check if user passed an argument
if [[ -z "$1" ]]; then
  >&2 echo -e "semver: Invalid version supplied. Please provide version argument following semver rules."   
  exit 1
fi

# Check if the provided argument follows the SEMVER rules
if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  exit 0
else
  >&2 echo -e "semver: The provided version does not follow semver rule (ie. 1.2.3)" >&2
  exit 1
fi
