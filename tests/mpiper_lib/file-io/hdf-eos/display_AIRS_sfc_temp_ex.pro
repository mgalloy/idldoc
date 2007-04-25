pro display_AIRS_sfc_temp_ex
    compile_opt idl2

    file = dialog_pickfile(filter='*.hdf')
    print, file

    ;; flag '3' returns data from swath into parameter 'buffer'.
    a = read_l12_swath_file(file, 3, buffer)

    lon = buffer.longitude
    lat = buffer.latitude
    tsurf = buffer.tsurfair

    ;; Note that tsurf has bad data values with tag -9999. IMAP
    ;; doesn't play well with these values. Convert them to NaNs.
    i_bad = where(tsurf lt 0.0, n_bad)
    print, n_bad
    tsurf_qc = tsurf
    tsurf_qc[i_bad] = !values.f_nan

    ;; Save these variables for later use.
    save, lon, lat, tsurf, tsurf_qc, file='geosfctemp.sav', /verbose

    loadct, 5
    tvlct, r, g, b, /get
    imap, tsurf_qc, lon, lat, $
        map_projection='Mercator', $
        limit=[20, -20, 60, 20], $
        rgb_table=[[r], [g], [b]], $
        /contour, $
        n_levels=20, $
        /fill, $
        grid_units=2
    
    ;; Insert continents, change color of continents, make image transparent.
end
