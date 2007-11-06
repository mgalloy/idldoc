;+
; Builds the idldoc sav file.
;-

; clear any other compilations
.reset

; compile required code

@compile_all

; compile any system routines that are used in the required code
resolve_all

; create the sav file
save, filename='idldoc.sav', /routines, description='IDLdoc ' + idldoc_version(/full)

exit