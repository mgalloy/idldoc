;+
; Many widget program keep the name of the data file currently loaded displayed
; in the titlebar for the widget. The titlebar will look like:
; "Object Widget Program - [ctscan.dat*]".
;
; @param filename {in}{required}{type=string} current filename of the
;        "data file" the widget program is examining
; @keyword modified {in}{optional}{type=boolean}{default=0B} set to make the
;          current data file as having been modified since opened
;
;-
pro objectwidget::setCurrentFilename, filename, modified=modified
    compile_opt strictarr

    title = self.name $
        + (n_elements(filename) eq 0 $
            ? '' $
            : ' - [' + filename + (keyword_set(modified) ? '*' : '') + ']')
    widget_control, self.tlb, base_set_title=title
end


;+
; Only event handler. Subclasses must provide an event handler which all events
; will pass through.
;
; @abstract
;-
pro objectwidget::handleEvents, event
    compile_opt strictarr

    ; implemented by derived classes
end


;+
; Widget cleanup.
;
; @abstract
;-
pro objectwidget::cleanupWidgets
    compile_opt strictarr

    ; implemented by derived classes
end


;+
; Create the widget hierarchy. Make sure to store the top-level base's widget
; identifier in the tlb instance variable.
;
; @abstract
;-
pro objectwidget::createWidgets
    compile_opt strictarr

    ; implemented by derived classes
end


;+
; Realize the widget hierarchy.
;-
pro objectwidget::realizeWidgets
    compile_opt strictarr

    widget_control, self.tlb, /realize
end


;+
; Start XMANAGER.
;-
pro objectwidget::startXmanager
    compile_opt strictarr

    xmanager, idl_validname(self.name, /convert_all) , self.tlb, $
        no_block=~self.blocking, $
        cleanup='cleanup_widgets', $
        event_handler='handle_events'
end


;+
; Cleanup object's resources.
;-
pro objectwidget::cleanup
    compile_opt strictarr

    ; nothing needs to be done since we haven't claimed any resources.
end


;+
; Initialize object's instance variables.
;
; @keyword blocking {in}{optional}{type=boolean}{default=0B} set to make the
;          widget block
; @keyword name {in}{optional}{type=string}{default=subclass name} name of
;          the widget program, used in titlebar and for XMANAGER
;-
function objectwidget::init, blocking=blocking, name=name
    compile_opt strictarr

    self.blocking = keyword_set(blocking)
    self.name = n_elements(name) eq 0L ? obj_class(self) : name

    return, 1B
end


;+
; The tlb's widget identifier is needed to control the widget program.
;
; @file_comments An ObjectWidget is a widget program written as an object.
;
; @field tlb the top level base's widget identifier
; @field blocking boolean flag set if blocking widget program
; @field name string name for the ObjectWidget program
;-
pro objectwidget__define
    compile_opt strictarr

    define = { objectwidget, $
        tlb : 0L, $
        blocking : 0B, $
        name : '' $
        }
end