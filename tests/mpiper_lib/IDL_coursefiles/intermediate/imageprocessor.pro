
;=========================================================================
;+
; The event handler for the File pull-down menu.
;
; @param event {in}{type=structure} The event structure passed from
;       xmanager
;-
pro imageprocessor_file, event
    compile_opt idl2

    ; Retrieve the state pointer and the user value of the widget
    ; that generated the event.
    widget_control, event.top, get_uvalue=pstate
    widget_control, event.id, get_uvalue=uval

    ; Perform the selected file operation, based on checking the user
    ; value of the widget that generated the event.
    case uval of
    'open': begin

        ; Read an image. If reading is cancelled, then return.
        ok = dialog_read_image(image=new_image, path=!dir, red=r, green=g, $
            blue=b, dialog_parent=event.top)
        if ok eq 0 then return

        ; Test the dimensions of the new image.
        isize = size(new_image, /structure)
        if isize.n_dimensions ne 2 then begin
            imageprocessor_error
            return
        endif

        ; Test color table information for the new image, if present.
        if n_elements(r) le 1 then begin
            loadct, 0, /silent
            tvlct, r, g, b, /get
        endif else tvlct, r, g, b

        ; Update the state pointer with info for the new image.
        (*pstate).new_colors = [[r],[g],[b]]
        *(*pstate).image = new_image
        *(*pstate).copy = new_image
        (*pstate).curr_x = 0
        (*pstate).curr_y = 0
        (*pstate).draw_xsize = isize.dimensions[0]
        (*pstate).draw_ysize = isize.dimensions[1]

        ; Resize the draw widget, based on the new image size.
        widget_control, (*pstate).wdraw, draw_xsize=(*pstate).draw_xsize, $
            draw_ysize=(*pstate).draw_ysize
        widget_control, (*pstate).wdraw, set_draw_view=[0,0]

        ; Make a new pixmap window & display the image.
        imageprocessor_setpixmap, pstate
        imageprocessor_dodisplay, pstate

        end

    'save': begin

        ; Write the image to a file.
        tvlct, r, g, b, /get
        a = dialog_write_image(*(*pstate).image, r, g, b, $
            filename='imageprocessor.tif', dialog_parent=event.top)

        end

    'exit': widget_control, event.top, /destroy ; Kill the widget program.

    endcase

end


;=========================================================================
;+
; The event handler for the image tools buttons.
;
; @param event {in}{type=structure} The event structure passed from
;       xmanager
;-
pro imageprocessor_tools, event
    compile_opt idl2

    ; Retrieve the state pointer & the user value of the widget that
    ; generated the event.
    widget_control, event.top, get_uvalue=pstate
    widget_control, event.id, get_uvalue=uval

    ; If there's no image to process, then return.
    if n_elements(*(*pstate).image) eq 0 then return

    ; Process the image according to which control was selected.
    case uval of
    'smooth': *(*pstate).image = smooth(*(*pstate).image, 5, /edge)
    'umask': *(*pstate).image = *(*pstate).image - $
        smooth(*(*pstate).image, 5, /edge)
    'sobel': *(*pstate).image = sobel(*(*pstate).image)
    'roberts': *(*pstate).image = roberts(*(*pstate).image)
    'median': *(*pstate).image = median(*(*pstate).image, 5)
    'negative': begin
        tvlct, r, g, b, /get
        tvlct, -(r+1B), -(g+1B), -(b+1B)
        end
    'ahisteq': *(*pstate).image = adapt_hist_equal(*(*pstate).image)
    'thresh': *(*pstate).image = bytscl(*(*pstate).copy gt event.value)
    'scale': *(*pstate).image = *(*pstate).copy > event.value
    'bscale': *(*pstate).image = bytscl(*(*pstate).image)
    'loadct': begin
        xloadct, /modal, group=event.top
        tvlct, r, g, b, /get
        (*pstate).new_colors = [[r],[g],[b]]
        end
    'revert': begin
        tvlct, (*pstate).old_colors
        *(*pstate).image = *(*pstate).copy
        end
    endcase

    ; Refresh the pixmap & display the image.
    imageprocessor_setpixmap, pstate, /update
    imageprocessor_dodisplay, pstate
end



;=========================================================================
;+
; The event handler for the draw widget in imageprocessor.
;
; @param event {in}{type=structure} The event structure passed from
;       xmanager
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
; This widget program allows a user to read a standard format image file
; and apply simple built-in image processing routines to the image. The
; processed image can then be saved to the operating system or passed back
; to the calling program.
;
; <center><img src="imageprocessor.png" alt="imageprocessor" /></center><br>
;
; @param image {in}{optional}{type=numeric array} A two-dimensional array
;       to be displayed as an image.
; @keyword processed {out}{optional}{type=pointer} Set to a pointer
;       reference in which the processed image is passed out of the
;       program.
; @keyword no_block {in}{optional}{type=boolean} Set to force widget
;       program to be nonblocking. Default is to block command line.
;
; @examples Display the image in the file 'endocell.jpg', process it
;   and return it to the calling program.
;   <pre>
;   IDL> file = filepath('endocell.jpg', subdir=['examples','data'])<br>
;   IDL> read_image, file, cells<br>
;   IDL> imageprocessor, cells, processed=pcells ; process the image!<br>
;   IDL> tv, *pcells ; display the processed image
;   </pre>
;
; @author Mark Piper, 1999
; @history Revised 2002, mp
; @copyright RSI
;-
pro imageprocessor, image, $
    processed=pimage, $
    no_block=no_block

    compile_opt idl2

    ; Retrieve the current IDL color mode & color table, if necessary.
    ; Set indexed color mode.
    device, get_decomposed=odec
    if odec eq 0 then begin
        tvlct, r, g, b, /get
        loadct, 0, /silent
    endif else begin
        device, decomposed=0
        r = (g = (b = bytarr(256)))
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
    wfilemenu = widget_button(menubar, value='File', /menu, $
        event_pro='imageprocessor_file')
    wopen = widget_button(wfilemenu, value='Open', uvalue='open')
    wsave = widget_button(wfilemenu, value='Save', uvalue='save')
    wexit = widget_button(wfilemenu, value='Exit', uvalue='exit', $
        /separator)

    ; Make a base with controls for image processing.
    wtoolsbase = widget_base(wtop, /column, event_pro='imageprocessor_tools')
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

    ; Create a state structure.
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

    ; Call XMANAGER.
    xmanager, 'imageprocessor', wtop, $
        cleanup='imageprocessor_cleanup', $
        no_block=keyword_set(no_block)
end
