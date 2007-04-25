
;====================================================================
;+
;   draw_plot
;-
pro draw_plot, old_x, old_y, new_x, new_y

    plot, old_x, old_y, /nodata
    oplot, old_x, old_y, psym=5, symsize=0.7, color=100
    if n_elements(new_y) ne 0 then oplot, new_x, new_y

end


;====================================================================
;+
;   view_spline_fit_event
;-
pro view_spline_fit_event, event

    widget_control, event.top, get_uvalue=pstate
    widget_control, event.id, get_uvalue=slider

    if (tag_names(event, /struct) eq 'WIDGET_KILL_REQUEST') $
        or (slider eq 'return') then begin
        widget_control, event.top, /destroy
        return
    endif

    if slider eq 'points' then begin
        widget_control, event.id, get_value=n_new_x
        (*pstate).n_new_x = n_new_x
    endif
    if slider eq 'sigma' then begin
        widget_control, event.id, get_value=sigma
        (*pstate).sigma = sigma
    endif

    new_x = findgen((*pstate).n_new_x)/((*pstate).n_new_x-1) $
        * ((*pstate).max_old_x-(*pstate).min_old_x) $
        + (*pstate).min_old_x
    new_y = spline((*pstate).old_x, (*pstate).old_y, new_x, $
                   (*pstate).sigma)

    draw_plot, (*pstate).old_x, (*pstate).old_y, new_x, new_y

    *(*pstate).new_x = new_x
    *(*pstate).new_y = new_y

end


;====================================================================
;+
; The widget creation routine.
;
; @file_comments A widget interface for the IDL built-in SPLINE
;   function.
; @param o_x {in}{type=numeric} A 1D array of abscissa values.
; @param o_y {in}{type=numeric} A 1D array of ordinate values.
; @keyword new_x {out}{type=numeric} A 1D array of abscissa values
;   for the interpolating function.
; @examples
;   <code>
;   IDL> x = findgen(10)*4 + randomu(seed, 10)*4<br>
;   IDL> y = beselj(x/3)<br>
;   IDL> new_y = view_spline_fit(x, y, new_x=new_x)<br>
;   IDL> plot, x, y, psym=5
;   IDL> oplot, new_x, new_y, line=1
;   </code>
; @author Mark Piper, RSI, 1999-11-17
;-
function view_spline_fit, o_x, o_y, NEW_X=n_x

    np = n_params()
    case np of
        0: begin
            message, 'Need two parameters: old_x, old_y', /info
            return, 0
        end
        1: begin
            old_y = o_x
            old_x = findgen(n_elements(o_x))
        end
        2: begin
            old_y = o_y
            old_x = o_x
        end
    endcase

    tvlct, old_r, old_g, old_b, /get
    loadct, 0, /silent
    tvlct, 0, 200, 0, 100

    max_old_x = max(old_x, min=min_old_x)
    n_old_x = n_elements(old_x)

    wtop = widget_base(title='View Spline Fit', /row, xoffset=100, $
                       yoffset=100, /tlb_kill_request)
    wdraw = widget_draw(wtop, xsize=400, ysize=300)
    wsbase = widget_base(wtop, /column)
    wslider1 = widget_slider(wsbase, $
        min=n_old_x, max=5*max_old_x, value=n_old_x, $
        title='Number of Points to Fit', $
        uvalue='points')
    wslider2 = cw_fslider(wsbase, min=0.01, max=20.0, value=1.0, $
                              title='Adjust Tension of Spline', $
                              /edit, uvalue='sigma')
    wreturn = widget_button(wsbase, value='Return', uvalue='return')

    widget_control, wtop, /realize

    widget_control, wslider1, get_value=n_new_x
    new_x = findgen(n_new_x)/(n_new_x-1) * $
        (max_old_x-min_old_x) + min_old_x
    new_y = spline(old_x, old_y, new_x, sigma)

    widget_control, wdraw, get_value=win_id
    wset, win_id
    draw_plot, old_x, old_y, new_x, new_y

    state = {old_x:old_x, $
             old_y:old_y, $
             new_x:ptr_new(new_x, /no_copy), $
             new_y:ptr_new(new_y, /no_copy), $
             sigma:sigma, $
             max_old_x:max_old_x, $
             min_old_x:min_old_x, $
             n_old_x:n_old_x, $
             n_new_x:n_new_x}
    pstate = ptr_new(state, /no_copy)
    widget_control, wtop, set_uvalue=pstate
    xmanager, 'view_spline_fit', wtop

    tvlct, old_r, old_g, old_b

    if arg_present(n_x) then n_x = *(*pstate).new_x
    n_y = *(*pstate).new_y
    ptr_free, (*pstate).new_x
    ptr_free, (*pstate).new_y
    ptr_free, pstate

    return, n_y
end
