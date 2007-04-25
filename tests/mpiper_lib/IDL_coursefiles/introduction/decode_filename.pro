;+
; Decodes a filename created by CREATE_FILENAME.
;
; @param filename {in}{required}{type=string} filename to decode
; @keyword prefix {out}{optional}{type=string}
; @keyword year {out}{optional}{type=int}
; @keyword month {out}{optional}{type=int}
; @keyword day {out}{optional}{type=int}
; @requires IDL 6.0
; @author Michael D. Galloy, RSI, 2003
;-
pro decode_filename, filename, prefix=prefix, year=year, month=month, day=day
    compile_opt idl2

    regex = '(.*)([[:digit:]]{4})([[:digit:]]{2})([[:digit:]]{2})\.dat'
    result = stregex(filename, regex, /subexpr, /extract)

    prefix = result[1]
    year = fix(result[2])
    month = fix(result[3])
    day = fix(result[4])
end
