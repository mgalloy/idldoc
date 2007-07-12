pro mgcoraggedarray::add, array
    compile_opt strictarr

end


function mgcoraggedarray::get, all=all, position=position, count=count, $
  isa=isa, reverse_indices=reverse_indices
    compile_opt strictarr

end


;+
; Free resources.
;-
pro mgcoraggedarray::cleanup
    compile_opt strictarr

    ptr_free, self.pExample
    obj_destroy, [self.oData, self.lengths]
end

 
;+
; Create a ragged array.
;
; @returns 1B for succes, 0B otherwise
; @keyword type {in}{optional}{type=integer} type code as in SIZE function to 
;          specify the type of elements in the list; TYPE or EXAMPLE keyword
;          must be used
; @keyword example {in}{optional}{type=any} used to specify the type of the list
;          by example; necessary if defining a list of structures
; @keyword blockSize {in}{optional}{type=integer}{default=1000L} initial size of
;          data array
;-
function mgcoraggedarray::init, type=type, example=example, blockSize=blockSize
    compile_opt strictarr
    on_error, 2

    self.oData = obj_new('mgarraylist', type=10L, blockSize=blockSize)
    self.lengths = obj_new('mgarraylist', type=3L, blockSize=blockSize)
    
    ; set type
    self.type = n_elements(type) eq 0 ? size(example, /type) : type
    if (self.type eq 0) then message, 'List type is undefined'

    ; store example if structure
    if (self.type eq 8) then begin 
        if (n_elements(example) eq 0) then begin
            message, 'Structure lists must specify type with EXAMPLE keyword'
        endif
        self.pExample = ptr_new(example)
    endif

    return, 1B
end


pro mgcoraggedarray__define
    compile_opt strictarr

    define = { MGcoRaggedArray, inherits MGcoAbstractList, $
               oData: obj_new(), $
               lengths: obj_new(), $
               type: 0L, $
               pExample: ptr_new() $
             }
end
