;+
; Runs unit tests.
;
; @keyword root {in}{type=string} root directory for of idlunit search for
;          '__test.pro' files
; @keyword widget {in}{optional}{type=boolean} set to use a widget interface
;          instead of output to stdout
;-
pro idlunit, root=root, widget=widget
    compile_opt idl2
    on_error, 2

    if (n_elements(root) eq 0) then begin
        if (not keyword_set(widget)) then begin
            message, 'ROOT keyword required'
        endif else begin
            root = dialog_pickfile(/directory)
        endelse
    endif

    test_files = file_search(root, '*__test.pro', count=count)
    if (count eq 0) then begin
        print, 'No tests found'
        return
    endif

    output = keyword_set(widget) ? obj_new('widget_output') : obj_new('text_output')

    for i = 0, n_elements(test_files) - 1 do begin
        suite = obj_new('test_suite', test_files[i], output=output)
        suite->run
        obj_destroy, suite
    endfor

    output->done_testing

    obj_destroy, output
end