;-----------------------------------------------------------------------------
;+
; The event handler for ASPECT_RATIO_EX. Handles Trackball events.
;
; @param event {in}{required}{type=structure} The event structure
;    passed from XMANAGER.
;-
pro aspect_ratio_ex_event, event
    compile_opt idl2

    widget_control, event.top, get_uvalue=pstate

    update = (*pstate).t->update(event, transform=updated)
    if update then begin
        (*pstate).m->getproperty, transform=old
        (*pstate).m->setproperty, transform=old#updated
    endif

    (*pstate).w->draw
end

;-----------------------------------------------------------------------------
;+
; The cleanup routine for ASPECT_RATIO_EX.
;
; @param tlb {in}{required}{type=long} The top-level base widget
;    identifier passed from XMANAGER.
;-
pro aspect_ratio_ex_cleanup, tlb
    compile_opt idl2

    widget_control, tlb, get_uvalue=pstate

    obj_destroy, (*pstate).t
    ptr_free, pstate
end


;-----------------------------------------------------------------------------
;+
; An example of normalizing the aspect ratio of a graphics scene when
; the aspect ratio of the destination changes. The key is to use Paul
; Sorensen's <tt>IDLexInscribingView</tt> in place of the default
; <tt>IDLgrView object</tt>.<p>
;
; This is a modified version of SURFVIEW, from the Intermediate IDL
; class.
;
; @uses <tt>IDLexLightModel</tt>
; @requires IDL 6.0
;
; @author Mark Piper, RSI, 2004
;-
pro aspect_ratio_ex
    compile_opt idl2

    xsize = 800
    ysize = 600

    tlb = widget_base(title='Aspect Ratio Example')
    draw = widget_draw(tlb, $
                       graphics_level=2, $
                       xsize=xsize, $
                       ysize=ysize, $
                       /button_events, $
                       /motion_events, $
                       /expose_events, $
                       renderer=1)
    widget_control, tlb, /realize
    widget_control, draw, get_value=w

    o = obj_new('orb', color=[200,0,0], density=2)
    m = obj_new('idlgrmodel')
    l = obj_new('idlexlightmodel', /default)
    v = obj_new('idlexinscribingview') ;; key
    m->add, o
    v->add, [m, l]

    v->setviewvolume, w, /isotropic ;; key

    w->setproperty, graphics_tree=v
    w->draw

    center = [xsize, ysize]/2
    radius = (xsize > ysize)/2
    t = obj_new('trackball', center, radius)

    state = { $
            w : w, $
            v : v, $
            m : m, $
            t : t $
            }
    pstate = ptr_new(state, /no_copy)
    widget_control, tlb, set_uvalue=pstate

    xmanager, 'aspect_ratio_ex', tlb, $
        cleanup='aspect_ratio_ex_cleanup', $
        event_handler='aspect_ratio_ex_event', $
        /no_block
end
