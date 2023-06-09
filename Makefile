#
# Simple Makefile for Bash and Golang based Projects.
#
PROJECT = rdm_sql_reporting

BASH_SCRIPTS = $(shell ls -1 *.bash)

MAN_PAGES = $(shell ls -1 *.1.md | sed -E 's/\.1.md/.1/g')

HTML_PAGES = $(shell find . -type f | grep -E '\.html')

PANDOC = $(shell which pandoc)

DOCS = docs examples # how-to demo

#VERSION = $(shell jq .version codemeta.json | cut -d\"  -f 2)
VERSION = $(shell grep '"version":' codemeta.json | cut -d\"  -f 4)

BRANCH = $(shell git branch | grep '* ' | cut -d\  -f 2)

OS = $(shell uname)

#PREFIX = /usr/local/bin
PREFIX = $(HOME)

ifneq ($(prefix),)
	PREFIX = $(prefix)
endif

EXT =
ifeq ($(OS), Windows)
	EXT = .exe
endif

build: $(MAN_PAGES) CITATION.cff about.md website

man: $(MAN_PAGES)

$(MAN_PAGES): .FORCE
	mkdir -p man/man1
	$(PANDOC) $@.md --from markdown --to man -s >man/man1/$@

CITATION.cff: codemeta.json
	cat codemeta.json | sed -E   's/"@context"/"at__context"/g;s/"@type"/"at__type"/g;s/"@id"/"at__id"/g' >_codemeta.json
	if [ -f $(PANDOC) ]; then echo "" | $(PANDOC) --metadata title="Cite $(PROJECT)" --metadata-file=_codemeta.json --template=codemeta-cff.tmpl >CITATION.cff; fi

about.md: codemeta.json .FORCE
	cat codemeta.json | sed -E 's/"@context"/"at__context"/g;s/"@type"/"at__type"/g;s/"@id"/"at__id"/g' >_codemeta.json
	if [ -f $(PANDOC) ]; then echo "" | pandoc --metadata-file=_codemeta.json --template codemeta-md.tmpl >about.md 2>/dev/null; fi
	if [ -f _codemeta.json ]; then rm _codemeta.json; fi


website: clean-website
	make -f website.mak

status:
	git status

save: .FORCE
	@if [ "$(msg)" != "" ]; then git commit -am "$(msg)"; else git commit -am "Quick Save"; fi
	-git push origin $(BRANCH)

refresh:
	git fetch origin
	git pull origin $(BRANCH)

publish: man website save
	-git checkout gh-pages
	-git pull origin $(BRANCH)
	-make -f website.mak
	-git commit -am "publishing website"
	-git push origin gh-pages
	git checkout $(BRANCH)

clean:
	@if [ -f version.go ]; then rm version.go; fi
	@if [ -d bin ]; then rm -fR bin; fi
	@if [ -d dist ]; then rm -fR dist; fi
	@if [ -d man ]; then rm -fR man; fi
	@if [ -d testout ]; then rm -fR testout; fi

clean-website:
	@for FNAME in $(HTML_PAGES); do rm "$${FNAME}"; done

install: build
	@echo "Installing programs in $(PREFIX)/bin"
	@for FNAME in $(PROGRAMS); do if [ -f "./bin/$${FNAME}$(EXT)" ]; then mv -v "./bin/$${FNAME}$(EXT)" "$(PREFIX)/bin/$${FNAME}$(EXT)"; fi; done
	@echo ""
	@echo "Make sure $(PREFIX)/bin is in your PATH"
	@echo "Install Bash scripts in $(PREFIX)/bin"
	@for FNAME in $(BASH_SCRIPTS); do if [ -f "./$${FNAME}" ]; then cp -v "./$${FNAME}" "$(PREFIX)/bin/$${FNAME}"; fi; done
	@echo "Installing man pages in $(PREFIX)/man"
	@mkdir -p $(PREFIX)/man/man1
	@for FNAME in $(MAN_PAGES); do if [ -f "./man/man1/$${FNAME}" ]; then cp -v "./man/man1/$${FNAME}" "$(PREFIX)/man/man1/$${FNAME}"; fi; done
	@echo ""
	@echo "Make sure $(PREFIX)/man is in your MANPATH"

uninstall: .FORCE
	@echo "Removing programs in $(PREFIX)/bin"
	@for FNAME in $(PROGRAMS); do if [ -f "$(PREFIX)/bin/$${FNAME}$(EXT)" ]; then rm -v "$(PREFIX)/bin/$${FNAME}$(EXT)"; fi; done
	@echo "Removing Bash script in $(PREFIX)/bin"
	@for FNAME in $(BASH_SCRIPTS); do if [ -f "$(PREFIX)/bin/$${FNAME}" ]; then rm -v "$(PREFIX)/bin/$${FNAME}"; fi; done
	@echo "Removing man pages in $(PREFIX)/man"
	@for FNAME in $(MAN_PAGES); do if [ -f "$(PREFIX)/man/man1/$${FNAME}" ]; then rm -v "$(PREFIX)/man/man1/$${FNAME}"; fi; done


dist/linux-amd64: $(PROGRAMS)
	@mkdir -p dist/bin
	@for FNAME in $(PROGRAMS); do env  GOOS=linux GOARCH=amd64 go build -o "dist/bin/$${FNAME}" cmd/$${FNAME}/*.go; done
	@cd dist && zip -r $(PROJECT)-$(VERSION)-linux-amd64.zip LICENSE codemeta.json CITATION.cff *.md bin/* $(DOCS)
	@rm -fR dist/bin


dist/macos-amd64: $(PROGRAMS)
	@mkdir -p dist/bin
	@for FNAME in $(PROGRAMS); do env GOOS=darwin GOARCH=amd64 go build -o "dist/bin/$${FNAME}" cmd/$${FNAME}/*.go; done
	@cd dist && zip -r $(PROJECT)-$(VERSION)-macos-amd64.zip LICENSE codemeta.json CITATION.cff *.md bin/* $(DOCS)
	@rm -fR dist/bin


dist/macos-arm64: $(PROGRAMS)
	@mkdir -p dist/bin
	@for FNAME in $(PROGRAMS); do env GOOS=darwin GOARCH=arm64 go build -o "dist/bin/$${FNAME}" cmd/$${FNAME}/*.go; done
	@cd dist && zip -r $(PROJECT)-$(VERSION)-macos-arm64.zip LICENSE codemeta.json CITATION.cff *.md bin/* $(DOCS)
	@rm -fR dist/bin


dist/windows-amd64: $(PROGRAMS)
	@mkdir -p dist/bin
	@for FNAME in $(PROGRAMS); do env GOOS=windows GOARCH=amd64 go build -o "dist/bin/$${FNAME}.exe" cmd/$${FNAME}/*.go; done
	@cd dist && zip -r $(PROJECT)-$(VERSION)-windows-amd64.zip LICENSE codemeta.json CITATION.cff *.md bin/* $(DOCS)
	@rm -fR dist/bin


dist/raspberry_pi_os-arm7: $(PROGRAMS)
	@mkdir -p dist/bin
	@for FNAME in $(PROGRAMS); do env GOOS=linux GOARCH=arm GOARM=7 go build -o "dist/bin/$${FNAME}" cmd/$${FNAME}/*.go; done
	@cd dist && zip -r $(PROJECT)-$(VERSION)-raspberry_pi_os-arm7.zip LICENSE codemeta.json CITATION.cff *.md bin/* $(DOCS)
	@rm -fR dist/bin

distribute_docs:
	@mkdir -p dist/
	@cp -v codemeta.json dist/
	@cp -v CITATION.cff dist/
	@cp -v README.md dist/
	@cp -v LICENSE dist/
	@cp -v INSTALL.md dist/
	@cp -vR man dist/
	@for DNAME in $(DOCS); do cp -vR $$DNAME dist/; done

release: distribute_docs dist/linux-amd64 dist/macos-amd64 dist/macos-arm64 dist/windows-amd64 dist/raspberry_pi_os-arm7


.FORCE:
