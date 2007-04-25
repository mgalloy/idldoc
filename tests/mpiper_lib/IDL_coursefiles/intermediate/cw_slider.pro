;+
; Updates the labels above the slider to the current value.
;
; @private
; @param pstate {in}{type=pointer} pointer to the state structure
;-
pro cw_slider_update_label, pstate
    compile_opt idl2, hidden
    on_error, 2

    valStr = strtrim(string((*pstate).value, format=(*pstate).format), 2)
    widget_control, (*pstate).label, set_value=valStr
end


;+
; Converts a number of pixels to a value.
;
; @private
; @returns the value
; @param pstate {in}{type=pointer} pointer to state structure
; @param x {in}{type=numeric type} number of pixels
;-
function cw_slider_convert_x_to_val, pstate, x
    compile_opt idl2, hidden
    on_error, 2

    val = (x - (*pstate).button_xsize - 1.) * $
        ((*pstate).maximum - (*pstate).minimum)
    val = val / ((*pstate).xsize - 2 * (*pstate).button_xsize - 2)
    val = val + (*pstate).minimum
    val = val < (*pstate).maximum
    val = val > (*pstate).minimum

    return, val
end


;+
; Converts a value to a number of pixels.  The current value is stored in the
; state structure, so it does not need to be passed.
;
; @private
; @returns the number of pixels
; @param pstate {in}{type=pointer} pointer to state structure
;-
function cw_slider_convert_val_to_x, pstate
    compile_opt idl2, hidden
    on_error, 2

    x = (((*pstate).value - (*pstate).minimum) * ((*pstate).xsize - 2 * (*pstate).button_xsize - 2)) $
        / ((*pstate).maximum - (*pstate).minimum)
    x = x + (*pstate).button_xsize / 2 + 1
    x = x > ((*pstate).button_xsize + 1)
    x = x < ((*pstate).xsize - 2 * (*pstate).button_xsize - 1)
    return, fix(x)
end


;+
; Refresh the slider display.
;
; @private
; @param pstate {in}{type=pointer} pointer to state structure
;-
pro cw_slider_refresh, pstate
    compile_opt idl2, hidden
    on_error, 2

    wset, (*pstate).drawID
    device, copy=[0, 0, (*pstate).xsize, (*pstate).ysize, 0, 0, $
        (*pstate).pixID]
end


;+
; Graphic comammands to move slider.
;
; @private
; @param pstate {in}{type=pointer} pointer to state structure
;-
pro cw_slider_put_slider, pstate
    compile_opt idl2, hidden
    on_error, 2

    x = cw_slider_convert_val_to_x(pstate)
    wset, (*pstate).drawID
    device, copy=[0, 0, (*pstate).button_xsize, (*pstate).button_ysize, $
        x, 1, (*pstate).buttonID]
end


;+
; This procedure is used if the user provides an event_pro for the compound
; widget.  This procedure will call the user's event_pro.
;
; @private
; @param event {in}{type=structure} event structure
;-
pro cw_slider_event_pro, event
    compile_opt idl2, hidden
    on_error, 2

    widget_control, widget_info(event.handler, /child), get_uvalue=pstate
    ret = cw_slider_event_func(event)

    if (size(ret, /type) eq 8) then begin
        ret.id = event.handler
        call_procedure, (*pstate).event_pro, ret
    endif
end


;+
; Main event handler for the slider.
;
; @private
; @returns 0 if event should be ignored; a new event if it should be passed
;          up the event handler tree
; @param event {in}{type=structure} event structure
;-
function cw_slider_event_func, event
    compile_opt idl2, hidden
    on_error, 2

    widget_control, widget_info(event.handler, /child), get_uvalue=pstate
    widget_control, event.id, get_uvalue=uval

    ret = 0

    if (uval eq 'timer') then begin

        if ((*pstate).down eq 0) then return, 0

        (*pstate).delay = (*pstate).delay * (*pstate).delay_factor > $
            (*pstate).delay_cutoff
        case (*pstate).up_button of
        -1 : begin
                (*pstate).value = ((*pstate).value - (*pstate).increment) > $
                    (*pstate).minimum
                widget_control, (*pstate).timer, timer=(*pstate).delay

            end
        0 : ; shouldn't happen
        1 : begin
                (*pstate).value = ((*pstate).value + (*pstate).increment) < $
                    (*pstate).maximum
                widget_control, (*pstate).timer, timer=(*pstate).delay
            end
        endcase

        cw_slider_refresh, pstate
        cw_slider_put_slider, pstate
        cw_slider_update_label, pstate
        return, { cw_slider, id:event.handler, top:event.top, $
            handler:event.handler, value:(*pstate).value, drag:1 }
    endif

    case event.type of
    0 : begin ; Button press
            (*pstate).down = 1

            if (event.x le (*pstate).button_xsize) then begin
                ; Decrement button press
                (*pstate).value = ((*pstate).value - (*pstate).increment) > $
                    (*pstate).minimum
                widget_control, (*pstate).timer, timer=(*pstate).delay
                (*pstate).up_button = -1
            endif else if (event.x ge $
                ((*pstate).xsize - (*pstate).button_xsize)) then begin
                    ; Increment button press
                    (*pstate).value = ((*pstate).value + (*pstate).increment) < $
                        (*pstate).maximum
                    widget_control, (*pstate).timer, timer=(*pstate).delay
                    (*pstate).up_button = 1
            endif else begin
                ; Slider press
                (*pstate).value = cw_slider_convert_x_to_val(pstate, event.x)
                (*pstate).up_button = 0
            endelse
            ret = { cw_slider, id:event.handler, top:event.top, $
                handler:event.handler, value:(*pstate).value, drag:0 }
        end
    1 : begin ; Button release
            widget_control, (*pstate).timer, /clear_events
            (*pstate).down = 0
            (*pstate).up_button = 0
            (*pstate).delay = (*pstate).orig_delay
        end
    2 : begin ; Motion
            if ((*pstate).down eq 0) then return, 0

            case (*pstate).up_button of
            -1 :
            0 : begin
                    (*pstate).value = cw_slider_convert_x_to_val(pstate, event.x)
                    ret = { cw_slider, id:event.handler, top:event.top, $
                        handler:event.handler, value:(*pstate).value, drag:1 }
                end
            1 :
            endcase
        end
    3 : ; Scroll: Will not happen
    4 : begin ; Expose
            wset, (*pstate).drawID
            device, copy=[0, 0, (*pstate).xsize, (*pstate).ysize, 0, 0, $
                (*pstate).pixID]
            cw_slider_put_slider, pstate
        end
    endcase

    cw_slider_refresh, pstate
    cw_slider_put_slider, pstate
    cw_slider_update_label, pstate

    return, ret
end


;+
; Cleanup procedure for the compound widget.  This takes care of deleting
; pixmaps and pointers.
;
; @private
; @param id {in}{type=widget ID} widget ID of "stash"
;-
pro cw_slider_cleanup, id
    compile_opt idl2, hidden
    on_error, 2

    widget_control, id, get_uvalue=pstate
    wdelete, (*pstate).buttonID
    wdelete, (*pstate).pixID
    ptr_free, pstate
end


;+
; Handles drawing the slider; must be done after the draw widget is realized.
;
; @private
; @param id {in}{type=widget ID} widget ID of "stash"
;-
pro cw_slider_realize, id
    compile_opt idl2, hidden
    on_error, 2

    widget_control, id, get_uvalue=pstate

    device, get_decomposed=dc
    device, decomposed=1

    widget_control, (*pstate).draw, get_value=drawID
    (*pstate).drawID = drawID

    sys_colors = widget_info((*pstate).draw, /system_colors)
    dark = rgb2idx(sys_colors.shadow_3d)
    light = rgb2idx(sys_colors.light_edge_3d)
    background = rgb2idx(sys_colors.face_3d)
    scroll = rgb2idx(sys_colors.scrollbar)

    window, /free, /pixmap, xsize=(*pstate).xsize, ysize=(*pstate).ysize
    (*pstate).pixID = !d.window
    erase, scroll

    xsize = (*pstate).xsize
    ysize = (*pstate).ysize
    b_xsize = (*pstate).button_xsize
    b_ysize = (*pstate).button_ysize

    plots, [0, 0, xsize - 1], [0, ysize - 1, ysize - 1], $
        /device, color=dark
    plots, [0, xsize - 1, xsize - 1], [0, 0, ysize - 1], $
        /device, color=light

    window, /free, /pixmap, xsize=b_xsize, ysize=b_ysize
    (*pstate).buttonID = !d.window

    erase, background
    plots, [0, 0, b_xsize-1], [0, b_ysize-1, b_ysize-1], $
        /device, color=light
    plots, [0, b_xsize-1, b_xsize-1], [0, 0, b_ysize-1], $
        /device, color=dark

    wset, (*pstate).pixID
    device, copy=[0, 0, b_xsize, b_ysize, 1, 1, (*pstate).buttonID]
    device, copy=[0, 0, b_xsize, b_ysize, xsize-b_xsize-1, 1, $
        (*pstate).buttonID]

    wset, (*pstate).drawID
    device, copy=[0, 0, xsize, ysize, 0, 0, (*pstate).pixID]

    device, decomposed=dc

    cw_slider_put_slider, pstate

    case strupcase(!version.os_family) of
        'WINDOWS' : cursor = 32512
        'UNIX' : cursor = 68
        else : cursor = 68
    endcase

    device, cursor_standard=cursor
end


;+
; Called by "WIDGET_CONTROL, wSlider, SET_VALUE=val".
;
; @private
; @param id {in}{type=widget ID} widget ID of the compound widget
; @param value {in}{type=numeric type} value to set the slider to
;-
pro cw_slider_set_value, id, value
    compile_opt idl2, hidden
    on_error, 2

    widget_control, widget_info(id, /child), get_uvalue=pstate
    if (value lt (*pstate).minimum or value gt (*pstate).maximum) then $
        message, 'value not in range for this spinner'

    (*pstate).value = value

    cw_slider_refresh, pstate
    cw_slider_put_slider, pstate
    cw_slider_update_label, pstate
end


;+
; Called by "WIDGET_CONTROL, wSlider, GET_VALUE=val".
;
; @private
; @returns the value of the widget
; @param id {in}{type=widget ID} widget ID of the compound widget
;-
function cw_slider_get_value, id
    compile_opt idl2, hidden
    on_error, 2

    widget_control, widget_info(id, /child), get_uvalue=pstate
    return, (*pstate).value
end


;+
; Compound widget representing a slider.  This slider allows for "DRAG" events
; on all systens and it drawn via a draw widget.
;
; @returns widget identifier for the compound widget
; @param parent {in}{type=widget ID} parent widget's ID
; @keyword delay {in}{optional}{type=numeric}{default=0.25} number of seconds
;          to wait before repeating when the user has the arrow button down
; @keyword delay_cutoff {in}{optional}{type=numeric}{default=1E-3} the shortest
;          delay time
; @keyword delay_factor {in}{optional}{type=numeric}{default=0.75} multiplier
;          of delay (so there is an acceleration effect)
; @keyword font {in}{optional}{type=string} font to use
; @keyword format {in}{optional}{type=string} format string (as used in PRINT)
; @keyword increment {in}{optional}{type=numeric}{default=1 pixel} amount to
;          move the slider on a single click of the arrows
; @keyword minimum {in}{optional}{type=numeric}{default=0}
; @keyword maximum {in}{optional}{type=numeric}{default=1}
; @keyword title {in}{optional}{type=string}{default=''} string displayed above
;          slider
; @keyword uname {in}{optional}{type=string}{default=none} standard UNAME;
;          can be accessed with WIDGET_CONTROL
; @keyword uvalue {in}{optional}{type=any IDL variable}{default=none} standard
;          UVALUE; can be accessed with WIDGET_CONTROL
; @keyword value {in}{optional}{type=numeric}{default=minimum} initial value
;          of the slider; can be accessed with WIDGET_CONTROL
; @keyword xsize {in}{optional}{type=integer type}{default=128 pixels} length
;          of slider (including arrows)
; @keyword ysize {in}{optional}{type=integer type}{default=14 pixels} height of
;          slider
; @author Michael Galloy
; @copyright RSI, 2001
;-
function cw_slider, parent, $
    delay=delay, $
    delay_cutoff=delay_cutoff, $
    delay_factor=delay_factor, $
    event_pro=event_pro, $
    font=font, $
    format=format, $
    increment=increment, $
    integer=integer, $
    minimum=minimum, $
    maximum=maximum, $
    title=title, $
    uname=uname, $
    uvalue=uvalue, $
    value=value, $
    xsize=xsize, $
    ysize=ysize

    compile_opt idl2
    on_error, 2

    if (n_elements(xsize) eq 0) then xsize = 128
    if (n_elements(ysize) eq 0) then ysize = 14

    button_xsize = ysize - 2
    button_ysize = ysize - 2

    if (n_elements(delay) eq 0) then delay = 0.25
    if (n_elements(delay_factor) eq 0) then delay_factor = 0.75
    if (n_elements(delay_cutoff) eq 0) then delay_cutoff = 1e-3

    if (n_elements(event_pro) eq 0) then begin
        epro = ''
        efunc = 'cw_slider_event_func'
        event_pro = ''
    endif else begin
        epro = 'cw_slider_event_pro'
        efunc = ''
    endelse

    if (n_elements(font) eq 0) then font = ''
    if (n_elements(format) eq 0) then $
        format = keyword_set(integer) ? '(I6)' : '(F6.2)'
    if (n_elements(minimum) eq 0) then miniumum = 0
    if (n_elements(maximum) eq 0) then maxiumum = 1
    if (n_elements(value) eq 0) then value = minimum

    if (keyword_set(integer)) then begin
        value = fix(value)
        minimum = fix(minimum)
        maximum = fix(maximum)
    endif

    if (n_elements(increment) eq 0) then $
        increment = float(maximum - minimum) / (xsize - 2 * button_xsize - 2)

    if (keyword_set(integer)) then $
        increment = ceil(increment)

    if (n_elements(uvalue) eq 0) then uvalue = ''
    if (n_elements(uname) eq 0) then uname = ''

    tlb = widget_base(parent, /column, xpad=0, ypad=0, $
        event_func=efunc, $
        event_pro=epro, $
        pro_set_value='cw_slider_set_value', $
        func_get_value='cw_slider_get_value', $
        uname=uname, uvalue=uvalue)
    label = widget_label(tlb, value=strtrim(string(value, format=format), 2), $
        /dynamic_resize, font=font)
    draw = widget_draw(tlb, xsize=xsize, ysize=ysize, /button_events, $
        /motion_events, /expose_events, uvalue='draw')

    if (n_elements(title) ne 0) then $
        titleLabel = widget_label(tlb, value=title, /align_left, font=font)

    timer = widget_base(tlb, /column, uvalue='timer', xpad=0, ypad=0)

    state = { $
        event_pro:event_pro, $
        xsize:xsize, ysize:ysize, $
        maximum:maximum, minimum:minimum, $
        increment:increment, $
        button_xsize:button_xsize, button_ysize:button_ysize, $
        draw:draw, $
        drawID:-1, $
        pixID:-1, $
        buttonID:-1, $
        label:label, $
        format:format, $
        value:float(value), $
        down:0, $
        up_button:0, $
        timer:timer, $
        orig_delay:delay, $
        delay:delay, $
        delay_cutoff:delay_cutoff, $
        delay_factor:delay_factor $
        }
    pstate = ptr_new(state, /no_copy)
    widget_control, widget_info(tlb, /child), set_uvalue=pstate, $
        kill_notify='cw_slider_cleanup'

    widget_control, tlb, /realize
    cw_slider_realize, widget_info(tlb, /child)

    return, tlb
end

