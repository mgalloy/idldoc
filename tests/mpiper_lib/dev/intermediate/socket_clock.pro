;--------------------------------------------------------------------
;
;	get_time
;
function get_time
    compile_opt idl2

    ;; Open socket connection & get date.
    socket, u, '10.17.2.95', 'daytime', $
        connect_timeout=5, $
        read_timeout=5, $
        /get_lun
    t = ''
    readf, u, t
    free_lun, u

    return, t
end

;--------------------------------------------------------------------
;
;	socket_clock_event
;
pro socket_clock_event, event
    compile_opt idl2
    on_error, 2

    ;; Retrieve time.
    time = get_time()

    ;; Display the date in the text widget.
    widget_control, event.id, set_value=time

    ;; Set timer.
    widget_control, event.id, timer=1

end


;--------------------------------------------------------------------
;
;	socket_clock
;
pro socket_clock
    compile_opt idl2
    on_error, 2

    ;; Get time.
    time = get_time()

    ;; Construct a widget hierarchy.
    wtop = widget_base(title='IDL Socket Clock', /row)
    wtext = widget_text(wtop, value=time, xsize=strlen(time), ysize=1, $
                        font='Times*Bold*20')
    widget_control, wtop, /realize

    ;; Set a timer.
    widget_control, wtext, timer=1

    ;; Call XMANAGER.
    xmanager, 'socket_clock', wtop, /no_block

end
