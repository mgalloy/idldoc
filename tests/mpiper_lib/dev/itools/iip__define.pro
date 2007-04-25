;============================================================================
;+
; The class constructor, used to call the superclass' init method.
;
; <p> Note that the TYPE keyword must be set on the call to the
; superclass' init method and the value must match that in the call to
; ITREGISTER in the launch routine, IIP.
;
; @keyword _ref_extra Pass-by-reference keyword inheritance mechanism.
; @returns 1 on success, 0 on failure.
;-
function iip::init, _ref_extra=re
    compile_opt idl2

   if (self->idlittoolbase::init(type='iip', _extra=re) eq 0) then $
       return, 0

   return, 1
end



;============================================================================
;+
; The class data definition routine, used here to inherit the standard
; iTool interface and functionality from the IDLitToolbase class.
;
; @file_comments This class serves to define what UI components from
;   the standard iTool system should be included in or discarded from
;   the iIP interface.
;
; <p> Compare with <b>example4tool__define.pro</b> in the
; <b>examples/doc/itools</b> directory.
;
; @inherits IDLitToolbase
; @requires IDL 6.1
; @author Mark Piper, RSI, 2004
;-
pro iip__define

    a = {iip, $
         inherits idlittoolbase $ 
        }
end

