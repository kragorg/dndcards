define dndbuild
	nix develop --command bash -c "dndbuild $(1)"
endef

.PHONY: all clean distclean FORCE

all:
	$(call dndbuild,)

PACKAGES := character.sty dnd-deck.cls dndcards.sty monster.sty spells.sty

outputs/out/%.pdf: %.tex $(PACKAGES)
	$(call dndbuild, $<)

%.pdf: %.tex FORCE
	$(MAKE) outputs/out/$@

%: %.tex FORCE
	$(MAKE) outputs/out/$@.pdf && open outputs/out/$@.pdf

clean:
	rm -rf outputs
	rm -f obj/*.pdf obj/*.aux

distclean: clean
	rm -rf obj
