VERSION=3.0
REVISION=-r`svn info | sed -n 's/Revision: \(.*\)/\1/p'`

clean:
	rm -f *.zip
	rm -rf api-docs
	rm -rf regression_test/*-docs
	rm -rf unit_tests/*-docs
	
doc:
	idl build_idldoc_docs

regression:
	idl -e "mgunit, 'docrtalltests_uts'"
	
tests:
	idl -e "mgunit, 'docutalltests_uts'"
	
srcdist:
	sed "s/version = '.*'/version = '$(VERSION)'/" < src/idldoc_version.pro | sed "s/revision = '.*'/revision = '$(REVISION)'/" > idldoc_version.pro
	mv idldoc_version.pro src/

	svn export . idldoc-$(VERSION)-src/
	svn export src/collection idldoc-$(VERSION)-src/collection
	svn export src/dist_tools idldoc-$(VERSION)-src/dist_tools
	svn export src/math idldoc-$(VERSION)-src/math
	svn export src/textmarkup idldoc-$(VERSION)-src/textmarkup
	svn export src/templating idldoc-$(VERSION)-src/templating
	svn export src/web idldoc-$(VERSION)-src/web
	zip -r idldoc-$(VERSION)-src.zip idldoc-$(VERSION)-src/*
	rm -rf idldoc-$(VERSION)-src
	
dist:
	sed "s/version = '.*'/version = '$(VERSION)'/" < src/idldoc_version.pro | sed "s/revision = '.*'/revision = '$(REVISION)'/" > idldoc_version.pro
	mv idldoc_version.pro src/
	
	mkdir idldoc-$(VERSION)
	
	idl -IDL_STARTUP "" build_idldoc
	mv idldoc.sav idldoc-$(VERSION)/
	
	svn export docs idldoc-$(VERSION)/docs/
	svn export src/templates idldoc-$(VERSION)/templates/
	svn export src/resources idldoc-$(VERSION)/resources/
	
	zip -r idldoc-$(VERSION).zip idldoc-$(VERSION)/*
	rm -rf idldoc-$(VERSION)

