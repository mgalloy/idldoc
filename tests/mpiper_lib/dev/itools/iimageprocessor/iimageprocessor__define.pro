;+
; The class constructor, used to call the superclass' init method,
; register the visualization type we want to employ and unregister UI
; components from the standard iTool interface.
;
; @keyword _ref_extra Pass-by-reference keyword inheritance mechanism.
; @returns 1 on success, 0 on failure.
;-
function iimageprocessor::init, _ref_extra=re
    compile_opt idl2

    if (self->idlittoolbase::init(_extra=re) eq 0) then return, 0

    ;; Register the image visualization.
    self->registervisualization, 'Image', 'IDLitVisImage', icon='image'

    ;; Remove some of the standard iTool operations and manipulators
    ;; from the Window menu.
    self->unregister, 'operations/window/fittoview'
    self->unregister, 'operations/window/data manager'
    self->unregister, 'operations/window/layout'

    return, 1
end



;+
; The class data definition routine, used here to inherit the standard
; iTool interface and functionality from the IDLitToolbase class.
;
; @file_comments This class serves to define what UI components from
;   the standard iTool system should be included in or discarded from
;   the custom iImageprocessor interface.
;
; <p> Compare with <b>example1tool__define.pro</b> and
; <b>example2tool__define.pro</b> in the <b>examples/doc/itools</b>
; directory.
;
; @inherits IDLitToolbase
; @requires IDL 6.1
; @author Mark Piper, RSI, 2004
;-
pro iimageprocessor__define

    a = {iimageprocessor, $
         inherits idlittoolbase $
        }
end
