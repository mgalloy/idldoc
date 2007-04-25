;+
; The cleanup for an object widget program. This requires the object
; widget program to store its own object reference in the top-level base's
; UVALUE and to implement a method: "pro classname::cleanupWidgets".
;
; @param event {in}{required}{type=structure} event structure
;-
pro cleanup_widgets, tlb
    compile_opt strictarr

    widget_control, tlb, get_uvalue=owidget
    owidget->cleanupWidgets
end
