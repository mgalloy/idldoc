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
