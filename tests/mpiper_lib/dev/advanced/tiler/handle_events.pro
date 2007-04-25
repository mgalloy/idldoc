;+
; The event handler for an object widget program. This requires the object
; widget program to store its own object reference in the top-level base's
; UVALUE and to implement a method: "pro classname::handleEvents, event".
;
; @param event {in}{required}{type=structure} event structure
;-
pro handle_events, event
    compile_opt strictarr

    widget_control, event.top, get_uvalue=owidget
    owidget->handleEvents, event
end
