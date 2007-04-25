;+
; An example of image sharpening using built-in IDL routines.
; This code is used in the chapter "Analysis" in the
; <i>Introduction to IDL</i> course manual.
;
; @examples
; <pre>
; IDL> sharpening_ex1
; </pre>
; @requires IDL 5.2
; @author Mark Piper, RSI, 2003
;-
pro sharpening_ex1
    compile_opt idl2

    ; Read an image from a file.
    file = filepath('endocell.jpg', subdir=['examples','data'])
    read_jpeg, file, cells
    info = size(cells, /structure)

    ; Display original image, making sure it's scaled to the byte range.
    loadct, 0, /silent
    window, 0, xsize=info.dimensions[0], ysize=info.dimensions[1], $
        title='Original Image'
    tvscl, cells

    ; Make a 3 x 3 Laplacian kernel.
    kernel = [[-1, -1, -1], $
              [-1, +8, -1], $
              [-1, -1, -1]]

    ; Cast the image data to type integer. The highpass filtered
    ; image that results from the Laplcian operator has positive &
    ; negative values. If the image remained type byte, the negative
    ; values would simply be wrapped into the byte range.
    cells = fix(cells)

    ; Apply the 3 x 3 Laplacian operator with the CONVOL function.
    hipass = convol(cells, kernel, /center)

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
    new = cells + hipass
    window, 2, xsize=info.dimensions[0], ysize=info.dimensions[1], $
        title='Sharpened Image'
    tv, bytscl(new)

    ; Make a split window for the manual, showing a portion of the
    ; original and the sharpened images.
    window, 3, title='Image Sharpening Example'
    lhalf = cells[0:!d.x_size/2-1, 0:!d.y_size-1]
    rhalf = new[0:!d.x_size/2-1, 0:!d.y_size-1]
    tvscl, lhalf, 0
    tvscl, rhalf, 1
end