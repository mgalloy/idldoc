;+
; Override to do an action when a test suite begins testing.
;
; @abstract
; @param testname {in}{type=string} name of the test
; @param ntests {in}{type=integral} number of tests
;-
pro test_output::start_testing, testname, ntests
    compile_opt idl2

end



;+
; Override to do an action when a test suite finishes testing.
;
; @abstract
; @param passed {in}{type=integral} number of passed tests
; @param failed {in}{type=integral} number of failed tests
; @param failed_tests {in}{type=object ref} vector of string test names
;-
pro test_output::end_testing, passed, failed, failed_tests
    compile_opt idl2

end


;+
; Override to do an action when a all testing is done.
;
; @abstract
;-
pro test_output::done_testing
    compile_opt idl2

end


;+
; Override to do an action when a test case passes or fails.
;
; @abstract
; @param pass {in}{type=boolean} 0 (fail) or 1 (pass)
; @param test_name {in}{type=string} name of the test case
;-
pro test_output::test_case, pass, test_name
    compile_opt idl2

end


pro test_output__define
    compile_opt idl2

    define = { test_output, empty:'' }
end