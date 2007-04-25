;+
; Finds common blocks in a code block.
;
; @todo Check if line before COMMON has a continuation character
; @returns strarr or -1L if none found
; @param code {in}{required}{type=strarr} IDL code for a routine
; @keyword count {out}{optional}{type=integral} number of common blocks found
;-
function find_common, code, count=count
    compile_opt idl2

    re = '^[[:space:]]*common[[:space:]]+([a-z_][a-z0-9_$]*)'
    results = stregex(code, re, /fold_case, /subexpr, length=len)

    ind = where(results[0, *] ne -1, count)
    if (count gt 0) then begin
        return, strmid(code[ind], results[1, ind], len[1, ind])
    endif else begin
        return, -1L
    endelse
end
