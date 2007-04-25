;2345678901234567890123456789012345678901234567890123456789012345678901234567890

;+
; Concatenate the elements of a string together with a space as a delimiter.
;
; @returns string
; @param str_arr {in}{required}{type=string array} string array of elements
; @keyword start {in}{optional}{type=string} string added to the front of the
;          result
;-
function add_lines, str_arr, start=start
    compile_opt idl2
    on_error, 2

    i_start = n_elements(start) eq 0 ? '' : start
    return, i_start + strcompress(strjoin(str_arr, ' '))
end
