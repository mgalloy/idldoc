;+
; The draw widget event handler.
;
; @param event {in}{required}{type=event structure} The draw widget
; event structure, passed by XMANAGER.
;-
pro window_zoom_event, event
    compile_opt idl2

    widget_control, event.top, get_uvalue=pstate

    if event.type eq 4 then begin
        (*pstate).w->draw
        return
    endif 

    update = (*pstate).t->update(event, transform=updated)
    if update then begin
        (*pstate).m->getproperty, transform=old
        (*pstate).m->setproperty, transform=old#updated
    endif

    if event.press eq 1 then begin
        if (event.key eq 7) then (*pstate).zoom_factor += 0.1
        if (event.key eq 8) then (*pstate).zoom_factor -= 0.1
        (*pstate).w->getproperty, dimensions=win_dims
        print, win_dims
        if (win_dims[0] lt 1280) && (win_dims[1] lt 1024) then $
            (*pstate).w->setcurrentzoom, (*pstate).zoom_factor
    endif
    if event.clicks eq 2 then begin
        print, 'reset zoom!'
        (*pstate).w->setcurrentzoom, null, /reset
    endif

    (*pstate).w->draw
end


;+
; The cleanup routine, called by XMANAGER. Used here to clean up the
; trackball object and the state variable.
;
; @param tlb {in}{required}{type=widget identifier} The top-level base
; widget identifier, passed by XMANAGER.
;-
pro window_zoom_cleanup, tlb
    compile_opt idl2

    widget_control, tlb, get_uvalue=pstate
    obj_destroy, (*pstate).t
    ptr_free, pstate
end



;+
; An example of increasing/decreasing the size of a window object with
; the up/down arrow keys. Double-clicking the mouse resets the
; original window size.
;
; @file_comments An example of increasing/decreasing the size of a
; window object with the IDLgrWindow::SetCurrentZoom method.
; @examples
; <pre>
; IDL> window_zoom_ex
; </pre>
; @uses polyhedron class, cube class, SET_STANDARD_ORIENTATION,
; idlexlightmodel class
; @author Mark Piper, RSI, 2005
;-
pro window_zoom_ex
    compile_opt idl2

    device, get_screen_size=ss
    window_size = fltarr(2) + max(ss)*0.5
    tlb = widget_base( $
        /column, $
        title='Window Zoom Example')
    draw = widget_draw(tlb, $
        graphics_level=2, $
        xsize=window_size[0], $
        ysize=window_size[1], $
        /button_events, $
        /motion_events, $
        /expose_events, $
        /keyboard_events)
    text = [ $
        'L mouse button: Rotate the cube about origin.', $
        '<Shift>+L mouse button: Rotate the cube about its centroid.']
    label = widget_text(tlb, value=text, ysize=2)
    widget_control, tlb, /realize
    widget_control, draw, get_value=w

    cube = obj_new('cube', $
        scale=0.25, $
        color=[0,127,0])
    m = obj_new('idlgrmodel')
    set_standard_orientation, m
    m->add, cube
    lm = obj_new('idlexlightmodel', /default)
    v = obj_new('idlgrview')
    v->add, [m, lm]

    w->setproperty, graphics_tree=v
    w->draw
    
    t = obj_new('trackball', window_size/2, window_size[0]/2)

    state = $
        {w : w, $
         v : v, $
         m : m, $
         t : t, $
         zoom_factor : 1.0}
    pstate = ptr_new(state, /no_copy)
    widget_control, tlb, set_uvalue=pstate
    
    xmanager, 'window_zoom', tlb, $
        cleanup='window_zoom_cleanup', $
        event_handler='window_zoom_event'
end
