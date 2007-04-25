;==============================================================================
;+
; Displays the image in the UI.
;-
pro im_engine::display
    compile_opt idl2

    self.owindow->draw, self.oviewgroup
end


;==============================================================================
;+
; Used to construct the Object Graphics hierarchy used in the UI. The
; viewgroup and image objects are member variables for this object.
;-
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


;==============================================================================
;+
; Draws the UI to the screen and obtains the window object reference.
;-
pro im_engine::realize
    compile_opt idl2

    widget_control, self.top, /realize
    widget_control, self.draw, get_value=window
    self.owindow = window
end


;==============================================================================
;+
; Constructs the UI in <code>im_engine</code>. Note that individual
; widgets have user names for identification in the
; <code>handle_events</code> method.
;-
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


;==============================================================================
;+
; Cleans up resources associated with the object. Called by OBJ_DESTROY.
;-
pro im_engine::cleanup
    compile_opt idl2

    if widget_info(self.top, /valid_id) then $
        widget_control, self.top, /destroy
    obj_destroy, self.oviewgroup
end


;==============================================================================
;+
; Initializes and assigns resources used in an <code>im_engine</code>
; object. Creates the widget interface for the object.
; Called by OBJ_NEW.
;
; @param image {in}{type=numeric array} An array to be displayed as
;   an image.
; @returns 1 on success, 0 on failure.
;-
function im_engine::init, image
    compile_opt idl2
    
    self.oimage = obj_new('idlgrimage', image, name='image')
    self->create_widgets
    self->realize
    self->build_object_tree
    self->display

    return, 1
end


;==============================================================================
;+
; The class data definition procedure for <code>im_engine</code>.
;
; @file_comments This is the Advanced IDL class project IM_ENGINE, 
; an object-based widget application for displaying and processing
; images.
;
; @field top The top-level base widget identifier for the UI.
; @field draw The draw widget identifier.
; @field scr_xsize The screen size of the draw area in the
;   x-direction; an image larger than this value is displayed with
;   scroll bars.
; @field scr_ysize The screen size of the draw area in the
;   y-direction; an image larger than this value is displayed with
;   scroll bars.
; @field status The widget identifier for the status bar.
; @field owindow The window object reference for the draw widget. An
;   instance of <code>IDLgrWindow</code>.
; @field oviewgroup The topmost container in the object tree displayed
;   in the UI. An instance of <code>IDLgrViewgroup</code>.
; @field oimage An <code>IDLgrImage</code> object that holds the image
;   data. 
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
               oimage           : obj_new() $
             }
end
