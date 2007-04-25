;+
; The event handler for the clipping plane slider. Move the slider to
; clip the object along the plane defined at the point x in the y-z
; plane.
;
; @param event {in}{required}{type=structure} The event structure,
; passed from XMANAGER.
;-
pro clip_plane_event, event
    compile_opt idl2

    widget_control, event.top, get_uvalue=pstate

    (*pstate).opolymodel->setproperty, $
        clip_planes=[1.0, 0.0, 0.0, -event.value/100.0]

    (*pstate).owindow->draw
end


;+
; The event handler for the draw widget. Handles rotation via the
; trackball and repaints on expose events.
;
; @param event {in}{required}{type=structure} The event structure,
; passed from XMANAGER.
;-
pro clip_plane_draw_event, event
    compile_opt idl2

    widget_control, event.top, get_uvalue=pstate

    if event.type eq 4 then begin
        (*pstate).owindow->draw
        return
    endif 

    is_updated = (*pstate).otrack->update(event, transform=updated)
    if is_updated eq 1 then begin
        (*pstate).opolymodel->getproperty, transform=original
        (*pstate).opolymodel->setproperty, transform=original#updated
        (*pstate).owindow->draw
    endif
end


;+
; The cleanup routine. Destroys the state variable.
;
; @param top {in}{required}{type=long} The top-level base widget
; identifier, passed from XMANAGER.
;-
pro clip_plane_cleanup, top
    compile_opt idl2

    widget_control, top, get_uvalue=pstate
    ptr_free, pstate
end


;+
; This program displays a polygonal mesh data set. A user can
; rotate the data with the mouse. A slider can be used to move a
; clipping plane, defined in the y-z plane, along the x-axis. The
; clipping plane is defined with the <code>IDLgrModel</code>
; CLIP_PLANES property.
;
; @file_comments An example of defining and using a clipping plane in
; Object Graphics.
; @examples
; <pre>
; IDL> clip_plane_ex
; </pre>
; @requires IDL 6.1
; @author Mark Piper, RSI, 2005
;-
pro clip_plane_ex
    compile_opt idl2

    ss = get_screen_size()
    xsize = ss[0]*0.3
    ysize = xsize

    tlb = widget_base( $
        /column, $
        title='Clipping Plane Example')
    draw = widget_draw(tlb, $
        graphics_level=2, $
        xsize=xsize, $
        ysize=ysize, $
        /button_events, $
        /motion_events, $
        /expose_events, $
        event_pro='clip_plane_draw_event')
    clip_slider = widget_slider(tlb, $
        /drag, $
        /suppress_value, $
        xsize=xsize, $
        event_pro='clip_plane_event')

    geom = widget_info(tlb, /geometry)
    xoffset = (ss[0] - geom.xsize)/2
    yoffset = (ss[1] - geom.ysize)/2
    widget_control, tlb, xoffset=xoffset, yoffset=yoffset

    widget_control, tlb, /realize

    file = filepath('seashell.dat', subdir=['examples','demo','demodata'])
    restore, file
    v = transpose([[x], [y], [z]])
    p = mesh

    opoly = obj_new('idlgrpolygon', $
        data=v, $
        polygons=p, $
        color=[200,200,180], $
        bottom=[200,100,100], $
        shininess=10.0)
    olight1 = obj_new('idlgrlight', type=1, intensity=0.8)
    olight2 = obj_new('idlgrlight', type=0, intensity=0.5)
    olightmodel = obj_new('idlgrmodel')
    opolymodel = obj_new('idlgrmodel', clip_planes=[0,0,0,0])
    opolyview = obj_new('idlgrview', color=[127,127,255])
    oviewgroup = obj_new('idlgrviewgroup') ; contains view & trackball

    opolymodel->add, opoly
    olightmodel->add, [olight1, olight2]
    opolyview->add, [opolymodel, olightmodel]
    oviewgroup->add, opolyview

    widget_control, draw, get_value=owindow

    get_bounds, opolymodel, xr, yr, zr
    opolymodel->translate, -mean(xr), -mean(yr), -mean(zr)
    set_view, opolyview, owindow, /isotropic
    opolyview->getproperty, viewplane_rect=vp, zclip=zc
    olight1->setproperty, location=[vp[0]+vp[2], vp[1]+vp[3], zc[0]]

    owindow->setproperty, graphics_tree=oviewgroup
    owindow->draw

    otrack = obj_new('trackball', [xsize,ysize]/2, xsize/2)
    oviewgroup->add, otrack

    ;; Set up the clipping plane slider along the x-axis. The scale is
    ;; defined for these particular data, as are the range of values
    ;; for the slider.
    scale = 100.0
    min_val = floor(vp[0]*scale)
    max_val = ceil((vp[0]+vp[2])*scale)
    widget_control, clip_slider, $
        set_slider_min=min_val, $
        set_slider_max=max_val, $
        set_value=max_val

    state = { $
        owindow		: owindow, $
        oviewgroup	: oviewgroup, $
        opolyview	: opolyview, $
        opolymodel	: opolymodel, $
        opoly		: opoly, $
        otrack		: otrack, $
        draw		: draw }
    pstate = ptr_new(state, /no_copy)
    widget_control, tlb, set_uvalue=pstate

    xmanager, 'clip_plane_ex', tlb, $
        /no_block, $
        cleanup='clip_plane_cleanup'
end
