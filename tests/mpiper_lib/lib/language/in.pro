;+
; Determines if the given element is an element of the given array.
;
; @returns byte, where 0 is returned if the element is in the array and 1 if not
; @examples The following<br>
;           &nbsp&nbsp&nbsp&nbsp&nbsp<code>IDL> print, in('Mike', ['Mike', 'George', 'Henry'])</code><br>
;           should print 1.
; @param element {in} {type=any} element to be checked for inclusion
; @param array {in} {type=array} array to check
; @author Michael D. Galloy
; @copyright RSI, 2001
;-
function in, element, array
    compile_opt idl2
    on_error, 2

    if (n_params() ne 2) then $
        message, 'incorrect number of arguments'

    ind = where(array eq element, count)
    return, count gt 0
end