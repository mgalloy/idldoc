; Inherited:
; size
; is_empty

function hash_set::in, element
    compile_opt idl2

    val = self->get(element, found=found)
    return, found
end


function hash_set::to_array, count
    compile_opt idl2

    return, self->keys(count)
end


pro hash_set::add, element, found=found
    compile_opt idl2

    self->put, element, 1B, found=found
end


pro hash_set::cleanup, clean=clean
    compile_opt idl2

    self->hash_table::cleanup, clean=clean
end


function hash_set::init, type=type, array_size=array_size
    compile_opt idl2

    return, self->hash_table::init(key_type=type, array_size=array_size, $
        value_type=1)
end


pro hash_set__define
    compile_opt idl2

    define = { hash_set, inherits hash_table }
end