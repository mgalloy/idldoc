VERSION=3.0.0
REVISION=-r`svn info | sed -n 's/Revision: \(.*\)/\1/p'`

clean:
	rm -f *.zip
	rm -rf updates.idldev.com
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

updates:
	rm -rf updates.idldev.com

	sed "s/version = '.*'/version = '$(VERSION)'/" < src/idldoc_version.pro | sed "s/revision = '.*'/revision = '$(REVISION)'/" > idldoc_version.pro
	mv idldoc_version.pro src/

	mkdir -p updates.idldev.com/{features,plugins}

	idl -e build_updates_site

	cp updates-resources/features/about.html updates.idldev.com/features/com.idldev.idl.idldoc.feature_$(VERSION)/
	cp updates-resources/features/feature.xml updates.idldev.com/features/com.idldev.idl.idldoc.feature_$(VERSION)/

	jar cvf updates.idldev.com/features/com.idldev.idl.idldoc.feature_$(VERSION).jar -C updates.idldev.com/features com.idldev.idl.idldoc.feature_$(VERSION)/
	rm -rf updates.idldev.com/features/com.idldev.idl.idldoc.feature_$(VERSION)/

	idl -IDL_STARTUP "" build_idldoc

	mkdir updates.idldev.com/plugins/com.idldev.idl.idldoc.feature_$(VERSION)/
	cp idldoc.sav updates.idldev.com/plugins/com.idldev.idl.idldoc.feature_$(VERSION)/
	rm idldoc.sav

	svn export docs updates.idldev.com/plugins/com.idldev.idl.idldoc.feature_$(VERSION)/docs/

	svn export src/templates updates.idldev.com/plugins/com.idldev.idl.idldoc.feature_$(VERSION)/templates/
	svn export src/resources updates.idldev.com/plugins/com.idldev.idl.idldoc.feature_$(VERSION)/resources/

	jar cvf updates.idldev.com/plugins/com.idldev.idl.idldoc.feature_$(VERSION).jar -C updates.idldev.com/plugins com.idldev.idl.idldoc.feature_$(VERSION)/
	rm -rf updates.idldev.com/plugins/com.idldev.idl.idldoc.feature_$(VERSION)/

	scp -r updates.idldev.com/* tizer.dreamhost.com:~/updates.idldev.com
