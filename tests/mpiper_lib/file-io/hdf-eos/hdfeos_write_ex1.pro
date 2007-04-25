;+
; Create an HDF-EOS file containing a grid data structure using data
; interpolated from an AIRS L2-T=RetStd product file. 
; Grid the TSurfAir (retrieved surface air temperature) datafield.
;
; @param file {in}{optional}{type=string} The filepath to the AIRS
; product file.
; @keyword debug {in}{optional}{type=boolean} Set this keyword to
; display debugging information when running the program.
; @examples
; <pre>
; IDL> hdfeos_write_ex
; </pre>
; @uses READ_L12_SWATH_FILE, an AIRS L2-RetStd product file
; @requires IDL 6.0
; @author Mark Piper, RSI, 2006
;-

pro hdfeos_write_ex, file, debug=debug
    compile_opt idl2
    on_error, 2

    switch 0 of
        n_params() :
        file_test(file) : begin
            file = dialog_pickfile( $
                title='Please select an HDF-EOS file...', $
                filter='*.hdf')
            if file eq '' then return
        end 
    endswitch 

    ;; Read the TSurfAir, Longitude and Latitude datafields using the
    ;; READ_L12_SWATH_FILE program distributed by NASA. The datafield
    ;; names must be listed with the correct case.
    ok = read_l12_swath_file(file, 3, b, $
        content_list=['TSurfAir','Longitude','Latitude'])
    if keyword_set(debug) then help, b, /structures

    ;; Interpolate the data to a regular grid in spherical lat-lon
    ;; coordinates. Exclude points marked with -9999.0 from the
    ;; analysis.
    bad = where(b.tsurfair eq -9999.0, n_bad)
    grid_input, b.longitude, b.latitude, b.tsurfair, $
        lon, lat, tsfc, exclude=bad
    min_lon = floor(min(lon))
    max_lon = ceil(max(lon))
    min_lat = floor(min(lat))
    max_lat = ceil(max(lat))
    lon_range = max_lon - min_lon
    lat_range = max_lat - min_lat
    lon_grid = findgen(lon_range) + min_lon
    ;tsfc_grid = griddata(lon, lat, tsfc, $
    ;    /inverse_distance, $
    ;    power=2, $
        

    ;; Define a map projection and convert the spherical lat-lon
    ;; coordinates to the 2D projection coordinates.




    ;; Open a new file to hold a grid data structure.
    fid = eos_gd_open('sfc_temp_grid_ex.hdf', /rdwr)  
    if fid eq -1 then begin
        message, 'Error opening file.', /continue
        return
    endif 
    if keyword_set(debug) then help, fid




    ;; Close the file.
    ok = eos_gd_close(fid)
    if ok eq -1 then begin
        message, 'Error closing file.', /continue
        return
    endif 
end
