;+
; This function converts an RGB triple into a long integer index value.
; It's useful for feeding specific colors from the RGB color system to
; the Direct Graphics COLOR and BACKGROUND keywords. This code is used
; in the chapter "Line Plots" in the <i>Introduction to IDL</i>
; course manual.
; <p>
;
; This is Beau Legeer's RGB2IDX function with some error-checking
; and IDL 6.0 syntax added.
; <p>
;
; @param rgb {in}{type=byte}{required} A three-element vector specifying
;   a color from the RGB color system. The input is converted to type
;   byte. The first element is the red intensity; the second, green, the
;   third, blue.
; @returns A long integer index corresponding to the RGB triple, with
;   <em>blue</em> as the most significant bit; i.e, BGR order.
; @requires IDL 6.0
; @author Mark Piper, RSI, 2003
;-
function color_index, rgb
    compile_opt idl2

    rgb = byte(rgb)
    s_rgb = size(rgb, /structure)
    if ~((n_params() eq 1) && (s_rgb.n_dimensions eq 1) $
        && (s_rgb.n_elements eq 3)) then begin
        message, 'An RGB triple must be passed.', /continue
        return, 0
    endif

    return, rgb[0] + (rgb[1]*2^8) + (rgb[2]*2^16)
end