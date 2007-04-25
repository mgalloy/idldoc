;+
; Plots data sets in the form for the performance test results
; given in the Advanced manual.
;
; @param x {in}{type=numeric vector} vector containing x-axis data
; @param y {in}{type=numeric array} array with one column for every
;          set of data and with the same number of rows as the x
;          param
; @keyword _extra {in}{optional}{type=_extra} keywords to
;          manual_plot (ie plot)
; @history Written by Michael Galloy, 2002 for Advanced Topics in IDL
;          class<br>
;   2003-10-14, MP - Changed plot parameters to make output to screen
;       more legible.<br>
;-
pro manual_plot, x, y, _extra=e
    compile_opt idl2

    n_dim = size(y, /n_dimensions)

    if (n_dim eq 1) then begin
        plot, x, y, background=255, color=0, xstyle=1, _extra=e
    endif else begin
        maxy = max(y)
        dim = size(y, /dimensions)
        plot, x, y[0, *], background=255, color=0, $
            xstyle=1, yrange=[0, maxy], _extra=e
        for i = 1, dim[0] - 1 do begin
            oplot, x, y[i, *], color=(i mod 6)+2, linestyle=(i mod 6)
        endfor
    endelse
end
