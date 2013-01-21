;+
; Builds the idldoc sav file.
;-

; clear any other compilations
.reset

; compile required code

@idldoc_compile_all

; NOT resolving all IDL lib routines anymore, so that the .sav file generated
; with IDL 6.4 can be safely used with later versions of IDL that may have
; different versions of the IDL library routines. IDLdoc is not intended to
; run in a runtime or VM environment, so they are not needed anyway. The .sav
; file is produced simply as a way to package all the required routines in a
; single file.

; create the sav file
save, filename='idldoc.sav', /routines, description='IDLdoc ' + idldoc_version(/full)

exit
