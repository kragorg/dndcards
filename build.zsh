#! /usr/bin/env zsh -df
setopt errexit pipefail
: ${src:=${PWD}} ${out:=outputs/out}
export TEXINPUTS=${src}//:

# We need a writable home directory for luaotfload’s font cache.
export HOME="$PWD"

# If the source file names are given on the command line, we use that.
# Otherwise we expect them to be specified in the environment variable
# `markdown`, shell-quoted. The file names are relative to the `src`
# directory.
if (( ${#argv} > 0 )) {
  inputs=( ${argv} )
} else {
  inputs=( ${(Q)${(z)texfiles}} )  # z: Split into words using shell parsing. Q: Remove quoting.
}
inputs=( ${src}/${^inputs} )       # ^: RC_EXPAND_PARAM.

fonts=(
  luaotfload-tool
  --formats=otf
  --update
)
latex=(
  lualatex
  --interaction=batchmode
  --halt-on-error
  --output-format=pdf
  --output-directory=${PWD}
)
install=(
  install
  -D -t ${out}
  -m 0644
  ${^inputs:t:r}.pdf
)

function run {
  print -Pru2 -- "%F{cyan}${argv}%f"
  ${argv}
}

function dolatex {
  run ${latex} $1 || {
    local rc=$?
    cat ${1:t:r}.log >&2
    return ${rc}
  }
}

run ${fonts}
for file ( ${^inputs} ) {  # ^: RC_EXPAND_PARAM.
  dolatex ${file}
}
run ${install}
