;+
; Scales data into the range of unsigned integers, a la the builtin BYTSCL.
; <p>
;
; <b>TODO:</b> Add keywords (e.g., TYPE) to generalize this to any
; integer type.
;
; @param arr {in} An array of numeric values to be scaled.
; @keyword top {optional}{type=uint} Sets the maximum value of the
;    range into which the input data are scaled. By default, this
;    value is the top of the uint type, 2U^16-1.
; @returns An array containing the input values scaled into the unit
;    range.
; @examples
;   <code>
;   IDL> x = randomn(123, 10)*1000<br>
;   IDL> print, x<br>
;       147   -1274   1328   -238   -906   2547   -910   478
;      -376     456<br>
;   IDL> y = uintscl(x)<br>
;   IDL> print, y<br>
;       24371       0   44627   17768    6311   65535    6243
;       30049   15401   29671<br>
;   </code>
; @requires IDL 5.3
; @author Mark Piper, RSI, 2000
;-
function uintscl, arr, top=top
    compile_opt idl2

    max_arr = max(arr, min=min_arr)
    if min_arr lt 0 then arr = temporary(arr) - min_arr
    maxval = 2.0^16-1
    if n_elements(top) gt 0 then maxval = float(top) < maxval
    scale = maxval / (max_arr-min_arr)
    return, uint(scale*arr)
end

