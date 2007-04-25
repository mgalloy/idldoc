;+
; General procedural layer between an event handler (method) and XMANAGER.
;
; @param event {in}{type=event structure} any event type
;-
pro handle_events, event
    compile_opt idl2
    ;on_error, 2

    widget_control, event.top, get_uvalue=self
    self->handle_events, event
end
