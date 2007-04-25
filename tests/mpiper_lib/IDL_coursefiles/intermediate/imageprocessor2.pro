
;=========================================================================
;+
; The event handler for the draw widget in imageprocessor.
;
; @param event {in}{type=structure} The event structure passed from xmanager
;-
pro imageprocessor_draw, event
    compile_opt idl2

    ; Retrieve the state pointer.
    widget_control, event.top, get_uvalue=pstate

    ; If event is scrollbar motion, then update current positions in the
    ; state pointer.
    if event.type eq 3 then begin
        (*pstate).curr_x = event.x
        (*pstate).curr_y = event.y
    endif

    ; Display the image.
    imageprocessor_dodisplay, pstate
end


;=========================================================================
;+
; The "do" routine for imageprocessor; displays the current image.
;
; @param pstate {in}{type=pointer} The state pointer
;-
pro imageprocessor_dodisplay, pstate
    compile_opt idl2

    ; Make sure the draw widget is the current graphics window.
    wset, (*pstate).wdraw_id

    ; Use the device copy technique to display the image in the draw widget.
    device, copy=[(*pstate).curr_x, (*pstate).curr_y, $
        (*pstate).scr_xsize, (*pstate).scr_ysize, 0, 0, (*pstate).pix_id]
end


;=========================================================================
;+
; Makes a pixmap window in memory to store the current image.
;
; @param pstate {in}{type=pointer} The state pointer
; @keyword update {in}{type=boolean} Set this keyword refresh the current
;       pixmap instead of making a new one.
;-
pro imageprocessor_setpixmap, pstate, update=update
    compile_opt idl2

    if not keyword_set(update) then begin
        if (*pstate).pix_id ne -1 then wdelete, (*pstate).pix_id
        window, /free, /pixmap, xsize=(*pstate).draw_xsize, $
            ysize=(*pstate).draw_ysize
        (*pstate).pix_id = !d.window
    endif
    wset, (*pstate).pix_id
    if n_elements(*(*pstate).image) ne 0 then tv, *(*pstate).image
end


;=========================================================================
;+
; The cleanup routine for imageprocessor, used to destroy the state
; pointer, reset color information & optionally pass back the processed
; image to the calling program.
;
; @param tlb {in}{type=long} The top-level base widget identifier, passed
;       to the program by xmanager.
;-
pro imageprocessor_cleanup, tlb
    compile_opt idl2

    ; Retrieve the state pointer.
    widget_control, tlb, get_uvalue=pstate

    ; Reset original color mode & destroy current pixmap window.
    device, decomposed=(*pstate).odec
    if (*pstate).odec eq 0 then tvlct, (*pstate).old_colors
    wdelete, (*pstate).pix_id

    ; Clean up pointer references. Note the image pointer is deliberately
    ; not freed if the processed keyword is used.
    if not (*pstate).processed then ptr_free, (*pstate).image
    ptr_free, (*pstate).copy, pstate
end


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
; An incomplete form of imageprocessor. The widget interface is defined
; and some event handling is performed. This completes code up to about
; p. 67 in the Intermediate IDL manual. Basically, an image can be
; displayed and the program cleans up properly.
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
pro imageprocessor2, image, processed=pimage
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
        /app_scroll, x_scroll_size=scr_xsize, y_scroll_size=scr_ysize, $
        event_pro='imageprocessor_draw')

    ; Realize the top-level base.
    widget_control, wtop, /realize

    ; Retrieve the draw widget index and set the scrollbars to their
    ; minimum positions.
    widget_control, wdraw, get_value=wdraw_id
    widget_control, wdraw, set_draw_view=[0,0]

    ; Create a state structure. Store this structure in the top-level
    ; base user value.
    state = { $
        image       : ptr_new(image), $
        copy        : ptr_new(image), $
        processed   : arg_present(pimage), $
        scr_xsize   : scr_xsize, $
        scr_ysize   : scr_ysize, $
        draw_xsize  : draw_xsize, $
        draw_ysize  : draw_ysize, $
        curr_x      : 0, $
        curr_y      : 0, $
        wdraw       : wdraw, $
        wdraw_id    : wdraw_id, $
        pix_id      : -1, $
        odec        : odec, $
        old_colors  : [[r], [g], [b]], $
        new_colors  : [[r], [g], [b]] $
        }
    pstate = ptr_new(state, /no_copy)
    widget_control, wtop, set_uvalue=pstate

    ; If the processed keyword is used, then set variable pimage to
    ; the pointer reference for the image.
    if (*pstate).processed then pimage=(*pstate).image

    ; Create a pixmap window and display the image on it.
    imageprocessor_setpixmap, pstate
    imageprocessor_dodisplay, pstate

    ; Call xmanager.
    xmanager, 'imageprocessor', wtop, $
        cleanup='imageprocessor_cleanup'
end
