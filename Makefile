xml2rfc ?= xml2rfc
kramdown-rfc2629 ?= kramdown-rfc2629

drafts := draft-ietf-ippm-responsiveness.xml draft-ietf-ippm-responsiveness.txt draft-ietf-ippm-responsiveness.html draft-ietf-ippm-responsiveness.pdf
xml := $(drafts:.txt=.xml)

all: $(drafts)


%.xml: %.md
	@echo "Converting MD to XML"
	$(kramdown-rfc2629) $< > $@

%.txt: %.xml
	@echo "Converting XML to TXT"
	$(xml2rfc) $< > $@

%.html: %.xml
	@echo "Converting XML to HTML"
	$(xml2rfc) --html $<  > $@

%.pdf: %.txt
	@echo "Converting TXT to PDF"
	enscript -B -o $(patsubst %.txt,%.ps,$<) $<
# Note: You may need to change to ps2pdf if you are using a non-macOS machine.
	ps2pdf $(patsubst %.txt,%.ps,$<)

test: all
	@echo "Spell checking"
	spellchecker --plugins spell indefinite-article repeated-words syntax-urls --dictionaries dictionary.txt --files '*.md'  
	@echo "linting the Markdown"
	markdownlint -c .markdownlint.jsonc *.md

clean:
	@echo "Cleaning"
	rm -rf $(drafts) *.ps
