pro cw_separator_do_output, draw, winID, xsize, ysize
    compile_opt idl2, hidden
    on_error, 2

    sys_colors = widget_info(draw, /system_colors)

    sep = bytarr(3, xsize, ysize)

    ; Background color
    sep[0, *, *] = sys_colors.face_3d[0]
    sep[1, *, *] = sys_colors.face_3d[1]
    sep[2, *, *] = sys_colors.face_3d[2]

    ; Left and top edges
    sep[0, *, ysize - 1] = sys_colors.shadow_3d[0]
    sep[1, *, ysize - 1] = sys_colors.shadow_3d[1]
    sep[2, *, ysize - 1] = sys_colors.shadow_3d[2]

    sep[0, 0, *] = sys_colors.shadow_3d[0]
    sep[1, 0, *] = sys_colors.shadow_3d[1]
    sep[2, 0, *] = sys_colors.shadow_3d[2]

    ; Right and bottom edges
    sep[0, *, 0] = sys_colors.light_edge_3d[0]
    sep[1, *, 0] = sys_colors.light_edge_3d[1]
    sep[2, *, 0] = sys_colors.light_edge_3d[2]

    sep[0, xsize - 1, *] = sys_colors.light_edge_3d[0]
    sep[1, xsize - 1, *] = sys_colors.light_edge_3d[1]
    sep[2, xsize - 1, *] = sys_colors.light_edge_3d[2]

    wset, winID
    tv, sep, true=1
end


;+
; Set the xsize or ysize component of value to 0 to get the default behavior.
; This is useful since a separator doesn't know the parent base's final size
; until all the widgets have been added.
;-
pro cw_separator_set_value, id, value
    compile_opt idl2, hidden
    on_error, 2

    if (n_elements(value) ne 2) then $
        message, 'value must be two element array'

    xsize = value[0]
    ysize = value[1]

    stash = widget_info(id, /child)
    widget_control, stash, get_uvalue=state

    if (xsize eq 0) then begin
        if (keyword_set(state.row)) then begin
            parentG = widget_info(state.parent, /geometry)
            xsize = parentG.scr_xsize - 12 * parentG.xpad > state.minLength
        endif else $
            xsize = state.defWidth
    endif

    if (ysize eq 0) then begin
        if (keyword_set(state.row)) then $
            ysize = state.defWidth $
        else begin
            parentG = widget_info(state.parent, /geometry)
            ysize = parentG.scr_ysize - 12 * parentG.ypad > state.minLength
        endelse
    endif

    state.xsize = xsize
    state.ysize = ysize

    widget_control, stash, set_uvalue=state

    widget_control, state.draw, xsize=xsize, ysize=ysize

    cw_separator_do_output, id, state.drawID, xsize, ysize
end


function cw_separator_get_value, id
    compile_opt idl2, hidden
    on_error, 2

    stash = widget_info(id, /child)
    widget_control, stash, get_uvalue=state
    return, [state.xsize, state.ysize]
end


pro cw_separator_realize, top
    compile_opt idl2, hidden

    on_error, 2

    stash = widget_info(top, /child)
    widget_control, stash, get_uvalue=state
    widget_control, state.draw, get_value=drawID
    state.drawID = drawID
    widget_control, stash, set_uvalue=state

    cw_separator_do_output, top, drawID, state.xsize, state.ysize
end


;+
; cw_separator
;
; Create a line separator to divide space between widgets.
;
; Written by Michael D. Galloy
; Copyright RSI, 2001
;-
function cw_separator, parent, xsize=xsize, ysize=ysize, row=row, column=column
    compile_opt idl2
    on_error, 2

    if (keyword_set(row) and keyword_set(column)) then $
        message, 'must be either row or column separator'

    if (not keyword_set(row) and not keyword_set(column)) then $
        row = 1

    minLength = 5 ; cols if /row, rows if /column
    defWidth = 3  ; rows if /row, cols if /column

    if (n_elements(xsize) eq 0) then begin
        if (keyword_set(row)) then begin
            parentG = widget_info(parent, /geometry)
            xsize = parentG.scr_xsize - 12 * parentG.xpad > minLength
        endif else $
            xsize = defWidth
    endif

    if (n_elements(ysize) eq 0) then begin
        if (keyword_set(row)) then $
            ysize = defWidth $
        else begin
            parentG = widget_info(parent, /geometry)
            ysize = parentG.scr_ysize - 12 * parentG.ypad > minLength
        endelse
    endif

    tlb = widget_base(parent, /column, /align_center, /base_align_center, $
        pro_set_value='cw_separator_set_value', $
        func_get_value='cw_separator_get_value')

    draw = widget_draw(tlb, xsize=xsize, ysize=ysize)

    state = { $
        xsize:xsize, $
        ysize:ysize, $
        draw:draw, $
        drawID:0, $
        parent:parent, $
        row:keyword_set(row), $
        minLength:minLength, $
        defWidth:defWidth $
        }
    widget_control, widget_info(tlb, /child), set_uvalue=state

    widget_control, tlb, notify_realize='cw_separator_realize'

    return, tlb
end