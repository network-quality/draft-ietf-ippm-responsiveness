xml2rfc ?= xml2rfc
kramdown-rfc2629 ?= kramdown-rfc2629

drafts := draft-cpaasch-ippm-responsiveness.txt draft-cpaasch-ippm-responsiveness.html draft-cpaasch-ippm-responsiveness.pdf
xml := $(drafts:.txt=.xml)

%.txt: %.md
	@echo "processing .md"
	$(kramdown-rfc2629) $< > $(patsubst %.txt,%.xml, $@)
	$(xml2rfc) $(patsubst %.txt,%.xml, $@) > $@

%.txt: %.xml
	@echo "creating .txt"
	$(xml2rfc) $< $@

%.html: %.xml
	@echo "creating .html"
	$(xml2rfc) --html $<  > $@

%.pdf: %.txt
	@echo "creating PDF"
	enscript -B -o $(patsubst %.txt,%.ps,$<) $<
	ps2pdf $(patsubst %.txt,%.ps,$<)

test:
	@echo "spell checking"
	spellchecker --plugins spell indefinite-article repeated-words syntax-urls --dictionaries dictionary.txt --files '*.md'  
	@echo "linting the Markdown"
	markdownlint -c .markdownlint.jsonc *.md

all: $(drafts)
