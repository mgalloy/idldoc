;+
; This procedure draws a wind rose - a polar plot of wind speed versus
; wind direction. It's a simple program, appropriate for class. Better
; programs exist - a quick Google search for "wind rose" on
; <code>comp.lang.idl-pvwave</code> turns up a few. This code is used
; in the chapter "Line Plots" in the <i>Introduction to IDL</i> course
; manual.
;
; @param wspd {in} An array of wind speeds. (whatever units)
; @param wdir {in} An array of wind directions, in degrees.
; @keyword _extra {in} Keyword inheritance.
; @examples
; <pre>
; IDL> ; LOAD_DATA is an Intro to IDL course program.
; IDL> speed = load_data('mesa_wspd')
; IDL> direction = load_data('mesa_wdir')
; IDL> wind_rose, speed, direction
; </pre>
; @requires IDL 5.2
; @author Mark Piper, 2003
;-
pro wind_rose, wspd, wdir, _extra=e
    compile_opt idl2

    if n_params() ne 2 then begin
        message, 'Wind speed and direction are required parameters.', /info
        return
    endif

    max_wspd = max(wspd, min=min_wspd)
    n_wspd = n_elements(wspd)

    new_wspd = reform(transpose([[wspd], [fltarr(n_wspd)]]), 2*n_wspd)
    new_wdir = reform(transpose([[wdir], [fltarr(n_wspd)]]), 2*n_wspd)

    plot, new_wspd, new_wdir*!dtor, /polar, $
        xrange=[-max_wspd,max_wspd], $
        yrange=[-max_wspd,max_wspd], $
        xstyle=5, ystyle=5, $
        _extra=e
    axis, 0, 0, xaxis=1, xrange=[-max_wspd,max_wspd], xstyle=1
    axis, 0, 0, yaxis=1, yrange=[-max_wspd,max_wspd], ystyle=1

    ; Draw isotachs in increments of 5.
    n_rings = fix(max_wspd)/5
    ring = findgen(361)
    for i = 0, n_rings-1 do $
        oplot, (i+1)*5*ring^0, ring*!dtor, /polar, linestyle=1

    ; Label cardinal directions.
    ;fudge = 0.05*max_wspd
    ;xyouts, 0, max_wspd+fudge, 'N', alignment=0.5
    ;xyouts, max_wspd+fudge, 0, 'E', alignment=0.5
    ;xyouts, 0, -max_wspd-fudge, 'S', alignment=0.5
    ;xyouts, -max_wspd-fudge, 0, 'W', alignment=0.5
end