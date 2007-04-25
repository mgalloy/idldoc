;+
; An example of creating a netCDF file.
;
; @examples
; <pre>
; IDL> netcdf_write_ex
; </pre>
; @requires IDL 6.0
; @author Mark Piper, RSI, 2005
;-
pro netcdf_write_ex
    compile_opt idl2

    ;; Read a binary file containing two 192 x 192 pixel 8-bit
    ;; images. (This info is from 'index.txt' in the same directory.)
    file1 = filepath('people.dat', subdir=['examples','data'])
    isize = 192
    images = read_binary(file1)
    images = reform(images, isize, isize, 2)

    ;; Read another binary file containing time series data. (Floating
    ;; point data, little endian byte ordering.)
    file2 = filepath('elnino.dat', subdir=['examples','data'])
    enso = read_binary(file2, data_type=4, endian='little')

    ;; Set up a new netCDF file.
    file_id = ncdf_create('example.nc', /clobber)

    ;; Define dimensions.
    dim_id = lonarr(3)
    dim_id[0] = ncdf_dimdef(file_id, 'xsize', isize)
    dim_id[1] = ncdf_dimdef(file_id, 'ysize', isize)
    dim_id[2] = ncdf_dimdef(file_id, 'length', n_elements(enso))

    ;; Define variables.
    var_id = lonarr(3)
    var_id[0] = ncdf_vardef(file_id, 'ali', dim_id[0:1], /byte)
    var_id[1] = ncdf_vardef(file_id, 'dave', dim_id[0:1], /byte)
    var_id[2] = ncdf_vardef(file_id, 'enso', dim_id[2], /float)

    ;; Define attributes to describe the data.
    ncdf_attput, file_id, 'Source', $
        'Data from IDL''s examples/data directory', /global  
    ncdf_attput, file_id, var_id[0], 'ali_attr', $
        'An image of Ali Bahrami', /char
    ncdf_attput, file_id, var_id[1], 'dave_attr', $
        'An image of Dave Stern', /char
    ncdf_attput, file_id, var_id[2], 'enso_attr', $
        'The ENSO time series', /char

    ;; End the definition phase. This statement puts the file in
    ;; "data" mode, which is needed to write variables to the file.
    ncdf_control, file_id, /endef

    ;; Write the variables to the file.
    ncdf_varput, file_id, var_id[0], images[*,*,0]
    ncdf_varput, file_id, var_id[1], images[*,*,1]
    ncdf_varput, file_id, var_id[2], enso

    ;; Close the file.
    ncdf_close, file_id
end
