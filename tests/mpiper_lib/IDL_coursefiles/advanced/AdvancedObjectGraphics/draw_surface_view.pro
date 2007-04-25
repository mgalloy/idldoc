;+
; The event handling routine for the transparency slider.
;
; @param event {in}{type=structure} The event structure.
; @author Mark Piper, 2002
; @copyright RSI
;-
pro draw_surface_view_transparency_event, event
    compile_opt idl2

    widget_control, event.top, get_uvalue=otop

    owin = otop->get(/all, isa='idlgrwindow')
    oview = otop->get(/all, isa='idlgrview')
    osurface = oview->getbyname('model/surface')

    ; Check that an image is texture mapped.
    osurface->getproperty, texture_map=t
    if not obj_valid(t) then return

    ; Set the value of the transparency channel.
    t->getproperty, data=img
    img[3,*,*] = byte(255-event.value)
    t->setproperty, data=img

    owin->draw
end


;+
; The event handling routine for the pull-down menus.
;
; @param event {in}{type=structure} The event structure.
; @author Mark Piper, 2002
; @copyright RSI
;-
pro draw_surface_view_menu_event, event
    compile_opt idl2

    widget_control, event.top, get_uvalue=otop
    uname = widget_info(event.id, /uname)

    oview = otop->get(/all, isa='idlgrview')
    osurface = oview->getbyname('model/surface')

    case uname of
    'exit': widget_control, event.top, /destroy
    'texture': begin

        ; Check that an image is not already texture mapped.
        osurface->getproperty, texture_map=t
        if obj_valid(t) then return

        file = filepath('rose.jpg', subdir=['examples','data'])
        read_jpeg, file, img

        ; Add an alpha channel to the image.
        newimg = bytarr(4,227,149)
        newimg[0,*,*] = img[0,*,*]
        newimg[1,*,*] = img[1,*,*]
        newimg[2,*,*] = img[2,*,*]
        newimg[3,*,*] = 255B

        ; Load the image data into an image object.
        oimage = obj_new('idlgrimage', newimg, /no_copy)
        otop->add, oimage

        ; Texture map the image onto the surface.
        osurface->setproperty, color=[255,255,255], texture_map=oimage, $
            /texture_interp

        ; Display the transparency slider.
        wtransparency = widget_info(event.top, find_by_uname='transbase')
        widget_control, wtransparency, map=1
        end
    'remove': begin

        ; Check that an image is texture mapped.
        osurface->getproperty, texture_map=t
        if not obj_valid(t) then return

        ; Remove the texture mapped image.
        osurface->setproperty, color=[255,0,0], texture_map=obj_new()

        ; Reset & hide the transparency slider.
        wtransbase = widget_info(event.top, find_by_uname='transbase')
        widget_control, wtransbase, map=0
        wtransparency = widget_info(event.top, find_by_uname='transparency')
        widget_control, wtransparency, set_value=0
        end
    'image': begin
        owin = otop->get(/all, isa='idlgrwindow')
        owin->getproperty, dimensions=dims
        ;;opicture = owin->read()
        obuffer = obj_new('idlgrbuffer', dimensions=dims)
        oview = otop->get(/all, isa='idlgrview')
        obuffer->draw, oview
        opicture = obuffer->read()
        opicture->getproperty, data=img
        obj_destroy, [opicture, obuffer]
        ok = dialog_write_image(img, dialog_parent=event.top)
        end
    'clip': begin
        oclip = obj_new('idlgrclipboard')
        oclip->draw, oview
        message, 'Output to OS clipboard.', /info, /noname
        obj_destroy, oclip
        end
    'ps': begin
        filename = dialog_pickfile(/write, file='draw_surface_view.ps')
        paperxsize = 8.5    ; inches
        paperysize = 11.0   ; inches
        oclip = obj_new('idlgrclipboard', units=1, $
            dimensions=[paperxsize,paperysize])
        viewxsize = 7.0
        viewysize = 7.0
        xloc = 0.5*(paperxsize-viewxsize)
        yloc = 0.5*(paperysize-viewysize)
        oview->getproperty, location=loc, dimensions=dims
        oview->setproperty, units=1, location=[xloc,yloc], $
            dimensions=[viewxsize,viewysize]    ; centered on page
        oclip->draw, oview, file=filename, /postscript, /vector
        obj_destroy, oclip
        oview->setproperty, location=loc, dimensions=dims
        end
    'print': begin
        oprint = obj_new('idlgrprinter')
        print_it = dialog_printersetup()
        if print_it then begin
            oprint->draw, oview
            oprint->newdocument
            message, 'Output to printer.', /info, /noname
        endif
        obj_destroy, oprint
        end
    endcase
end

;+
; The event handling routine for the draw window.
;
; @param event {in}{type=structure} The event structure.
; @author Mark Piper, 2002
; @copyright RSI
;-
pro draw_surface_view_window_event, event
    compile_opt idl2

    widget_control, event.top, get_uvalue=otop

    otrack = otop->get(/all, isa='trackball')
    owin = otop->get(/all, isa='idlgrwindow')
    oview = otop->get(/all, isa='idlgrview')
    omodel = oview->getbyname('model')

    ; Trackball update.
    is_updated = otrack->update(event, transform=updated)
    if is_updated then begin
        omodel->getproperty, transform=current
        omodel->setproperty, transform=current#updated
    endif

    ; Display mouse position in view volume.
    on_surface = owin->pickdata(oview, omodel, [event.x,event.y], $
        picked_point)
    wstatus1 = widget_info(event.top, find_by_uname='status1')
    if on_surface then begin
        xloc = string(picked_point[0], format='(f5.2)')
        yloc = string(picked_point[1], format='(f5.2)')
        zloc = string(picked_point[2], format='(f5.2)')
        loc_label = ' Location [x,y,z] : [' + xloc + ', ' + yloc + ', ' $
            + zloc + '] '
        widget_control, wstatus1, set_value=loc_label
    endif else begin
        loc_label = ' Location [x,y,z] : [] '
        widget_control, wstatus1, set_value=loc_label
    endelse

    ; Display the object at the mouse location with a tooltip.
    objs = owin->select(oview, [event.x,event.y])
    if size(objs, /type) ne 3 then begin
         the_obj = obj_class(objs[0])
         obj_label = ' Object selected: ' + the_obj
         widget_control, event.id, tooltip=obj_label
    endif else widget_control, event.id, tooltip=' '

    ; Redraw window contents.
    owin->draw
end


;+
; The event handling routine for the top-level base. Handles resize events
; generated by the top-level base. The draw widget is given the new size of
; the top-level base minus some padding.
;
; @param event {in}{type=structure} The event structure.
; @author Mark Piper, 2002
; @copyright RSI
;-
pro draw_surface_view_resize_event, event
    compile_opt idl2

    widget_control, event.top, get_uvalue=otop

    owin = otop->get(/all, isa='idlgrwindow')
    otrack = otop->get(/all, isa='trackball')

    ; Set the draw window size after resizing the tlb.
    wstatus = widget_info(event.top, find_by_uname='status1')
    gstatus = widget_info(wstatus, /geometry)
    gtop = widget_info(event.top, /geometry)
    wdraw = widget_info(event.top, find_by_uname='wdraw')
    newx = (event.x - gtop.xpad*2) > 200
    newy = (event.y - gstatus.scr_ysize - gtop.ypad*3 - gtop.space) > 200
    widget_control, wdraw, xsize=newx, ysize=newy

    ; Reset the trackball with the new window dimensions.
    center = [newx, newy]/2
    radius = (newx < newy)/2
    otrack->reset, center, radius

    owin->draw
end


;+
; The cleanup routine for DRAW_SURFACE_VIEW. Used to destroy the top
; container for holding object references.
;
; @param wtop {in}{type=long} The top-level base widget identifier passed
;   from XMANANGER.
; @author Mark Piper, 2002
; @copyright RSI
;-
pro draw_surface_view_cleanup, wtop

    widget_control, wtop, get_uvalue=top
    obj_destroy, top
end

;+
; A program for demonstrating functionality in the IDL Object Graphics
; system.
;
; @author Mark Piper, 2002
; @copyright RSI
;-
pro draw_surface_view, _extra=e
    compile_opt idl2

    ; Build a widget hierarchy.
    wtop = widget_base( $
        title='A View Of A Surface', $
        /column, $
        mbar=menubar, $
        /tlb_size_events)

    wmenu1 = widget_button(menubar, $
        value='File', $
        /menu, $
        event_pro='draw_surface_view_menu_event')
    wexit = widget_button(wmenu1, $
        value='Exit', $
        uname='exit')
    wmenu2 = widget_button(menubar, $
        value='Texture Map', $
        /menu, $
        event_pro='draw_surface_view_menu_event')
    wtexturemap = widget_button(wmenu2, $
        value='Apply Texture Map', $
        uname='texture')
    wremovemap = widget_button(wmenu2, $
        value='Remove Texture Map', $
        uname='remove')
    wmenu3 = widget_button(menubar, $
        value='Output', $
        /menu, $
        event_pro='draw_surface_view_menu_event')
    wimage = widget_button(wmenu3, $
        value='to Image', $
        uname='image')
    wclip = widget_button(wmenu3, $
        value='to Clipboard', $
        uname='clip')
    wps = widget_button(wmenu3, $
        value='to PostScript', $
        uname='ps')
    wprint = widget_button(wmenu3, $
        value='to Printer', $
        uname='print')


    wsubbase = widget_base(wtop)

    wtransbase = widget_base(wsubbase, $
        /row, $
        map=0, $ ; initially unmapped
        xoffset=5, $
        yoffset=5, $
        uname='transbase')
    wtransparency = widget_slider(wtransbase, $
        title='Transparency', $
        min=0, $
        max=255, $
        value=0, $
        /suppress_value, $
        uname='transparency', $
        event_pro='draw_surface_view_transparency_event')

    wdraw = widget_draw(wsubbase, $
        xsize=400, $
        ysize=400, $
        graphics_level=2, $
        /expose_events, $
        /motion_events, $
        /button_events, $
        uname='wdraw', $
        event_pro='draw_surface_view_window_event')
    wstatus = widget_label(wtop, $
        value=' Location [x,y,z] : [] ', $
;        /sunken, $
        /dynamic_resize, $
        /align_left, $
        uname='status1')

    widget_control, wtop, /realize
    widget_control, wdraw, get_value=win

    ; Build an object tree based on a surface object.
    ;data = beselj(shift(dist(40),20,20)/2)*20
    data = dist(40)
    view = create_surface_view(data, /standard_orientation, $
        /standard_scaling)

    ; Add lighting.
    lm = obj_new('idlexlightmodel', /default_lights)
    view->add, lm

    ; Change the surface style and color.
    surf = view->getbyname('model/surface')
    surf->setproperty, style=2, color=[200,0,0], shading=1

    track = obj_new('trackball', [200,200], 200)

    win->setproperty, graphics_tree=view, uvalue=woptions
    win->draw

    ; Add all objects to a top-level container.
    top = obj_new('idl_container')
    top->add, [win, view, track]

    widget_control, wtop, set_uvalue=top

    xmanager, 'draw_surface_view', wtop, $
        /no_block, $
        event_handler='draw_surface_view_resize_event', $
        cleanup='draw_surface_view_cleanup'
end
