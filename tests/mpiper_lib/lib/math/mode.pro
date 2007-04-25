;+
; Finds the mode (the most likely value) of an array. If more than
; one mode exists, all the mode values are returned.
;
; @param in_array {in}{type=numeric} An array of numbers.
; @returns The mode of the input array.
; @examples
; <pre>
; IDL> a = fix(randomn(123L, 5, 5)*10)
; IDL> print, mode(a)
;        4
; IDL> b = [2, 2, 2, 3, 3, 3]
; IDL> print, mode(b)
;        2       3
; </pre>
; @requires IDL 5.6
; @author Mark Piper, RSI, 2005
; @todo Make this routine work.
; @bugs Works for integers, but not for reals with fractions.
;-
function mode, in_array
	compile_opt idl2
	on_error, 2

	; HISTOGRAM uses a bin size of 1 by default.
	h = histogram(in_array, locations=x, /nan)
	i_mode = where(h eq max(h))
	return, x[i_mode]
end