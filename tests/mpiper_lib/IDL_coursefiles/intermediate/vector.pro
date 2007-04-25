;+
; Convenience function to create a vector object.
;
; @keyword _extra keywords to vector::init
; @author Michael D. Galloy
; @copyright RSI, 2002
;-
function vector, _extra=e
    compile_opt idl2

    on_error, 2
    return, obj_new('vector', _strict_extra=e)
end