;+
; Builds the idldoc sav file.
;-

; clear any other compilations
.reset

; compile required code

.compile src/idldoc
.compile src/doc_system__define
.compile src/idldoc_version

.compile src/collection/mgcoabstractlist__define
.compile src/collection/mgcoarraylist__define
.compile src/collection/mgcoabstractiterator__define
.compile src/collection/mgcoarraylistiterator__define
.compile src/collection/mgcohashtable__define

.compile src/dist_tools/mg_cmp_version
.compile src/dist_tools/mg_src_root

.compile src/introspection/doc_thumbnail
.compile src/introspection/doc_typename
.compile src/introspection/doc_variable_declaration

.compile src/math/mg_linear_function

.compile src/parser/docparformatparser__define
.compile src/parser/docparidldocfileparser__define
.compile src/parser/docparidldocformatparser__define
.compile src/parser/docparidlformatparser__define
.compile src/parser/docparmarkupparser__define
.compile src/parser/docparoverviewfileparser__define
.compile src/parser/docparprofileparser__define
.compile src/parser/docparprofiletokenizer__define
.compile src/parser/docparrstformatparser__define
.compile src/parser/docparrstmarkupparser__define
.compile src/parser/docparverbatimmarkupparser__define
.compile src/parser/docparverbatimformatparser__define

.compile src/templating/mgfftemplate__define
.compile src/templating/mgfftokenizer__define

.compile src/textmarkup/mgtmhtml__define
.compile src/textmarkup/mgtmlatex__define
.compile src/textmarkup/mgtmtag__define
.compile src/textmarkup/mgtmlanguage__define
.compile src/textmarkup/mgtmnode__define
.compile src/textmarkup/mgtmtag__define
.compile src/textmarkup/mgtmtext__define

.compile src/tree/doctreedirectory__define
.compile src/tree/doctreeprofile__define
.compile src/tree/doctreesavfile__define
.compile src/tree/doctreeidldocfile__define
.compile src/tree/doctreeroutine__define
.compile src/tree/doctreeargument__define
.compile src/tree/doctreeindex__define

.compile src/util/mg_int_format

; compile any system routines that are used in the required code
resolve_all

; create the sav file
save, filename='idldoc.sav', /routines, description='IDLdoc ' + idldoc_version(/full)

exit