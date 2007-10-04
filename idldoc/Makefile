VERSION=3.0-development

all: clean docs dist

clean:
	rm *.zip

docs:
	# idl make_idldoc_docs

dist:
	sed "s/return, '.*'/return, '$(VERSION)'/" < src/idldoc_version.pro > idldoc_version.pro
	mv idldoc_version.pro src/
	idl build_idldoc
	mkdir idldoc-$(VERSION)
	mv idldoc.sav idldoc-$(VERSION)/
	svn export docs idldoc-$(VERSION)/docs/
	zip -r idldoc-$(VERSION).zip idldoc-$(VERSION)/*
	rm -rf idldoc-$(VERSION)
	