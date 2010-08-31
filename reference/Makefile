TITLE=idldoc-tutorial

.PHONY: clean

$(TITLE).pdf: $(TITLE).tex
	pdflatex $(TITLE).tex
	pdflatex $(TITLE).tex

$(TITLE).tex: $(TITLE).rst
	rst2latex.py $(TITLE).rst $(TITLE).tex

clean: 
	rm -f $(TITLE).tex
	rm -f $(TITLE).out
	rm -f $(TITLE).log
	rm -f $(TITLE).aux			
	rm -f $(TITLE).pdf