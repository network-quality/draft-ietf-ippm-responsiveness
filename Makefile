xml2rfc ?= xml2rfc
kramdown-rfc2629 ?= kramdown-rfc2629

drafts := draft-cpaasch-ippm-responsiveness.txt draft-cpaasch-ippm-responsiveness.html draft-cpaasch-ippm-responsiveness.pdf
xml := $(drafts:.txt=.xml)

%.txt: %.md
	$(kramdown-rfc2629) $< > $(patsubst %.txt,%.xml, $@)
	$(xml2rfc) $(patsubst %.txt,%.xml, $@) > $@

%.txt: %.xml
	$(xml2rfc) $< $@

%.html: %.xml
	$(xml2rfc) --html $< $@

%.pdf: %.txt
	enscript -B -o $(patsubst %.txt,%.ps,$<) $<
	ps2pdf $(patsubst %.txt,%.ps,$<)

all: $(drafts)
