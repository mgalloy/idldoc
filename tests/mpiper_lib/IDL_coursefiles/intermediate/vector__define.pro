;+
; Reset the vector to remove all elements.
;-
pro vector::reset
    compile_opt idl2

    on_error, 2

    current = self.next

    while (obj_valid(current)) do begin
        next = current.next
        obj_destroy, current, /single
        current = next
    endwhile

    self.used = 0
    self.last = obj_new()
end


;+
; Changes the given item of the vector to the given value
;
; @param index {in}{type=integer} the index of the element to change
; @param value {in}{type=vector's element type} the value to change the given
;        item to
;-
pro vector::change, index, value
    compile_opt idl2

    on_error, 2

    if ((index lt 0) or $
        ((index ge self.used) and not obj_valid(self.next))) then $
            message, 'index out of bounds'

    if (index ge self.used) then $
        self.next->change, index - self.used, value $
    else $
        (*self.ptr)[index] = value
end


;+
; Retrieve the given element of the vector.
;
; @returns the element at the given index
; @param index {in}{type=integer} the index of the element to retrieve;
;        indices begin at 0 and end at the number of elements - 1
;-
function vector::get, index
    compile_opt idl2

    on_error, 2

    if ((index lt 0) or $
        ((index ge self.used) and not obj_valid(self.next))) then $
            message, 'index out of bounds'

    if (index ge self.used) then $
        return, self.next->get(index - self.used) $
    else $
        return, (*self.ptr)[index]
end


;+
; Add the given value to the end of the vector.
;
; @param value {in}{type=the vector's element type} the value to be added
;        to the end of the vector
;-
pro vector::add, value
    compile_opt idl2

    on_error, 2

    current = self

    if (obj_valid(self.last)) then $
        current = self.last

    if (current.used ge current.block_size) then begin
        new = obj_new('vector', $
            block_size=self.block_size, $
            type=self.type)
        current.next = new
        self.last = new
        current = new
    endif

    (*current.ptr)[current.used] = value
    current.used = current.used + 1
end


;+
; Returns the number of elements in the vector
;
; @returns number of elements in the vector
;-
function vector::size
    compile_opt idl2

    on_error, 2

    if (obj_valid(self.next)) then $
        return, self.used + self.next->size() $
    else $
        return, self.used
end


;+
; Print the contents of the vector to the output log or optionally to a file.
;
; @keyword lun {in}{optional}{type=logical unit number}{default=-1 (stdout)}
;          logical unit number of a file to print the vector to
;-
pro vector::print, lun=lun
    compile_opt idl2

    on_error, 2

    if (self.used eq 0) then return

    print, (*self.ptr)[0:(self.used - 1)]
    if (obj_valid(self.next)) then self.next->print
end



;+
; Cleanup resources.
;
; @keyword single {in}{optional}{type=boolean}{default=false} set to cleanup
;          just this vector and not those pointed to by self.next; used
;          internally
;-
pro vector::cleanup, single=single
    compile_opt idl2

    on_error, 2

    ptr_free, self.ptr

    if (keyword_set(single)) then return

    current = self.next

    while (obj_valid(current)) do begin
        next = current.next
        obj_destroy, current, /single
        current = next
    endwhile
end


;+
; Create the vector with a given block size and variable type.
;
; @keyword block_size {in}{optional}{type=numeric}{default=100} the size of
;          node in the vector list
; @keyword example {in}{optional}{type=any IDL variable type} example data of
;          the same type that the vector should be made; the actual data is
;          not used or stored.  One of EXAMPLE or TYPE must be present.
; @keyword type {in}{optional}{type=int} the type code returned from
;          size(/type) of the vector. One of EXAMPLE or TYPE must be present.
;-
function vector::init, block_size=block_size, example=example, $
    type=type

    compile_opt idl2

    on_error, 2

    if (n_elements(block_size) eq 0) then block_size = 1000

    ex_pres = n_elements(example) ne 0
    type_pres = n_elements(type) ne 0

    if (ex_pres and type_pres) then $
        message, 'EXAMPLE and TYPE keywords are mutually exclusive'

    if ((not ex_pres) and (not type_pres)) then $
        message, 'one of EXAMPLE and TYPE keywords necessary'

    if (ex_pres) then type = size(example, /type)

    if (block_size le 0) then $
        message, 'BLOCK_SIZE must be greater than zero'

    self.block_size = block_size
    self.type = type
    self.ptr = ptr_new(make_array(block_size, type=type, /nozero))
    self.used = 0
    self.next = obj_new()
    self.last = obj_new()

    return, 1
end


;+
; Variable length vector that does not allow removes.
;
; @author Michael D. Galloy
; @copyright RSI, 2002
;-
pro vector__define
    compile_opt idl2

    on_error, 2

    define = { vector, $
        block_size:0L, $
        used:0L, $
        type:0L, $        ; type code as returned by size function
        ptr:ptr_new(), $
        next:obj_new(), $
        last:obj_new() $
        }
end
