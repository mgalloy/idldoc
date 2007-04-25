idlunit_test_catch_error_number = 0
catch, idlunit_test_catch_error_number
if (idlunit_test_catch_error_number ne 0) then begin
    catch, /cancel
    return, 0 ; fail the test if any error occurs
endif