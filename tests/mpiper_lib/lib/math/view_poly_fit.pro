;+
;   view_poly_fit
;
;   11-17-99
;   Mark Piper
;
;   Build a GUI around the POLY_FIT function.
;-

;====================================================================
;+
;   draw_plot
;-
pro draw_plot, old_x, old_y, new_x, new_y

    plot, old_x, old_y, /nodata
    oplot, old_x, old_y, psym=5, symsize=0.7, color=100
    if n_elements(new_y) ne 0 then $
        oplot, new_x, new_y, color=101

end


;====================================================================
;+
;   view_poly_fit_event
;-
pro view_poly_fit_event, event

    widget_control, event.top, get_uvalue=pstate
    widget_control, event.id, get_uvalue=uval

    if (tag_names(event, /struct) eq 'WIDGET_KILL_REQUEST') $
        or (uval eq 'return') then begin
        widget_control, event.top, /destroy
        return
    endif

    if uval eq 'degree' then begin
        widget_control, event.id, get_value=degree
        coeffs = poly_fit((*pstate).old_x, (*pstate).old_y, $
                          degree, new_y)
        (*pstate).degree = degree
        *(*pstate).coeffs = coeffs
        *(*pstate).new_y = new_y
    endif

    draw_plot, (*pstate).old_x, (*pstate).old_y, $
        (*pstate).old_x, *(*pstate).new_y

end


;====================================================================
;+
;   view_poly_fit
;-
function view_poly_fit, old_x, old_y, YFIT=yfit
    compile_opt idl2

;
;  Check the input parameters
;
    if n_params() ne 2 then begin
        message, 'Need two parameters, x & y', /info
        return, 0
    endif

    n_old_x = n_elements(old_x)

;
;  Load colors
;
    tvlct, old_r, old_g, old_b, /get
    loadct, 0, /silent
    tvlct, 0, 200, 0, 100
    tvlct, 200, 0, 0, 101

;
;  Create the widget hierarchy
;
    wtop = widget_base(title='View Polynomial Fit', /row, $
                       xoffset=100, yoffset=100, /tlb_kill_request)
    wcolbase = widget_base(wtop, /column)
    wdegree = widget_slider(wcolbase, title='Degree', $
                            value=2, min=0, max=n_old_x/2.0, uvalue='degree')
    wreturn = widget_button(wcolbase, value='Return', $
                            uvalue='return')
    wdraw = widget_draw(wtop, xsize=400, ysize=325)

;
;  Realize the widget hierarchy
;
    widget_control, wtop, /realize
    widget_control, wdegree, get_value=degree

;
;  Access properties of the realized widgets
;
    widget_control, wdraw, get_value=win_id
    wset, win_id
    draw_plot, old_x, old_y

;
;  Store information in the state structure
;
    state = {old_x:old_x, $
             old_y:old_y, $
             degree:degree, $
             coeffs:ptr_new(fltarr(3)), $
             new_y:ptr_new(fltarr(n_old_x)) $
            }
    pstate = ptr_new(state, /no_copy)
    widget_control, wtop, set_uvalue=pstate

;
;  Call XMANAGER
;
    xmanager, 'view_poly_fit', wtop

;
;  When the widget is killed, clean up and return info
;  to the calling level
;
    tvlct, old_r, old_g, old_b
    coeffs = *(*pstate).coeffs
    new_y = *(*pstate).new_y
    ptr_free, (*pstate).coeffs
    ptr_free, (*pstate).new_y
    ptr_free, pstate

    if arg_present(yfit) then yfit = new_y
    return, reform(coeffs)
end
