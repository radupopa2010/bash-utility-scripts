#!/bin/bash

# The purpose of this script is to 

# The long options name is more readable as `set -eou pipefail`
set errexit
set nounset
set option-name pipefail

SCRIPt_NAME="$0"
SCRIPT_PATH=$(dirname "$0")               # relative
SCRIPT_PATH=$(cd "${SCRIPT_PATH}" && pwd) # absolutized and normalized

function usage {
  cat << EOF
Usage: ${SCRIPt_NAME} OPTION

OPTION can be one of -l, --local or -c, --container, but not both.
OPTION 
  -l, --local        Run script on localhost
  -c, --container    Run script inside a container
  -t, --testdir DIR  Specify which tests to run   

EXAMPLES
${SCRIPt_NAME} -l -t features
${SCRIPt_NAME} --local --testdir=features
${SCRIPt_NAME} -c -t features
${SCRIPt_NAME} --container --testdir=features

EOF
}

function die { 
  # complain to STDERR and exit with error
  echo -e "$*" >&2; exit 2; 
}  

function log {
  local lvl msg fmt
  lvl=$1 msg=$2
  fmt='+%Y-%m-%d %H:%M:%S'
  lg_date=$(date "${fmt}")
  if [[ "${lvl}" = "DIE" ]] ; then
    lvl="ERROR"
   echo "${lg_date} - ${lvl} - ${msg}"
   exit 1
  else
    echo "${lg_date} - ${lvl} - ${msg}"
  fi
}

function needs_arg { 
  if [ -z "$OPTARG" ]; then 
    die "No arg for --$OPT option" 
  fi
}

function parse_args {
  while getopts clt:-: OPT; do
    # support long options: https://stackoverflow.com/a/28466267/519360
    if [ "$OPT" = "-" ]; then   # long option: reformulate OPT and OPTARG
      OPT="${OPTARG%%=*}"       # extract long option name
      OPTARG="${OPTARG#$OPT}"   # extract long option argument (may be empty)
      OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
    fi
    # shellcheck disable=SC2214
    case "$OPT" in
      l | local )      RUN_LOCAL=true ;;
      c | container )  RUN_CONTAINER=true ;;
      t | testdir )    needs_arg ; TEST_DIR="${OPTARG}" ;;
      ??* )            die "Illegal option --$OPT" ;;  # bad long option
      ? )              exit 2 ;;  # bad short option (error reported via getopts)
    esac
  done
  shift $((OPTIND-1)) # remove parsed options and args from $@ list

  check_args
}

function check_args {

  if ${RUN_LOCAL} && ${RUN_CONTAINER} ; then
    die "ERROR: Only one of -l, --local or -c, --conatiner falgs can be set\n\n$(usage)"
  elif ! ${RUN_LOCAL} && ! ${RUN_CONTAINER} ; then
    die "ERROR: At least one of -l, --local or -c, --conatiner falgs must be set\n\n$(usage)"
  fi

  if [[ -z "${TEST_DIR}" ]] ; then
    die "ERROR: Must specify 'testdir' argument to script \n\n$(usage)"
  fi
}

function is_empty_dir {
  local dir_path=$1
  ! find "${dir_path}" -mindepth 1 -print -quit | grep -q .
}

 function random_string {                                                                  
   # Generate random string                                                                
   tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 20 | head -1                                
 }

#
### How to section
#

# Best tips for bash https://mywiki.wooledge.org/BashFAQ

# Process files in a safe way:
while read -r -d $'\0' file_name; do                                                      
 # do stuff with file_name
 echo "${file_name}"
 file_name_patern=""
done < <(find . -regextype posix-egrep -regex ".*(${file_name_patern})" -type f -print0)


# Process files line by line https://mywiki.wooledge.org/BashFAQ/001
while read -r  line; do
  # do stuff with line
  echo "${line}"
done < some_file.txt


function log {
  local lvl msg fmt
  lvl=$1 msg=$2
  fmt='+%Y-%m-%d %H:%M:%S'
  lg_date=$(date "${fmt}")
  if [[ "${lvl}" = "DIE" ]] ; then
    lvl="ERROR"
   echo "${lg_date} - ${lvl} - ${msg}"
   exit 1
  else
    echo "${lg_date} - ${lvl} - ${msg}"
  fi
}

# How to regex
# https://riptutorial.com/bash/example/19469/regex-matching
pat='[^0-9]+([0-9]+)'
s='I am a string with some digits 1024'
[[ $s =~ $pat ]] # $pat must be unquoted
echo "${BASH_REMATCH[0]}"
echo "${BASH_REMATCH[1]}"
# The 0th index in the BASH_REMATCH array is the total match
# The i'th index in the BASH_REMATCH array is the i'th captured group, where i = 1, 2, 3 ...


