;====================================================================
;+
;   view_curve_fit_doplot -- plot the data
;-
pro view_curve_fit_doplot, pstate
    compile_opt idl2

;
;  Plot the old, and (if available) new, data.
;
    plot, (*pstate).old_x, (*pstate).old_y, /nodata, xtitle='X', ytitle='Y', $
        color=7, background=8
    oplot, (*pstate).old_x, (*pstate).old_y, psym=1, symsize=0.7, color=5
    if (*pstate).new_y[0] ne 0 then $
        oplot, (*pstate).old_x, (*pstate).new_y, color=6, thick=2

end


;====================================================================
;+
;   view_curve_fit_exit_event
;-
pro view_curve_fit_exit_event, event
    compile_opt idl2

;
;  Destroy the top-level base.  This kills the widget
;  and exits XMANAGER.
;
    widget_control, event.top, /destroy

end


;====================================================================
;+
;   view_curve_fit_select_event
;-
pro view_curve_fit_select_event, event
    compile_opt idl2

;
;  Retrieve the pointer to the state structure.
;
    widget_control, event.top, get_uvalue=pstate

;
;  Set the model chosen.
;
    (*pstate).model = event.index

;
;  Select a message about the model to be displayed in the text widget.
;
    case event.index of
        1: model_text = 'Exponential model: y = a0*a1^x + a2'
        2: model_text = 'Geometric model: y = a0*x^a1 + a2'
        3: model_text = 'Gompertz model: y = a0*a1^(x*a2) + a3'
        4: model_text = 'Hyperbolic model: y = 1/(a0 + a1*x)'
        5: model_text = 'Logistic model: y = 1/(a0*a1^x + a2)'
        6: model_text = 'Logsquare model: y = a0 + a1*log(x) + a2*log(x)^2'
        7: model_text = 'Polynomial fit: y = a0 + a1*x + a2*x^2 + a3*x^3'
        else: model_text = 'Please select a model.'
    endcase

;
;  Display the model information in the text widget.
;
    widget_control, (*pstate).wtext, set_value=model_text, /append
    widget_control, (*pstate).wtext, set_text_top_line=(*pstate).texttopline
    (*pstate).texttopline = (*pstate).texttopline + 1

end


;====================================================================
;+
;   view_curve_fit_wscoeff_event
;-
pro view_curve_fit_wscoeff_event, event
    compile_opt idl2

;
;  Retrieve the pointer to the state structure.
;
    widget_control, event.top, get_uvalue=pstate

;
;  Retrieve the values of the seed coefficients and
;  load them into the state structure.
;
    widget_control, event.id, get_value=tblval
    (*pstate).scoeff = tblval

end


;====================================================================
;+
;   view_curve_fit_calc_event
;-
pro view_curve_fit_calc_event, event
    compile_opt idl2

;
;  Retrieve the pointer to the state structure.
;
    widget_control, event.top, get_uvalue=pstate

;
;  Compute a curve fit with the selected model.
;
    case (*pstate).model of
        1: begin
            coeffs = comfit((*pstate).old_x, (*pstate).old_y, $
                            (*pstate).scoeff[0:2], /exponential, yfit=new_y)
        end
        2: begin
            coeffs = comfit((*pstate).old_x, (*pstate).old_y, $
                            (*pstate).scoeff[0:2], /geometric, yfit=new_y)
        end
        3: begin
            coeffs = comfit((*pstate).old_x, (*pstate).old_y, $
                            (*pstate).scoeff, /gompertz, yfit=new_y)
        end
        4: begin
            coeffs = comfit((*pstate).old_x, (*pstate).old_y, $
                            (*pstate).scoeff[0:1], /hyperbolic, yfit=new_y)
        end
        5: begin
            coeffs = comfit((*pstate).old_x, (*pstate).old_y, $
                            (*pstate).scoeff[0:2], /logistic, yfit=new_y)
        end
        6: begin
            coeffs = comfit((*pstate).old_x, (*pstate).old_y, $
                            (*pstate).scoeff[0:2], /logsquare, yfit=new_y)
        end
        7: begin
            degree = 4 & test=1
            while test do begin
                degree = degree - 1
                if (*pstate).scoeff[degree] ne 0 then test=0
            endwhile
            coeffs = poly_fit((*pstate).old_x, (*pstate).old_y, $
                              degree, new_y)
        end
        else: begin
            err_text = 'Please select a model.'
            widget_control, (*pstate).wtext, set_value=err_text, /append
            widget_control, (*pstate).wtext, $
                set_text_top_line=(*pstate).texttopline
            (*pstate).texttopline = (*pstate).texttopline + 1
            return
        end
    endcase

;
;  Capture math errors and print them in the text widget.
;
    math_errstring = ['Divide by zero', 'Underflow', 'Overflow', $
                      'Illegal operand']
    math_err = check_math()
    for i = 4, 7 do begin
        if ishft(math_err, -i) and 1 then begin
            err_text = ' % CHECK_MATH: ' + math_errstring[i-4]
            widget_control, (*pstate).wtext, set_value=err_text, /append
            widget_control, (*pstate).wtext, $
                set_text_top_line=(*pstate).texttopline
            (*pstate).texttopline = (*pstate).texttopline + 1
        endif
    endfor

;
;  Update the coefficients.
;
    (*pstate).rcoeff = fltarr(n_elements((*pstate).scoeff))
    (*pstate).rcoeff = coeffs
    (*pstate).new_y = new_y

;
;  Display the calculated coefficients in the second table widget.
;
    widget_control, (*pstate).wrcoeff, set_value=(*pstate).rcoeff

;
;  Display the original data plus the new curve fit in the draw window.
;
    view_curve_fit_doplot, pstate

end


;====================================================================
;+
;   view_curve_fit_event
;-
pro view_curve_fit_event, event
    compile_opt idl2

;
;  Retrieve the pointer to the state structure.
;
    widget_control, event.top, get_uvalue=pstate

;
;  If the system close button is pressed, kill the widget.
;
    if (tag_names(event, /struct) eq 'WIDGET_KILL_REQUEST') then begin
        widget_control, event.top, /destroy
        return
    endif

end


;====================================================================
;+
; NAME:
;   VIEW_CURVE_FIT
;
; PURPOSE:
;   This widget app performs a curve fit to a set of input data, using the
;   IDL COMFIT and POLY_FIT functions.  Note that COMFIT is based on
;   CURVEFIT, which is kinda clunky.
;
; CATEGORY:
;   Widgets, curve fitting.
;
; CALLING SEQUENCE:
;
;   Result = VIEW_CURVE_FIT(X, Y)
;
; INPUTS:
;   X: Input abscissas.
;   Y: Ordinates to be fit.
;
; KEYWORD PARAMETERS:
;   NEW_Y:    Set this keyword to a named variable to receive the
;     fitted ordinates.
;   DEBUG: Set this keyword to debug the program.  A predefined
;     set of abscissas & ordinates will be used.
;
; OUTPUTS:
;   This function returns the coefficients of the curvefit selected
;   within the widget app.
;
; SIDE EFFECTS:
;   This widget app is based on the CURVEFIT, which contains some
;   poor coding -- some fits don't converge easily & math errors
;   accumulate.
;
; PROCEDURE:
;   Additional topics: using table widgets, using text widgets, handling
;   math errors with CHECK_MATH, TLB_KILL_REQUEST_EVENTS, using
;   keywords, input parameter checking, COMPILE_OPT statement, error
;   handling with CATCH, include files, using droplist widgets, !quiet and
;   !except system variables, bitwise logical statements.
;
; EXAMPLE:
;   IDL> x = findgen(100)/2. - 20.
;   IDL> y = x^3/1000. * sin(x)^2 + randomn(seed,100)
;   IDL> coeffs = view_curve_fit(x,y,NEW_Y=new_y)
;   IDL> plot, x, y, PSYM=1
;   IDL> oplot, x, new_y
;
; MODIFICATION HISTORY:
;   Written by:  Mark Piper, 12-20-99.
;-
function view_curve_fit, o_x, o_y, NEW_Y=new_y, DEBUG=dbg
    compile_opt idl2

;
;  Check the input parameters
;
    np = n_params()
    case np of
        0: begin
            if keyword_set(dbg) then begin
                old_x = findgen(200)/10 - 10
                old_y = 0.1*old_x^3 - 0.2*exp(old_x/2) $
                    + randomn(seed,200)*20
            endif else begin
                message, 'Need two input parameters.', /continue
                message, 'Calling sequence: coeff = VIEW_CURVE_FIT(x,y)', $
                    /continue, /noname
                return, 0
            endelse
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

;
;  Set color decomposition and load four colors for displaying the data.
;
    device, get_decomposed=odec
    device, decomposed=0
    tvlct, old_r, old_g, old_b, /get
    tvlct, 0, 200, 0, 5
    tvlct, 200, 0, 0, 6
    tvlct, 255, 255, 255, 7
    tvlct, 0, 0, 0, 8

;
;  Create the widget hierarchy.
;
    wtop = widget_base(title='View Curve Fit', /row, xoffset=50, $
                       yoffset=50, /tlb_kill_request)

    wbase1 = widget_base(wtop, /column)
    wdraw = widget_draw(wbase1, xsize=400, ysize=300)
    text = 'This widget application uses the built-in IDL functions COMFIT ' $
        + 'and POLY_FIT. Check the IDL Online Help Guide for information ' $
        + 'on these routines.'
    wtext = widget_text(wbase1, value=text, /wrap, /scroll, ysize=3, $
                        font='Helvetica*Bold*16')

    orig_table_vals = fltarr(1,4)+1.0
    wbase2 = widget_base(wtop, /column, space=2, /align_center)
    wbase2c = widget_base(wbase2, /column, /frame, space=5)
    model = ['  Select... ', ' Exponential  ', ' Geometric  ', ' Gompertz  ', $
             ' Hyperbolic  ', ' Logistic  ', ' Logsquare  ', ' Polynomial  ']
    wmodellist = widget_droplist(wbase2c, value=model, $
                                 title='Curve Fit Model ', $
                                 event_pro='view_curve_fit_select_event')
    wbase2a = widget_base(wbase2, /column, /frame)
    wlabel2a = widget_label(wbase2a, value='Model Seed Coefficients')
    wscoeff = widget_table(wbase2a, /edit, alignment=1, $
                           value=orig_table_vals, $
                           row_labels=['S0', 'S1', 'S2', 'S3'], $
                           xsize=1, ysize=4, column_labels=['Value'], $
                           event_pro='view_curve_fit_wscoeff_event')
    wcalc = widget_button(wbase2, value='Calculate Curve Fit', $
                          uvalue='return', /frame, $
                          event_pro='view_curve_fit_calc_event')
    wbase2b = widget_base(wbase2, /column, /frame)
    wlabel2b = widget_label(wbase2b, value='Calculated Model Coefficients')
    wrcoeff = widget_table(wbase2b, alignment=1, $
                           value=orig_table_vals, $
                           row_labels=['A0', 'A1', 'A2', 'A3'], $
                           xsize=1, ysize=4, column_labels=['Value'])
    wreturn = widget_button(wbase2, value='Exit', /frame, $
                            event_pro='view_curve_fit_exit_event')

;
;  Realize the top-level base.
;
    widget_control, wtop, /realize

;
;  Retrieve the window ID from the realized draw widget.
;
    widget_control, wdraw, get_value=win_id
    wset, win_id

;
;  Store information in the state structure.
;
    state = {old_x:old_x, $
             old_y:old_y, $
             new_y:fltarr(n_elements(old_y)), $
             scoeff:orig_table_vals, $
             rcoeff:orig_table_vals, $
             wrcoeff:wrcoeff, $
             wtext:wtext, $
             texttopline:0, $
             model:0L}
    pstate = ptr_new(state, /no_copy)
    widget_control, wtop, set_uvalue=pstate

;
;  Set !quiet to suppress informational math messages.
;
    orig_quiet = !quiet
    !quiet=1L

;
;  Set !except to silence output of math errors.
;
;orig_except = !except
;!except=0

;
;  Draw the input data without a curve fit.
;
    view_curve_fit_doplot, pstate

;
;  Call XMANAGER.
;
    xmanager, 'view_curve_fit', wtop

;
;  After the widget is killed, execute the following statements.
;
    tvlct, old_r, old_g, old_b
    if arg_present(new_y) then new_y = (*pstate).new_y
    coeffs = reform((*pstate).rcoeff)
    ptr_free, pstate
    !quiet = orig_quiet
    device, decomposed=odec

;
;  Return the array of calculated coefficients to the calling program.
;
    if keyword_set(dbg) then print, 'Coeffs: ', coeffs
    return, coeffs

end
