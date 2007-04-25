;+
; This is the event handler for the program resizing_widgets.
;
; @param event {in}{type=structure} The event structure passed by xmanager.
;-
pro resizing_widgets_event, event

    if tag_names(event, /structure_name) eq 'WIDGET_BASE' then begin
        butn1 = widget_info(event.top, find_by_uname='butn1')
        butn2 = widget_info(event.top, find_by_uname='butn2')
        widget_control, butn1, xsize=event.x/2-2, ysize=event.y-2
        widget_control, butn2, xsize=event.x/2-2, ysize=event.y-2
    endif

end

;+
; This program shows how to dynamically resize a basic widget from
; IDL's Widget Toolkit. A button widget is used in this example.
; Note that resizing only occurs when the resize keyword has been set.
;
; @keyword resize {in}{type=boolean}{optional} Set this keyword to signal
;       top-level base resize events.
; @author Mark Piper, 2002
; @copyright RSI
;-
pro resizing_widgets, resize=resize

    top = widget_base(tlb_size_events=keyword_set(resize), /row)

    butn1 = widget_button(top, value='Button One', uname='butn1')
    butn2 = widget_button(top, value='Button Two', uname='butn2')

    widget_control, top, /realize

    xmanager, 'resizing_widgets', top

end