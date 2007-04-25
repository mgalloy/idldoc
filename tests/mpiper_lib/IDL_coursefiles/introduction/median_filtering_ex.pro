;+
; An example of using the IDL MEDIAN function. This code
; is used in the chapter "Analysis" in the <i>Introduction to
; IDL</i> course manual.
;
; @examples
; <pre>
; IDL> median_filtering_ex
; </pre>
; @uses LOAD_DATA
; @requires IDL 5.3
; @author Mark Piper, RSI, 2003
;-
pro median_filtering_ex
    compile_opt idl2

    ; Read image data from a file.
    ali = load_data('people')
    isize = size(ali, /dimensions)

    ; Make a new image speckled with white and black pixels.
    noisy = ali
    white_points = randomu(seed, 1e3)*isize[0]*isize[1]
    noisy[white_points] = 255B
    black_points = randomu(seed, 1e3)*isize[0]*isize[1]
    noisy[black_points] = 0B

    ; Display the original, noisy and filtered images.
    loadct, 0
    window, xsize=isize[0]*3, ysize=isize[1], $
        title='Median Filtering Example'
    tv, ali, 0
    tv, noisy, 1
    tv, median(noisy, 3), 2
end