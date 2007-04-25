;+
; Finds the fields of a class.
;
; @categories introspection
;
; @returns 1 if found, 0 if not
; @param class {in}{required}{type=string}
; @keyword names {out}{optional}{type=strarr}
; @keyword types {out}{optional}{type=strarr}
;-
function idldoc_class_fields, class, names=names, types=types
    compile_opt idl2

    found = 0

    catch, error_no
    if (error_no ne 0) then begin
        catch, /cancel
        return, 0
    endif

    old_quiet = !quiet
    !quiet = 1
    statement = 'fields = { ' + class + ' }'
    @idldoc_execute
    ;result = execute('fields = { ' + class + ' }', 1, 1)
    !quiet = old_quiet

    found = result

    if (found) then begin
        names = tag_names(fields)
        types = strarr(n_elements(names))
        for i = 0, n_elements(names) - 1 do begin
             type = size(fields.(i), /type)
             if (type eq 8 or n_elements(fields.(i)) gt 1) then begin
                types[i] = idldoc_idl_declaration(fields.(i))
             endif else begin
                types[i] = type_name(type)
             endelse
        endfor
    endif

    return, found
end