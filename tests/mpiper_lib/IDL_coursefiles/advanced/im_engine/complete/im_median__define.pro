;+
; Set "code" instance variable to point at a string array which
; contains IDL code operating on the "image" variable.
;-
pro im_median::set_code
    compile_opt idl2

    *self.code = 'image = median(temporary(image), ' $
        + strtrim(self.width, 2) + ')'
end


;+
; Performs the median smoothing image processing operation.<p>
;
; @returns An instance of <code>idlgrimage</code>.
; @param oimage {in}{type=object} An <code>idlgrimage</code> object
;     reference.
;-
function im_median::do_it, oimage
    compile_opt idl2

    oimage->getproperty, data=data, interleave=interleave
    ndims = size(data, /n_dimensions)
    case interleave of
        0: begin
            case ndims of
                2: new_data = median(data, self.width)
                3: begin
                    new_data = data
                    new_data[0,0,0] = median(data[0,*,*], self.width)
                    new_data[1,0,0] = median(data[1,*,*], self.width)
                    new_data[2,0,0] = median(data[2,*,*], self.width)
                end
            endcase
        end
        1: new_data = data ; etc
        2: new_data = data ; and so forth
    endcase
    return, obj_new('idlgrimage', new_data)
end


;+
; Class constructor for <code>im_median</code>. Note that the
; superclass must be instantiated to gain its data and methods.
;
; @returns 1 on success, 0 on failure
;-
function im_median::init
    compile_opt idl2

    if self->im_operator::init() ne 1 then return, 0

    self.width = 5    
    return, 1
end


;+
; The class data definition procedure for <code>im_median</code>.
;
; @file_comments This class defines a median smoothing operation
; that can be applied to an image.
;
; @inherits <code>im_operator</code>
; @field width The width of the (square) kernel.
;
; @author Mike Galloy, 2002
; @history mutated 2003, Mark Piper
; @copyright RSI
;-
pro im_median__define
    compile_opt idl2

    define = { im_median, $
               inherits im_operator, $
               width : 0 $
             }
end
