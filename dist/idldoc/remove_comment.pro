;2345678901234567890123456789012345678901234567890123456789012345678901234567890

;+
; Removes comments from a line of IDL code.
;
; @returns given line with the removal of any comments
; @param line {in}{required}{type=string} a line of IDL code
;-
function remove_comment, line
    compile_opt idl2

    ret_line = line

    com_pos = strpos(ret_line, ';')
    if (com_pos ne -1) then $
        ret_line = strmid(line, 0, com_pos-1 > 0)

    return, strtrim(ret_line, 2)
end
