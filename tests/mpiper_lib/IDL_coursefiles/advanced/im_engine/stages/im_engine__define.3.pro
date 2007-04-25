;==============================================================================
;+
; This method reconstructs the widget interface if it has been
; dismissed.
;-
pro im_engine::restore_interface
    compile_opt idl2

    if widget_info(self.top, /valid_id) then return
    self->create_widgets
    self->realize
    self->display
    self->start_xmanager
end


;==============================================================================
;+
; The class setter method, used to access private member variables in
; an <code>im_engine</code> object.
;
; @keyword kill_object {in}{type=boolean} Set this keyword to indicate
;   that the object should be destroyed when the UI is destroyed.
; @keyword scr_xsize {in}{type=long} The screen size of the draw
;   widget in the x-direction; scroll bars are displayed if an image
;   is larger than this value. 
; @keyword scr_ysize {in}{type=long} The screen size of the draw
;   widget in the y-direction; scroll bars are displayed if an image
;   is larger than this value. 
;-
pro im_engine::set, kill_object=ko, scr_xsize=scrx, scr_ysize=scry
    compile_opt idl2

    if keyword_set(ko) then self.kill_object = 1

    if n_elements(scrx) ne 0 then begin
        device, get_screen_size=ss
        self.scr_xsize = scrx < 0.8*ss[0]
        widget_control, self.draw, xsize=self.scr_xsize
    endif

    if n_elements(scry) ne 0 then begin
        device, get_screen_size=ss
        self.scr_ysize = scry < 0.8*ss[1]
        widget_control, self.draw, ysize=self.scr_ysize
    endif
end


;==============================================================================
;+
; The class getter method, used to access private member variables in
; an <code>im_engine</code> object.
;-
pro im_engine::get
    compile_opt idl2

end


pro im_engine::handle_events, event
    compile_opt idl2

    uname = widget_info(event.id, /uname)
    case uname of
        'draw' : self->display
        'exit' : widget_control, self.top, /destroy
        else : 
    endcase
end


pro im_engine::cleanup_widgets, top
    compile_opt idl2

    if self.kill_object then obj_destroy, self
end


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
    ;;device, get_screen_size=ss
    ;;self.scr_xsize = 0.8*ss[1] < dims[0]
    ;;self.scr_ysize = 0.8*ss[1] < dims[1]
    self.draw = widget_draw(self.top, $
                            /scroll, $
                            ;;x_scroll_size=self.scr_xsize, $
                            ;;y_scroll_size=self.scr_ysize, $
                            xsize=dims[0], ysize=dims[1], $
                            graphics_level=2, $
                            renderer=1, $ ; software rendering!!!
                            /expose_events, $
                            /motion_events, $
                            uname='draw')
    self->set, scr_xsize=dims[0]
    self->set, scr_ysize=dims[1]

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
;+
; @field kill_object A flag. When set, if the UI is destroyed, then
;   the object is destroyed as well.
;
; @requires IDL 6.0
; @author Mike Galloy, 2002
; @history mutated almost beyond recognition 2003, Mark Piper
; @copyright RSI
;-
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
               oimage           : obj_new(), $
               kill_object      : 0 $
             }
end
