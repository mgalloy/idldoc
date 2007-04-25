;+
; Checks a condition and throws an error if not true.
;
; @param condition {in}{type=boolean} condition to check
; @param fail_message {in}{optional}{type=string} error message to pass MESSAGE
;-
pro assert, condition, fail_message
    compile_opt idl2

    on_error, 2

    if (n_elements(fail_message) eq 0) then fail_message = 'Error'
    if (not condition) then message, fail_message
end
