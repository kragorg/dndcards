#! /usr/bin/env zsh -df
setopt errexit pipefail
: ${src:=${PWD}} ${out:=outputs/out}
export TEXINPUTS=${src}//:

# We need a writable home directory for luaotfload’s font cache.
export HOME="$PWD"

inputs=( ${argv} )

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
  ${^inputs:r}.pdf
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
for file ( ${src}/${^inputs} ) {  # ^: RC_EXPAND_PARAM.
  dolatex ${file}
}
run ${install}
