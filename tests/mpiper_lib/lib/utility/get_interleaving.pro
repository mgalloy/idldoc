;+
; A convenience function for determining the interleaving of an RGB
; image.
;
; @todo Settings for RGBA (4xMxN) and grayscale-alpha (2xMxN) images;
;   handling of 3x3 images; degenerate dimensions.
;
; @examples
;   <pre>
;   IDL> file = filepath('rose.jpg', subdir=['examples','data'])
;   IDL> rose = read_image(file)
;   IDL> tval = get_interleaving(rose, dimensions=d)
;   IDL> print, tval
;              1
;   IDL> print, d
;           227         149
;   IDL> tv, rose, true=tval
;   </pre>
; @param image {in}{required}{type=numeric array} A numeric array (of
;   undetermined interleaving) to be displayed as an image.
; @keyword dimensions {out}{optional}{type=long} A two-element array
;   giving the dimensions of the image [width,height] in pixels.
; @returns The value of TV's TRUE keyword describing the interleaving
;   of the image, or 0 for a non-interleaved image, or -1 for data
;   that cannot be displayed as an image.
;
; @requires IDL 6.0
; @author Mark Piper, RSI, 2004
;-
function get_interleaving, image, $
                           dimensions=dims
    compile_opt idl2

    n_dims = size(image, /n_dimensions)
    the_dims = size(image, /dimensions)

    true_val = -1

    case n_dims of
        2: begin
            ++true_val
            dims = the_dims[0:1]
        end
        3: begin
            for i = 0,2 do $
                if the_dims[i] eq 3 then true_val = i+1
            case true_val of
                1: dims = [the_dims[1], the_dims[2]]
                2: dims = [the_dims[0], the_dims[2]]
                3: dims = [the_dims[0], the_dims[1]]
                else:
            endcase 
        end 
        else: 
    endcase 

    return, true_val
end
