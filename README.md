# About draft-ietf-ippm-responsiveness

This repository contains the source document for the **Responsiveness under Working Conditions** Internet-Draft.
That document describes a technique for measuring responsiveness in a network.

## Usage

`make all` creates PDF, text, and HTML formats of the RFC

`make test` runs various tests on the Markdown file to ensure that it's well formatted and passes the spell check.

## Requirements

The make script requires the following tools:

* **kramdown-rfc2629** - processes a Markdown file into an XML representation.
Install with `gem install kramdown-rfc2629`

* **xml2rfc** - convert an XML file to RFC format.
Install with `pip install xml2rfc`

* **enscript** - Convert a text file to a Postscript file.
Install with `brew install enscript`

* **ps2pdf** - Convert a Postscript file to a PDF file.
(May be preinstalled on macOS)

* **markdownlint-cli** - Run a 'lint' process over the Markdown file
Install with `brew install markdownlint-cli`
This command relies on the rules in the `.markdownlint.jsonc` file.
*Note: The I-D file does not begin with a valid YAML heading.
The `--- abstract` at the end confuses markdownlint's "ignoreheading" processing.
To avoid the problem, place a `---` line just above that line and `make lint`
Unfortunately, this makes an invalid I-D file, so that line must be removed
before creating final documents.*

* **spellchecker-cli** spell check the markdown files.
Install with `yarn global add spellchecker-cli`
Uses the dictionary.txt file to ignore correct, but unusual words.
