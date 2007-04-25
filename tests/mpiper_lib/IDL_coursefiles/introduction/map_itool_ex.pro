;+
; An example of using MAP_PROJ_INIT and MAP_PROJ_FORWARD to create a
; lat/lon array that is displayed in map and in Cartesian coordinates in
; an iTool. This code is used in the chapter "Map Projections" in
; the <i>Introduction to IDL</i> course manual.
;
; @examples
; <pre>
; IDL> map_itool_ex
; </pre>
; @requires IDL 6.0
; @author Mark Piper, RSI, 2002
;-
pro map_itool_ex
    compile_opt idl2

    ; Make a map projection. Use Mollweide, like the other two examples
    ; in the chapter. Assume default datum. Use the same limits as in
    ; the other examples.
    map = map_proj_init('Mollweide', limit=[33.0, -106.0, 43.0, -92.0])

    ; Define the number of grid nodes for lat/lon.
    n_lat = 11
    n_lon = 15

    ; Set the values of lat/lon at the nodes.
    lon = (findgen(n_lat*n_lon) mod n_lon) - 106.0
    lat = (findgen(n_lat*n_lon) mod n_lat) + 33.0

    ; Convert lat/lon grid to Cartesian x/y coords. Note the input to
    ; MAP_PROJ_FORWARD requires vectors of lat & lon or a 2 x N array
    ; of lons & lats.
    grid = map_proj_forward(lon, lat, map_structure=map)

    ; Reform the data for input to an iPlot. Scale data to km.
    x = reform(grid[0,*])*1e-3
    y = reform(grid[1,*])*1e-3

    ; Display the original grid in map coords.
    iplot, lon, lat, $
        sym_index=5, $
        linestyle=6, $
        view_grid=[2,1], $
        color=[255,0,0], $
        xtitle='Longitude (deg W)', $
        ytitle='Latitude (deg N)'

    ; Display the grid in Cartesian coords.
    iplot, x, y, $
        sym_index=5, $
        linestyle=6, $
        /view_next, $
        color=[0,0,255], $
        xtitle='X (km W)', $
        ytitle='Y (km N)'
end