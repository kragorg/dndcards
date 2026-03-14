#!/usr/bin/env zsh

setopt errexit pipefail

zparseopts -D -E -K -A opts --    \
    -builddir:                    \
    -dst:                         \
    -output:                      \
    -src:
: ${opts[--builddir]:?} ${opts[--src]:?} ${opts[--dst]:?}

if [[ -n ${opts[--output]} && ${opts[--output]} != "-" ]] {
    exec >${opts[--output]}
    trap 'rm -f ${opts[--output]}' ERR
}

for opt ( ${(k)opts} ) {
    print -- "${opt##--} = ${opts[$opt]}"
}

cat <<"EOF"

rule fontcache
  command = mkdir -p $builddir && HOME=$builddir luaotfload-tool --formats=otf --update && touch $out
  description = Generating font cache

rule latexmk
  command = HOME=$builddir TEXINPUTS=$src//: latexmk --pdflua --interaction=nonstopmode --halt-on-error --outdir=$builddir $in && install -D -m 0644 $builddir/$pdf $out
  description = Building $pdf

build $builddir/.fontcache: fontcache

EOF

common=( character.sty dnd-deck.cls dndcards.sty monster.sty spells.sty )
common=( '$src/'${^common} )

for arg ( ${argv} ) {
    print -- "build \$dst/${arg:t:r}.pdf: latexmk ${arg} | $common || \$builddir/.fontcache"
    print -- "  pdf = ${arg:t:r}.pdf"
    print
}

print -n -- 'default'
for arg ( ${argv} ) {
    print -n -- " \$dst/${arg:t:r}.pdf"
}
print
