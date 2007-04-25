;+
; Sets a statement (or a group of statements) that perform(s) an image
; processing operation in the member variable <i>code</i>. Override
; this method in a subclass.
;
; @abstract
;-
pro im_operator::set_code
    compile_opt idl2

    *self.code = ''
end


;+
; This method is used to print to a file an IDL statement (created in
; the <code>set_code</code> method) that performs an image processing
; operation.  
;
; @keyword lun logical unit number to which code is written
; @keyword indent number of spaces to indent
;-
pro im_operator::write_code, lun=lun, indent=indent
    compile_opt idl2

    self->set_code

    i_lun = n_elements(lun) eq 0 ? -1 : lun
    i_indent = n_elements(indent) eq 0 ? 0 : indent

    spaces = string(bytarr(i_indent) + 32B) ; ASCII 32B = space

    printf, i_lun, spaces + *self.code
end


;+
; Performs the image processing operation. Override this method in a
; subclass.
;
; @abstract
; @returns an IDLgrImage object
; @param oimage an IDLgrImage object
;-
function im_operator::do_it, oimage
    compile_opt idl2

    return, obj_new()
end


pro im_operator::cleanup
    compile_opt idl2

    ptr_free, self.code
end


function im_operator::init
    compile_opt idl2

    self.code = ptr_new(/allocate_heap)
    return, 1
end


;+
; The class data definition procedure for <code>im_operator</code>.
;
; @file_comments This is the base class for any image processing
; operation performed the application IM_ENGINE. This class is
; abstract; it is meant to be subclassed to implement specific image
; processing operations.
;
; @field code IDL statement(s) to be written to a file.
;
; @author Mike Galloy, 2002
; @history mutated 2003, Mark Piper
; @copyright RSI
;-
pro im_operator__define
    compile_opt idl2

    define = { im_operator, $
               code:ptr_new() $
             }
end
