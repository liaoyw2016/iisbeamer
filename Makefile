SRC      = beamerthemeiis
TEXVER   = 2011
VIEWPDF  = okular
EX       = example
FEATURES = index history

## Determine the host the Makefile is running on.
HOST = $(shell hostname)

## Determine the path to the pdflatex binary depending on the current host.
ifeq ($(HOST),muem_mobile)
  ## Path to the latex/pdflatex binary for my cygwin installation on my laptop.
  LATEX     = "/cygdrive/c/Program Files/MiKTeX 2.9/miktex/bin/x64/latex.exe"
	PDFLATEX  = "/cygdrive/c/Program Files/MiKTeX 2.9/miktex/bin/x64/pdflatex.exe"
  MAKEINDEX = "/cygdrive/c/Program Files/MiKTeX 2.9/miktex/bin/x64/makeindex.exe"
else
  ## Otherwise we assume that we are running this Makefile on my work PC.
  LATEX     = latex-$(TEXVER)
  PDFLATEX  = pdflatex-$(TEXVER)
  MAKEINDEX = makeindex-$(TEXVER)
endif

## Determine the host the Makefile is running on.
HOST = $(shell hostname)

.PHONY: help clean

all: sty doc $(FEATURES) example
	@$(PDFLATEX) $(SRC).dtx

$(SRC).sty: $(SRC).dtx $(SRC).ins
	@$(LATEX) $(SRC).ins

$(SRC).pdf: $(SRC).dtx
	@$(PDFLATEX) $(SRC).dtx

sty: $(SRC).sty

doc: $(SRC).pdf

example: $(EX).pdf

## A pattern rule to create a PDF from a TEX source (only used for the example).
%.pdf: %.tex
	@$(PDFLATEX) $(EX) $<
	@$(PDFLATEX) $(EX) $<

## Targets to build the history.
history: $(SRC).gls $(SRC).ilg

$(SRC).glo $(SRC).aux: $(SRC).dtx
	@$(PDFLATEX) $(SRC).dtx

$(SRC).gls: $(SRC).dtx $(SRC).glo
	@$(MAKEINDEX) -s gglo.ist -o $(SRC).gls $(SRC).glo

## Targets to build the index.
index: $(SRC).ind $(SRC).ilg

$(SRC).idx $(SRC).nlo: $(SRC).dtx
	@$(PDFLATEX) $(SRC).dtx

$(SRC).ind $(SRC).ilg: $(SRC).dtx $(SRC).idx
	@$(MAKEINDEX) -s gind.ist -o $(SRC).ind $(SRC).idx

view:
	$(VIEWPDF) $(SRC).pdf &

clean:
	@rm -f *.log *~ *.aux *.glo *.gls *.idx *.ilg *.ind
	@rm -f *.out *.tdo *.toc *.sty *.nav *.snm *.vrb $(SRC).pdf

help:
	@echo
	@echo "USAGE    : make [options] <target(s)>"
	@echo
	@echo "TARGETS  : help               - Show the help (this text)."
	@echo                                                        
	@echo "           (default)          - Call 'all' target"
	@echo "           all                - Create theme files, documentation, and example"
	@echo "           sty                - Create theme files"
	@echo "           doc                - Create theme documentation"
	@echo "           history            - Create theme history"
	@echo "           index              - Create theme index"
	@echo "           example            - Create example file"
	@echo "           clean              - Clean directory" 
	@echo
	@echo "OPTIONS  : -B                 - Always build (regardless of whether the dependencies"
	@echo "                                are outdated or not)."
	@echo
	@echo "EXAMPLEs : make"
	@echo "           make example"
	@echo
