;+
; Reads weather data from an FAA/NWS Automated Surface Observing
; System (ASOS) station. ASCII format. No QC performed.
; Note that time is in UTC, not LST.
;
; @param asos_file {in}{type=string} The name of an ASOS file to read.
; @returns A structure with the contents of the file.
; @requires IDL 5.2
; @author Mark Piper, University of Colorado, 1996
; @history MP, 2000-01: Converted routine to a function & returned file
;  contents in a structure. Added COMPILE_OPT statement. IDLdoc-ed.
;-
function read_asos, asos_file
    compile_opt idl2

    ; Error handler.
    catch, err
    if err ne 0 then begin
        catch, /cancel
        message, !error_state.msg
        return, 0
    endif

    ; Initialize dummy arrays.
    d = ''  & t = '' & stn = ''
    la = 0.0 & lo = 0.0 & el = 0.0
    p = 0.0 & ta = 0.0 & td = 0.0
    ws = 0.0 & wd = 0.0

    ; Initialize data arrays.
    date        = d
    time        = t
    station     = stn
    elevation   = el
    lat         = la
    lon         = lo
    pressure    = p
    temperature = ta
    dewpoint    = td
    winddir     = wd
    windspd     = ws

    ; Open data file for reading.
    openr, lun, asos_file, /get, err=oerror
    if oerror ne 0 then begin
        message, 'Surface data file not found.', /continue
        return, 0
    endif

    ; Read the contents of the data file.  It's a mess.
    ncount = 0L & line = '' & indicator1 = 0.0 & indicator2 = 0.0
    while (not eof(lun)) do begin
        readf, lun, d, t, la, lo, $
            format='(15X,a2,8X,a8,13X,d8.5,8x,d10.5)'
        readf, lun, stn
        readf, lun, el
        readf, lun, line
        readf, lun, line
        readf, lun, indicator1
        for i = 1, (3*round(indicator1) + 1) do begin
           readf, lun, line
        endfor
        readf, lun, indicator2
        if (round(indicator2) gt 1) then begin
           for i = 1, indicator2 - 1 do begin
             readf, lun, line
           endfor
        endif
        readf, lun, line
        readf, lun, p
        readf, lun, ta
        readf, lun, td
        readf, lun, wd
        readf, lun, ws
        readf, lun, line
        readf, lun, line
        date        = d
        time        = [time, t]
        lat         = [lat, la]
        lon         = [lon, lo]
        station     = [station, stn]
        elevation   = [elevation, el]
        pressure    = [pressure, p]
        temperature = [temperature, ta]
        dewpoint    = [dewpoint, td]
        winddir     = [winddir, wd]
        windspd     = [windspd, ws]
    endwhile

    ; Close the data file.
    free_lun, lun

    ; Construct the data structure to be returned to the calling level.
    surface_data = { $
        date        : date, $
        time        : time[1:*], $
        lat         : lat[1:*], $
        lon         : lon[1:*], $
        station     : station[1:*], $
        elev        : elevation[1:*], $
        pressure    : pressure[1:*], $
        temperature : temperature[1:*], $
        dewpoint    : dewpoint[1:*], $
        wdir        : winddir[1:*], $
        wspd        : windspd[1:*] $
        }
    return, surface_data
end
