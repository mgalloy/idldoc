;+
; @keyword version {out}{optional}{type=long} a counter that is incremented as 
;          the list is modified (so iterators know if the underlying list has 
;          changed)
;-
pro mgcoabstractlist::getProperty, version=version
    compile_opt strictarr
    
    if (arg_present(version)) then version = self.version
end


;+
; Add elements to the list.
;
; @abstract
; @param elements {in}{required}{type=list type} scalar or vector array of the 
;        same type as the list
; @keyword position {in}{optional}{type=integer}{default=end of list} index to 
;          insert elements at (NOT IMPLEMENTED)
;-
pro mgcoabstractlist::add, elements, position=position
    compile_opt strictarr

end


;+
; Returns the number of elements in the list.
;
; @abstract
; @returns long integer
;-
function mgcoabstractlist::count
    compile_opt strictarr

    return, 0L
end


;+
; Get elements of the list. 
;
; @abstract
; @returns element(s) of the list or -1L if no elements to return
; @keyword all {in}{optional}{type=boolean} set to return all elements
; @keyword position {in}{optional}{type=integer} set to an index or an index 
;          array of elements to return; defaults to 0 if ALL keyword not set
; @keyword count {out}{optional}{type=integer} set to a named variable to get 
;          the number of elements returned by this function
; @keyword isa {in}{optional}{type=string or strarr} classname(s) of objects to 
;          return; only allowable if list type is object
;-
function mgcoabstractlist::get, all=all, position=position, count=count, isa=isa
    compile_opt strictarr

    return, -1L
end

;+
; Determines whether a list contains specified elements.
;
; @abstract
; @returns 1B if contained or 0B if otherwise
; @param elements {in}{required}{type=type of list} scalar or vector of elements
;        of the same type as the list
; @keyword position {out}{optional}{type=long} set to a named variable that will
;          return the position of the first instance of the corresponding 
;          element of the specified elements
;-
function mgcoabstractlist::isContained, elements, position=position
    compile_opt strictarr

end


;+
; Move an element of the list to another position.
; 
; @abstract
; @param source {in}{required}{type=long} index of the element to move
; @param destination {in}{required}{type=long} index of position to move element
;-
pro mgcoabstractlist::move, source, destination
    compile_opt strictarr

end


;+
; Remove specified elements from the list.
; 
; @abstract
; @param elements {in}{optional}{type=type of list} elements of the list to 
;        remove
; @keyword position {in}{optional{type=long} set to a scalar or vector array of 
;          indices to remove from the list
; @keyword all {in}{optional}{type=boolean} set to remove all elements of the list
;-

pro mgcoabstractlist::remove, elements, position=position, all=all
    compile_opt strictarr

end


;+
; Creates an iterator to iterate through the elements of the list. The 
; destruction of the iterator is the responsibility of the caller of this 
; method.
;
; @abstract
; @returns MGAbstractIterator object
;-
function mgcoabstractlist::iterator
    compile_opt strictarr

    return, obj_new()
end


;+
; Free resouces.
;-
pro mgcoabstractlist::cleanup
    compile_opt strictarr

end


;+
; Initialize list.
;
; @returns 1B
;-
function mgcoabstractlist::init
    compile_opt strictarr

    return, 1B
end


;+
; Define member variables.
;
; @file_comments Abstract class to define a list interface. This class is not
;                intended to be instantiated, just to be inherited from.
; @field version a counter that is incremented as the list is modified (so 
;                iterators know if the underlying list has changed)
;-
pro mgcoabstractlist__define
    compile_opt strictarr

    define = { MGcoAbstractList, version: 0L }
end
