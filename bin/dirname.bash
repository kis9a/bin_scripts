#!/bin/bash

dirname() {
  local tmp=${1:-.}

  [[ $tmp != *[!/]* ]] && {
    printf '/\n'
    return
  }

  tmp=${tmp%%"${tmp##*[!/]}"}

  [[ $tmp != */* ]] && {
    printf '.\n'
    return
  }

  tmp=${tmp%/*}
  tmp=${tmp%%"${tmp##*[!/]}"}
  printf '%s\n' "${tmp:-/}"
}

dirname "$@"
