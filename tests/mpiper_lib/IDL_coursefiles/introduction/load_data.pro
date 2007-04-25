;+
; A program for loading data files used in the RSI course
; <i>Introduction to IDL</i>.
;
; @param name {in}{required}{type=string} The name of a dataset, entered
;  as a string.
; @keyword list {optional}{type=boolean} Set this keyword to return a list
;  of available datasets.
; @returns A requested dataset.
; @examples
; <pre>
; IDL> dem = load_data('lvdem')
; IDL> isurface, dem
; </pre>
; @pre This file must be in the same directory as the course files.
; @uses READ_ASOS, GET_INTRO_DIR
; @requires IDL 5.3
; @author Mike Galloy and Mark Piper, RSI, 2003
; @history
;  2004-08, MP: Uses SOURCEROOT instead of SET_TRAINING_DIRECTORY<br>
;  2005-10, MP: Added 'ladem' and 'laimage'<br>
;  2005-10, MP: Replaced SOURCEROOT and <i>!training</i> with
;               GET_INTRO_DIR function<br>
;-
function load_data, name, list=list
    compile_opt idl2
    on_error, 2

    datasets = [ $
        'asos', $
        'chirp', $
        'continents', $
        'ladem', $
        'laimage', $
        'lvdem', $
        'lvimage', $
        'marbells', $
        'mesa_time', $
        'mesa_temp', $
        'mesa_dewp', $
        'mesa_wspd', $
        'mesa_wdir', $
        'people', $
        'temperature', $
        'wind', $
        'world_elevation', $
        'world_elevation_low_res']
    if keyword_set(list) then return, datasets

    if (n_params() eq 0) then message, 'Incorrect number of parameters.'

	;; Locate the course files.
    course_dir = get_intro_dir()

    name = strlowcase(name)
    local_name = string((byte(name))[0:3])
    switch local_name of
    'asos' : begin
            filename = filepath('20_02.dat', root_dir=course_dir)
            data = read_asos(filename)
            return, data
        end
    'chir' : begin
            filename = filepath('chirp.dat', subdir=['examples','data'])
            chirp = read_binary(filename)
            return, chirp
        end
    'cont' : begin
            filename = filepath('continent_mask.dat', $
                subdir=['examples', 'data'])
            openr, lun, filename, /get_lun
            el = bytarr(360, 360)
            readu, lun, el
            free_lun, lun
            return, el
        end
    'lade' : begin
            filename = filepath('elevbin.dat', subdir=['examples','data'])
            return, read_binary(filename, data_dims=[64,64], data_type=1)
        end
    'laim' : begin
            filename = filepath('elev_t.jpg', subdir=['examples','data'])
            read_jpeg, filename, image
            return, image
        end
    'lvde' : begin
            filename = filepath('lvdem.sav', root_dir=course_dir)
            restore, filename
            return, lvdemdata
        end
    'lvim' : begin
            filename = filepath('lvimage.jpg', root_dir=course_dir)
            image = read_image(filename)
            image = reform(image[0, *, *])
            image = congrid(image, 64, 64)
            return, image
        end
    'marb' : begin
            filename = filepath('surface.dat', subdir=['examples', 'data'])
            elev = read_binary(filename, data_type=2, data_dims=[350,450])
            return, elev
        end
    'mesa' : begin
            if strlen(name) lt 7 then ml_data_name = 'mesa_ti' $
                else ml_data_name = string((byte(name))[0:6])
            ml_file = filepath('mlab.20020626.cdf', root_dir=course_dir)
            ml_id = ncdf_open(ml_file)
            case ml_data_name of
                'mesa_ti': data_id = ncdf_varid(ml_id, 'time_offset')
                'mesa_te': data_id = ncdf_varid(ml_id, 'tdry')
                'mesa_de': data_id = ncdf_varid(ml_id, 'dp')
                'mesa_ws': data_id = ncdf_varid(ml_id, 'wspd')
                'mesa_wd': data_id = ncdf_varid(ml_id, 'wdir')
            else: data_id = ncdf_varid(ml_id, 'time_offset')
            endcase
            ncdf_varget, ml_id, data_id, data
            ncdf_close, ml_id
            return, data
        end
    'peop' : begin
            filename = filepath('people.dat', subdir=['examples', 'data'])
            ali = read_binary(filename, data_dims=[192,192])
            return, ali
        end
    'temp' : begin
            file = filepath('u0.dat', root_dir=course_dir)
            d = read_ascii(file, data_start=8, num_records=50)
            time = reform(d.(0)[0,*])
            temp = reform(d.(0)[5,*])
            return, {time:time-min(time), temperature:temp}
        end
    'wind' : begin
            file = filepath('u0.dat', root_dir=course_dir)
            d = read_ascii(file, data_start=8, num_records=50)
            t = reform(d.(0)[0,*])
            u = reform(d.(0)[1,*])
            v = reform(d.(0)[2,*])
            w = reform(d.(0)[3,*])
            s = sqrt(u^2 + v^2 + w^2)
            return, {time:t-min(t), speed:s}
        end
    'worl' : begin
            filename = filepath('worldelv.dat', subdir=['examples', 'data'])
            openr, lun, filename, /get_lun
            el = bytarr(360, 360)
            readu, lun, el
            free_lun, lun
            el = shift(temporary(el), 180, 0)
            if name eq 'world_elevation_low_res' then $
                el = congrid(temporary(el), 60, 60)
            return, el
        end
    else: message, 'Dataset name not found.'
    endswitch
end
