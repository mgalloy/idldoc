;+
; Return an array of object references of IDLdcRoutines marked with the given
; tag.
;
; @returns array of IDLdcRoutines or -1L
; @param tag {in}{required}{type=string} category
; @keyword count {out}{optional}{type=long} number of IDLdcRoutines returned
;-
function idldoctaglisting::getRoutines, tag, count=count
    compile_opt strictarr

    list = self->get(tag, found=found)
    if (~found) then begin
        count = 0L
        return, -1L
    endif else begin
        count = list->size()
        return, list->to_array()
    endelse
end


;+
; Returns the distinct tags found in the listing.
;
; @returns string array or -1L
; @keyword count {out}{required}{type=long} number of distinct tags found in
;          listing
;-
function idldoctaglisting::getTags, count=count
    compile_opt strictarr

    return, self->keys(count)
end


;+
; Add a tag (which may or may not already be in the IDLdocTagListing) for a
; given routine.
;
; @param tag {in}{required}{type=string} category
; @param oroutine {in}{required}{type=objref} IDLdcRoutine object
;-
pro idldoctaglisting::addTag, tag, oroutine
    compile_opt strictarr


    list = self->get(tag, found=found)
    if (~found) then begin
        ; type 11 = objref
        list = obj_new('array_list', block_size=10, type=11)
        list->add, oroutine
        self->put, tag, list
    endif else begin
        list->add, oroutine
    endelse
end


;+
; Free resources.
;-
pro idldoctaglisting::cleanup
    compile_opt strictarr

    vals = self->values(count)
    if (count gt 0) then obj_destroy, vals

    self->hash_table::cleanup
end


;+
; Create the IDLdocTagListing.
;
; @returns 1 for success, 0 for failure
;-
function idldoctaglisting::init
    compile_opt strictarr

    ; type 7 = string, type 11 = objref, 53 is a nice prime number around 50
    retval = self->hash_table::init(array_size=53, key_type=7, value_type=11)
    if (retval ne 1) then return, 0B

    return, 1
end


;+
; Define instance variables.
;-
pro idldoctaglisting__define
    compile_opt strictarr

    define = { idldoctaglisting, inherits hash_table }
end
