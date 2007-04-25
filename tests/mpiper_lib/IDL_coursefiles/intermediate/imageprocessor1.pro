;=========================================================================
;+
; Displays an error message.
;-
pro imageprocessor_error
    compile_opt idl2

    ; Display an error message in a dialog box.
    err_msg = ['This image cannot be viewed with this utility.', $
        'Please select another image.']
    ok = dialog_message(err_msg)
end


;=========================================================================
;+
; An early form of imageprocessor, where the widget interface is defined.
; No event handling. This completes code up to about p. 61 in the
; Intermediate IDL manual.
;
; @param image {in}{optional}{type=numeric array} A two-dimensional array
;       to be displayed as an image.
; @keyword processed {out}{optional}{type=pointer} Set to a pointer
;       reference in which the processed image is passed out of the
;       program.
; @author Mark Piper, 1999
; @history Revised 2002, mp
; @copyright RSI
;-
pro imageprocessor1, image, processed=pimage
    compile_opt idl2

    ; Retrieve the current IDL color mode & color table, if necessary.
    ; Set indexed color mode.
    device, get_decomposed=odec
    if odec eq 0 then begin
        tvlct, r, g, b, /get
        loadct, 0, /silent
    endif else begin
        device, decomposed=0
        r = (g = (b = 0))
    endelse

    ; Check the input parameter.
    isize = size(image, /structure)
    if n_params() eq 1 then begin
        fail = 0
        if isize.n_dimensions ne 2 then fail = 1
        if ((isize.type eq 0) or $
            (isize.type ge 6 and isize.type le 11)) then fail = 1
        if fail then begin
            imageprocessor_error
            return
        endif
    endif

    ; Make a top-level base with a menubar.
    wtop = widget_base(title='RSI Training - ImageProcessor', /row, $
        mbar=menubar, xoffset=100, yoffset=100)

    ; Make the menubar.
    wfilemenu = widget_button(menubar, value='File', /menu)
    wopen = widget_button(wfilemenu, value='Open', uvalue='open')
    wsave = widget_button(wfilemenu, value='Save', uvalue='save')
    wexit = widget_button(wfilemenu, value='Exit', uvalue='exit', $
        /separator)

    ; Make a base with controls for image processing.
    wtoolsbase = widget_base(wtop, /column)
    wsmooth = widget_button(wtoolsbase, value='Smooth', uvalue='smooth')
    wusmask = widget_button(wtoolsbase, value='Unsharp Mask', uvalue='umask')
    wsobel = widget_button(wtoolsbase, value='Sobel', uvalue='sobel')
    wroberts = widget_button(wtoolsbase, value='Roberts', uvalue='roberts')
    wmedian = widget_button(wtoolsbase, value='Median', uvalue='median')
    wnegative = widget_button(wtoolsbase, value='Negative', uvalue='negative')
    wahisteq = widget_button(wtoolsbase, value='Adapt Hist Equal', $
        uvalue='ahisteq')
    wthresh = widget_slider(wtoolsbase, title='Threshold', $
        min=0, max=255, value=0, uvalue='thresh')
    wscale = widget_slider(wtoolsbase, title='Scale', $
        min=0, max=255, value=0,uvalue='scale')
    wbscale = widget_button(wtoolsbase, value='Byte Scale', uvalue='bscale')
    wloadct = widget_button(wtoolsbase, value='Load Color Table', $
        uvalue='loadct')
    wrevert = widget_button(wtoolsbase, value='Revert', uvalue='revert')

    ; Make a draw widget with scroll bars.
    scr_xsize = 400
    scr_ysize = 400
    draw_xsize = isize.type ne 0 ? isize.dimensions[0] : scr_xsize
    draw_ysize = isize.type ne 0 ? isize.dimensions[1] : scr_ysize
    wdraw = widget_draw(wtop, xsize=draw_xsize, ysize=draw_ysize, $
        /app_scroll, x_scroll_size=scr_xsize, y_scroll_size=scr_ysize)

    ; Realize the top-level base.
    widget_control, wtop, /realize
end