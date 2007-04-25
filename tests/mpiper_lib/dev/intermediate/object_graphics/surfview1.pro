
;--------------------------------------------------------------------------
pro surfview_event, event

    widget_control, event.top, get_uvalue=pstate

    update = (*pstate).t->update(event, transform=updated)
    if update then begin
        (*pstate).m->getproperty, transform=OLD
        (*pstate).m->setproperty, transform=old#updated
    endif

    if event.type eq 0 and event.press eq 1 then $
        (*pstate).is_pressed = 1

    if event.type eq 2 then begin
        if (*pstate).is_pressed then (*pstate).s->setproperty, style=1
    endif

    if event.type eq 1 then begin 
        (*pstate).s->setproperty, style=2
        (*pstate).is_pressed = 0
    endif 

    (*pstate).w->draw

    return
end


;--------------------------------------------------------------------------
pro surfview_cleanup, tlb

    widget_control, tlb, get_uvalue=pstate

    obj_destroy, [(*pstate).t, (*pstate).image]
    ptr_free, pstate

    return
end

;--------------------------------------------------------------------------
pro surfview, zdata
    compile_opt idl2

    ;; If no data are passed, then make some.
    if n_params() eq 0 then zdata = hanning(40,40)

    ;; Make & realize the widget hierarchy.
    tlb = widget_base()
    draw = widget_draw(tlb, $
                       graphics_level=2, $
                       xsize=400, $
                       ysize=400, $
                       /button_events, $
                       /motion_events, $
                       /expose_events)
    widget_control, tlb, /realize

    ;; Get the window object from the draw widget.
    widget_control, draw, get_value=w

    ;; Call MAKE_SURFACE_VIEW to generate an OGH based on the input
    ;; data.
    v = make_surface_view(zdata)

    ;; Extract the surface and model object references.
    s = v->getbyname('surfacemodel/surface')
    m = v->getbyname('surfacemodel')

    ;; Make the surface solid & white. Also, set TEX_COORDS for
    ;; texture mapping
    s->setproperty, style=2, color=[255,255,255], /texture_coord

    ;; Read an image & texture map it to the surface.
    file = filepath('people.jpg', subdirectory=['examples','data'])
    ali = read_image(file)
    image = obj_new('idlgrimage', ali)
    s->setproperty, texture_map=image

    ;; Set the graphics_tree property of the window object & render
    ;; the OGH to the window.
    w->setproperty, graphics_tree=v
    w->draw
    
    ;; Make a trackball. It exists outside the OGH.
    t = obj_new('trackball', [200,200], 200)

    ;; Make a state variable.
    state = $
        {w : w, $
         v : v, $
         m : m, $
         s : s, $
         t : t, $
         image : image, $
         is_pressed : 0}
    pstate = ptr_new(state, /no_copy)
    widget_control, tlb, set_uvalue=pstate
    
    ;; Call XMANAGER to register widget program & begin event handling.
    xmanager, 'surfview', tlb, $
        cleanup='surfview_cleanup', $
        event_handler='surfview_event'

    return
end
