;+
; An example of displaying gridded weather station data with an image
; on a map projection. This code is used in the chapter "Map
; Projections" in the <i>Introduction to IDL</i> course manual.
;
; @examples
; <pre>
; IDL> map_image_ex
; </pre>
; @uses LOAD_GRAYS, GET_INTRO_DIR
; @requires IDL 6.0
; @author Mark Piper, RSI, 2002
; @history
;  2005-10, MP: Now uses GET_INTRO_DIR.
;-
pro map_image_ex
    compile_opt idl2

    ; Restore gridded surface temperature data from an IDL 6.0 SAVE file.
    file = filepath('gridded_temperature.sav', root_dir=get_intro_dir())
    restore, filename=file, /verbose

    ; Draw map.
    window, 2, title='Map-Image Example'
    load_grays
    map_set, /mollweide, /noborder, /isotropic, $
        limit=[33.0, -106.0, 43.0, -92.0]

    ; Display data as an image, warped with MAP_IMAGE.
    loadct, 5
    min_lat = min(g_lat, max=max_lat)
    min_lon = min(g_lon, max=max_lon)
    warped_image = map_image(g_temp, startx, starty, $
        compress=1, $
        latmin=min_lat, $
        latmax=max_lat, $
        lonmin=min_lon, $
        lonmax=max_lon, $
        bilinear=1, $
        missing=max(g_temp))
    tvscl, warped_image, startx, starty

    ; Draw the state boundaries over the image.
    map_continents, /usa, color=0
end