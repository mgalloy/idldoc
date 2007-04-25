; TODO
;   add /integer, /float, and /double keywords, TYPE=
;   make arrows prettier
;   tooltips

;+
; Handle draw widget events.
;
; @param event {in}{type=event structure} draw widget event
; @private
;-
pro cw_spinner_draw, event
    compile_opt idl2, hidden
    on_error, 2

    widget_control, widget_info(event.handler, /child), get_uvalue=pstate

    case event.type of
    0 : begin
            (*pstate).down = 1
            widget_control, (*pstate).text, get_value=value
            (*pstate).value = float(value)

            (*pstate).up = event.y ge (*pstate).ysize / 2 ? 1 : -1

            tempValue = (*pstate).value + (*pstate).up * (*pstate).increment
            tempValue = tempValue > (*pstate).minimum
            tempValue = tempValue < (*pstate).maximum

            (*pstate).value = tempValue
            widget_control, (*pstate).text, $
                set_value=strtrim(string((*pstate).value, $
                    format=(*pstate).format), 2)

            widget_control, (*pstate).timer, timer=(*pstate).delay_time
        end
    1 : begin
            (*pstate).down = 0
            (*pstate).delay_time = (*pstate).orig_delay
            widget_control, (*pstate).timer, /clear_events
        end
    2 : ; Motion - shouldn't happen
    3 : ; Scroll - shouldn't happen
    4 : (*pstate).oWindow->draw, (*pstate).oView
    endcase
end


;+
; @private
; @param event {in}{type=structure} text, timer, and draw events
;-
pro cw_spinner_event_pro, event
    compile_opt idl2, hidden
    on_error, 2

    widget_control, widget_info(event.handler, /child), get_uvalue=pstate
    ret = cw_spinner_event_func(event)

    if (size(ret, /type) eq 8) then $
        call_procedure, (*pstate).event_pro, ret
end


;+
; Main event handling code.
;
; @private
; @returns cw_spinner_event structure
; @param event {in}{type=event structure} draw, text, and timer events
;-
function cw_spinner_event_func, event
    compile_opt idl2, hidden
    on_error, 2

    widget_control, widget_info(event.handler, /child), get_uvalue=pstate
    widget_control, event.id, get_uvalue=uval

    timer = 0

    case uval of
    'draw' : cw_spinner_draw, event
    'text' : begin
            widget_control, (*pstate).text, get_value=value
            (*pstate).value = float(value)
        end
    'timer' : begin
            timer = 1
            if ((*pstate).down) then begin
                temp = (*pstate).value + (*pstate).up * (*pstate).increment
                if (temp ge (*pstate).minimum and $
                    temp le (*pstate).maximum) then begin
                    (*pstate).value = temp
                    widget_control, (*pstate).text, $
                        set_value=strtrim(string((*pstate).value, $
                            format=(*pstate).format), 2)
                endif
                (*pstate).delay_time = (*pstate).delay_factor * (*pstate).delay_time > $
                    (*pstate).delay_cutoff
                widget_control, (*pstate).timer, timer=(*pstate).delay_time
            endif
        end
    endcase

    return, { cw_spinner, id:event.handler, top:event.top, $
        handler:event.handler, value:double((*pstate).value), drag:timer }
end


;+
; @private
; @returns
; @param tlb {in}{type=long}
; @keyword xsize {in}{type=numeric}
; @keyword ysize {out}{type=numeric}
;-
function cw_spinner_create_arrows, tlb, xsize=xsize, ysize=ysize
    compile_opt idl2, hidden
    on_error, 2

    sys_colors = widget_info(tlb, /system_colors)
    arrows = bytarr(3, xsize, ysize)
    arrows[0, *, *] = sys_colors.face_3d[0]
    arrows[1, *, *] = sys_colors.face_3d[1]
    arrows[2, *, *] = sys_colors.face_3d[2]

    arrows[0, 0, *] = sys_colors.light_edge_3d[0]
    arrows[1, 0, *] = sys_colors.light_edge_3d[1]
    arrows[2, 0, *] = sys_colors.light_edge_3d[2]

    arrows[0, *, [(ysize-1)/2, ysize-1]] = sys_colors.light_edge_3d[0]
    arrows[1, *, [(ysize-1)/2, ysize-1]] = sys_colors.light_edge_3d[1]
    arrows[2, *, [(ysize-1)/2, ysize-1]] = sys_colors.light_edge_3d[2]

    arrows[0, xsize - 1, *] = sys_colors.shadow_3d[0]
    arrows[1, xsize - 1, *] = sys_colors.shadow_3d[1]
    arrows[2, xsize - 1, *] = sys_colors.shadow_3d[2]

    arrows[0, *, [(ysize + 1)/2, 0]] = sys_colors.shadow_3d[0]
    arrows[1, *, [(ysize + 1)/2, 0]] = sys_colors.shadow_3d[1]
    arrows[2, *, [(ysize + 1)/2, 0]] = sys_colors.shadow_3d[2]

    width = 2
    for y = 5, (ysize - 1) / 2 do begin
        arrows[0, ((xsize - 1) / 2 - width / 2):((xsize - 1) / 2 + width / 2), y] = 0
        arrows[1, ((xsize - 1) / 2 - width / 2):((xsize - 1) / 2 + width / 2), y] = 0
        arrows[2, ((xsize - 1) / 2 - width / 2):((xsize - 1) / 2 + width / 2), y] = 0
        width = width + 2
        if (width ge xsize - 4) then break
    endfor

    width = 2
    for y = ysize - 6, (ysize + 1) / 2, -1 do begin
        arrows[0, ((xsize - 1) / 2 - width / 2):((xsize - 1) / 2 + width / 2), y] = 0
        arrows[1, ((xsize - 1) / 2 - width / 2):((xsize - 1) / 2 + width / 2), y] = 0
        arrows[2, ((xsize - 1) / 2 - width / 2):((xsize - 1) / 2 + width / 2), y] = 0
        width = width + 2
        if (width ge xsize - 4) then break
    endfor

    return, arrows
end


;+
; @private
; @param stash {in}{type=long}
;-
pro cw_spinner_realize, stash
    compile_opt idl2, hidden
    on_error, 2

    widget_control, stash, get_uvalue=pstate

    textG = widget_info((*pstate).text, /geometry)
    widget_control, (*pstate).draw, $
        draw_xsize=fix(textG.scr_ysize / 2), $
        draw_ysize=fix(textG.scr_ysize)

    widget_control, (*pstate).draw, get_value=oWindow
    (*pstate).oWindow = oWindow

    (*pstate).oView = obj_new('IDLgrView', location=[0, 0], $
        dimensions=[(*pstate).xsize, (*pstate).ysize])

    oModel = obj_new('IDLgrModel')
    (*pstate).oView->add, oModel

    oImage = obj_new('IDLgrImage', (*pstate).arrows)
    oModel->add, oImage

    oImage->getProperty, xrange=xr, yrange=yr
    xc = norm_coord(xr)
    yc = norm_coord(yr)
    xc[0] = 2 * (xc[0] - 0.5)
    yc[0] = 2 * (yc[0] - 0.5)
    xc[1] = 2 * xc[1]
    yc[1] = 2 * yc[1]
    oImage->setProperty, xcoord_conv=xc, ycoord_conv=yc

    oWindow->draw, (*pstate).oView

    oWindow->setCurrentCursor, 'ARROW'
end


;+
; @private
; @param id {in} {type=long} widget identifier of the spinner
;-
pro cw_spinner_cleanup, id
    compile_opt idl2, hidden
    on_error, 2

    widget_control, id, get_uvalue=pstate
    obj_destroy, (*pstate).oWindow
    obj_destroy, (*pstate).oView
    ptr_free, pstate
end


;+
; @private
; @param id {in}{type=widget ID} widget identifier of the spinner
; @param value {in} {type=numeric} new value for the spinner
;-
pro cw_spinner_set_value, id, value
    compile_opt idl2, hidden
    on_error, 2

    widget_control, widget_info(id, /child), get_uvalue=pstate

    if (value lt (*pstate).minimum or value gt (*pstate).maximum) then $
        message, 'value not in range for this spinner'

    (*pstate).value = value
    strVal = strtrim(string(value, format=(*pstate).format), 2)
    widget_control, (*pstate).text, set_value=strVal
end


;+
; @private
; @returns the value of the spinner
; @param id {in} {type=lon} widget identifier of the spinner
;-
function cw_spinner_get_value, id
    compile_opt idl2, hidden
    on_error, 2

    widget_control, widget_info(id, /child), get_uvalue=pstate

    return, (*pstate).value
end


;+
; A "spinner" that allows a user to click on arrows to change a numeric value.
;
; @file_comments A "spinner" that allows a user to click on arrows to change
;                a numeric value.
; @returns the widget identifier of the base of the compound widget
; @param parent {in}{type=int} parent widget identifier
; @keyword event_pro {in}{type=string} event handlerprocedure for events
;          generated by the spinner
; @keyword font {in}{type=string} font for the title
; @keyword format {in}{type=string} format code suitable for string FORMAT
;          keyword to format the value
; @keyword value {in}{type=numeric}
; @keyword minimum {in}{type=numeric}
; @keyword maximum {in}{type=numeric}
; @keyword increment {in}{type=numeric}
; @keyword xsize {in}{type=numeric}
; @keyword title {in}{type=string}
; @keyword delay_time {in}{type=float}
; @keyword delay_factor {in}{type=float}
; @keyword delay_cutoff {in}{type=float}
; @keyword uname {in}{type=string} sets the user name of the compound widget
; @keyword uvalue {in}{type=any} sets the user value of the compound widget
; @requires IDL 5.5
; @author Michael D. Galloy
; @copyright RSI, 2001
;-
function cw_spinner, parent, $
    event_pro=event_pro, $
    font=font, $
    format=format, $
    value=value, $
    minimum=minimum, $
    maximum=maximum, $
    increment=increment, $
    xsize=xsize, $
    title=title, $
    delay_time=delay_time, $
    delay_factor=delay_factor, $
    delay_cutoff=delay_cutoff, $
    type=type, $
    uvalue=uvalue, $
    uname=uname

    compile_opt idl2
    on_error, 2

    if (n_elements(event_pro) eq 0) then begin
        event_pro = ''
        epro = ''
        efunc = 'cw_spinner_event_func'
    endif else begin
        epro = 'cw_spinner_event_pro'
        efunc = ''
    endelse

    if (n_elements(font) eq 0) then font = ''
    if (n_elements(format) eq 0) then format = '(F6.2)'
    if (n_elements(maximum) eq 0) then maximum = !values.f_infinity
    if (n_elements(minimum) eq 0) then minimum = -!values.f_infinity
    if (n_elements(increment) eq 0) then $
        increment = (maximum - minimum) / 100.
    if (n_elements(xsize) eq 0) then xsize = 8
    if (n_elements(delay_time) eq 0) then delay_time = 0.25
    if (n_elements(delay_factor) eq 0) then delay_factor = 0.75
    if (n_elements(delay_cutoff) eq 0) then delay_cutoff = 1e-3
    if (n_elements(uname) eq 0) then uname = ''
    if (n_elements(value) eq 0) then value = minimum
    if (n_elements(type) eq 0) then type = size(value, /type)

    tlb = widget_base(parent, /row, space=0, /base_align_center, $
        event_pro=epro, event_func=efunc, $
        pro_set_value='cw_spinner_set_value', $
        func_get_value='cw_spinner_get_value', $
        uvalue=uvalue, uname=uname)
    stash = widget_base(tlb, /row, xpad=0, ypad=0)
    if (n_elements(title) ne 0) then $
        label = widget_label(tlb, value=title, font=font)
    text = widget_text(tlb, value=strtrim(string(value, format=format), 2), $
        xsize=xsize, /edit, uvalue='text', font=font)

    buttons_xsize = 12
    buttons_ysize = 22;fix(textG.scr_ysize)

    arrows = cw_spinner_create_arrows(tlb, $
        xsize=buttons_xsize, ysize=buttons_ysize)
    draw = widget_draw(tlb, $
        xsize=buttons_xsize, ysize=buttons_ysize, $
        /button_events, /expose_events, $
        uvalue='draw', graphics_level=2, renderer=1)
    timer = widget_base(tlb, uvalue='timer', xpad=0, ypad=0)

    state = { $
        event_pro:event_pro, $
        draw:draw, $
        oWindow:obj_new(), $
        oView:obj_new(), $
        arrows:arrows, $
        xsize:buttons_xsize, $
        ysize:buttons_ysize, $
        text:text, $
        timer:timer, $
        format:format, $
        value:fix(value, type=type), $
        maximum:maximum, $
        minimum:minimum, $
        increment:increment, $
        orig_delay:delay_time, $
        delay_time:delay_time, $
        delay_factor:delay_factor, $
        delay_cutoff:delay_cutoff, $
        down:0, $
        up:1, $
        waiting:0 $
        }
    pstate = ptr_new(state, /no_copy)
    widget_control, widget_info(tlb, /child), set_uvalue=pstate, $
        kill_notify='cw_spinner_cleanup
    widget_control, widget_info(tlb, /child), $
        notify_realize='cw_spinner_realize'

    widget_control, tlb, /realize
    cw_spinner_realize, widget_info(tlb, /child)

    help, /str, widget_info(draw, /geometry)

    return, tlb
end
