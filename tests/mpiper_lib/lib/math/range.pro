;+
; Gives the range (def as max - min) of an array of real (e.g., integer,
; float) numbers. No type conversion is performed.
;
; @param x {in}{type=numeric} An array of real numbers.
; @keyword minmax {optional}{type=boolean} Set to compute and return
;   the min and max values of the array.
; @keyword _extra {optional} Keyword inheritance.
; @returns The range of the data values; or, if the MINMAX keyword is
;   set, a three-element array giving range, the min value and the max
;   value of the input array.
; @requires IDL 5.3
; @author Mark Piper, RSI, 2003
;-
function range, x, minmax=m, _extra=e
    compile_opt idl2

    xmin = min(x, max=xmax, _extra=e)
    ret = xmax - xmin
    if keyword_set(m) then ret = [ret, xmin, xmax]
    return, ret
end
