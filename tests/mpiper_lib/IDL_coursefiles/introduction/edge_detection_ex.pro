;+
; An example of using the IDL SOBEL and ROBERTS functions. This code
; is used in the chapter "Analysis" in the <i>Introduction to
; IDL</i> course manual.
;
; @uses LOAD_DATA
; @requires IDL 5.2
; @author Mark Piper, RSI, 2003
;-
pro edge_detection_ex
    compile_opt idl2

    ; Read image data from a file.
    ali = load_data('people')
    isize = size(ali, /dimensions)

    ; Display the original and filtered images.
    window, xsize=isize[0]*3, ysize=isize[1], $
        title='Edge Detection Example'
    tv, ali, 0
    tv, sobel(ali), 1
    tv, roberts(ali), 2
end