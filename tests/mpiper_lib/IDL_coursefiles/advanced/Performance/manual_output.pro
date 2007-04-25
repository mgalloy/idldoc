;+
; Converts a spaces in an input string to underscores in the return
; value.
;
; @returns string with no spaces
; @param str {in}{type=string} input string
;-
function replace_spaces, str
    compile_opt idl2, hidden

    space = (byte(' '))[0]
    underscore = (byte('_'))[0]
    bstr = byte(str)

    ind = where(bstr eq space, count)
    if (count gt 0) then bstr[ind] = underscore

    return, string(bstr)
end


;+
; Plots data sets in the form for the performance test results
; given in the Advanced manual.
;
; @param x {in}{type=numeric vector} vector containing x-axis data
; @param y {in}{type=numeric array} array with one column for every
;          set of data and with the same number of rows as the x
;          param
; @keyword filename {in}{optional}{type=string} base filename for PS
;          output; the operating system name and the '.eps' file
;          extension will be appended to this filename
; @keyword screen {in}{optional}{type=boolean} set to send output to
;          the screen instead of PS file
; @keyword _extra {in}{optional}{type=_extra} keywords to
;          manual_plot (ie plot)
; @uses IDL 6.0
; @history Written by Michael Galloy, 2002 for Advanced Topics in IDL
;          class<br>
;   2003-10-14, MP - Changed plot parameters to make output to screen
;       more legible.<br>
;-
pro manual_output, x, y, filename=filename, screen=screen, _extra=e
    compile_opt idl2

    if (n_elements(filename) eq 0) then $
        message, 'FILENAME required keyword'

    orig_device = !d.name
    if (~keyword_set(screen)) then begin
        set_plot, 'ps'
        os_name = replace_spaces(!version.os_name)
        device, /encapsulated, filename=filename + '_' + os_name + '.eps',  $
            xsize=4.0, ysize=2.0, /inches, preview=2, pre_xsize=4.0, pre_ysize=2.0
        device, set_font='Helvetica', /tt_font
        manual_plot, x, y, font=1, charsize=0.75, _extra=e
        device, /close_file
        set_plot, orig_device
    endif else begin
        device, get_decomposed=odec
        device, decomposed=0
        tek_color
        manual_plot, x, y, font=-1, _extra=e
        loadct, 0, /silent
        device, decomposed=odec
    endelse
end
