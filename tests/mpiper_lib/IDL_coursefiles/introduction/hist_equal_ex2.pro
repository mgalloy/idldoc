;+
; An example of using the IDL HIST_EQUAL function. This code
; is used in the chapter "Analysis" in the <i>Introduction to
; IDL</i> course manual.
;
; @requires IDL 6.0
; @author Mark Piper, RSI, 2003
;-
pro hist_equal_ex2
    compile_opt idl2

    ; Read image data from a file.
    file = filepath('convec.dat', subdir=['examples','data'])
    isize = [248,248]
    mantle = read_binary(file, data_dims=isize)

    ; Set up an iTool and display the image in it.
    iimage, mantle, dimensions=isize*2, view_grid=[2,2], $
        title='Histogram Equalization Example', $
        xtickfont_size=6, ytickfont_size=6, $
        identifier=this_tool

    ; Calculate and display the image's histogram in the iTool.
    iplot, histogram(mantle), overplot=this_tool, view_number=2, $
        xtickfont_size=6, ytickfont_size=6, max_value=5000, $
        xtitle='pixel value', ytitle='# of occurences'

    ; Apply the HIST_EQUAL function. Display the results in the
    ; iTool.
    eq_mantle = hist_equal(mantle)
    iimage, eq_mantle, overplot=this_tool, view_number=3, $
        xtickfont_size=6, ytickfont_size=6

    ; Calculate and display the equalized image's histogram in
    ; the iTool.
    iplot, histogram(eq_mantle), overplot=this_tool, view_number=4, $
        xtickfont_size=6, ytickfont_size=6, max_value=5000, $
        xtitle='pixel value', ytitle='# of occurences'
end