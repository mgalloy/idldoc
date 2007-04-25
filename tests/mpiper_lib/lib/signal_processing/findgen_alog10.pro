;+
; This function returns a sequence of numbers that are evenly
; distributed on a log base 10 axis.
;
; @param minp {in}{type=float} The minimum value in the sequence.
; @param maxp {in}{type=float} The maximum value in the sequence.
; @param n_elts {in}{type=long} The number of elements in the sequence.
; @keyword double {optional}{type=boolean} Set this keyword to use double
;   precision. Default is single-precision floating point.
; @returns A vector of values evenly spaced in log base 10.
; @requires IDL 5.2 or greater
; @examples
; <code>
; IDL> a = findgen_alog10(1, 100, 12, /double)<br>
; IDL> plot, a, /ylog, psym=5, ytitle='a'<br>
; </code>
;
; @author Mark Piper, 1996
;-

function findgen_alog10, minp, maxp, n_elts, double=d
    compile_opt idl2
    on_error, 2

    ; Check for three arguments.
    if n_params() ne 3 then begin
        message, 'Minimum value, maximum value and number of elements' $
            + ' needed.', /continue
        return, 0
    endif

    ; Compute the log base 10 value of the min and max points.
    x = alog10(minp)
    y = alog10(maxp)

    ; Create a vector of values between x and y.
    rtype = keyword_set(d) ? 5 : 4
    z = ((y-x)/(n_elts-1))*indgen(n_elts, type=rtype) + x

    ; Return the values in base 10.
    return, 10.0^z
end