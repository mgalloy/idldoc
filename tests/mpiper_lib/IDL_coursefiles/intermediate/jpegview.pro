
;--------------------------------------------------------------------
;
;   jpegview_dodisplay
;
pro jpegview_dodisplay, pstate
    compile_opt idl2

    ; Ensure that the draw widget is set to be the current graphics window.
    wset, (*pstate).win_id

    ; Display the image.
    tv, *(*pstate).image, true=(*pstate).is_truecolor

end


;--------------------------------------------------------------------
;
;   jpegview_resize
;
pro jpegview_resize, event
    compile_opt idl2

    ; Retrieve the user value of the tlb -- it's the pointer to the
    ; state structure.
    widget_control, event.top, get_uvalue=pstate

    ; Use WIDGET_INFO to get geometry information about the new size
    ; of the top-level base.
    tlbg = widget_info(event.top, /geometry)

    ; Set the new size of the image (and the draw widget) by
    ; subtracting the padding from the tlb.
    newx = event.x - tlbg.xpad
    newy = event.y - tlbg.ypad

    ; Resize the image using CONGRID.
    *(*pstate).image = (*pstate).is_truecolor $
        ? congrid(*(*pstate).imagecopy, 3, newx, newy, /interp) $
        : congrid(*(*pstate).imagecopy, newx, newy)

    ; Set new draw widget size.
    widget_control, (*pstate).draw, xsize=newx, ysize=newy

    ; Call the "Do" routine to display the image.
    jpegview_dodisplay, pstate

end


;--------------------------------------------------------------------
;
;   jpegview_cleanup
;
pro jpegview_cleanup, tlb
    compile_opt idl2

    ; Retrieve the user value of the tlb -- it's the pointer to the
    ; state structure.
    widget_control, tlb, get_uvalue=pstate

    ; Reset the original IDL color mode and color table, if necessary.
    device, decomposed=(*pstate).odec
    if (*pstate).odec eq 0 then $
        tvlct, (*pstate).r, (*pstate).g, (*pstate).b

    ; Clean up the pointer references.
    ptr_free, (*pstate).image, (*pstate).imagecopy, pstate

end


;--------------------------------------------------------------------
;
;   jpegview
;
pro jpegview
    compile_opt idl2

    ; Retrieve the visual depth of the display and the current IDL
    ; color mode, as well as the color table, if allowed.
    device, get_visual_depth=vd
    device, get_decomposed=odec
    if odec eq 0 then begin
        tvlct, r, g, b, /get
        loadct, 0, /silent
    endif else r = (g = (b = 0))

    ; Use DIALOG_PICKFILE to select a JPEG image file.
    jpeg_file = dialog_pickfile(filter='*.jpg', /fix_filter)
    if jpeg_file eq '' then return

    ; Use QUERY_JPEG to get information about the selected image file.
    ok = query_jpeg(jpeg_file, jpeg_fileinfo)
    if ok eq 0 then return

    ; Read the contents of the JPEG file into an IDL variable.
    if vd le 8 then begin
        read_jpeg, jpeg_file, image_data, colormap, colors=!d.table_size, $
            /dither, /two_pass_quantize
        tvlct, colormap
        jpeg_fileinfo.channels = 1
    endif else read_jpeg, jpeg_file, image_data

    ; Construct a widget hierarchy with a top-level base and a draw widget.
    tlb = widget_base(title='JPEG Viewer | ' + jpeg_file, /column, $
        tlb_size_events=1)
    draw = widget_draw(tlb, xsize=jpeg_fileinfo.dimensions[0], $
        ysize=jpeg_fileinfo.dimensions[1])
    widget_control, tlb, /realize
    widget_control, draw, get_value=win_id

    ; Store useful information in a state structure.
    state = { $
        odec:odec, $
        r:r, g:g, b:b, $
        is_truecolor:(jpeg_fileinfo.channels gt 1), $
        win_id:win_id, $
        draw:draw, $
        image:ptr_new(image_data), $
        imagecopy:ptr_new(image_data, /no_copy) $
        }

    ; Store the state structure in heap memory (global) and
    ; reference it with a pointer.
    pstate = ptr_new(state, /no_copy)

    ; Store a pointer to the state structure as the user value of
    ; the top-level base widget.
    widget_control, tlb, set_uvalue=pstate

    ; Call the "Do" routine to display the image, passing relevant
    ; information in the pointer to the state structure.
    jpegview_dodisplay, pstate

    ; Call XMANAGER in non-blocking mode.
    xmanager, 'jpegview', tlb, /no_block, $
        event_handler='jpegview_resize', $
        cleanup='jpegview_cleanup'

end