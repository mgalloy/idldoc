;+
; The "do" routine for plotinteractive.
;
; @param pstate {in}{type=pointer} The state pointer
;-
pro plotinteractive_doplot, pstate

    ; Ensure that the data are being plotted in the draw window.
    wset, (*pstate).win_id

    ; Plot the data.
    plot, (*pstate).data, linestyle=(*pstate).linestyle, $
        psym=(*pstate).psym*(*pstate).connect

end


;+
; The event handler for the draw widget in plotinteractive.
;
; @param event {in}{type=structure} The event structure from xmanager
;-
pro plotinteractive_draw, event

    ; Retrieve the pointer to the state structure.
    widget_control, event.top, get_uvalue=pstate

    ; Enter this block when a motion event occurs.
    if (event.type eq 2) then begin

        ; Convert event.x & event.y from device to data coordinates.
        datac = convert_coord(event.x, event.y, /device, /to_data)

        ; Make a string from the resulting coordinates.
        statusstr = '(' + strtrim(datac[0],2) + ', ' + strtrim(datac[1],2) $
            + ')'

        ; Set this string as the value of the status label widget.
        widget_control, (*pstate).status, set_value=statusstr
    endif
end


;+
; The event handler for the button toggling plot symbol connections
; in plotinteractive.
;
; @param event {in}{type=structure} The event structure from xmanager
;-
pro plotinteractive_connect, event

    ; Retrieve the pointer to the state structure.
    widget_control, event.top, get_uvalue=pstate

    ; Flip the sign of the connect field in the state structure.
    (*pstate).connect = -(*pstate).connect

    ; Call the "Do" routine to replot.
    plotinteractive_doplot, pstate

end


;+
; The event handler for the plot symbol droplist in plotinteractive.
;
; @param event {in}{type=structure} The event structure from xmanager
;-
pro plotinteractive_sym, event

    ; Retrieve the pointer to the state structure.
    widget_control, event.top, get_uvalue=pstate

    ; Store the new symbol in the state structure.
    (*pstate).psym=event.index

    ; Call the "Do" routine to replot.
    plotinteractive_doplot, pstate

end

;+
; The event handler for the line style droplist in plotinteractive.
;
; @param event {in}{type=structure} The event structure from xmanager
;-
pro plotinteractive_ls, event

    ; Get the pointer to the state structure from the user value
    ; of the top-level base.
    widget_control, event.top, get_uvalue=pstate

    ; Store the new linestyle in the state structure.
    (*pstate).linestyle=event.index

    ; Call the "Do" routine.
    plotinteractive_doplot, pstate

end

;+
; An unfinished version of plotinteractive. This code reflects the state
; of the program at the completion of Chapter 4, "Interactive Plot" in
; the Intermediate IDL manual.
;
; @param data {in}{optional}{type=float or integer array} An array of
;       ordinates to be plotted
; @bugs The core IDL routine convert_coord doesn't work with more than
;       one Direct Graphics window open. This is bug 20199. Workaround:
;       store !x & !y for the different windows.
; @author Beau Legeer, 1999
; @history Revised 2002, Mark Piper
; @copyright RSI
;-
pro plotinteractive2, data

    ; Test the input parameter.
    if (n_params() eq 0) then data=sin(findgen(36)*10*!dtor)

    ; Create the top-level base.
    tlb = widget_base(title='Interactive Plot', /column)

    ; Make a label widget.
    status = widget_label(tlb, value='', /dynamic_resize)

    ; Create a 500 x 200 pixel draw widget.
    draw = widget_draw(tlb, xsize=500, ysize=200, $
        /motion_events, event_pro='plotinteractive_draw')

    ; Create a row base to hold a series of controls.
    controlbase = widget_base(tlb, /row)

    ; Create a droplist to hold line style choices.
    linestyles = ['Solid','Dotted','Dashed','Dash Dot', $
        'Dash Dot Dot', 'Long Dash']
    linestyledrop = widget_droplist(controlbase, value=linestyles, $
        title='Linestyle', event_pro='plotinteractive_ls')

    ; Define a hexagon for symbol 8.
    usersym, [1.0, 0.5, -0.5, -1.0, -0.5, 0.5, 1.0], $
             [0.0, 1.0, 1.0, 0.0, -1.0, -1.0, 0.0], /fill

    ; Make a droplist for the plot symbols.
    symbols = ['None', 'Plus', 'Asterisk', 'Period', 'Diamond', $
        'Triangle', 'Square', 'X', 'Hexagon']
    symboldrop = widget_droplist(controlbase, value=symbols, $
        title='Symbol', event_pro='plotinteractive_sym')

    ; Create a nonexclusive base to hold a toggle button for symbol
    ; connections.
    connectbase = widget_base(controlbase, /nonexclusive)
    connectbutton = widget_button(connectbase, value='Connect Symbols', $
        event_pro='plotinteractive_connect')

    ; Draw the widget hierarchy to the screen.
    widget_control, tlb, /realize

    ; Get the window index of the draw widget and set it to be the
    ; current window.
    widget_control, draw, get_value=win_id
    wset, win_id

    ; Create a structure of data for the application.
    state = {data:data, win_id:win_id, linestyle:0, psym:0, $
        connect:1, status:status}

    ; Create a pointer to the state structure and put that pointer
    ; into the user value of the top-level base.
    pstate = ptr_new(state, /no_copy)
    widget_control, tlb, set_uvalue=pstate

    ; Draw a plot by calling the "Do" routine.
    plotinteractive_doplot, pstate

    ;  Call xmanager to start the event handling process.
    xmanager, 'plotinteractive', tlb

    ; Clean up the pointer reference before exiting the program.
    ptr_free, pstate

end