;2345678901234567890123456789012345678901234567890123456789012345678901234567890

;+
; Determines if the widget hierarchy exists.
;
; @returns 1 if the widget hierarchy exists and is visible; 0 if not
; @keyword valid {out}{optional}{type=boolean} tells if the widget hierarchy
;          is valid
;-
function object_widget::is_visible, valid=valid
    compile_opt idl2

    valid = widget_info(self.tlb, /valid)
    if (valid) then return, widget_info(self.tlb, /map) else return, valid
end


;+
; Iconify the window.
;-
pro object_widget::iconify
    compile_opt idl2

    widget_control, self.tlb, iconify=1
end


;+
; Make the window disappear.
;-
pro object_widget::hide
    compile_opt idl2

    widget_control, self.tlb, map=0
end


;+
; Show the window.
;-
pro object_widget::show
    compile_opt idl2

    widget_control, self.tlb, iconify=0, map=1
end


;+
; Set the title in the title bar of the window.
;
; @param title {in}{required}{type=string} title string
;-
pro object_widget::set_title, title
    compile_opt idl2

    widget_control, self.tlb, base_set_title=title
end


;+
; Starts XMANAGER for the object-widget program.  Sets the event handler to
; "handle_events" and the cleanup routine to "cleanup_widgets".
;
; @keyword name {in}{optional}{type=string}{default="object_widget"} the name to
;          register the program under
;-
pro object_widget::start_xmanager, name=name
    compile_opt idl2

    xmanager, n_elements(name) eq 0 ? 'object_widget' : name, self.tlb, $
        /no_block, event_handler='handle_events', cleanup='cleanup_widgets'
end


;+
; Realizes the widget hierarchy.  Override and call this method if a draw
; widget's value (window ID or IDLgrWindow object reference) is needed.
;-
pro object_widget::realize
    compile_opt idl2

    widget_control, self.tlb, /realize
end


;+
; Routine to handle when the widget program dies.
;
; @abstract
;-
pro object_widget::handle_events, event
    compile_opt idl2

end


;+
; Destroys the widget hierarchy.
;-
pro object_widget::destroy_widgets
    compile_opt idl2

    widget_control, self.tlb, /destroy
end


;+
; Creates the widget hierarchy.  Save the top-level base's widget ID in the
; "tlb" field.
;
; @abstract
;-
pro object_widget::create_widgets
    compile_opt idl2

end


;+
; Routine to handle when the widget program dies.
;
; @abstract
;-
pro object_widget::cleanup_widgets, top
    compile_opt idl2

end


;+
; Define instance variables common to all object-widget programs.
;
; @file_comments Subclass this class to create an object-widget program.
; @abstract
; @field tlb top-level base's widget identifier; this is necessary to remember
;        because there are many methods that need to access the widget hierarchy
;        and it shouldn't have to be passed in
; @author Michael Galloy
; @copyright RSI, 2002
;-
pro object_widget__define
    compile_opt idl2

    define = { object_widget, $
        tlb:0L $
        }
end
