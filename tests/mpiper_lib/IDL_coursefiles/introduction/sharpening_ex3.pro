;+
; An example of image sharpening using built-in IDL routines.
; This code is used in the chapter "Analysis" in the
; <i>Introduction to IDL</i> course manual.
;
; @examples
; <pre>
; IDL> sharpening_ex3
; </pre>
; @requires IDL 5.3
; @author Mark Piper, 2003
;-
pro sharpening_ex3
    compile_opt idl2

    ; Read an image from a file.
    file = filepath('nyny.dat', subdir=['examples','data'])
    ny = read_binary(file, data_dims=[768,512])
    info = size(ny, /structure)

    ; Display original image, making sure it's scaled to the byte range.
    loadct, 0, /silent
    window, 0, xsize=info.dimensions[0], ysize=info.dimensions[1], $
        title='Original Image'
    tvscl, ny

    ; Make a Laplacian kernel.
    kernel = [[-1, -1, -1], $
              [-1, +8, -1], $
              [-1, -1, -1]]

    ; Cast the image data to type integer. The highpass filtered
    ; image that results from the Laplcian operator has positive &
    ; negative values. If the image remained type byte, the negative
    ; values would simply be wrapped into the byte range.
    ny = fix(ny)

    ; Apply the 3 x 3 Laplacian operator with the CONVOL function.
    hipass = convol(ny, kernel, /center)

    ; The highpass filtered image does indeed have negative values!
    print, min(hipass), max(hipass)

    ; Bytescale the highpass filtered image.
    hipass = bytscl(hipass)

    ; Display the bytescaled highpass filtered image.
    window, 1, xsize=info.dimensions[0], ysize=info.dimensions[1], $
        title='Highpass Filtered Image'
    tv, hipass

    ; Add the highpass filtered image to the original. Bytescale the
    ; result and display.
    new = ny + hipass
    window, 2, xsize=info.dimensions[0], ysize=info.dimensions[1], $
        title='Sharpened Image'
    tv, bytscl(new)
end
