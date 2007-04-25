;+
; Tests the ADD method.
;-
function vector_tester::test_add
    compile_opt idl2

    @idlunit_test_catch

    v = vector(example='', block=2)
    v->add, '0'
    v->add, '1'
    v->add, '2'
    v->add, '3'
    v->remove, 2
    arr = v->to_array()
    assert, (size(arr, /dimensions))[0] eq 3, 'array incorrect size'

    iter = v->iterator()
    iter_arr = make_array(v->size(), type=7)
    for i = 0, v->size() - 1 do $
        iter_arr[i] = iter->next()
    assert, array_equal(arr, iter_arr), $
        'iterator array not equal to to_array'

    obj_destroy, v

    return, 1
end


;+
; Tests whether the iterator will fail if the vector is changed.
;-
function vector_tester::test_safe_iterator_add
    compile_opt idl2

    catch, errornum
    if (errornum ne 0) then begin
        catch, /cancel
        if obj_valid(v) then obj_destroy, v
        if obj_valid(iter) then obj_destroy, iter
        return, 1
    endif

    v = vector(example='', block=2)
    v->add, '0'
    iter = v->iterator()
    v->add, '1'
    element = iter->next() ; this should fail

    obj_destroy, [v, iter]

    return, 0
end


;+
; Tests whether the iterator will fail if the vector is changed.
;-
function vector_tester::test_safe_iterator_remove
    compile_opt idl2

    errornum = 0
    catch, errornum
    if (errornum ne 0) then begin
        catch, /cancel
        if obj_valid(v) then obj_destroy, v
        return, 1
    endif

    passed = 0

    v = vector(example='', block=2)
    v->add, '0'
    iter = v->iterator()
    v->remove, 0
    element = iter->next() ; this should fail

    obj_destroy, v
    assert, 0, 'iterator should have failed'

    return, passed
end


;+
; Tests speed of creation of large vector.
;-
function vector_tester::test_creation_speed
    compile_opt idl2

    @idlunit_test_catch

    bsize = 100L
    n_elements = 100000L

    t0 = systime(1)
    v = vector(example='', block_size=bsize)
    for i = 0, n_elements - 1 do $
        v->add, strtrim(i, 2)
    obj_destroy, v
    t1 = systime(1)

    assert, (t1 - t0) le 4.5, 'too slow on creation'
    return, 1
end


;+
; Tests the speed of the iterator.
;-
function vector_tester::test_iteration_speed
    compile_opt idl2

    @idlunit_test_catch

    bsize = 100L
    n_elements = 100000L

    v = vector(example='', block_size=bsize)
    for i = 0, n_elements - 1 do $
        v->add, strtrim(i, 2)
    t0 = systime(1)
    iter = v->iterator()
    while(not iter->done()) do a = iter->next()
    t1 = systime(1)
    obj_destroy, v

    assert, (t1 - t0) le 3.7, 'iterator too slow'
    return, 1
end


pro vector_tester::cleanup
    compile_opt idl2, hidden

end


function vector_tester::init
    compile_opt idl2, hidden

    return, 1
end


pro vector_tester__test
    compile_opt idl2, hidden

    define = { vector_tester, empty:'' }
end
