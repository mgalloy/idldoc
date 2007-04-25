;+
; An example of using the IDL SPLINE and POLY_FIT functions to
; interpolate a 1D data set. This code is used in the chapter
; "Analysis" in the <i>Introduction to IDL</i> course manual.
;
; @examples
; <pre>
; IDL> spline_ex2
; </pre>
; @requires IDL 5.2
; @author Mark Piper, RSI, 2000
;-
pro spline_ex2
    compile_opt idl2

    ; Generate a sequence of points.
    n = 10
    x = findgen(n)
    y = randomu(333L, n)

    ; Generate a new set of abscissas at a bunch of points within
    ; the support of the original data, 0 < x < 10.
    scale = 6
    new_x = n*findgen(n*scale)/(n*scale)

    ; Interpolate the original data to the new points using SPLINE.
    new_y1 = spline(x, y, new_x)

    ; For comparison, construct a polynomial interpolant.
    coeffs = poly_fit(x, y, 11)
    new_y2 = fltarr(n*scale)
    for i = 0, n_elements(coeffs)-1 do new_y2 += coeffs[i]*new_x^i

    ; Plot the original points (triangles), the spline interpolation
    ; (red) and the polynomial interpolation (yellow).
    loadct, 5, /silent
    plot, x, y, psym=5, /ynozero
    oplot, new_x, new_y1, color=110
    oplot, new_x, new_y2, color=220
    wshow
end