VERSION=3.6.2
REVISION=-`git log -1 --pretty=format:%h`
IDL=idl64
DOC_IDL=idl83
TAG=IDLDOC_`echo $(VERSION) | sed -e"s/\./_/g"`
BRANCH=v$(VERSION)


.PHONY: all clean doc book regression tests version srcdist dist updates tag branch


all:
	cd src; make all IDL=$(IDL)

clean:
	cd src; make clean
	rm -f *.zip
	rm -rf updates.idldev.com
	rm -rf api-docs
	rm -rf api-book
	rm -rf regression_test/*-docs
	rm -rf unit_tests/*-docs

doc:
	$(DOC_IDL) < idldoc_build_docs.pro

book:
	$(DOC_IDL) idldoc_build_book
	cd api-book; pdflatex -halt-on-error index.tex
	cd api-book; pdflatex -halt-on-error index.tex	

regression:
	$(IDL) -e "mgunit, 'docrtalltests_uts'"

tests:
	$(IDL) -e "mgunit, 'docutalltests_uts'"

version:
	sed "s/version = '.*'/version = '$(VERSION)'/" < src/idldoc_version.pro | sed "s/revision = '.*'/revision = '$(REVISION)'/" > idldoc_version.pro
	mv idldoc_version.pro src/

dist:
	make version

	rm -rf idldoc-$(VERSION)
	mkdir idldoc-$(VERSION)

	$(IDL) -IDL_STARTUP "" < idldoc_build.pro
	mv idldoc.sav idldoc-$(VERSION)/

	cp COPYING.rst idldoc-$(VERSION)/
	cp CREDITS.rst idldoc-$(VERSION)/
	cp ISSUES.rst idldoc-$(VERSION)/
	cp RELEASE.rst idldoc-$(VERSION)/
	cp INSTALL.rst idldoc-$(VERSION)/
	cp README.rst idldoc-$(VERSION)/

	cd docs; make
	mkdir idldoc-$(VERSION)/docs
	cp docs/idldoc-reference.pdf idldoc-$(VERSION)/docs/
	cp docs/idldoc-tutorial.pdf idldoc-$(VERSION)/docs/

	cp -r src/templates idldoc-$(VERSION)/templates/
	cp -r src/resources idldoc-$(VERSION)/resources/

	zip -r idldoc-$(VERSION).zip idldoc-$(VERSION)/*
	rm -rf idldoc-$(VERSION)

tag:
	@make_tag.sh $(TAG)

branch:
	@make_branch.sh $(BRANCH)

updates:
	rm -rf updates.idldev.com

	sed "s/version = '.*'/version = '$(VERSION)'/" < src/idldoc_version.pro | sed "s/revision = '.*'/revision = '$(REVISION)'/" > idldoc_version.pro
	mv idldoc_version.pro src/

	mkdir -p updates.idldev.com/{features,plugins}

	$(IDL) -e idldoc_build_updates_site

	cp updates-resources/features/about.html updates.idldev.com/features/com.idldev.idl.idldoc.feature_$(VERSION)/
	cp updates-resources/features/feature.properties updates.idldev.com/features/com.idldev.idl.idldoc.feature_$(VERSION)/

	jar cvf updates.idldev.com/features/com.idldev.idl.idldoc.feature_$(VERSION).jar -C updates.idldev.com/features/com.idldev.idl.idldoc.feature_$(VERSION)/ .
	rm -rf updates.idldev.com/features/com.idldev.idl.idldoc.feature_$(VERSION)/

	$(IDL) -IDL_STARTUP "" < idldoc_build

	mkdir updates.idldev.com/plugins/com.idldev.idl.idldoc_$(VERSION)/
	cp idldoc.sav updates.idldev.com/plugins/com.idldev.idl.idldoc_$(VERSION)/
	rm idldoc.sav

	cp -r docs updates.idldev.com/plugins/com.idldev.idl.idldoc_$(VERSION)/docs/

	cp -r src/templates updates.idldev.com/plugins/com.idldev.idl.idldoc_$(VERSION)/templates/
	cp -r src/resources updates.idldev.com/plugins/com.idldev.idl.idldoc_$(VERSION)/resources/

	jar cvfm updates.idldev.com/plugins/com.idldev.idl.idldoc_$(VERSION).jar updates.idldev.com/plugins/manifest -C updates.idldev.com/plugins/com.idldev.idl.idldoc_$(VERSION) .
	rm -rf updates.idldev.com/plugins/com.idldev.idl.idldoc_$(VERSION)/
	rm updates.idldev.com/plugins/manifest

	scp -r updates.idldev.com/* tizer.dreamhost.com:~/updates.idldev.com
