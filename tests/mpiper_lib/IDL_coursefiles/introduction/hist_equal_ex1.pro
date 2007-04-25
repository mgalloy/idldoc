;+
; An example of using the IDL HIST_EQUAL function. This code
; is used in the chapter "Analysis" in the <i>Introduction to
; IDL</i> course manual.
;
; @requires IDL 5.3
; @author Mark Piper, RSI, 2003
;-
pro hist_equal_ex1
    compile_opt idl2

    ; Read image data from a file.
    file = filepath('convec.dat', subdir=['examples','data'])
    isize = [248,248]
    mantle = read_binary(file, data_dims=isize)

    ; Make a window with dimensions twice that of the image.
    window, xsize=isize[0]*2, ysize=isize[1]*2, $
        title='Histogram Equalization Example'

    ; Set up plot window.
    !p.multi = [2,2,2,0,1]

    ; Display the image and its histogram.
    tv, mantle, 0
    plot, histogram(mantle), max_value=5000, xtitle='pixel value', $
        ytitle='# of occurences'

    ; Apply the HIST_EQUAL function. Display the resulting image
    ; and its histogram.
    eq_mantle = hist_equal(mantle)
    tv, eq_mantle, 2
    plot, histogram(eq_mantle), max_value=5000, xtitle='pixel value', $
        ytitle='# of occurences'

    ; Reset !p.multi.
    !p.multi = 0
end