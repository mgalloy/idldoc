;+
; Determine if the underlying collection has another element to retrieve.
;
; @returns 1 if underlying collection has another element, 0 otherwise
;-
function mgcoabstractiterator::hasNext
    compile_opt strictarr

end


;+
; Return the next item in the underlying collection.
;
; @returns list item
;-
function mgcoabstractiterator::next
    compile_opt strictarr

end


;+
; Removes from the underlying MGArrayList the last element returned.
;-
pro mgcoabstractiterator::remove
    compile_opt strictarr

end


;+
; Free resources of the iterator (not the underlying collection).
;-
pro mgcoabstractiterator::cleanup
    compile_opt strictarr

end


;+
; Initialize an iterator.
;
; @returns 1 for success, 0 otherwise
;-
function mgcoabstractiterator::init
    compile_opt strictarr

    return, 1B
end


;+
; Define member variables.
;
; @field version used to compare to the version of the underlying collection to
;        determine if the underlying collection has changed
;-
pro mgcoabstractiterator__define
    compile_opt strictarr

    define = { MGcoAbstractIterator, version: 0L }
end
