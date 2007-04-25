;+
; Extract data from a MOPITT data file.
; MOPITT data are HDF-EOS.
; Currently, the only data available from MOPITT are CO mixing ratio.
;
; @param eos_file {in}{type=string} The filepath to an HDF-EOS file
;   containing MOPITT data.
; @param field_name {in}{type=string} The name of the data field name
;   for which data is to be obtained.
; @param longitude_interval {in}{type=double} The range of longitudes
;   in which to look for data.
; @param latitude_interval {in}{type=double} The range of latitudes
;   in which to look for data.
;-
function read_mopitt, eos_file, field_name, longitude_interval, $
    latitude_interval

    ;; Is HDF-EOS supported?
    if ~eos_exists() then begin
        message, 'HDF-EOS is not supported.', /continue
        return, 0
    endif 

    ;; Check whether this is an HDF-EOS file.
    is_eos = eos_query(eos_file, info)
    if is_eos eq 0 then begin
        message, 'Not a valid HDF-EOS file. Returning.', /continue
        return, 0
    endif

    ;; Open the swath file.
    swath_file_id = eos_sw_open(eos_file, /read)

    ;; Attach the swath.
    swath_id = eos_sw_attach(swath_file_id, info.swath_names)

    ;; Hardcode the names of the geolocation fields. The field name is
    ;; used to extract field data from the file.
    fname_time = 'Time'
    fname_lon  = 'Longitude'
    fname_lat  = 'Latitude'

    ;; Define a box region from which data can be extracted. Force
    ;; the lat and lon values to be of type double.
    latitude_interval = double(latitude_interval)
    longitude_interval = double(longitude_interval)
    region_id = eos_sw_defboxregion(swath_id, longitude_interval, $
        latitude_interval, 2L)

    ;; Extract time, lat, lon & requested data from the region.
    y_data = eos_sw_extractregion(swath_id, region_id, field_name, 0L, data)
    y_lon = eos_sw_extractregion(swath_id, region_id, fname_lon, 0L, lon)
    y_lat = eos_sw_extractregion(swath_id, region_id, fname_lat, 0L, lat)
    y_time = eos_sw_extractregion(swath_id, region_id, fname_time, 0L, time)

    ;; Detach the swath.
    a = eos_sw_detach(swath_id)

    ;; Close the swath file.
    a = eos_sw_close(swath_file_id)

    ;; If no data were found then return 0L.
    if y_data eq -1 then return, 0L

    ;; If the dataset requested is CO Mixing Ratio, then only use the
    ;; lowest level (850 mb), since this will be used to approximate the
    ;; surface value. Also, separate the data array from error estimate
    ;; array.
    case strlowcase(field_name) of
    'co mixing ratio': begin
        data = reform(data[0,0,*])
        error = reform(data[1,0,*])
        end
    'ch4 total column bench 1' : begin
        data = reform(data[0,*])
        error = reform(data[1,*])
        end
    else: error = 0
    endcase

    ;; Return the requested data.
    ret = { $
        values      : data, $
        accuracy    : error, $
        time        : time, $
        lon         : lon, $
        lat         : lat  $
        }
    return, ret
end
