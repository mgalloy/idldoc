;==============================================================================
;+
; This method reconstructs the widget interface if it has been
; dismissed.
;-
pro im_engine::restore_interface
    compile_opt idl2

    if widget_info(self.top, /valid_id) then return
    self->create_widgets

    iter = self.op_vector->iterator()
    while ~iter->done() do begin
        next = iter->next()
        self->register_op, next.class_name, next.menu_name, /restore
    endwhile 

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
; Displays the original (unprocessed) image, along with its histogram.
;-
pro im_engine::revert
    compile_opt idl2

    ;; Revert display to original image. Store previous image in undo, 
    ;; so the revert can be undone.
    self.oimage_orig->getproperty, data=orig
    self.oimage->getproperty, data=display
    self.oimage_undo->setproperty, data=display
    self.oimage->setproperty, data=orig

    if self.histogram->is_visible() then self.histogram->display
    self->display
end


;==============================================================================
;+
; Negates the previous image processing operation.
;-
pro im_engine::undo
    compile_opt idl2

    ;; Swap the display and undo data. Yes, you can undo an undo.
    self.oimage_undo->getproperty, data=undo
    self.oimage->getproperty, data=display
    self.oimage_undo->setproperty, data=display
    self.oimage->setproperty, data=undo

    if self.histogram->is_visible() then self.histogram->display
    self->display
end


;==============================================================================
;+
; The class setter method, used to access private member variables in
; an <code>im_engine</code> object.
;
; @keyword new_image {in}{type=object} An image object to be set as
;   the current image in the display. 
; @keyword kill_object {in}{type=boolean} Set this keyword to indicate
;   that the object should be destroyed when the UI is destroyed.
; @keyword scr_xsize {in}{type=long} The screen size of the draw
;   widget in the x-direction; scroll bars are displayed if an image
;   is larger than this value. 
; @keyword scr_ysize {in}{type=long} The screen size of the draw
;   widget in the y-direction; scroll bars are displayed if an image
;   is larger than this value. 
;-
pro im_engine::set, new_image=oimage_new, kill_object=ko, scr_xsize=scrx, $
             scr_ysize=scry
    compile_opt idl2

    if obj_valid(oimage_new) then begin
        if ~self.macro_recording then begin
            self.oimage->getproperty, data=current
            self.oimage_undo->setproperty, data=current
        endif
        oimage_new->getproperty, data=new
        obj_destroy, oimage_new
        self.oimage->setproperty, data=new
        if self.histogram->is_visible() then self.histogram->display
        self->display
    endif
    
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
;
; @keyword op_vector {out}{type=object} Set this keyword to a named
;   variable in which the vector of registered operations is returned.
;-
pro im_engine::get, op_vector=opvec
    compile_opt idl2

    if arg_present(opvec) then opvec = self.op_vector
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

    if self.macro_recording then begin
        self.macro_vector->add, op
    endif else obj_destroy, op
end


;==============================================================================
;+
; Adds a menu entry in the UI for the requested image operation.
;
; @param class_name {in}{type=string} The name of the class used to
;   define the operation.
; @param menu_name {in}{type=string} The name displayed in the menu
;   entry.
; @keyword restore {in}{type=boolean} Set this keyword when restoring
;   the UI.
;-
pro im_engine::register_op, class_name, menu_name, restore=restore
    compile_opt idl2

    if self->op_exists(class_name) and ~keyword_set(restore) then begin
        message, 'Operation "' + class_name + '" already registered.', $
                 /informational
        return
    endif

    op_menu = widget_info(self.top, find_by_uname='image_op_menu')
    new_op_button = widget_button(op_menu, value=menu_name, $
                                  uname='image_op:' + class_name)
    if ~keyword_set(restore) then $
        self.op_vector->add, {class_name:class_name, menu_name:menu_name}
end


;==============================================================================
;+
; Removes a menu entry in the UI for the requested image operation.
;
; @param class_name {in}{type=string} The name of the class used to
;   define the operation.
;-
pro im_engine::unregister_op, class_name
    compile_opt idl2

    if n_elements(class_name) ne 0 then begin
        op_index = self->op_exists(class_name, /index)
        if op_index ne -1 then begin
            self.op_vector->remove, op_index
            op_button = widget_info(self.top, $
                                    find_by_uname='image_op:' + class_name)
            widget_control, op_button, /destroy
        endif else begin
            message, 'Operation class name "' + class_name + '" not found', $
                     /informational
        endelse 
    endif
end


;==============================================================================
;+
; Used to determine whether a given image processing operation has
; been registered in the <code>im_engine</code> interface.
;
; @param class_name {in}{type=string} The name of the class used to
;   define the operation.
; @keyword index {optional}{type=boolean} Set this keyword to have the
;   method return the actual index into self.op_vector that the
;   requested op occupies.
; @returns 1 if the operation exists, 0 if it doesn't. If the INDEX
;   keyword is set, the index of the operation in self.op_vector is
;   returned, or -1 if the op doesn't exist.
;-
function im_engine::op_exists, class_name, index=index
    compile_opt idl2

    if (self.op_vector->size() eq 0 || n_elements(class_name) eq 0) then $
        return, 0

    all_ops = self.op_vector->to_array()
    match = where(all_ops.(0) eq strlowcase(class_name), n_match)
    if keyword_set(index) then $
        return, match $
    else $
        return, n_match ge 1
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
        'draw' : begin
            oview  = self.oviewgroup->getbyname('view')
            omodel = self.oviewgroup->getbyname('view/model')
            on_image = self.owindow->pickdata(oview, omodel, $
                                              [event.x,event.y], ppoint)
            if on_image eq 0 then begin
                xloc = string(ppoint[0], format='(i4.3)')
                yloc = string(ppoint[1], format='(i4.3)')
                self.oimage->getproperty, data=img, interleave=interleave
                idims = size(img, /n_dimensions)
                case interleave of
                    0: begin
                        if idims eq 2 then pixval = img[ppoint[0],ppoint[1]] $
                        else pixval = img[*,ppoint[0],ppoint[1]]
                    end
                    1: pixval = img[ppoint[0],*,ppoint[1]]
                    2: pixval = img[ppoint[0],ppoint[1],*]
                endcase
                zloc = strjoin(string(pixval, format='(i4.3)'))
                label = '[x,y,z] : [' + xloc + ',' + yloc + ', ' + zloc + '] '
                widget_control, self.position, set_value=label
            endif
            self->display
        end
        'open' : begin
            ok = dialog_read_image(image=img, dialog_parent=self.top, $
                                   query=info, red=r, green=g, blue=b)
            if ~ok then return
            if self.histogram->is_visible() then self.histogram->kill_widgets
            obj_destroy, self.oviewgroup 
            self.oimage = obj_new('idlgrimage', img, name='image')
            self.oimage_undo->setproperty, data=img
            self.oimage_orig->setproperty, data=img
            self->build_object_tree
            if info.has_palette then begin
                opalette = obj_new('idlgrpalette', r, g, b)
                self.oviewgroup->add, opalette
                self.oimage->setproperty, palette=opalette
                self.oimage_undo->setproperty, palette=opalette
                self.oimage_orig->setproperty, palette=opalette
            endif
            self.oimage->getproperty, dimensions=dims
            widget_control, self.draw, draw_xsize=dims[0], draw_ysize=dims[1]
            self->set, scr_xsize=dims[0]
            self->set, scr_ysize=dims[1]
            self->display
        end
        'save' : begin
            self.oimage->getproperty, data=image
            a = dialog_write_image(image, dialog_parent=self.top, $
                                   file='im_engine.png', type='png', $
                                   /warn_exist)
        end
        'exit' : widget_control, self.top, /destroy
        'undo' : self->undo
        'revert' : self->revert
        'histogram' : begin
            if not self.histogram->is_visible() then begin
                self.histogram->create_widgets
                self.histogram->realize
                self.histogram->set, image=self.oimage
                self.histogram->start_xmanager
            endif
        end
        'macro_code' : begin
            if ~obj_valid(self.macro_vector) then begin
                self->change_label, 'Macro not defined.'
                return
            endif
            file = dialog_pickfile(dialog_parent=event.top, $
                                   title='Select Output File for Code...', $
                                   /write, /overwrite_prompt, $
                                   default_extension='pro')
            if file eq '' then return

            function_name = file_basename(file, '.pro')
            
            openw, lun, file, /get_lun

            printf, lun, '; Code generated by IM_ENGINE'
            printf, lun, 'function ' + function_name + ', image'
            printf, lun

            iter = self.macro_vector->iterator()
            while ~iter->done() do begin
                next = iter->next()
                next->write_code, lun=lun, indent=4
            endwhile

            printf, lun, '    return, image'
            printf, lun, 'end'

            free_lun, lun
        end
        'macro_play' : begin
            if ~obj_valid(self.macro_vector) then begin
                self->change_label, 'Macro not defined.'
                return
            endif
            iter = self.macro_vector->iterator()
            while ~iter->done() do begin
                next = iter->next()
                self->perform_op, next
            endwhile
        end
        'macro_stop' : begin
            self->change_label, 'IMaging Engine'
            self.macro_recording = 0
            widget_control, widget_info(self.top, $
                                        find_by_uname='macro_play'), $
                            sensitive=1
            widget_control, widget_info(self.top, $
                                        find_by_uname='macro_code'), $
                            sensitive=1
            widget_control, widget_info(self.top, $
                                        find_by_uname='macro_stop'), $
                            sensitive=0
        end
        'macro_record' : begin
            if obj_valid(self.macro_vector) then begin
                obj_destroy, self.macro_vector, /clean
                widget_control, widget_info(self.top, $
                                            find_by_uname='macro_play'), $
                                sensitive=1
                widget_control, widget_info(self.top, $
                                            find_by_uname='macro_code'), $
                                sensitive=1
            endif 
            self.macro_vector = obj_new('vector', example=obj_new())
            self->change_label, 'Recording macro...'
            self.macro_recording = 1
            widget_control, widget_info(self.top, $
                                        find_by_uname='macro_stop'), $
                            sensitive=1
        end
        else : begin ; perform an operation
            if (stregex(uname, '^image_op:') ne -1) then begin
                widget_control, widget_info(self.top, find_by_uname='undo'), $
                                sensitive=1
                subs = stregex(uname, '^image_op:(.*)', $
                               /subexpr, /extract)
                class_name = subs[1]
                self->create_op, class_name
            endif else begin
                ok = dialog_message('Unknown operation: "' $
                                    + uname + '" occurred.')
            endelse
        end
    endcase
end


;==============================================================================
;+
; Destroys UI and cleans up resources associated with it. Optionally
; destroys object, as well. This method is called by XMANAGER through
; the widget cleanup routine CLEANUP_WIDGETS.<p> 
;
; @param top {in}{type=long} The top-level base widget identifier,
;   required in the call by XMANAGER.
;-
pro im_engine::cleanup_widgets, top
    compile_opt idl2

    self.histogram->kill_widgets
    if self.kill_object then obj_destroy, self
end


;==============================================================================
;+
; Calls XMANAGER to register the widget interface for
; <code>im_engine</code>. Events are passed through the
; wrapper routine HANDLE_EVENTS. The kill_notify signal is passed
; through CLEANUP_WIDGETS.<p>
;
; Note that the NO_BLOCK keyword is ignored by IDL Runtime and IDL
; Virtual Machine.
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
    open_button = widget_button(file_menu, value='Open...', $
                                uname='open')
    save_button = widget_button(file_menu, value='Save...', $
                                uname='save')   
    exit_button = widget_button(file_menu, value='Exit', $
                                 uname='exit', /separator)

    ;; Display menu
    display_menu = widget_button(menubar, value='Display', /menu)
    undo_button = widget_button(display_menu, value='Undo', $
                                uname='undo', sensitive=0)
    revert_button = widget_button(display_menu, value='Revert to Original', $
                                  uname='revert')
    hist_button = widget_button(display_menu, value='Histogram...', $
                                uname='histogram', /separator)

    ;; Macro menu
    macro_menu = widget_button(menubar, value='Macro', /menu)
    record_button = widget_button(macro_menu, value='Record', $
                                  uname='macro_record')
    stop_button = widget_button(macro_menu, value='Stop', $
                                uname='macro_stop', sensitive=0)
    play_button = widget_button(macro_menu, value='Play', $
                                uname='macro_play', sensitive=0)
    code_button = widget_button(macro_menu, value='Write code', $
                                uname='macro_code', sensitive=0)

    ;; Operations menu
    op_menu = widget_button(menubar, value='Operations', /menu, $
                            uname='image_op_menu')

    self.oimage->getproperty, dimensions=dims
    self.draw = widget_draw(self.top, $
                            /scroll, $
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
    self.position = widget_label(status_row, $
                                 value='Position information', $
                                 /sunken, /dynamic_resize)
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
    obj_destroy, [self.oimage_orig, self.oimage_undo]
    obj_destroy, self.histogram
    obj_destroy, self.op_vector
    obj_destroy, self.macro_vector, /clean
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

    if n_params() eq 1 then begin
        isize = size(image, /structure)
        fail = 0
        if ((isize.n_dimensions lt 2) || (isize.n_dimensions gt 4)) then $
            fail = 1
        if ((isize.type eq 0) || $
            (isize.type ge 6 and isize.type le 11)) then fail = 1
        if fail then begin
            message, 'Input data cannot be displayed as an image', /continue
            return, 0
        endif
    endif else image = bytarr(400,400)+255B
    
    self.oimage = obj_new('idlgrimage', image, name='image')
    self.oimage_orig = obj_new('idlgrimage', image, name='orig')
    self.oimage_undo = obj_new('idlgrimage', name='undo')
    self->create_widgets
    self->realize
    self->build_object_tree
    self->display
    if ~(lmgr(/vm) || lmgr(/runtime)) then self->start_xmanager

    self.histogram = obj_new('im_histogram')
    self.op_vector = obj_new('vector', example={class_name:'', menu_name:''})

    return, 1
end


;==============================================================================
;+
; <center><img src="im_engine.png" alt="im_engine"/></center><br>
;
; The class data definition procedure for <code>im_engine</code>.
;
; @file_comments This is the Advanced IDL class project IM_ENGINE, 
; an object-based widget application for displaying and processing images.
;
; @field top The top-level base widget identifier for the UI.
; @field draw The draw widget identifier.
; @field status The widget identifier for the status bar.
; @field position The widget identifier for the position bar.
; @field scr_xsize The screen size of the draw area in the
;   x-direction; an image larger than this value is displayed with
;   scroll bars.
; @field scr_ysize The screen size of the draw area in the
;   y-direction; an image larger than this value is displayed with
;   scroll bars.
; @field owindow The window object reference for the draw widget. An
;   instance of IDLgrWindow.
; @field oviewgroup The topmost container in the object tree displayed in
;   the UI. An instance of <code>IDLgrViewgroup</code>.
; @field oimage An IDLgrImage object that holds the image data.
; @field histogram An <code>im_histogram</code> object, used to
;   display the histogram of the image in the display.
; @field oimage_undo An instance of <code>IDLgrImage</code> used to
;   hold the result of the previous operation.
; @field oimage_orig An instance of <code>IDLgrImage</code> used to
;   hold original image.
; @field kill_object A flag. When set, if the UI is destroyed, then
;   the object is destroyed as well.
; @field macro_vector An instance of <code>vector</code> used to hold
;   the sequence of image processing operations defined in a macro.
; @field macro_recording A flag that is set when a macro is being
;   recorded.
; @field op_vector A vector of structure variables containing the
;   class name and menu name for each registered image processing
;   operation.
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
               position         : 0, $
               histogram        : obj_new(), $
               macro_vector     : obj_new(), $
               macro_recording  : 0, $
               op_vector        : obj_new(), $
               owindow          : obj_new(), $
               oviewgroup       : obj_new(), $
               oimage           : obj_new(), $
               oimage_undo      : obj_new(), $
               oimage_orig      : obj_new(), $
               kill_object      : 0 $
             }
end
