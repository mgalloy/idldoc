;+
; Print any message required when a test scenario finishes.
;-
pro idlunit_test::finish_test
    compile_opt idl2

    if (not self.widget) then print
end


;+
; Do the appropriate action when a test passes or fails.
;
; @param status {in}{type=integral type} 0 (fails) or 1 (succeeds)
;-
pro idlunit_test::print_test, status
    compile_opt idl2

    if (self.widget) then begin
        call_procedure, self.callback, status
    endif else begin
        char = status ? '.' : 'X'
        print, char, format='(A, $)'
    endelse
end


;+
; Print a message to a text widget or stdout.
;
; @param message {in}{type=string} message to print
;-
pro idlunit_test::print, message
    compile_opt idl2

    if (self.widget) then begin
        widget_control, self.text_widget, set_value=message
    endif else begin
        print, message, format='(A, $)'
    endelse
end


;+
; Run the tests of the given test scenario.
;-
pro idlunit_test::run
    compile_opt idl2

    ; Strip basename from filename
    base_pos = strpos(self.filename, path_sep(), /reverse_search)
    basename = base_pos eq -1 ? self.filename : strmid(self.filename, base_pos + 1)
    pro_pos = strpos(basename, '.')
    pro_name = strmid(basename, 0, pro_pos)

    ; Create test object
    call_procedure, pro_name
    test_object = obj_new(pro_name)
    message = 'Testing ' + pro_name

    ; Find test methods
    help, /routines, output=all_routines
    ; TODO: finish this!

    ; Run test methods
    for i = 0, n_elements(test_methods) - 1 do begin
        result = call_method(test_methods[i])
        if (result) then begin
            self.passed = self.passed + 1
        endif else begin
            self.failed = self.failed + 1
        endelse
    endfor
end


;+
; Nothing to do.
;-
pro idlunit_test::cleanup
    compile_opt idl2

end


;+
; Define test object.
;
; @returns 1 if successful, 0 otherwise
; @param filename {in}{type=string}
; @keyword callback {in}{optional}{type=string} procedure to call when tests
;          passes or fails; one argument 0 (fails) or 1 (passes); required if
;          WIDGET keyword set
; @keyword text_widget {in}{optional}{type=widget ID} text widget that run
;          method can write messages to; required if WIDGET keyword set
; @keyword widget {in}{optional}{type=boolean} set for communication with
;          widget interface
;-
function idlunit_test::init, filename, callback=callback, $
    text_widget=text_widget, widget=widget

    compile_opt idl2

    if (n_elements(filename) eq 0) then message, 'filename argument required'
    if (not file_test(filename)) then message, 'filename does not exist'

    self.filename = filename
    self.passed = 0L
    self.failed = 0L

    self.widget = keyword_set(widget)
    self.callback = n_elements(callback) eq 0 ? '' : callback
    self.text_widget = n_elements(text_widget) eq 0 ? 0L : text_widget
end


;+
; Represents a test scenario and all of its related tests.
;-
pro idlunit_test__define
    compile_opt idl2

    define = { idlunit_test, $
        filename:'', $
        widget:0, $
        text_widget:0L, $
        callback:'', $
        passed:0L, $
        failed:0L $
        }
end
