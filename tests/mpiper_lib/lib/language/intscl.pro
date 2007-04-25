;+
; Scales data into the integer range, a la the builtin BYTSCL for
; the byte type.<p>
;
; @param arr {in} An array of numeric values to be scaled.
; @keyword top {optional}{type=uint} Sets the maximum value of the
;    range into which the input data are scaled. By default, this
;    value is the top of the uint type, 2U^16-1.
; @returns An array containing the input values scaled into the unit
;    range.
; @requires IDL 5.3
; @author Mark Piper, RSI, 2000
;-
function intscl, arr, top=top, type=type
    compile_opt idl2

    max_arr = max(arr, min=min_arr)
    if min_arr lt 0 then arr = temporary(arr) - min_arr
    maxval = 2.0^16-1
    if n_elements(top) gt 0 then maxval = float(top) < maxval
    scale = maxval / (max_arr-min_arr)
    return, uint(scale*arr)
end
