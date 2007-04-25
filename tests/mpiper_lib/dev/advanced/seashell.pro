;+
; The event handler for the opacity slider.
;
; @param event {in}{required}{type=structure} The event structure,
; passed from XMANAGER.
;-
pro seashell_opacity_event, event
    compile_opt idl2

    widget_control, event.top, get_uvalue=pstate

    ;; Index the ALPHA_CHANNEL property of the polygon object with
    ;; the value of the Opacity slider.
    (*pstate).opoly->setproperty, alpha_channel=event.value/100.0

    (*pstate).owindow->draw
end


;+
; The event handler for the top-level base. Handles resize events by
; making the draw widget as large as the newly sized top-level base,
; minus the padding around the sides.<p>
;
; GET_BOUNDS and SET_VIEW are used to compute a new view volume that
; maintains the original aspect ratio of the data being displayed.<p>
;
; The state of the trackball is also reset, using a new center and
; radius.<p>
;
; @param event {in}{required}{type=structure} The event structure,
; passed from XMANAGER.
;-
pro seashell_resize_event, event
    compile_opt idl2

    widget_control, event.top, get_uvalue=pstate

    newx = (event.x - 2*(*pstate).xpad) > 100
    newy = (event.y - 2*(*pstate).ypad) > 100
    widget_control, (*pstate).draw, xsize=newx, ysize=newy

    get_bounds, (*pstate).opolymodel, xr, yr, zr
    set_view, (*pstate).opolyview, (*pstate).owindow, $
        xrange=xr, $
        yrange=yr, $
        zrange=zr, $
        /do_aspect, $
        /isotropic

    center = [newx,newy]/2
    radius = (newx < newy)/2
    (*pstate).otrack->reset, center, radius

    (*pstate).owindow->draw
end


;+
; The event handler for the draw widget.<p>
; 
; When the trackball is updated, apply its updated transformation
; matrix to the polygon's model, by default. However, if the <Shift>
; key is pressed, apply the transformation to the light's model
; instead.<p>
;
; @param event {in}{required}{type=structure} The event structure,
; passed from XMANAGER.
;-
pro seashell_draw_event, event
    compile_opt idl2

    widget_control, event.top, get_uvalue=pstate

    if event.type eq 4 then begin
        (*pstate).owindow->draw
        return
    endif 

    is_updated = (*pstate).otrack->update(event, transform=updated)
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
end


;+
; The cleanup routine. Destroys the state variable.
;
; @param top {in}{required}{type=long} The top-level base widget
; identifier, passed from XMANAGER.
;-
pro seashell_cleanup, top
    compile_opt idl2

    widget_control, top, get_uvalue=pstate
    ptr_free, pstate
end


;+
; This program displays a polygonal mesh data set. A user can manipulate
; the data with the mouse. The transparency/opacity of the data are
; controlled with a slider linked to <code>IDLgrPolygon</code>'s
; ALPHA_CHANNEL property. The display can be resized by grabbing
; and dragging the corner of application.
;
; @file_comments An example of controlling the transparency of a
; graphics atom in Object Graphics.
; @examples
; <pre>
; IDL> seashell
; </pre>
; @requires IDL 6.1
; @author Mark Piper, RSI, 2005
;-
pro seashell
    compile_opt idl2

    ss = get_screen_size()
    xsize = ss[0]*0.3
    ysize = xsize

    tlb = widget_base( $
        title='Seashell', $
        /tlb_size_events)
    opacity_base = widget_base(tlb, $
        xoffset=10, $
        yoffset=10, $
        event_pro='seashell_opacity_event')
    opacity_slider = widget_slider(opacity_base, $
        min=0, $
        max=100, $
        value=100, $
        title='Opacity (%)')
    draw = widget_draw(tlb, $
        graphics_level=2, $
        xsize=xsize, $
        ysize=ysize, $
        /button_events, $
        /motion_events, $
        /expose_events, $
        event_pro='seashell_draw_event')

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
        shininess=10.0)
    olight1 = obj_new('idlgrlight', type=1, intensity=0.8)
    olight2 = obj_new('idlgrlight', type=0, intensity=0.5)
    olightmodel = obj_new('idlgrmodel')
    opolymodel = obj_new('idlgrmodel')
    opolyview = obj_new('idlgrview', color=[100,100,220])
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

    xmanager, 'seashell', tlb, $
        /no_block, $
        cleanup='seashell_cleanup', $
        event_handler='seashell_resize_event'
end
