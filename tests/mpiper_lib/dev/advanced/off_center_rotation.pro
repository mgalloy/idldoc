;+
; The draw widget event handler.<p>
;
; <u>The idea</u>: When the left mouse button is held & dragged, the
; trackball's update matrix is applied in the standard manner, such
; that the cube is rotated about the origin. However, if the <Shift>
; key (<code>event.modifiers = 1</code>) is also held, first translate
; the cube's model to the origin, then apply the trackball's update to
; the model, then translate the model back to its prior location. This
; causes the cube to be rotated about its origin instead.<p>
;
; @param event {in}{required}{type=event structure} The draw widget
; event structure, passed by XMANAGER.
;-
pro off_center_rotation_event, event
    compile_opt idl2

    widget_control, event.top, get_uvalue=pstate

    update = (*pstate).t->update(event, transform=updated)
    if update then begin
        if event.modifiers eq 1 then begin ;; rotate about centroid
            t1 = (*pstate).m->getctm()
            (*pstate).m->translate, -t1[3], -t1[7], -t1[11]
            t2 = (*pstate).m->getctm()
            (*pstate).m->setproperty, transform=t2#updated
            (*pstate).m->translate, t1[3], t1[7], t1[11]
        endif else begin ;; rotate about origin
            (*pstate).m->getproperty, transform=old
            (*pstate).m->setproperty, transform=old#updated
        endelse 
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
pro off_center_rotation_cleanup, tlb
    compile_opt idl2

    widget_control, tlb, get_uvalue=pstate

    obj_destroy, (*pstate).t
    ptr_free, pstate
end



;+
; An example of rotating an off-origin graphic atom about its
; centroid.<p>
;
; Holding and dragging the left mouse button rotates the cube about
; the origin in the standard manner. Holding the <Shift> key and the
; left mouse button rotates the cube about its centroid.<p>
;
; @file_comments An example of rotating an off-origin graphic atom
; about its centroid.
; @examples
; <pre>
; IDL> off_center_rotation
; </pre>
; @uses polyhedron class, cube class, SET_STANDARD_ORIENTATION,
; idlexlightmodel class
; @author Mark Piper, RSI, 2005
;-
pro off_center_rotation
    compile_opt idl2

    window_size = [400,400]
    tlb = widget_base(/column, title='Off-Center Rotation')
    draw = widget_draw(tlb, $
                       graphics_level=2, $
                       xsize=window_size[0], $
                       ysize=window_size[1], $
                       /button_events, $
                       /motion_events, $
                       /expose_events)
    text = [ $
        'L mouse button: Rotate the cube about origin.', $
        '<Shift>+L mouse button: Rotate the cube about its centroid.']
    label = widget_text(tlb, value=text, ysize=2)
    widget_control, tlb, /realize
    widget_control, draw, get_value=w

    ;; Make an orange cube 0.25 units on a side (I'm assuming the
    ;; default view volume dimensions).
    side_length = 0.3
    cube = obj_new('cube', $
        scale=0.25, $
        color=[255,160,0])

    ;; Mark the origin with an orb.
    origin = obj_new('orb', radius=0.02)

    ;; Give the cube a model. Move the cube 0.5 units on the x-axis
    ;; and rotate it into the same orientation as used by SURFACE.
    m = obj_new('idlgrmodel')
    set_standard_orientation, m
    m->translate, 0.5, 0.0, 0.0
    m->add, cube

    ;; Add lights.
    lm = obj_new('idlexlightmodel', /default)

    v = obj_new('idlgrview')
    v->add, [m, lm, origin]

    w->setproperty, graphics_tree=v
    w->draw
    
    t = obj_new('trackball', window_size/2, window_size[0]/2)

    state = $
        {w : w, $
         v : v, $
         m : m, $
         t : t}
    pstate = ptr_new(state, /no_copy)
    widget_control, tlb, set_uvalue=pstate
    
    xmanager, 'off_center_rotation', tlb, $
        cleanup='off_center_rotation_cleanup', $
        event_handler='off_center_rotation_event'
end
