;+
; An example of image sharpening. This code is used in the chapter
; "Analysis" in the <i>Introduction to IDL</i> course manual.
;
; @examples
; <pre>
; IDL> sharpening_ex2
; </pre>
; @requires IDL 5.3
; @author Mark Piper, RSI, 2003
;-
pro sharpening_ex2
    compile_opt idl2

    ; Read an image from a file.
    file = filepath('convec.dat', subdir=['examples','data'])
    mantle = read_binary(file, data_dims=[248,248])
    info = size(mantle, /structure)

    ; Display original image, making sure it's scaled to the byte range.
    loadct, 0, /silent
    window, 0, xsize=info.dimensions[0], ysize=info.dimensions[1], $
        title='Original Image', xpos=100, ypos=100
    tvscl, mantle

    ; Make a Laplacian kernel.
    kernel = [[-1, -1, -1], $
              [-1, +8, -1], $
              [-1, -1, -1]]

    ; Cast the image data to type integer. The highpass filtered
    ; image that results from the Laplcian operator has positive &
    ; negative values. If the image remained type byte, the negative
    ; values would simply be wrapped into the byte range.
    mantle = fix(mantle)

    ; Apply the 3 x 3 Laplacian operator with the CONVOL function.
    hipass = convol(mantle, kernel, /center)

    ; The highpass filtered image does indeed have negative values!
    print, min(hipass), max(hipass)

    ; Bytescale the highpass filtered image.
    hipass = bytscl(hipass)

    ; Display the bytescaled highpass filtered image.
    window, 1, xsize=info.dimensions[0], ysize=info.dimensions[1], $
        title='Highpass Filtered Image', $
        xpos=100+info.dimensions[0]+20, $
        ypos=100+info.dimensions[1]+40
    tv, hipass

    ; Add the highpass filtered image to the original. Bytescale the
    ; result and display.
    new = bytscl(mantle + hipass)
    window, 2, xsize=info.dimensions[0], ysize=info.dimensions[1], $
        title='Sharpened Image', $
        xpos=100, $
        ypos=100+info.dimensions[1]+40
    tv, new

    ; Match histograms by scaling.
    new2 = bytscl(new, min=28, max=173)
    window, 3, xsize=info.dimensions[0], ysize=info.dimensions[1], $
        title='Sharpened Image, take 2', $
        xpos=100+info.dimensions[0]+20, $
        ypos=100
    tv, new2
end