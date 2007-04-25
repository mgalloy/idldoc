;+
; The event handler for the opacity slider.
;-
pro jet_opacity_event, event
    compile_opt idl2

    ;; Get the state variable from the top-level base's user value.
    widget_control, event.top, get_uvalue=pstate

    ;; Index the ALPHA_CHANNEL property of the polygon object with
    ;; the value of the Opacity slider.
    (*pstate).opoly->setproperty, alpha_channel=event.value/100.0

    ;; Repaint the window.
    (*pstate).owindow->draw
end


;+
; The event handler for the top-level base. Handles resize events by
; making the draw widget as large as the newly sized top-level base,
; minus the padding around the sides.
;-
pro jet_resize_event, event
    compile_opt idl2

    ;; Get the state variable from the top-level base's user value.
    widget_control, event.top, get_uvalue=pstate

    ;; Determine the new size of the draw widget & apply them.
    newx = (event.x - 2*(*pstate).xpad) > 100
    newy = (event.y - 2*(*pstate).ypad) > 100
    widget_control, (*pstate).draw, xsize=newx, ysize=newy

    ;; Use GET_BOUNDS and SET_VIEW to compute a new view volume that
    ;; maintains the original aspect ratio of the data being
    ;; displayed.
    get_bounds, (*pstate).opolymodel, xr, yr, zr
    set_view, (*pstate).opolyview, (*pstate).owindow, $
        xrange=xr, $
        yrange=yr, $
        zrange=zr, $
        /do_aspect, $
        /isotropic

    ;; Reset the state of the trackball, using a new center and radius.
    center = [newx,newy]/2
    radius = (newx < newy)/2
    (*pstate).otrack->reset, center, radius

    ;; Repaint the window.
    (*pstate).owindow->draw
end


;+
; The event handler for the draw widget.
;-
pro jet_draw_event, event
    compile_opt idl2

    ;; Get the state variable from the top-level base's user value.
    widget_control, event.top, get_uvalue=pstate

    ;; Check for an update of the trackball.
    is_updated = (*pstate).otrack->update(event, transform=updated)

    ;; If the trackball is updated, then apply its updated transformation
    ;; matrix to the polygon's model. If the <Shift> key is pressed,
    ;; apply the transformation to the light's model instead.
    if is_updated eq 1 then begin
        if event.modifiers eq 1 then begin
            (*pstate).olightmodel->getproperty, transform=original
            (*pstate).olightmodel->setproperty, transform=original#updated
        endif else begin
            (*pstate).opolymodel->getproperty, transform=original
            (*pstate).opolymodel->setproperty, transform=original#updated
        endelse
        (*pstate).owindow->draw
    endif

    ;; Repaint the window on an expose event (type = 4).
    if event.type eq 4 then (*pstate).owindow->draw
end


;+
; The cleanup routine.
;-
pro jet_cleanup, top
    compile_opt idl2

    ;; Get the state variable from the top-level base's user value.
    widget_control, top, get_uvalue=pstate

    ;; Clean up the state pointer.
    ptr_free, pstate
end


;+
; This program displays a polygonal mesh data set. A user can manipulate
; the data with the mouse.
;
; @todo Allow the display of any polygonal mesh data set.
; @requires IDL 6.1
; @author Mark Piper, 2005
;-
pro jet
    compile_opt idl2

    ;; Determine the screen size of the user's display.
    ss = get_screen_size()
    xsize = ss[0]*0.3
    ysize = xsize

    ;; Make the widget hierarchy.
    tlb = widget_base( $
        title='X-29 Jet', $
        /tlb_size_events)
    opacity_base = widget_base(tlb, $
        xoffset=10, $
        yoffset=10, $
        event_pro='jet_opacity_event')
    opacity_slider = widget_slider(opacity_base, $
        min=0, $
        max=100, $
        value=100, $
        title='Opacity (%)')
    draw = widget_draw(tlb, $
        graphics_level=2, $     ; makes an OG window
        xsize=xsize, $
        ysize=ysize, $
        /button_events, $
        /motion_events, $
        /expose_events, $
        event_pro='jet_draw_event')

    ;; Get the geometry information for the top-level base.
    geom = widget_info(tlb, /geometry)

    ;; Determine coordinates to center the interface on the display.
    ;; Apply them to the top-level base.
    xoffset = (ss[0] - geom.xsize)/2
    yoffset = (ss[1] - geom.ysize)/2
    widget_control, tlb, xoffset=xoffset, yoffset=yoffset

    ;; Realize the widget hierarchy.
    widget_control, tlb, /realize

    ;; Read the file that contains the jet data.
    file = '~/IDL/IDL_training/intermediate/x29.txt'
    read_noff, file, v, p

    ;; Create the objects needed in the OGH.
    opoly = obj_new('idlgrpolygon', $
        data=v, $
        polygons=p, $
        color=[0,100,0])
    olight1 = obj_new('idlgrlight', type=1)
    olight2 = obj_new('idlgrlight', type=0, intensity=0.4)
    olightmodel = obj_new('idlgrmodel')
    opolymodel = obj_new('idlgrmodel')
    opolyview = obj_new('idlgrview')
    oviewgroup = obj_new('idlgrviewgroup') ; contains view & trackball

    ;; Build the OGH.
    opolymodel->add, opoly
    olightmodel->add, [olight1, olight2]
    opolyview->add, [opolymodel, olightmodel]
    oviewgroup->add, opolyview

    ;; Get the window object reference from the draw widget.
    widget_control, draw, get_value=owindow

    ;; Use GET_BOUNDS to find the ranges of the data in the three
    ;; coordinate dimensions.
    get_bounds, opolymodel, xr, yr, zr

    ;; Translate the data to the origin of the coordinate system.
    opolymodel->translate, -mean(xr), -mean(yr), -mean(zr)

    ;; Use SET_VIEW to scale the coordinate system to the largest
    ;; of the three ranges, plus a little padding.
    set_view, opolyview, owindow, /isotropic

    ;; Get the new dimensions of the view volume. Use them to position
    ;; the first light in a corner of the view volume.
    opolyview->getproperty, viewplane_rect=vp, zclip=zc
    olight1->setproperty, location=[vp[0], vp[1]+vp[3], zc[0]]

    ;; Set the GRAPHICS_TREE property on the window object.
    ;; Display the OGH in the window.
    owindow->setproperty, graphics_tree=oviewgroup
    owindow->draw

    ;; Make a trackball. Add it to the OGH in the viewgroup.
    otrack = obj_new('trackball', [xsize,ysize]/2, xsize/2)
    oviewgroup->add, otrack

    ;; Make a state variable.
    state = { $
        owindow		: owindow, $
        oviewgroup	: oviewgroup, $
        opolyview	: opolyview, $
        opolymodel	: opolymodel, $
        olightmodel	: olightmodel, $
        opoly		: opoly, $
        otrack		: otrack, $
        draw		: draw, $
        xpad		: geom.xpad, $
        ypad		: geom.ypad}
    pstate = ptr_new(state, /no_copy)
    widget_control, tlb, set_uvalue=pstate

    ;; Call XMANAGER to register the widget program & begin event
    ;; handling.
    xmanager, 'jet', tlb, $
        /no_block, $
        cleanup='jet_cleanup', $
        event_handler='jet_resize_event'
end
