;+
; General procedural layer between widget cleanup (method) and XMANAGER.
;
; @param top {in}{type=widget ID} the top level base's widget ID
;-
pro cleanup_widgets, top
    compile_opt idl2

    widget_control, top, get_uvalue=self
    self->cleanup_widgets
end
