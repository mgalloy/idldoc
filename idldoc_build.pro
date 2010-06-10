;+
; Builds the idldoc sav file.
;-

; clear any other compilations
.reset

; compile required code

@idldoc_compile_all

; compile any system routines that are used in the required code
resolve_all, skip_routines=['mg_termistty']

; create the sav file
save, filename='idldoc.sav', /routines, description='IDLdoc ' + idldoc_version(/full)

exit