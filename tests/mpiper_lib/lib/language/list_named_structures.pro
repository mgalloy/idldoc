;+
; This function returns a list (in the form of a string array) of the
; named structures currently defined in an IDL session. This routine
; is a wrapper around the OUTPUT keyword to HELP, the use of which
; isn't recommended.
;
; @examples
; <pre>
; IDL> print, list_named_structures()
; !AXIS !CPU !DEVICE !ERROR_STATE !MAKE_DLL !MAP !MOUSE !PLT !VALUES 
; !VERSION !WARN
; </pre>
; @returns A string array containing the names of the named structures
; present in the current IDL session.
; @requires IDL 5.3
; @author Mark Piper, RSI, 2005
;-
function list_named_structures
    compile_opt idl2

    help, /structures, output=list
    i_names = where(strmid(list, 0, 2) eq '**', n_names)
    names = list[i_names]

    prefix = '** Structure '
    n_prefix = strlen(prefix)
    comma_position = strpos(list[i_names], ',')
    for i=0, n_names-1 do $
        names[i] = strmid(names[i], n_prefix, comma_position[i]-n_prefix)

    return, names
end
