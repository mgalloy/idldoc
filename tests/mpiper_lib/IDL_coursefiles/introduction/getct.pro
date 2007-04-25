;+
; This function returns the RGB values of a built-in IDL color
; table without actually loading the color table. It's also a nice
; example of working with associated variables, since the IDL
; color table data are stored as a series of records in an unformatted
; binary file.
;
; @examples
; <pre>
; IDL> rgb = getct(5)
; </pre>
; @param table_number {in}{required}{type=integer} The index of a
;  built-in IDL color table (an integer between 0 and 40).
; @returns A !d.table_size x 3 byte array giving the colors in the
;  requested color table.
; @requires IDL 5.3
; @author Beau Legeer, RSI, 1999
; @history
;  2004-04-08, MP: Modified to conform to style guidelines.
;-
function getct, table_number
    compile_opt idl2

    file = filepath('colors1.tbl', subdir=['resource', 'colors'])

    openr, lun, file, /get_lun

    vec = assoc(lun, bytarr(256), 1)
    r = vec[table_number*3]
    g = vec[table_number*3 + 1]
    b = vec[table_number*3 + 2]

    free_lun, lun

    ;; Interpolate the color table if the number of displayable
    ;; colors is less than 256 on an 8-bit visual class.
    nc = !d.table_size
    if nc le 256 then begin
        p = (indgen(nc) * 255) / (nc-1)
        r = r[p]
        g = g[p]
        b = b[p]
    endif

    return, [[r],[g],[b]]
end

