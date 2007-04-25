;+
; Creates a filename with the current date with a given prefix and a '.dat'
; extension.
;
; @returns A string that can be used as a filename.
; @param prefix {in}{required}{type=string} String to prefix filename with
; @keyword suffix {in}{optional}{type=string}{default='.dat'} String to use as file
;  extension.
; @examples
; <pre>
; IDL> name = create_filename('mydata')
; IDL> print, name
; mydata20040820.dat
; IDL> name = create_filename('journal_', suffix='.pro')
; IDL> print, name
; journal_20040820.pro
; </pre>
; @requires IDL 6.0
; @author Michael D. Galloy, RSI, 2003
; @history
;  2004-08, MP: Added the SUFFIX keyword.<br>
;-
function create_filename, prefix, suffix=suffix
    compile_opt idl2

    jtime = systime(/julian)
    caldat, jtime, month, day, year

	if ~n_elements(suffix) then suffix='.dat'

    format = '(I2.2)'
    filename = prefix $
        + strtrim(year, 2) $
        + string(month, format=format) $
        + string(day, format=format) $
        + suffix

    return, filename
end
