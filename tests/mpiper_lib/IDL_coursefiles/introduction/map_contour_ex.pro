;+
; An example of displaying gridded weather station data with a contour
; plot on a map projection. This code is used in the chapter "Map
; Projections" in the <i>Introduction to IDL</i> course manual.
;
; @examples
; <pre>
; IDL> map_contour_ex
; </pre>
; @uses LOAD_GRAYS, GET_INTRO_DIR
; @requires IDL 6.0
; @author Mark Piper, RSI, 2002
; @history
;  2005-10, MP: Now uses GET_INTRO_DIR.
;-
pro map_contour_ex
    compile_opt idl2

    ; Restore gridded surface temperature data from an IDL 6.0 SAVE file.
    file = filepath('gridded_temperature.sav', root_dir=get_intro_dir()
    restore, filename=file, /verbose

    ; Draw map and show positions of the ASOS stations with triangles.
    ; Note use of NAME keyword to MAP_SET as an alternate way of specifying
    ; the projection.
    window, 1, title='Map-Contour Example'
    load_grays
    map_set, name='Mollweide', /noborder, /isotropic, $
        limit=[33.0, -106.0, 43.0, -92.0]
    map_continents, /usa
    plots, lon, lat, psym=5

    ; Make a contour plot over the station locations.
    loadct, 5
    contour, g_temp, g_lon, g_lat, $
        /overplot, $
        levels=indgen(11)*2+278, $
        /follow, $
        c_colors=indgen(11)*20+20
end