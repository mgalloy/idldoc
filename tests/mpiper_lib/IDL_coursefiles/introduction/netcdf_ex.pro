;+
; An example of reading datasets from a NetCDF file.
; The file contains archived 5-min wx data recorded at the NCAR
; Mesa Lab weather station for one day, 2002-06-26.
; The dataset <i>tdry</i> (dry-bulb temperature) is extracted from the
; file and plotted versus the dataset <i>time_offset</i>.
; <p>
;
; The data can be retrieved from
; <a href="ftp://ftp.atd.ucar.edu/pub/archive/weather/mesa">
; ftp://ftp.atd.ucar.edu/pub/archive/weather/mesa</a>
; <p>
;
; @examples
; <pre>
; IDL> netcdf_ex
; </pre>
; @uses GET_INTRO_DIR
; @requires IDL 5.3
; @author Mark Piper, RSI, 2003
; @history
;  2005-10, MP: Now uses GET_INTRO_DIR()
;-
pro netcdf_ex
    compile_opt idl2

    ; Open the NetCDF file.
    ml_file = filepath('mlab.20020626.cdf', root_dir=get_intro_dir())
    ml_id = ncdf_open(ml_file)

    ; Find the ids for two datasets, 'tdry' and 'time_offset'.
    ; These dataset names can be found in the README file from the
    ; ML weather station ftp site.
    tdry_id = ncdf_varid(ml_id, 'tdry')
    time_id = ncdf_varid(ml_id, 'time_offset')

    ; Extract the datasets from the file.
    ncdf_varget, ml_id, tdry_id, tdry
    ncdf_varget, ml_id, time_id, time

    ; Close the file.
    ncdf_close, ml_id

    ; Plot the data. Note that start time is 00 UTC, or 1800 MDT the
    ; previous day.
    plot_time = time/60.0^2 ; convert from seconds to hours
    plot, plot_time, tdry, $
        /ynozero, $
        xrange=[0,24], $
        xstyle=1, $
        xticks=8, $
        xtitle='Time (UTC)', $
        ytitle='Temperature (C)', $
        title='NCAR Mesa Lab Temperature: 2003-06-26'
end