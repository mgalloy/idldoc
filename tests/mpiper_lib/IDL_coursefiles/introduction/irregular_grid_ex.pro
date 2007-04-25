;+
; An example of using the IDL GRIDDATA function to interpolate
; irregulary spaced weather station data to a 2D grid. This code
; is used in the chapter "Analysis" in the <i>Introduction to
; IDL</i> course manual.
;
; @examples
; <pre>
; IDL> irregular_grid_ex
; </pre>
; @uses LOAD_GRAYS, GET_INTRO_DIR, READ_ASOS
; @requires IDL 5.5
; @author Mark Piper, RSI, 2002
; @history
;  2005-10, MP: Replaced <i>!training</i> with GET_INTRO_DIR.
;-
pro irregular_grid_ex
    compile_opt idl2

    ; Read data from file.
    file = filepath('20_02.dat', root_dir=get_intro_dir())
    data = read_asos(file)
    if size(data, /type) eq 3 then return

    ; Look at what's returned.
    help, data, /structure

    ; Show planview of positions of the ASOS stations.
    load_grays
    window, 0
    plot, data.lon, data.lat, psym=7, /ynoz, $
        xtitle='Longitude (deg)', ytitle='Latitude (deg)'

    ; Do a little QC. Bad values in this data set are marked with
    ; value 999999. Find where the bad points are.
    bad = where(data.pressure eq 999999.0)

    ; Preprocess with GRID_INPUT. Use it to remove bad and duplicate
    ; points. GRID_INPUT can also be used to transform from spherical
    ; to Cartesian coords. Data are in spherical coords; keep them
    ; this way--they'll be displayed on a map. Show that the bad
    ; points have been removed & the duplicate points have been
    ; averaged, both in value & spatially.
    grid_input, data.lon, data.lat, data.pressure, $
        lon_qc, lat_qc, pressure_qc, exclude=bad, epsilon=0.25
    plots, lon_qc, lat_qc, psym=6

    ; Grid data with GRIDDATA. The inputs are the qc variables output
    ; from GRID_INPUT.
    lon_vec = findgen(21)/20*10-104
    lat_vec = findgen(17)/16*8+34
    pressure_grid = griddata(lon_qc, lat_qc, pressure_qc, $
        /inverse_distance, power=3, /grid, xout=lon_vec, yout=lat_vec)

    ; Display gridded data.
    window, 1
    shade_surf, pressure_grid*1e-2, lon_vec, lat_vec, $
        charsize=1.5, $
        ax=45, $
        xtitle='Longitude (deg)', $
        ytitle='Latitude (deg)', $
        ztitle='Pressure (hPa)'
end