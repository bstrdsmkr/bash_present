#! /bin/bash

help_message() {
  local HELP_MESSAGE='advanced_bash.sh is a script designed
  to show off the advanced features of the BASH
  language. Below you can find the options which
  are accepted by the script to change behavior:
  -a) The -a defines the default alignment for slides and 
      therefore must be followed by either left, right, or center.
  -h) Displays this help message.

  -s) Declare the directory in which the slides are stored.'
  echo "${HELP_MESSAGE}"
}

term_size() {
  TERM_SIZE=$(read -p $'\e[18t' -s -r -d t size; echo ${size#*;})
  TERM_WIDTH=${TERM_SIZE/*;}
  TERM_HEIGHT=${TERM_SIZE/;*}
}

align_text() {
  if [[ "${1}" = 'left' ]]; then
    PRESET_ALIGN='left'
  elif [[ "${1}" = 'right' ]]; then
    PRESET_ALIGN='right'
  elif [[ "${1}" = 'center' ]]; then
    PRESET_ALIGN='right'
  else
    help_message
    exit 1
  fi
}

slide_present() {
  slide_present_align() {
    LINE="${1}"
    ALIGN="${2}"
    if [[ "${LINE}" = '<left>' ]]; then 
      echo 'left'
    elif [[ "${LINE}" = '<right>' ]]; then  
      echo 'right'
    elif [[ "${LINE}" = '<center>' ]]; then
      echo 'center'
    elif [[ "${LINE}" = '</left>' ]] || [[ "${LINE}" = '</right>' ]] || [[ "${LINE}" = '</center>' ]]; then
      echo "${PRESET_ALIGN}"
    else
      echo "${ALIGN}"
    fi
  }

  clear
  local SLIDE=${1}
  local SLIDE_START=$(( TERM_HEIGHT / 5 ))
  for ROW in $(eval echo "{0..$SLIDE_START}"); do
    echo
  done
  local ALIGN="${PRESET_ALIGN}"
  while IFS= read -r LINE; do
    local ALIGN=$(slide_present_align "${LINE}" ${ALIGN})
    if [[ "${ALIGN}" = 'left' ]]; then 
      local BUFFER=$(( TERM_WIDTH / 4))   
    elif [[ "${ALIGN}" = 'right' ]]; then  
      local BUFFER=$(( $((TERM_WIDTH - ${#LINE})) - $((TERM_WIDTH / 4)) ))
    elif [[ "${ALIGN}" = 'center' ]]; then
      local BUFFER=$(( $((TERM_WIDTH - ${#LINE})) / 2 ))
    fi
    if [[ ! "${LINE}" =~ ^\<.*\>$ ]]; then
      for SPACE in $(eval echo "{0..$BUFFER}"); do
        echo -n ' '
      done
      echo "${LINE}"
    fi
  done < "${SLIDE}"
}

main() {
  local OPTION
  PRESET_ALIGN='left'
  while getopts "a:hs:" OPTION; do
    case "$OPTION" in
      a)
        align_text "${OPTARG}";;
      h)
        help_message
        exit 0;;
      s)
        local SLIDES_DIR="${OPTARG}";;
      ?)
        echo "${OPTION} is an invalid option."
        help_message
        exit 1;;
    esac
  done
  term_size
  for SLIDE in $(ls -1 ${SLIDES_DIR}); do
    slide_present "${SLIDES_DIR}/${SLIDE}"
    read ENTER
  done
  clear
}


main ${@}
