;+
; Set "code" instance variable to point at a string array which
; contains IDL code operating on the "image" variable.
;-
pro im_hist_equal::set_code
    compile_opt idl2

    *self.code = 'image = hist_equal(temporary(image))'
end


;+
; Performs the image processing operation.<p>
; <b>TODO:</b> make this work for multiband images.
;
; @returns An instance of IDLgrImage
; @param oimage {in}{type=object} An IDLgrImage object reference.
;-
function im_hist_equal::do_it, oimage
    compile_opt idl2

    oimage->getproperty, data=data
    new_data = hist_equal(data)
    return, obj_new('idlgrimage', new_data)
end


;+
; Class constructor for <code>im_hist_equal</code>. Note that the
; superclass must be instantiated to gain its data and methods.
;
; @returns 1 on success, 0 on failure
;-
function im_hist_equal::init
    compile_opt idl2

    if self->im_operator::init() eq 0 then return, 0
    return, 1
end


;+
; The class data definition procedure for <code>im_hist_equal</code>.
;
; @file_comments This class defines a histogram-equalization operation
; that can be applied to an image.
;
; @inherits <code>im_operator</code>
; @author Mike Galloy, 2002
; @history mutated 2003, Mark Piper
; @copyright RSI
;-
pro im_hist_equal__define
    compile_opt idl2

    define = { im_hist_equal, $
               inherits im_operator $
             }
end
