;==============================================================================
;+
; Handles events for the UI in <code>im_engine</code>. All events
; generated in the UI pass through the wrapper routine HANDLE_EVENTS
; and arrive here, where the event is parsed based on the generating
; widget's user name.
;
; @param event {in}{type=structure} The event structure passed from
;   XMANAGER.
;-
pro im_engine::handle_events, event
    compile_opt idl2

    uname = widget_info(event.id, /uname)
    case uname of
        'draw' : self->display ;; not needed for expose ev if renderer=1
        'exit' : widget_control, self.top, /destroy
        else : 
    endcase
end


;==============================================================================
;+
; Destroys UI and cleans up resources associated with it. Optionally
; destroys object, as well. This method is called by XMANAGER through
; the widget cleanup routine CLEANUP_WIDGETS.
;
; @param top {in}{type=long} The top-level base widget identifier,
;   required in the call by XMANAGER.
;-
pro im_engine::cleanup_widgets, top
    compile_opt idl2

end


;==============================================================================
;+
; Calls XMANAGER to register the widget interface for
; <code>im_engine</code>. Events are passed through the wrapper
; routine HANDLE_EVENTS. The kill_notify signal is passed through
; CLEANUP_WIDGETS.
;
; @uses HANDLE_EVENTS, CLEANUP_WIDGETS
;-
pro im_engine::start_xmanager
    compile_opt idl2

    xmanager, obj_class(self), self.top, $
        /no_block, $
        event_handler='handle_events', $
        cleanup='cleanup_widgets'
end


pro im_engine::display
    compile_opt idl2

    self.owindow->draw, self.oviewgroup
end


pro im_engine::build_object_tree
    compile_opt idl2

    self.oviewgroup = obj_new('idlgrviewgroup', name='viewgroup')
    self.oimage->getproperty, dimensions=dims
    oview = obj_new('idlgrview', $
                    viewplane_rect=[0, 0, dims[0], dims[1]], $
                    name='view')
    omodel = obj_new('idlgrmodel', name='model')
    omodel->add, self.oimage
    oview->add, omodel
    self.oviewgroup->add, oview
end


pro im_engine::realize
    compile_opt idl2

    widget_control, self.top, /realize
    widget_control, self.draw, get_value=window
    self.owindow = window
end


pro im_engine::create_widgets
    compile_opt idl2

    self.top = widget_base(title='IMaging Engine', uname='top', $
                           mbar=menubar, uvalue=self, /column, $
                           tlb_frame_attr=1)

    ;; File menu
    file_menu = widget_button(menubar, value='File', /menu, $
                              uname='file')
    exit_button = widget_button(file_menu, value='Exit', $
                                 uname='exit', /separator)

    ;; Display menu
    display_menu = widget_button(menubar, value='Display', /menu)

    ;; Macro menu
    macro_menu = widget_button(menubar, value='Macro', /menu)

    ;; Operations menu
    op_menu = widget_button(menubar, value='Operations', /menu, $
                            uname='image_op_menu')

    self.oimage->getproperty, dimensions=dims
    device, get_screen_size=ss
    self.scr_xsize = 0.8*ss[1] < dims[0]
    self.scr_ysize = 0.8*ss[1] < dims[1]
    self.draw = widget_draw(self.top, $
                            /scroll, $
                            x_scroll_size=self.scr_xsize, $
                            y_scroll_size=self.scr_ysize, $
                            xsize=dims[0], ysize=dims[1], $
                            graphics_level=2, $
                            renderer=1, $ ; software rendering!!!
                            /expose_events, $
                            /motion_events, $
                            uname='draw')

    status_row = widget_base(self.top, /row, uname='row')
    self.status = widget_label(status_row, $
                               value='IMaging Engine', $
                               /sunken, xsize=150)
end


pro im_engine::cleanup
    compile_opt idl2

    if widget_info(self.top, /valid_id) then $
        widget_control, self.top, /destroy
    obj_destroy, self.oviewgroup
end


function im_engine::init, image
    compile_opt idl2
    
    self.oimage = obj_new('idlgrimage', image, name='image')
    self->create_widgets
    self->realize
    self->build_object_tree
    self->display
    self->start_xmanager

    return, 1
end


;==============================================================================

pro im_engine__define
    compile_opt idl2

    define = { im_engine, $
               top              : 0, $
               draw             : 0, $
               scr_xsize        : 0, $
               scr_ysize        : 0, $
               status           : 0, $
               owindow          : obj_new(), $
               oviewgroup       : obj_new(), $
               oimage           : obj_new() $
             }
end
