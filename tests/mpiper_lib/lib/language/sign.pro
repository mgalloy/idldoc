;+
; A function that returns the mathematical sign (positive/negative) of
; its input, which can be a scalar or an array of numeric type. Type
; checking of the input is provided.
;
; @example
;   <pre>
;   IDL> print, sign(54)
;              1
;   IDL> print, sign(-6.33)
;             -1
;   IDL> a = [54, 0, -6.33]
;   IDL> print, sign(a)
;              1           0          -1
;   </pre>
; @bugs It seems like there should be a cleaner algorithm than the one
;   I've used.
;
; @param input {in}{type=numeric} A scalar or array of a real, numeric
;   type.
; @returns 1L if the input is greater than zero, -1L if the input is
;   less than zero, 0L if the input is zero.
; @requires IDL 6.0
; @author Mark Piper, RSI, 2004
;-
function sign, input
    compile_opt idl2, logical_predicate
    on_error, 2

    type = size(input, /type)
    if (type eq 0) || (type ge 6 && type le 11) then $
        message, 'Need input parameter of real, numeric type.'

    return, -long(input lt 0) + long(input gt 0)
end
