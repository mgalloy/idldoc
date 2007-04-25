;+
; An example of using the IDL SPLINE function to perform cubic
; spline interpolation on a 1D data set. This code is used in the
; chapter "Analysis" in the <i>Introduction to IDL</i> course
; manual.
;
; @examples
; <pre>
; IDL> spline_ex1
; </pre>
; @requires IDL 5.2
; @author Mark Piper, RSI, 2000
;-
pro spline_ex1
    compile_opt idl2

    ; Generate a sequence of points that lie on a sine curve.
    ; Values sampled from a normal distribution are added to the
    ; sine curve to simulate measurement error.
    n = 10
    x = findgen(n)
    y = sin(x) + randomn(seed, n)*0.1

    ; Generate a new set of abscissas at a bunch of points within
    ; the support of the original data, 0 < x < 10.
    new_x = n*findgen(n*4)/(n*4)

    ; Interpolate the original data to the new points using SPLINE.
    ; The return from SPLINE are the ordinates of the interpolated
    ; points.
    new_y = spline(x, y, new_x)

    ; Plot the original points (triangles) and the interpolated
    ; points (dots).
    plot, x, y, psym=5, xtitle='x', ytitle='y'
    oplot, new_x, new_y, linestyle=1
    wshow
end