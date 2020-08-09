RMDFILES=$(wildcard *.Rmd)
HTMLFILES=$(addsuffix .html,$(basename $(RMDFILES)))

all: $(HTMLFILES)

$(HTMLFILES): %.html: %.rmd
	Rscript -e 'library("rmarkdown"); render("$<")'
