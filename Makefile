define ninjabuild
	nix develop -c ninja $(1)
endef

.PHONY: all clean distclean FORCE
.ONESHELL:

all:
	$(call ninjabuild,)

outputs/out/%.pdf: %.tex
	$(call ninjabuild, $@)

%.pdf: %.tex FORCE
	$(MAKE) outputs/out/$@

%: %.tex FORCE
	$(MAKE) outputs/out/$@.pdf && open outputs/out/$@.pdf

define document_start
\\documentclass{dnd-deck}  \
\\begin{document}
endef
define document_end
\\end{document}
endef
define all_awk
/\\NewDocumentCommand\{\\$1/ {              \
	match($$0, /\\$1([^}]+)/);          \
	print substr($$0, RSTART, RLENGTH)  \
}
endef

all-spells.tex: spells.sty
	(                                   \
	echo '$(document_start)'            \
	&& awk '$(call all_awk,Spell)' $^   \
	| grep -v '\\SpellCards'            \
	&& echo '$(document_end)'           \
	) >$@ || ( rm -f $@; false )

all-monsters.tex: monster.sty
	(                                    \
	echo '$(document_start)'             \
	&& awk '$(call all_awk,Monster)' $^  \
	&& echo '$(document_end)'           \
	) >$@ || ( rm -f $@; false )

clean:
	rm -f all-spells.tex all-monsters.tex
	rm -rf outputs
	rm -f build.ninja obj/*.pdf obj/*.aux

distclean: clean
	rm -rf obj

-include Makefile.local
