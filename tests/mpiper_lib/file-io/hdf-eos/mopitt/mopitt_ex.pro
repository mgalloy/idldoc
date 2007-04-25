;+
; An example of reading some CO mixing ratio data from a MOPITT
; data file.
;-
pro mopitt_ex
    compile_opt idl2

    ; Select a MOPITT data file to read.
    path = '\\toaster\rsi_psg\mpiper\consulting\Janice_Priestley\'
    file = 'MOP02-20030401-L2V5.7.2.prov.hdf'

    ; View file info in HDF_BROWSER. Export time, lat, lon and CO
    ; mixing ratio to IDL.
    temp = hdf_browser(path+file)

    ; Read the selected datasets from the file.
    d = hdf_read(file, template=temp)

    ; Extract arrays from the data structure returned by HDF_READ.
    ; Lat, lon & time are vectors. CO mixing ratio is dimensioned
    ; 2 x 6 x N. Extract a vector using elt 1 of dim 1 (data) and
    ; elt 1 of dim 2 (850 mb level; near sfc).
    lon = d.mop02_geo_longitude
    lat = d.mop02_geo_latitude
    time = d.mop02_geo_time
    r_co = reform(d.MOP02_data_comixingratio[0, 0, *])

    ; Extract an interval of data from a pass of the satellite. This
    ; interval was selected by a cursory inspection of the data.
    interval = indgen(1000) + 20000
    lon_0 = lon[interval]
    lat_0 = lat[interval]
    r_co_0 = r_co[interval]

    ; Display the data in the interval.
    device, get_decomposed=odec
    device, decomposed=0
    loadct, 5
    min_r_co_0 = min(r_co_0, max=max_r_co_0)
    range_r_co_0 = max_r_co_0 - min_r_co_0
    window, 0
    contour, r_co_0, lon_0, lat_0, $
        /irregular, $
        /fill, $
        levels=findgen(11)/10*range_r_co_0 + min_r_co_0, $
        ytitle='Latitude (deg N)', $
        xtitle='Longitude (deg E)', $
        title='CO Mixing Ratio (850 hPa)'
    device, decomposed=odec

    ; Print some measures for the data interval displayed.
    print, 'Minimum CO mixing ratio (ppbv):', min_r_co_0
    print, 'Maximum CO mixing ratio (ppbv):', max_r_co_0
    print, 'Moments 1-4 of CO mixing ratio values:'
    print, moment(r_co_0)

end