;=========================================================================
;+
; Displays an error message.
;-
pro imageprocessor_error
    compile_opt idl2

    ; Display an error message in a dialog box.
    err_msg = ['This image cannot be viewed with this utility.', $
        'Please select another image.']
    ok = dialog_message(err_msg)
end