;+
; Get properties of the test_suite.
;
; @keyword passed {out}{optional}{type=integral} number of passed tests
; @keyword failed {out}{optional}{type=integral} number of failed tests
;-
pro test_suite::get, passed=passed, failed=failed
    compile_opt idl2

    passed = self.passed
    failed = self.failed
end




;+
; Run the tests of the given test scenario.
;-
pro test_suite::run
    compile_opt idl2

    ; Strip basename from filename
    base_pos = strpos(self.filename, path_sep(), /reverse_search)
    basename = base_pos eq -1 ? self.filename : strmid(self.filename, base_pos + 1)
    pro_pos = strpos(basename, '.')
    pro_name = strmid(basename, 0, pro_pos)
    test_pos = strpos(pro_name, '__test')
    self.testname = strmid(pro_name, 0, test_pos)

    ; Create test object
    call_procedure, pro_name

    ; Find test methods
    help, /routines, output=all_routines
    search_string = strupcase('^' + self.testname + '::test')
    results = stregex(all_routines, search_string)
    indices = where(results eq 0, count)

    ; Exit if not tests found
    if (count eq 0) then return

    test_object = obj_new(self.testname)

    test_methods = all_routines[indices]
    test_methods = stregex(test_methods, search_string + '[A-Z|0-9|$|_]*', /extract)
    self.tests = n_elements(test_methods)
    self.output->start_testing, self.testname, n_elements(test_methods)

    ; Run test methods
    for i = 0, n_elements(test_methods) - 1 do begin
        result = call_method(test_methods[i], test_object)
        if (result) then begin
            self.passed = self.passed + 1
        endif else begin
            self.failed = self.failed + 1
            self.failed_tests->add, test_methods[i]
        endelse
        self.output->test_case, result, test_methods[i]
    endfor

    obj_destroy, test_object

    self.output->end_testing, self.passed, self.failed, self.failed_tests
end


;+
; Nothing to do.
;-
pro test_suite::cleanup
    compile_opt idl2

    obj_destroy, self.failed_tests
end


;+
; Define test object.
;
; @returns 1 if successful, 0 otherwise
; @param filename {in}{type=string}
; @keyword output {in}{type=object ref} subclass of test_output class
;-
function test_suite::init, filename, output=output
    compile_opt idl2
    on_error, 2

    if (n_elements(filename) eq 0) then return, 0
    if (not file_test(filename)) then return, 0
    if (not obj_valid(output)) then return, 0

    self.filename = filename
    self.passed = 0L
    self.failed = 0L
    self.failed_tests = obj_new('vector', example='')
    self.output = output

    return, 1
end


;+
; Represents a test scenario and all of its related tests.
;-
pro test_suite__define
    compile_opt idl2

    define = { test_suite, $
        filename:'', $
        testname:'', $
        tests:0L, $
        passed:0L, $
        failed:0L, $
        failed_tests:obj_new(), $
        output:obj_new() $
        }
end