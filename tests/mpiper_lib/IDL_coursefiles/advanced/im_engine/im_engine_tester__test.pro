;+
; Tests whether heap variables are cleaned up correctly.
;-
function im_engine_tester::test_heap_variable_leakage
    compile_opt idl2

    @idlunit_test_catch

    help, /heap, output=h
    before = strjoin(h[0:2])

    oengine = obj_new('im_engine', *self.image)
    obj_destroy, oengine

    help, /heap, output=h
    after = strjoin(h[0:2])

    assert, before eq after, 'heap variables not cleaned up properly'
    return, before eq after
end


;+
; Tests the creation of a .sav file using the routine BUILD_IM_ENGINE.
;-
function im_engine_tester::test_save_file_build
    compile_opt idl2

    @idlunit_test_catch

    build_im_engine
    file_exists = file_test('./im_engine.sav')

    assert, file_exists, '.sav file not built'
    return, file_exists
end



pro im_engine_tester::cleanup
    compile_opt idl2, hidden

    if ptr_valid(self.image) then ptr_free, self.image
end


function im_engine_tester::init
    compile_opt idl2, hidden

    filename = filepath('rbcells.jpg', subdir=['examples', 'data'])
    self.image = ptr_new(read_image(filename))

    return, 1
end


pro im_engine_tester__test
    compile_opt idl2, hidden

    define = { $
             im_engine_tester, $
             image:ptr_new() $
             }
end
