;+
; Reads a netCDF file containing daily 5-min mean atmospheric state
; variables recorded at the NCAR Mesa Lab (ML) weather station. A plot
; of wind speed versus time is displayed.
;
; <p>Links:
; <ol>
; <li> ML weather station: http://www.atd.ucar.edu/cgi-bin/weather.cgi?site=ml
; <li> FTP archive: ftp://ftp.atd.ucar.edu/pub/archive/weather/
; </ol>
;
; @param file {in}{optional}{type=string} A filepath to a netCDF file
; downloaded from the NCAR ML weather station archive.
; @examples
; <pre>
; IDL> netcdf_read_ex
; </pre>
; @uses A netCDF file downloaded from the NCAR ML weather station.
; @requires IDL 6.0
; @author Mark Piper, RSI, 2005
;-
pro netcdf_read_ex, file
    compile_opt idl2
    on_error, 2

    switch 0 of
        n_params() :
        file_test(file) : begin
            file = dialog_pickfile(title='Please select a netCDF file...')
            if file eq '' then return
        end 
    endswitch 

    ;; Open the netCDF file.
    file_id = ncdf_open(file)

    ;; Find and display the number of dimensions, variables, and
    ;; global attributes.
    file_info = ncdf_inquire(file_id)
    help, file_info, /structures

    ;; Get the dimensions.
    dim_names = strarr(file_info.ndims)
    dim_sizes = lonarr(file_info.ndims)
    name = (size = '')
    for i = 0, file_info.ndims-1 do begin
        ncdf_diminq, file_id, i, name, size
        dim_names[i] = name
        dim_sizes[i] = size
        print, i, ' Dimension name: ', dim_names[i]
        print, i, ' Dimension size: ', dim_sizes[i]
    endfor 

    ;; Get info about the variables.
    var_info = replicate({name:"", datatype:"", ndims:0l, natts:0l, $
        dim:lonarr(file_info.ndims)}, file_info.nvars)
    for i = 0, file_info.nvars-1 do begin
        var_info[i] = ncdf_varinq(file_id, i)
        help, var_info[i], /structures
    endfor 

    ;; Get the data from the time and wind speed variables. (The
    ;; creator of the file should use attributes for the units of
    ;; these variables! Assume SI units.)
    time_id = ncdf_varid(file_id, 'time_offset')
    ncdf_varget, file_id, time_id, time
    wspd_id = ncdf_varid(file_id, 'wspd')
    ncdf_varget, file_id, wspd_id, wspd

    ;; Display the wind speed data as a function of time.
    s_per_hr = 3600.0
    plot, time/s_per_hr, wspd, $
        xtitle='Time (UTC)', $
        ytitle='Wind Speed (ms!u-1!n)', $
        title='Wind Speed, NCAR Mesa Lab Weather Station, 2005-08-10'
    xyouts, 0.6, 0.9, '300-s mean values', /normal
end
