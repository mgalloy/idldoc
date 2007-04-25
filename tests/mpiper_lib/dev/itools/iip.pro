;+
; The launch routine for the iIP iTool. iIP is iImage with a custom
; panel replacing the standard iImage panel.
;
; <p> Compare with <b>example4tool__define.pro</b> in the
; <b>examples/doc/itools</b> directory.
;
; @todo Figure out how to display both the standard iImage panel and
; this new panel in iImage's sidebar.
;
; @keyword identifier {in}{type=float} A positional parameter.
; @keyword _extra Keyword inheritance.
;
; @uses IIP_PANEL, IIP__DEFINE
; @requires IDL 6.1
; @author Mark Piper, RSI, 2004
;-
pro iip, $
    identifier=id, $
    _extra=e
    compile_opt idl2

    itregister, 'iImage panel example', 'iip'
    
    ;; Register the user interface panel, setting the TYPE
    ;; keyword. Must match the type set in the class definition.
    itregister, 'IP Panel for iImage', 'iip_panel', $
        type='iip', /ui_panel


    id = idlitsys_createtool('iImage panel example', $
        visualization_type = ['Image'], $
        title = 'iImage with an image processing panel', $
        _extra=e)
end
