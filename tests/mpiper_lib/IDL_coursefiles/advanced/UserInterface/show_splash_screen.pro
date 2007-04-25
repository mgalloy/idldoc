;+
; Shows an image without a window border on the screen.
;
; @returns widget identifier of top-level base
; @param image {in}{type=2 or 3 dimensional array} an image to
;        display
; @keyword true {in}{optional}{type=integer, 0-3}{default=0} order of
;          bands, 0 if 8-bit image
; @keyword order {in}{optional}{type=boolean} orientation of image
; @keyword title {in}{optional}{type=string} title of window to
;          display in icon
;-
function show_splash_screen, image, title=title, true=true, $
    order=order

    compile_opt idl2
    on_error, 2

    true_local = n_elements(true) eq 0 ?  0 : true

    sz = size(image, /structure)

    if (true_local eq 0 and sz.n_dimensions ne 2) then $
            message, 'TRUE keyword must be set to 1, 2, 3 ' $
                + 'for 24-bit image'

    if (true_local ne 0 and sz.n_dimensions ne 3) then $
            message, 'TRUE keyword must be set to 0 for 8-bit image'

    xind = (true_local ne 1) ? 0 : 1
    yind = ((true_local eq 0) or (true_local eq 3)) ? 1 : 2

    device, get_screen_size=screen_size
    xoffset = (screen_size[0] - sz.dimensions[xind]) / 2
    yoffset = (screen_size[1] - sz.dimensions[yind]) / 2

    tlb = widget_base(tlb_frame_attr=4, /column, title=title, $
        xpad=0, ypad=0, xoffset=xoffset, yoffset=yoffset)
    draw = widget_draw(tlb, xsize=sz.dimensions[xind], $
        ysize=sz.dimensions[yind])

    widget_control, tlb, /realize
    widget_control, draw, get_value=win_id

    wset, win_id
    tv, image, true=true_local, order=keyword_set(order)

    return, tlb
end
