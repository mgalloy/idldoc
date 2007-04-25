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