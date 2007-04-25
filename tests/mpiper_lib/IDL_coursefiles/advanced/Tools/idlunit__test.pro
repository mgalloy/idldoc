function idlunit::test_A
    compile_opt idl2
    @idlunit_test_catch

    wait, a
    return, 1
end


function idlunit::test_1
    compile_opt idl2
    @idlunit_test_catch

    wait, a
    return, 1
end


function idlunit::test_2
    wait, 1
    return, 1
end


function idlunit::another_method
end


function idlunit::init

    return, 1
end

pro idlunit__test
    compile_opt idl2

    define = { idlunit, $
        empty:'' $
        }
end