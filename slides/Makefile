RMDFILES=$(wildcard *.Rmd)
HTMLFILES=$(addsuffix .html,$(basename $(RMDFILES)))

all: $(HTMLFILES)

$(HTMLFILES): %.html: %.Rmd
	Rscript -e 'library("rmarkdown"); render("$<")'
