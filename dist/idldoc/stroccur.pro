;2345678901234567890123456789012345678901234567890123456789012345678901234567890

;+
; Finds the positions in an expression which match any of the letters in a
; search string.
;
; @returns array of string positions or -1 if the search string is not found
; @param expression {in}{required}{type=string}
; @param search_string {in}{required}{type=string} string of letters to check
;        for in the expression
; @keyword count {out}{optional}{type=integral} number of occurrences of the
;          of letters from the search string
;-
function stroccur, expression, search_string, count=count
    compile_opt idl2

    ex_byte = byte(expression)
    ss_byte = byte(search_string)

    result = bytarr(n_elements(ex_byte))
    for i = 0, n_elements(ss_byte) - 1 do begin
        result = result or (ex_byte eq ss_byte[i])
    endfor

    return, where(result eq 1, count)
end