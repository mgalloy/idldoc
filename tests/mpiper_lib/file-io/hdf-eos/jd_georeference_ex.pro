;+
; An example of geolocating a sequence of lat/lon points.
;
; @author Mark Piper, RSI, 2006
;-
pro jd_georeference_ex
    compile_opt idl2

    ;; Read the sample data. The file contains two lines of header
    ;; followed by columns of longitude, latitude and surface
    ;; temperature, 30 values of each.
    n_vals = 30
    data = fltarr(3, n_vals)
    line = ''
    file = './sample_data.txt'
    openr, lun, file, /get_lun
    for i = 0, 1 do readf, lun, line
    readf, lun, data
    free_lun, lun

    ;; Extract the three vectors (longitude, latitude and surface
    ;; temperature) from the data array. Display them.
    lon  = reform(data[0,*])
    lat  = reform(data[1,*])
    tsfc = reform(data[2,*])
    window, 0, xsize=750, ysize=250
    !p.multi = [0,3,1]
    plot, lon, ytitle='Longitude (deg)'
    plot, lat, ytitle='Latitude (deg)', /ynozero
    plot, tsfc, ytitle='Temperature (K)', /ynozero
    !p.multi = 0

    ;; Define a map projection. Map the lat/lon values to the
    ;; projection. The variable 'xy' holds geolocated values in the
    ;; projection space.
    map = map_proj_init('Robinson')
    help, map
    xy = map_proj_forward(lon, lat, map_structure=map)
    help, xy
    print, xy
end
