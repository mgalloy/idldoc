;2345678901234567890123456789012345678901234567890123456789012345678901234567890

;+
; Returns the first space-delimited word on the line.
;
; @returns first "word" on the line
; @param line {in}{required}{type=string} any string
;-
function get_first_word, line
    compile_opt idl2

    tokens = strsplit(line, /extract)
    return, tokens[0]
end