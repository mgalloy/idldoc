;+
; This function returns the minimum and maximum value of an array of
; real-valued numbers. (It's more convenient than calling MIN and MAX
; separately.) No type conversion is performed on the input, though
; basic type checking is.
;
; @param x {in}{type=numeric} An array of real-valued numbers.
; @keyword range {optional}{out}{type=numeric} Set to a named variable
;  to return the range of the input array.
; @keyword _ref_extra {optional} Keyword inheritance,
;  pass-by-reference. Used for exchanging info with MIN and MAX. See
;  the Online Help for keywords for these routines.
; @keyword subscript_min {optional}{out}{type=numeric} Returns the
;  index of the minimum value of the input array.
; @returns A two-element array giving the minimum and maximum values
;  of the input array
; @examples
; <pre>
; IDL> x = randomn(1L, 5)*2
; IDL> print, x
;     -1.67371    -0.344560     0.374235      3.23088    -0.353548
; IDL> print, minmax(x, range=r)
;     -1.67371      3.23088
; IDL> print, r
;      4.90459
; </pre>
; @requires IDL 6.0
; @author Mark Piper, 2003
; @history
; <ul>
; <li> 2004-02, MP: Added RANGE keyword.
; <li> 2005-09, MP: Added _REF_EXTRA and SUBSCRIPT_MIN keywords. Added
; parameter-checking code.
; </ul>
;-
function minmax, x, range=r, subscript_min=i_min, _ref_extra=e
    compile_opt idl2

    ;; Exit if the input parameter doesn't exist or isn't real-valued.
    xtype = size(x, /type)
    switch 1 of
        n_params() eq 0 : 
        xtype eq 0 :
        xtype ge 6 && xtype le 11 : begin
            message, 'Real-valued input array required.', /info
            return, 0
        end
    endswitch

    xmin = min(x, i_min, max=xmax, _extra=e)
    if arg_present(r) then r = xmax-xmin
    return, [xmin, xmax]
end
