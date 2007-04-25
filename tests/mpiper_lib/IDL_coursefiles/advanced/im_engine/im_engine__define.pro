;==============================================================================
;+
; This method can be used to reconstruct the widget interface if it has
; been dismissed.<p>
;
; <b>TODO:</b> Need to restore registered operations.
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
; Changes the text in the status bar.
;
; @param message {in}{type=string} A string containing a message to
;   be displayed in the status bar.
;-
pro im_engine::change_label, message
    compile_opt idl2

    widget_control, self.status, set_value=message
end


;==============================================================================
;+
; Displays the original (unprocessed) image, along with its histogram.<p>
; <b>TODO:</b> Reset the UI to the size of the original image.
;-
pro im_engine::revert
    compile_opt idl2

    self.oimage_orig->getproperty, data=orig
    self.oimage->getproperty, data=display
    self.oimage_undo->setproperty, data=display
    self.oimage->setproperty, data=orig

    if self.histogram->is_visible() then $
        self.histogram->display
    self->display
end


;==============================================================================
;+
; Negates the previous image processing operation.
;-
pro im_engine::undo
    compile_opt idl2

    self.oimage_undo->getproperty, data=undo
    self.oimage->getproperty, data=display
    self.oimage_undo->setproperty, data=display
    self.oimage->setproperty, data=undo

    if self.histogram->is_visible() then $
        self.histogram->display
    self->display
end


;==============================================================================
;+
; The class setter method.
;
; @keyword new_image
; @keyword kill_interface_and_object
;-
pro im_engine::set, new_image=oimage_new, kill_interface_and_object=kiao
    compile_opt idl2

    if obj_valid(oimage_new) then begin

        ;; Move currently displayed data to undo.
        self.oimage->getproperty, data=current
        self.oimage_undo->setproperty, data=current

        ;; Place new data in display.
        oimage_new->getproperty, data=new
        obj_destroy, oimage_new
        self.oimage->setproperty, data=new

        if self.histogram->is_visible() then $
            self.histogram->display
        self->display
    endif

    if keyword_set(kiao) then self.kill_all = 1
end


;==============================================================================
;+
; The class getter method.
;-
pro im_engine::get
    compile_opt idl2

end


;==============================================================================
;+
; This method performs a registered image processing operation, resulting
; in a new image.
;
; @param op {in}{type=object} An image processing operation object, an
;   instance of a subclass of <code>im_operator</code>.
;-
pro im_engine::perform_op, op
    compile_opt idl2

    oimage_new = op->do_it(self.oimage)
    self->set, new_image=oimage_new
end


;==============================================================================
;+
; Creates an image processing operation. If macro recording is on, the
; operation is added to the macro.
;
; @param class_name {in}{type=string} The name of the class in which
;   the image processing operation is defined.
;-
pro im_engine::create_op, class_name
    compile_opt idl2

    op = obj_new(class_name)
    self->perform_op, op

    if (self.macro_recording) then begin
        self.macro_vector->add, op
    endif else begin
        obj_destroy, op
    endelse
end


;==============================================================================
;+
; Adds a menu entry in the UI for the requested image operation.
;
; @param class_name {in}{type=string} The name of the class used to
;   define the operation.
; @param menu_name {in}{type=string} The name displayed in the menu
;   entry.
;-
pro im_engine::register_op, class_name, menu_name
    compile_opt idl2

    op_menu = widget_info(self.top, find_by_uname='image_op_menu')
    new_op_button = widget_button(op_menu, value=menu_name, $
                                  uname='image_op:' + class_name)
end


;==============================================================================
;+
; Handles events for the UI in <code>im_engine</code>. All events
; generated in the UI pass through the wrapper routine HANDLE_EVENTS
; and arrive here, where the event is parsed based on the generating
; widget's user name.<p>
; <b>TODO:</b> Break event handing code into methods.
;
; @param event {in}{type=structure} The event structure passed from
;   XMANAGER.
;-
pro im_engine::handle_events, event
    compile_opt idl2

    uname = widget_info(event.id, /uname)
    case uname of
        'top' : begin
            newx = event.x - 2*(*self.geometry).pad
            newy = event.y $                   ;
                - 2*(*self.geometry).pad $     ; A struggle, but
                - (*self.geometry).space $     ; now this works.
                - (*self.geometry).y_label     ;
            if !version.os_family eq 'unix' then $    ; On Motif, the menu
                newy = newy - (*self.geometry).y_menu ; size is in event.y
;            widget_control, self.draw, $
;                xsize=newx, ysize=newy+1
            widget_control, self.draw, xsize=newx, ysize=newy
            self->display
            end
        'draw' : begin
            self->display
        end
        'exit' : widget_control, self.top, /destroy
        'undo': self->undo
        'revert': self->revert
        'histogram': begin
            if not self.histogram->is_visible() then begin
                self.histogram->create_widgets
                self.histogram->realize
                self.histogram->set, image=self.oimage
                self.histogram->start_xmanager
            endif
        end
        'macro_code' : begin
            file = dialog_pickfile(dialog_parent=event.top, $
                                   title='Select output file for code...')
            if (file eq '') then return

            if (file_test(file)) then begin
                ok = dialog_message(file + ' exists. Overwrite?', $
                                    /cancel, dialog_parent=event.top)
                if (strlowcase(ok) eq 'cancel') then return
            endif

            fpos = strpos(file, path_sep(), /reverse_search) + 1
            filename = strmid(file, fpos)
            dot_pos = strpos(filename, '.')
            f_len = dot_pos eq -1 ? strlen(filename) : dot_pos
            function_name = strmid(filename, 0, f_len)

            openw, lun, file, /get_lun

            printf, lun, '; Code generated by IM_ENGINE'
            printf, lun, 'function ' + function_name + ', image'
            printf, lun

            iter = self.macro_vector->iterator()
            while (not iter->done()) do begin
                next = iter->next()
                next->write_code, lun=lun, indent=4
            endwhile

            printf, lun, '    return, image'
            printf, lun, 'end'

            free_lun, lun
        end
        'macro_play' : begin
            iter = self.macro_vector->iterator()
            while (not iter->done()) do begin
                next = iter->next()
                self->perform_op, next
            endwhile
        end
        'macro_stop' : begin
            self->change_label, ' '
            self.macro_recording = 0
        end
        'macro_record' : begin
            if obj_valid(self.macro_vector) then $
                obj_destroy, self.macro_vector
            self.macro_vector = obj_new('vector', example=obj_new())
            self->change_label, 'Recording macro...'
            self.macro_recording = 1
        end
        else : begin ; perform an operation
            if (stregex(uname, '^image_op:') ne -1) then begin
                subs = stregex(uname, '^image_op:(.*)', $
                               /subexpr, /extract)
                class_name = subs[1]
                self->create_op, class_name
            endif else begin
                ok = dialog_message('Unknown operation: ' $
                                    + uname + ' occurred.')
            endelse
        end
    endcase
end


;==============================================================================
;+
; Destroys UI and cleans up resources associated with it. Optionally
; destroys object, as well.<p>
;
; This method is called by XMANAGER through the widget cleanup routine
; CLEANUP_WIDGETS.<p>
;
; @param top {in}{type=long} The top-level base widget identifier,
;   required in the call by XMANAGER.
;-
pro im_engine::cleanup_widgets, top
    compile_opt idl2

    self.histogram->kill_widgets
    ptr_free, self.geometry
    if self.kill_all then obj_destroy, self
end


;==============================================================================
;+
; This method is used to compute geometry information for the realized
; widgets, which is then stored in the member variable
; <i>geometry</i>. The geometry info is used in resizing the UI.
;-
pro im_engine::compute_geometry
    compile_opt idl2

    status_row = widget_info(self.top, find_by_uname='row')
    g_status_row = widget_info(status_row, /geometry)
    file_menu = widget_info(self.top, find_by_uname='file')
    g_file_menu = widget_info(file_menu, /geometry)
    g_top = widget_info(self.top, /geometry)

    geom = {pad : g_top.xpad, $
            space : g_top.space, $
            x_menu : g_file_menu.xsize, $
            y_menu : g_file_menu.ysize, $
            x_label : g_status_row.xsize, $
            y_label : g_status_row.ysize $
            }
    self.geometry = ptr_new(geom, /no_copy)
end


;==============================================================================
;+
; Calls XMANAGER to register the widget interface for
; <code>im_engine</code>. Events are passed through the
; wrapper routine HANDLE_EVENTS. The kill_notify signal is passed
; through CLEANUP_WIDGETS.<p>
;
; Note that the NO_BLOCK keyword is ignored by IDL Runtime.
;-
pro im_engine::start_xmanager
    compile_opt idl2

    xmanager, obj_class(self), self.top, $
        /no_block, $
        event_handler='handle_events', $
        cleanup='cleanup_widgets'
end


;==============================================================================
;+
; Displays the image in the UI.
;-
pro im_engine::display
    compile_opt idl2

    self.owindow->draw, self.oview
end


;==============================================================================
;+
; Used to construct the Object Graphics hierarchy used in the UI. The
; view and image objects are memeber variables for this object.
;-
pro im_engine::build_object_tree
    compile_opt idl2

    self.oimage->getproperty, dimensions=dims
    self.oview = obj_new('idlgrview', $
                         viewplane_rect=[0, 0, dims[0], dims[1]], $
                         name='view')
    omodel = obj_new('idlgrmodel', name='model')
    omodel->add, self.oimage
    self.oview->add, omodel
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
    self->compute_geometry
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
                           /tlb_size_events)

    file_menu = widget_button(menubar, value='File', /menu, $
                              uname='file')
    exit_button = widget_button(file_menu, value='Exit', $
                                 uname='exit', /separator)

    display_menu = widget_button(menubar, value='Display', /menu)
    undo_button = widget_button(display_menu, value='Undo', $
                                uname='undo')
    revert_button = widget_button(display_menu, value='Revert to Original', $
                                  uname='revert')
    hist_button = widget_button(display_menu, value='Histogram...', $
                                uname='histogram', /separator)

    macro_menu = widget_button(menubar, value='Macro', /menu)
    record_button = widget_button(macro_menu, value='Record', $
                                  uname='macro_record')
    stop_button = widget_button(macro_menu, value='Stop', $
                                uname='macro_stop')
    play_button = widget_button(macro_menu, value='Play', $
                                uname='macro_play')
    code_button = widget_button(macro_menu, value='Write code', $
                                uname='macro_code')

    op_menu = widget_button(menubar, value='Operations', /menu, $
                            uname='image_op_menu')

    self.oimage->getproperty, dimensions=dims
    self.draw = widget_draw(self.top, $
                             xsize=dims[0], ysize=dims[1], $
                             graphics_level=2, $
                             renderer=1, $   ; software rendering!!!
                             /expose_events, $
                             uname='draw')

    status_row = widget_base(self.top, /row, uname='row')
    self.status = widget_label(status_row, $
                                      value='IMaging Engine', $
                                      xsize=200, /sunken)
end


;==============================================================================
;+
; Cleans up resources associated with the object. Called by OBJ_DESTROY.
;-
pro im_engine::cleanup
    compile_opt idl2

    if widget_info(self.top, /valid_id) then $
        widget_control, self.top, /destroy
    obj_destroy, [self.oview, self.oimage_undo, self.oimage_orig]
    if ptr_valid(self.geometry) then $
        ptr_free, self.geometry
    obj_destroy, self.histogram
    obj_destroy, self.macro_vector
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

    if n_elements(image) eq 0 then return, 0

    self.oimage = obj_new('idlgrimage', image, name='image')
    self.oimage_orig = obj_new('idlgrimage', image, name='orig')
    self.oimage_undo = obj_new('idlgrimage', name='undo')
    self->create_widgets
    self->realize
    self->build_object_tree
    self->display
    self->start_xmanager

    self.histogram = obj_new('im_histogram')

    self.macro_recording = 0

    return, 1
end


;==============================================================================
;+
; <center><img src="im_engine.png" alt="im_engine"/></center><br>
;
; The class data definition procedure for <code>im_engine</code>.
;
; @file_comments This is the Advanced IDL class project IM_ENGINE.
; It is an object-based widget application for displaying and processing
; images.
; Image processing operations can be registered with the application
; after creation.
; It has the ability to record and play macros,
; then dump the macros operations to a
; file. Programmatically generated IDL code is cool!
;
; @field top The top-level base widget identifier for the UI.
; @field draw The draw widget identifier.
; @field status The widget identifier for the status bar.
; @field owindow The window object reference for the draw widget. An
;   instance of IDLgrWindow.
; @field oview The topmost container in the object tree displayed in
;   the UI. An instance of IDLgrView.
; @field oimage An IDLgrImage object that holds the image data.
; @field geometry A pointer containing size information for elements
;   in the UI.
; @field histogram An <code>im_histogram</code> object, used to
;   display the histogram of the image in the display.
; @field oimage_undo An instance of <code>IDLgrImage</code> used to
;   hold the result of the previous operation.
; @field oimage_orig An instance of <code>IDLgrImage</code> used to
;   hold original image.
; @field macro_vector An instance of <code>vector</code> used to hold
;   the sequence of image processing operations defined in a macro.
; @field macro_recording A flag that is set when a macro is being
;   recorded.
;
; @author Mike Galloy, 2002
; @history mutated 2003, Mark Piper
; @copyright RSI
;-
pro im_engine__define
    compile_opt idl2

    define = { im_engine, $
               top              : 0, $
               draw             : 0, $
               status           : 0, $
               geometry         : ptr_new(), $
               histogram        : obj_new(), $
               macro_vector     : obj_new(), $
               macro_recording  : 0, $
               op_vector        : obj_new(), $
               owindow          : obj_new(), $
               oview            : obj_new(), $
               oimage           : obj_new(), $
               oimage_undo      : obj_new(), $
               oimage_orig      : obj_new(), $
               kill_all         : 0 $
             }
end
