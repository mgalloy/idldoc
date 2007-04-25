;+
; An example of making a map of South America in IDL.
; This code is used in the chapter "Map Projections"
; in the <i>Introduction to IDL</i> course manual.
;
; @examples
; <pre>
; IDL> map_ex
; </pre>
; @requires IDL 5.3
; @author Mark Piper, RSI, 2001
;-
pro map_ex
    compile_opt idl2

    ;; Create a window.
    window, 0, xs=350, ys=450, title='Map Example'

    ;; Create a map projection.
    loadct, 39, /silent
    map_set, /mercator, $
        e_horizon={fill:1, color:50}, $
        limit=[-60,-90,20,-30], $
        ymargin=3, $
        /noborder, $
        /isotropic

    ;; Draw a grid.
    map_grid, /box_axes, color=255, charsize=0.8

    ;; Draw coasts.
    map_continents, /coasts, color=0, thick=3

    ;; Draw continents.
    map_continents, color=160, fill_continents=1

    ;; Draw countries.
    map_continents, /countries, color=0
end
