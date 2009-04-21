VERSION=3.2dev
REVISION=-r`svn info | sed -n 's/Revision: \(.*\)/\1/p'`
IDL=idl

.PHONY: clean doc book regression tests srcdist dist updates
	
clean:
	rm -f *.zip
	rm -rf updates.idldev.com
	rm -rf api-docs
	rm -rf api-book
	rm -rf regression_test/*-docs
	rm -rf unit_tests/*-docs
	
doc:
	$(IDL) build_idldoc_docs

book:
	$(IDL) build_idldoc_book
	cd api-book; pdflatex -halt-on-error index.tex
	cd api-book; pdflatex -halt-on-error index.tex	
	
regression:
	$(IDL) -e "mgunit, 'docrtalltests_uts'"
	
tests:
	$(IDL) -e "mgunit, 'docutalltests_uts'"
	
srcdist:
	sed "s/version = '.*'/version = '$(VERSION)'/" < src/idldoc_version.pro | sed "s/revision = '.*'/revision = '$(REVISION)'/" > idldoc_version.pro
	mv idldoc_version.pro src/

	svn export . idldoc-$(VERSION)-src/

	zip -r idldoc-$(VERSION)-src.zip idldoc-$(VERSION)-src/*
	rm -rf idldoc-$(VERSION)-src
	
dist:
	sed "s/version = '.*'/version = '$(VERSION)'/" < src/idldoc_version.pro | sed "s/revision = '.*'/revision = '$(REVISION)'/" > idldoc_version.pro
	mv idldoc_version.pro src/
	
	mkdir idldoc-$(VERSION)
	
	$(IDL) -IDL_STARTUP "" build_idldoc
	mv idldoc.sav idldoc-$(VERSION)/
	
	svn export docs idldoc-$(VERSION)/docs/
	svn export src/templates idldoc-$(VERSION)/templates/
	svn export src/resources idldoc-$(VERSION)/resources/
	
	zip -r idldoc-$(VERSION).zip idldoc-$(VERSION)/*
	rm -rf idldoc-$(VERSION)

updates:
	rm -rf updates.idldev.com

	sed "s/version = '.*'/version = '$(VERSION)'/" < src/idldoc_version.pro | sed "s/revision = '.*'/revision = '$(REVISION)'/" > idldoc_version.pro
	mv idldoc_version.pro src/

	mkdir -p updates.idldev.com/{features,plugins}

	$(IDL) -e build_updates_site

	cp updates-resources/features/about.html updates.idldev.com/features/com.idldev.idl.idldoc.feature_$(VERSION)/
	cp updates-resources/features/feature.properties updates.idldev.com/features/com.idldev.idl.idldoc.feature_$(VERSION)/

	jar cvf updates.idldev.com/features/com.idldev.idl.idldoc.feature_$(VERSION).jar -C updates.idldev.com/features/com.idldev.idl.idldoc.feature_$(VERSION)/ .
	rm -rf updates.idldev.com/features/com.idldev.idl.idldoc.feature_$(VERSION)/

	$(IDL) -IDL_STARTUP "" build_idldoc

	mkdir updates.idldev.com/plugins/com.idldev.idl.idldoc_$(VERSION)/
	cp idldoc.sav updates.idldev.com/plugins/com.idldev.idl.idldoc_$(VERSION)/
	rm idldoc.sav

	svn export docs updates.idldev.com/plugins/com.idldev.idl.idldoc_$(VERSION)/docs/

	svn export src/templates updates.idldev.com/plugins/com.idldev.idl.idldoc_$(VERSION)/templates/
	svn export src/resources updates.idldev.com/plugins/com.idldev.idl.idldoc_$(VERSION)/resources/

	jar cvfm updates.idldev.com/plugins/com.idldev.idl.idldoc_$(VERSION).jar updates.idldev.com/plugins/manifest -C updates.idldev.com/plugins/com.idldev.idl.idldoc_$(VERSION) .
	rm -rf updates.idldev.com/plugins/com.idldev.idl.idldoc_$(VERSION)/
	rm updates.idldev.com/plugins/manifest

	scp -r updates.idldev.com/* tizer.dreamhost.com:~/updates.idldev.com
