;===========================================================================
;+
; Event handler for the top-level base widget.
;-
pro cowview_resize_event, event
    compile_opt idl2

    widget_control, event.top, get_uvalue=pstate

    ;; Add padding while setting the new draw widget size.
    newx = (event.x - 2 * (*pstate).pad) > 100
    newy = (event.y - 2 * (*pstate).pad) > 100
    widget_control, (*pstate).draw, xsize=newx, ysize=newy

    ;; Reset the center and radius of the trackball.
    center = [newx,newy]/2
    radius = (newx < newy)/2
    (*pstate).ot->reset, center, radius

    (*pstate).ow->draw
end


;===========================================================================
;+
; Event handler for the draw widget.
;-
pro cowview_draw_event, event
    compile_opt idl2

    widget_control, event.top, get_uvalue=pstate

    update = (*pstate).ot->update(event, transform=updated)
    if update then begin
        (*pstate).om->getproperty, transform=old
        (*pstate).om->setproperty, transform=old#updated
    endif

    (*pstate).ow->draw
end


;===========================================================================
;+
; Cleanup routine.
;-
pro cowview_cleanup, tlb
    compile_opt idl2

    widget_control, tlb, get_uvalue=pstate
    ptr_free, pstate
end


;===========================================================================
;+
; A view of a cow, in Object Graphics.
;
; @requires IDL 6.1
; @author Mark Piper, RSI, 2004
;-
pro cowview2
    compile_opt idl2

    ;; Make & realize the widget hierarchy.
    tlb = widget_base( $
                         title="Yessiree, it's a Holstein.", $
                         /tlb_size_events)
    draw = widget_draw(tlb, $
                       graphics_level=2, $
                       xsize=400, $
                       ysize=400, $
                       /button_events, $
                       /motion_events, $
                       /expose_events, $
                       event_pro='cowview_draw_event')
    widget_control, tlb, /realize

    ;; Get geometry info for the top-level base.
    geom = widget_info(tlb, /geometry)

    ;; Restore the cow data.
    file = filepath('cow10.sav', SUBDIR=['examples','data'])
    restore, file
    v0 = transpose([[x],[y],[z]])
    p0 = polylist
    c0 = byte(round(smooth(randomu(seed, n_elements(v0)), 5, /edge_truncate))) * 255B
    minv0 = min(v0, max=maxv0)

    ;; Build an object graphics hierarchy based on a polygon object.
    op = obj_new('idlgrpolygon', data=v0, polygons=p0, color=[255, 255, 255], shading=0, vert_colors=c0)
    om = obj_new('idlgrmodel')
    om->add, op
    ol1 = obj_new('idlgrlight', type=1, location=[-maxv0,maxv0,maxv0]*1.5)
    ol2 = obj_new('idlgrlight', type=0, intensity=0.5)
    olm = obj_new('idlgrmodel')
    olm->add, ol1
    olm->add, ol2
    ov = obj_new('idlgrview', color=[75, 150, 75])
    ov->add, om
    ov->add, olm
    ovg = obj_new('idlgrviewgroup')
    ovg->add, ov

    ;; Resize the view volume for the polygon.
    ov -> setproperty, $
        viewplane_rect=[minv0, minv0, abs(minv0)+maxv0, $
                        abs(minv0)+maxv0]*1.5, $
        zclip=[maxv0,minv0]*1.5, $
        eye=maxv0*1.5+0.1

    ;; Get the window object from the draw widget.
    widget_control, draw, get_value=ow

    ;; Set the graphics_tree property of the window object & render
    ;; the OGH to the window.
    ow->setproperty, graphics_tree=ovg
    ow->draw

    ;; Make a trackball. Add it to the viewgroup.
    ot = obj_new('trackball', [200,200], 200)
    ovg->add, ot

    ;; Make a state variable.
    state = $
        {ow   : ow, $
         om   : om, $
         ot   : ot, $
         draw : draw, $
         pad  : geom.xpad $
        }
    pstate = ptr_new(state, /no_copy)
    widget_control, tlb, set_uvalue=pstate

    ;; Call XMANAGER to register widget program & begin event handling.
    xmanager, 'cowview', tlb, $
        /no_block, $
        cleanup='cowview_cleanup', $
        event_handler='cowview_resize_event'
end
