#
# Makefile for running pandoc on all Markdown docs ending in .md
#
PROJECT = rdm_sql_reporting

PANDOC = $(shell which pandoc)

MD_PAGES = $(shell ls -1 *.md | grep -v 'nav.md')

HTML_PAGES = $(shell ls -1 *.md | grep -v 'nav.md' | sed -E 's/.md/.html/g')

build: $(HTML_PAGES) $(MD_PAGES)
	@for FNAME in $(HTML_PAGES); do git add "$$FNAME"; done
	@if [ -f index.html ]; then git add index.html; fi
	@git commit -am 'website build process'

$(HTML_PAGES): $(MD_PAGES) .FORCE
	if [ -f $(PANDOC) ]; then $(PANDOC) --metadata title=$(basename $@) -s --to html5 $(basename $@).md -o $(basename $@).html \
		--lua-filter=./links-to-html.lua \
	    --template=page.tmpl; fi
	@if [ $@ = "README.html" ]; then mv README.html index.html; fi
	@if [ $@ = "INSTALL.html" ]; then mv "INSTALL.html" "install.html"; fi

clean:
	@if [ -f index.html ]; then rm index.html; fi
	@for FNAME in $(HTML_PAGES); do if [ -f "$$FNAME" ]; then rm "$$FNAME"; fi; done

.FORCE:
