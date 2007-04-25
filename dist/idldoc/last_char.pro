;2345678901234567890123456789012345678901234567890123456789012345678901234567890

;+
; Finds the last character of the line.
;
; @returns last character of the given line
; @param line {in}{required}{type=string} any string
;-
function last_char, line
    compile_opt idl2

    return, strmid(line, 0, 1, /reverse_offset)
end