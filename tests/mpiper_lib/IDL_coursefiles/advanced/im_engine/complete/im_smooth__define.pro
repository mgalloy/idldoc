;+
; Set "code" instance variable to point at a string array which
; contains IDL code operating on the "image" variable.
;-
pro im_smooth::set_code
    compile_opt idl2

    *self.code = 'image = smooth(temporary(image), ' $
        + strtrim(self.width, 2) + ')'
end


;+
; Performs the running-mean smooth image processing operation.<p>
;
; @returns An instance of <code>idlgrimage</code>.
; @param oimage {in}{type=object} An <code>idlgrimage</code> object
;     reference.
;-
function im_smooth::do_it, oimage
    compile_opt idl2

    oimage->getproperty, data=data, interleave=interleave
    ndims = size(data, /n_dimensions)
    case interleave of
        0: begin
            case ndims of
                2: new_data = smooth(data, self.width, /edge_truncate)
                3: begin
                    new_data = data
                    new_data[0,0,0] = smooth(data[0,*,*], $
                                             self.width, /edge_truncate)
                    new_data[1,0,0] = smooth(data[1,*,*], $
                                             self.width, /edge_truncate)
                    new_data[2,0,0] = smooth(data[2,*,*], $
                                             self.width, /edge_truncate)
                end
            endcase
        end
        1: new_data = data ; etc
        2: new_data = data ; and so forth
    endcase
    return, obj_new('idlgrimage', new_data)
end


;+
; Class constructor for <code>im_smooth</code>. Note that the
; superclass must be instantiated to gain its data and methods.
;
; @returns 1 on success, 0 on failure
;-
function im_smooth::init
    compile_opt idl2

    if self->im_operator::init() ne 1 then return, 0

    self.width = 5    
    return, 1
end


;+
; The class data definition procedure for <code>im_smooth</code>.
;
; @file_comments This class defines a running-mean smoothing operation
; that can be applied to an image.
;
; @inherits <code>im_operator</code>
; @field width The width of the (square) smoothing kernel.
;
; @author Mike Galloy, 2002
; @history mutated 2003, Mark Piper
; @copyright RSI
;-
pro im_smooth__define
    compile_opt idl2

    define = { im_smooth, $
               inherits im_operator, $
               width : 0 $
             }
end
