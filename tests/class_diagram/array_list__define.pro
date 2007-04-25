;+
; Used internally to tell iterator that the underlying vector has been changed.
; Should only be called by methods of vector that change the vector.  This
; will cause the iterator to fail the next time the DONE or NEXT method
; is called (this iterator is "fail-fast").
;
; @private
;-
pro array_list_iterator::notify_changed
    compile_opt idl2

    self.changed = 1B
end


;+
; Determines if there are any more elements of the underlying vector to visit.
;
; @returns 1 if no more elements of the underlying vector, 0 otherwise
;-
function array_list_iterator::done
    compile_opt idl2
    on_error, 2

    if (self.changed) then message, 'underlying array_list has changed'

    return, self.pos ge self.array_list->size()
end


;+
; Returns the next elements and advances the iterator.  After an iterator is
; created, "next" will return the first element of the vector.
;
; @returns next element of the array
;-
function array_list_iterator::next
    compile_opt idl2
    on_error, 2

    if (self.changed) then message, 'underlying array_list has changed'

    return, self.array_list->get(self.pos++)
end


;+
; Frees resources.  Does not free underlying array_list, but destroying the
; underlying array_list will free its iterators.
;-
pro array_list_iterator::cleanup
    compile_opt idl2

end


;+
; Creates a array_list_iterator allowing traversal of the list.  Any changes to
; the underlying array_list will cause the iterator to produce errors if
; accessed (it is "fail-fast").
;
; @returns 1 for success
; @param array_list {in}{required}{type=vector object} the underlying array_list
;
; @examples A typical use of an iterator is:
; <pre>   iter = al->iterator()
;   while (~iter->done()) then begin
;       elem = iter->next()
;       process, elem
;   endwhile</pre>
;-
function array_list_iterator::init, array_list
    compile_opt idl2

    self.array_list = array_list
    self.pos = 0L
    self.changed = 0B

    return, 1
end


;+
; Define instance variables.
;
; @field array_list underlying array_list to iterator through
; @field pos current position in the array_list
; @field changed 1 if underlying array_list has changed since iterator has been
;        created, 0 otherwise
;-
pro array_list_iterator__define
    compile_opt idl2

    define = { array_list_iterator, $
        array_list:obj_new(), $
        pos:0L, $
        changed:0B $
        }
end


;+
; Iterators are simply objects used to loop through elements of a container.
; It is more efficient to use an iterator than to use the GET method if
; all the elements of the array_list must be looped through.  If a vectorizable
; operation must be performed on all elements of the array_list, consider using
; the TO_ARRAY method to obtain an array of the elements.
;
; <p> This iterator is "fail-fast", ie. it produces an error if the underlying
; array_list is modified (using the ADD, REMOVE, RESET, or COMPACT methods) after
; the iterator was created, but only when the iterator is accessed.  In other
; words, it is safe to create an iterator, modify the array_list, and then
; ignore or destroy the iterator. But creating an iterator, modifying the
; array_list, and then accessing the iterator through the NEXT or DONE methods
; is an error.
;
; @returns array_list_iterator object reference
; @examples A typical use of an iterator is:
; <pre>   iter = al->iterator()
;   while (~iter->done()) then begin
;       elem = iter->next()
;       process, elem
;   endwhile</pre>
;-
function array_list::iterator
    compile_opt idl2
    on_error, 2

    new = obj_new('array_list_iterator', self)
    self.iterators->add, new
    return, new
end


;+
; Determines if there are elements in the array_list.
;
; @returns 1 if array_list is empty and 0 otherwise
;-
function array_list::is_empty
    compile_opt idl2
    on_error, 2

    return, self.cur_size eq 0
end


;+
; Reset the array_list to remove all elements.
;-
pro array_list::reset
    compile_opt idl2

    ; notify iterators that vector has been modified
    iters = self.iterators->get(/all, count=count)
    for i = 0, count - 1 do $
        if (obj_valid(iters[i])) then $
            iters[i]->notify_changed

    self.cur_size = 0L
end


;+
; Swaps two values of the array_list.
;
; @param index1 {in}{required}{type=integral} index of element to swap
; @param index2 {in}{required}{type=integral} index of element to swap
;-
pro array_list::swap, index1, index2
    compile_opt idl2

    ; notify iterators that vector has been modified
    iters = self.iterators->get(/all, count=count)
    for i = 0, count - 1 do $
        if (obj_valid(iters[i])) then $
            iters[i]->notify_changed

    temp_value = (*self.data)[index1]
    (*self.data)[index1] = (*self.data)[index2]
    (*self.data)[index2] = temp_value
end


;+
; Changes the given item of the array_list to the given value
;
; @param index {in}{required}{type=int} the index of the element to change
; @param value {in}{required}{type=same as the array_list} the value to change the
;        given item to
;-
pro array_list::change, index, value
    compile_opt idl2

    case 1 of
    n_params() ne 2 : begin
            message, 'incorrect number of parameters'
        end
    self.cur_size eq 0 : begin
            message, 'attempt to access element of an empty list'
        end
    index gt self.cur_size-1 : begin
            message, 'attempt to subscript with index ' + strtrim(index, 2) $
                + ' > upper bound ' + strtrim(self.cur_size-1, 2)
        end
    index lt -self.cur_size : begin
            message, 'attempt to subscript with index ' + strtrim(index, 2) $
                + ' < lower bound ' + strtrim(-self.cur_size, 2)
        end
    else : ; no error
    endcase

    ; notify iterators that vector has been modified
    iters = self.iterators->get(/all, count=count)
    for i = 0, count - 1 do $
        if (obj_valid(iters[i])) then $
            iters[i]->notify_changed

    (*self.data)[index] = value
end


;+
; Compact the array_list to use space the most efficiently.  This could be
; useful after many removes and additions have been done.  This is mainly
; here to implement the same interface as vector.  Warning: the next add to the
; array_list will double the space used by the array_list.
;-
pro array_list::compact
    compile_opt idl2

    ; notify iterators that vector has been modified
    iters = self.iterators->get(/all, count=count)
    for i = 0, count - 1 do $
        if (obj_valid(iters[i])) then $
            iters[i]->notify_changed

    *self.data = (*self.data)[0:self.cur_size-1]
    self.max_size = self.cur_size
end


;+
; Removes an element from the array_list.
;
; @param index {in}{required}{type=int} index of the element to remove
; @keyword element {out}{optional}{type=array_list type} returns element
;          removed; this can be useful for checking or to free a dynamic
;          resource if no longer needed
;-
pro array_list::remove, index, element=element
    compile_opt idl2
    on_error, 2

    case 1 of
    n_params() ne 1 : begin
            message, 'incorrect number of parameters'
        end
    self.cur_size eq 0 : begin
            message, 'attempt to access element of an empty list'
        end
    index gt self.cur_size-1 : begin
            message, 'attempt to subscript with index ' + strtrim(index, 2) $
                + ' > upper bound ' + strtrim(self.cur_size-1, 2)
        end
    index lt -self.cur_size : begin
            message, 'attempt to subscript with index ' + strtrim(index, 2) $
                + ' < lower bound ' + strtrim(-self.cur_size, 2)
        end
    else : ; no error
    endcase

    ; notify iterators that vector has been modified
    iters = self.iterators->get(/all, count=count)
    for i = 0, count - 1 do $
        if (obj_valid(iters[i])) then $
            iters[i]->notify_changed

    element = (*self.data)[index]
    if (index ne self.cur_size - 1) then begin
        (*self.data)[index] = (*self.data)[index+1:self.cur_size-1]
    endif
    self.cur_size--
end


;+
; Retrieve elements of the array_list by index (starting at 0).  Use the get
; method to get particular elements; use an iterator to examine each element
; in order. Use to_array to perform vectorizable operations to all elements.
;
; @returns the element at the given index
; @param index {in} {type=int} the index of the element to retrieve; indices
;        begin at 0 and end at the number of elements - 1, can also use
;        negative values to count from the end of the array_list ie. -1
;        indicates the last element of the array_list
;-
function array_list::get, index
    compile_opt idl2
    on_error, 2

    case 1 of
    n_params() ne 1 : begin
            message, 'incorrect number of parameters'
        end
    self.cur_size eq 0 : begin
            message, 'attempt to access element of an empty list'
        end
    index gt self.cur_size-1 : begin
            message, 'attempt to subscript with index ' + strtrim(index, 2) $
                + ' > upper bound ' + strtrim(self.cur_size-1, 2)
        end
    index lt -self.cur_size : begin
            message, 'attempt to subscript with index ' + strtrim(index, 2) $
                + ' < lower bound ' + strtrim(-self.cur_size, 2)
        end
    else : ; no error
    endcase

    ilookup = index lt 0 ? self.cur_size + index : index
    return, (*self.data)[ilookup]
end


;+
; Add the given value(s) to the end of the array_list.
;
; @param value {in}{required}{type=scalar or array of type of array_list} the
;        value to be added; this value may be a scalar or an array of elements
;        to be added
;-
pro array_list::add, value
    compile_opt idl2
    on_error, 2

    if (n_params() ne 1) then begin
        message, 'incorrect number of parameters'
    endif

    ; notify iterators that vector has been modified
    iters = self.iterators->get(/all, count=count)
    for i = 0, count - 1 do $
        if (obj_valid(iters[i])) then $
            iters[i]->notify_changed

    if ((self.cur_size + n_elements(value)) gt self.max_size) then begin
        self.max_size *= 2
        temp_array = [*self.data, *self.data]
        *self.data = temp_array
    endif

    (*self.data)[self.cur_size] = value
    self.cur_size += n_elements(value)
end


;+
; Creates a standard IDL array to contain all the elements of the array_list.
;
; @returns an array of the type of vector or -1 if array_list is empty
; @keyword empty {out}{optional}{type=boolean} returns 1 if array_list is empty, 0
;          otherwise
;-
function array_list::to_array, empty=empty
    compile_opt idl2

    empty = self.cur_size eq 0L
    return, empty ? -1L : (*self.data)[0:self.cur_size-1]
end


;+
; Returns the number of elements in the array_list.
;
; @returns long
; @keyword type {out}{optional}{type=integral} the type of the data stored in the list
;-
function array_list::size, type=type
    compile_opt idl2
    on_error, 2

    type = self.type
    return, self.cur_size
end


;+
; Print the contents of the array_list to an LUN.
;
; @keyword lun {in}{optional}{type=int}{default=-1} logical unit number of a
;          file to print the array_list to; LUN=-1 is STDOUT
; @keyword _extra {in}{optional}{type=keywords} keywords to PRINTF
;-
pro array_list::print, lun=lun, _extra=e
    compile_opt idl2

    if (self.cur_size eq 0) then return
    ilun = n_elements(lun) eq 0 ? -1L : lun

    printf, ilun, (*self.data)[0:self.cur_size-1], _strict_extra=e
end


;+
; Free resources of the array_listbut not the resources of the elements
; of the array_list.
;-
pro array_list::cleanup
    compile_opt idl2
    on_error, 2

    if (obj_valid(self.iterators)) then obj_destroy, self.iterators
    ptr_free, self.sample_struct

    ptr_free, self.data
end


;+
; Create an array_list with the initial BLOCK_SIZE and type given by either
; EXAMPLE or TYPE.
;
; @returns 1 for success
; @keyword block_size {in}{optional}{type=integral}{default=1000} size of the
;          intial buffer; the size is doubled every time space is needed
; @keyword example {in}{optional}{type=any} an example of the variable type
;          for the array_list; EXAMPLE or TYPE is required
; @keyword type {in}{optional}{type=integral} type code (as in SIZE function)
;          for the array_list; EXAMPLE or TYPE is required
;
; @examples
; <pre>   IDL> al = obj_new('array_list', block_size=4, example='')
;   IDL> al->add, 'a'
;   IDL> print, al->size()
;            1
;   IDL> al->add, ['b', 'c', 'd']
;   IDL> print, al->size()
;            4
;   IDL> print, al->get(2), al->get(-1)
;   cd</pre>
;-
function array_list::init, block_size=block_size, example=example, type=type
    compile_opt idl2

    if (n_elements(example) eq 0 && n_elements(type) eq 0) then begin
        return, 0
    endif

    self.max_size = n_elements(block_size) eq 0 ? 1000L : block_size
    self.cur_size = 0L

    self.type = n_elements(type) eq 0 $
        ? (n_elements(example) eq 0 ? -1L : size(example, /type)) $
        : type

    if ((n_elements(example) ne 0) && (self.type eq 8)) then self.sample_struct = ptr_new(example)

    if (self.type eq 8) then begin ; type 8 is structure
        self.data = ptr_new(replicate(*self.sample_struct, self.max_size))
    endif else begin
        self.data = ptr_new(make_array(self.max_size, type=self.type, /nozero))
    endelse

    self.iterators = obj_new('IDL_Container')

    return, 1
end


;+
; Define the instance variables of the array_list.
;
; @file_comments An array_list is an object representing a variable length list
;                of scalar elements of any single type. Array_lists support
;                adding elements at the end of the vector only, but any element
;                may be removed from the array_list. An iterator is provided for
;                efficient and easy looping through the elements of the
;                array_list.
;
; @field data pointer to an array
; @field cur_size the current size of the data in the array
; @field max_size the maximum size of the data in the current array
; @field type type code (as in SIZE function) for the elements in the array_list
; @field sample_struct pointer to a structure if the type is "structure"
; @field iterators IDL_Container for the iterators of this array_list
;
; @requires IDL 6.0
;
; @categories container
;
; @author Michael D. Galloy
; @history Created September 26, 2003
; @copyright RSI, 2003
;-
pro array_list__define
    compile_opt idl2

    define = { array_list, $
        data : ptr_new(), $
        cur_size : 0L, $
        max_size : 0L, $
        type : 0L, $
        sample_struct : ptr_new(), $
        iterators : obj_new() $
        }
end
