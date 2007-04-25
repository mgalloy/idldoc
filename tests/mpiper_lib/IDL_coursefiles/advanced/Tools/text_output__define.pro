pro text_output::start_testing, testname, ntests
    compile_opt idl2

    print, 'Testing ' + testname + ' (' + strtrim(ntests, 2) + '):', format='(A, $)'
end


pro text_output::end_testing, passed, failed, failed_tests
    compile_opt idl2

    print, ' (' + strtrim(passed, 2) + '/' + strtrim(passed + failed, 2) + ' passed)'

    if (failed ne 0) then begin
        failed_tests_arr = failed_tests->to_array()
        failed_tests_arr = '  ' + failed_tests_arr + ' failed'
        for i = 0, n_elements(failed_tests_arr) - 1 do $
            print, failed_tests_arr[i]
    endif
end


;+
; Override to do an action when a all testing is done.
;-
pro text_output::done_testing
    compile_opt idl2

end


;+
; @param test_name {in}{type=string} name of the test case
;-
pro text_output::test_case, pass, test_name
    compile_opt idl2

    char = pass ? '.' : 'X'
    print, char, format='(A, $)'
end


pro text_output__define
    compile_opt idl2

    define = { text_output, inherits test_output }
end