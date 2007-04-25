;===========================================================================
;+
; Event handler for the top-level base widget, called by XMANAGER when
; the user resizes the top-level base.
;
; @param event {in}{type=structure} The event structure.
;-
pro teapot_resize_event, event
    compile_opt idl2, logical_predicate

    widget_control, event.top, get_uvalue=pstate

    ;; Add padding while setting the new draw widget size.
    newx = (event.x - 2 * (*pstate).pad) > 100
    newy = (event.y - 2 * (*pstate).pad) > 100
    widget_control, (*pstate).draw, xsize=newx, ysize=newy

    ;; Reset the center and radius of the trackball.
    center = [newx,newy]/2
    radius = (newx < newy)/2
    (*pstate).ot->reset, center, radius

    ;; Repaint the window.
    (*pstate).ow->draw
end


;===========================================================================
;+
; Event handler for the draw widget, called by XMANAGER when the user
; interacts with the draw widget.
;
; @param event {in}{type=structure} The event structure.
;-
pro teapot_draw_event, event
    compile_opt idl2, logical_predicate

    widget_control, event.top, get_uvalue=pstate

    is_updated = (*pstate).ot->update(event, transform=updated)
    if is_updated then begin
        (*pstate).om->getproperty, transform=old
        (*pstate).om->setproperty, transform=old#updated
    endif

    ;; Repaint the window.
    (*pstate).ow->draw
end


;===========================================================================
;+
; Cleanup routine, called by XMANAGER when the TEAPOT UI is dismissed.
;
; @param tlb {in}{type=long} The top-level base widget identifier.
;-
pro teapot_cleanup, tlb
    compile_opt idl2, logical_predicate

    widget_control, tlb, get_uvalue=pstate
    ptr_free, pstate
end


;===========================================================================
;+
; A view of a teapot, with Object Graphics.
;
; @requires IDL 6.1
; @author Mark Piper, RSI, 2004
;-
pro teapot
    compile_opt idl2, logical_predicate

    ;; Determine the user's screen resolution.
    ss = get_screen_size()
    xsize = ss[0]*0.3
    ysize = xsize

    ;; Make & realize the widget hierarchy.
    tlb = widget_base( $
                         title='The Long, Dark Teatime of the Soul', $
                         /tlb_size_events)
    draw = widget_draw(tlb, $
                       graphics_level=2, $
                       xsize=xsize, $
                       ysize=ysize, $
                       /button_events, $
                       /motion_events, $
                       /expose_events, $
                       event_pro='teapot_draw_event')
    widget_control, tlb, /realize

    ;; Restore the teapot data.
    file = filepath('teapot.dat', subdir=['examples','demo','demodata'])
    restore, file

    ;; Create the objects necessary to build a visualization based on
    ;; a polygon object.
    op = obj_new('idlgrpolygon', $
        data=transpose([[x],[y],[z]]), $
        polygons=mesh, $
        color=[0,0,200], $
        shading=1, $
        shininess=100.0, $
        specular=[0,0,100], $
        reject=0)
    om = obj_new('idlgrmodel')
    ol1 = obj_new('idlgrlight', $
        type=1, $
        location=fltarr(3)+2.0)
    ol2 = obj_new('idlgrlight', $
        type=0, $
        intensity=0.4)
    olm = obj_new('idlgrmodel')
    ov = obj_new('idlgrview')
    ovg = obj_new('idlgrviewgroup')

    ;; Build the OGH.
    om->add, op
    olm->add, [ol1, ol2]
    ov->add, om
    ov->add, olm
    ovg->add, ov

    ;; Scale the data into a unit cube, centered at the origin of the
    ;; view volume.
    d = transpose([[x],[y],[z]])
    mind = min(d, max=maxd)
    ms = norm_coord([mind,maxd])
    op->getproperty, xrange=xr, yrange=yr, zrange=zr
	xoff = (xr[1]-xr[0])/2.0 + xr[0]
	yoff = (yr[1]-yr[0])/2.0 + yr[0]
	zoff = (zr[1]-zr[0])/2.0 + zr[0]
	om->translate, -xoff/2, -yoff/2, -zoff/2
    op->setproperty, xcoord_conv=ms, ycoord_conv=ms, zcoord_conv=ms

    ;; Resize the view volume for the polygon.
;    minv = min(transpose([[x],[y],[z]]), max=maxv)
;    scale_factor = 1.5 ; arbitrary, for padding
;    ov -> setproperty, $
;        viewplane_rect=[minv, minv, abs(minv)+maxv, $   ; still
;                        abs(minv)+maxv]*scale_factor, $ ; thinking
;        zclip=[maxv,minv]*scale_factor, $
;        eye=maxv*scale_factor+0.1 ; push eye outside view volume

    ;; Translate the teapot to the center of the coordinate system.
    ;;op->getproperty, yrange=yr
    ;;print, yr
    ;;ov->getproperty, viewplane_rect=vpr
    ;;print, vpr
;    om->translate, 0.0, -1.5, 0.0

    ;; Get the window object from the draw widget.
    widget_control, draw, get_value=ow

    ;; Set the graphics_tree property of the window object & render
    ;; the OGH to the window.
    ow->setproperty, graphics_tree=ovg
    ow->draw

    ;; Make a trackball. Add it to the viewgroup.
    ot = obj_new('trackball', [xsize,ysize]/2, xsize/2)
    ovg->add, ot

    ;; Get geometry info for the top-level base.
    geom = widget_info(tlb, /geometry)

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
    xmanager, 'teapot', tlb, $
        /no_block, $
        cleanup='teapot_cleanup', $
        event_handler='teapot_resize_event'
end
