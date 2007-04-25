;+
; Creates a long integer color from RGB coordinates, suitable for use in
; decomposed color mode in direct graphics.
;
; @returns long
; @param rgb {in}{required}{type=byte, or bytarr} 3-element byte array
;        representing color or just red value(s); if red value(s) then g and b
;        parameters should be present
; @param g {in}{optional}{type=byte, or bytarr} green value(s)
; @param b {in}{optional}{type=byte, or bytarr} blue value(s)
;-
function rgb2idx, rgb, g, b
    compile_opt strictarr
    on_error, 2

    case n_params() of
    1 : begin
            if (n_elements(rgb) ne 3) then begin
                message, 'incorrect number of parameters'
            endif
            ir = rgb[0]
            ig = rgb[1]
            ib = rgb[2]
        end
    3 : begin
            ir = rgb
            ig = g
            ib = b
        end
    else : message, 'incorrect number of parameters'
    endcase

    return, ir + ig * 2L^8 + ib * 2L^16
end