;=============================================================================
;+
; Finds and returns the value of a widget (or, for a button widget,
; whether it is set), given the uname of the widget.
;
; @returns The value of the widget, or for a button, 1 if set, 0 if
;  not set.
; @param uname {in}{required}{type=string} The user value of the
;  widget being manipulated.
;-
function xidldoc::get_value, uname
    compile_opt idl2, hidden

    if n_params() ne 1 then begin
        message, 'Need widget user name.', /continue
        return, 0
    endif

    id = widget_info(self.top, find_by_uname=uname)
    name = strlowcase(widget_info(id, /name))
    if name eq 'button' then begin
        value = widget_info(id, /button_set)
    endif else begin
        widget_control, id, get_value=value
    endelse
    return, value
end



;=============================================================================
;+
; Finds and sets the value of a widget, given the uname of the widget
; and the value to set.
;
; @param uname {in}{required}{type=string} The user value of the
;  widget being manipulated.
; @param value {in}{required} The value to assign the widget.
;-
pro xidldoc::set_value, uname, value
    compile_opt idl2, hidden

    if n_params() ne 2 then begin
        message, 'Need widget user name and value.', /continue
        return
    endif

    id = widget_info(self.top, find_by_uname=uname)
    widget_control, id, set_value=value
end



;=============================================================================
;+
; Runs IDLdoc, given the parameters set in the xIDLdoc UI. IDLdoc
; messages, warnings and errors are displayed in the IDL output
; log. It is assumed that the user has IDLdoc installed, either in
; their path, or already compiled in memory.
;-
pro xidldoc::run
    compile_opt idl2, hidden

    ;; Get widget values.
    root = self->get_value('root')
    overview = self->get_value('overview')
    output = self->get_value('output')
    title = self->get_value('title')
    subtitle = self->get_value('subtitle')
    footer = self->get_value('footer')
    user = self->get_value('user')
    embed = self->get_value('embed')
    stats = self->get_value('stats')
    quiet = self->get_value('quiet')
    silent = self->get_value('silent')
    navbar = self->get_value('navbar')
    browse = self->get_value('browse')
    assist = self->get_value('assist')
    preform = self->get_value('preform')

    ;; Do more parameter checking here.

    ;; Set up the call to IDLdoc.
    keys = create_struct('root', root, 'title', title, 'subtitle', subtitle, $
                         'user', user, 'embed', embed, 'statistics', stats, $
                         'quiet', quiet, 'silent', silent, $
                         'nonavbar', ~navbar, 'browse_routines', browse, $
                         'assistant', assist, 'preformat', preform)
    if overview ne '' then keys = create_struct(keys, 'overview', overview)
    if output ne '' then keys = create_struct(keys, 'output', output)
    if footer ne '' then keys = create_struct(keys, 'footer', footer)
    idldoc, _extra=keys
end



;=============================================================================
;+
; Handles events in the xIDLdoc UI. All events generated in the UI
; pass through the wrapper routine HANDLE_EVENTS and arrive here,
; where the event is parsed based on the generating widget's user
; name.
;
; @param event {in}{required}{type=structure} The event structure
;  passed from XMANAGER.
;-
pro xidldoc::handle_events, event
    compile_opt idl2, hidden

    uname = widget_info(event.id, /uname)
    case uname of
        'run': self->run
        'cancel': widget_control, self.top, /destroy
        'draw': self->display
        'root_browse': begin
            dir = dialog_pickfile(/directory, dialog_parent=self.top, $
                                  title='Select IDLdoc Root Directory')
            if ~dir then return
            self->set_value, 'root', dir
            output = self->get_value('output')
            if ~output then self->set_value, 'output', dir
        end
        'overview_browse': begin
            root = self->get_value('root')
            file = dialog_pickfile(dialog_parent=self.top, /must_exist, $
                                   path=root, title='Select Overview File')
            if ~file then return
            self->set_value, 'overview', file
        end
       'output_browse': begin
            root = self->get_value('root')
            dir = dialog_pickfile(/directory, dialog_parent=self.top, $
                                  title='Select IDLdoc Output Directory', $
                                  path=root)
            if ~dir then return
            self->set_value, 'output', dir
        end
       'footer_browse': begin
            root = self->get_value('root')
            file = dialog_pickfile(dialog_parent=self.top, /must_exist, $
                                   path=root, title='Select Footer File')
            if ~file then return
            self->set_value, 'footer', file
            end
        else:
    endcase
end



;=============================================================================
;+
; Destroys the UI and cleans up any resources associated with it.
; Destroys the object in this case, as well.
;
; <p> This method is called by XMANAGER through the widget cleanup routine
; CLEANUP_WIDGETS.
;
; @param top {in}{type=long} The top-level base widget identifier,
;  required in the call by XMANAGER.
;-
pro xidldoc::cleanup_widgets, top
    compile_opt idl2, hidden

    obj_destroy, self
end



;=============================================================================
;+
; Calls XMANAGER to register xIDLdoc's widget interface. Events are
; passed through the wrapper routine HANDLE_EVENTS. The kill_notify
; signal is passed through CLEANUP_WIDGETS.
;
; <p> Note that the NO_BLOCK keyword is ignored by IDL Runtime/Virtual
; Machine for IDL < 6.0.
;
; @uses HANDLE_EVENTS, CLEANUP_WIDGETS
;-
pro xidldoc::start_xmanager
    compile_opt idl2, hidden

    xmanager, obj_class(self), self.top, $
              /no_block, $
              event_handler='handle_events', $
              cleanup='cleanup_widgets'
end



;=============================================================================
;+
; Displays the header image in the draw window, if present.
;-
pro xidldoc::display
    compile_opt idl2, hidden

    device, get_decomposed=odec
    if odec eq 0 then begin
        tvlct, r, g, b, /get
        loadct, 0, /silent
    endif
    if self.has_image then tv, *self.image, true=1
    if odec eq 0 then tvlct, r, g, b
end



;=============================================================================
;+
; Realizes the widget hierarchy.
;-
pro xidldoc::realize
    compile_opt idl2, hidden

    widget_control, self.top, /realize
    if self.has_image then begin
        widget_control, self.draw, get_value=window_id
        self.win_id = window_id
    endif
end



;=============================================================================
;+
; Centers the UI on the display.
;-
pro xidldoc::center_ui
    compile_opt idl2, hidden

    geom = widget_info(self.top, /geometry)
    ss = get_screen_size()
    xoffset = ((ss[0] - geom.scr_xsize)/2) > 0
    yoffset = ((ss[1] - geom.scr_ysize)/2) > 0
    widget_control, self.top, xoffset=xoffset, yoffset=yoffset
end



;=============================================================================
;+
; Makes a UI element consisting of a label, a text field and a
; "Browse" button.
;
; @todo Make this into a compound widget.
;
; @param parent {in}{required}{type=long} The widget identifier
;  of the parent base of this group of widgets.
; @param label {in}{required}{type=string} The text to display in
;  the label widget.
; @param text {in}{required}{type=string} The text to display in
;  the text widget.
; @keyword no_button {in}{optional}{type=boolean} Set to not
;  display the "Browse" button.
;-
pro xidldoc::make_input_row, parent, label, text, no_button=no_button
    compile_opt idl2, hidden

    under_base = widget_base(parent, /row)
    base = widget_base(under_base, /row, space=5)
    labl = widget_label(base, value=label+':', $
                        font=self->select_font(/bold))
    text  = widget_text(base, value=text, xsize=40, /editable, $
                        uname=strlowcase(label))
    button_base = widget_base(under_base, /row, map=~keyword_set(no_button))
    butn  = widget_button(button_base, value='Browse', $
                          uname=strlowcase(label)+'_browse')
end



;=============================================================================
;+
; Returns a string containing the name of a font that can be used in a
; label or text widget.
;
; @todo Make this into an independent function outside this class
; definition.
;
; @keyword big {in}{optional}{type=boolean} Set this keyword to get
;  a larger font.
; @keyword bold {in}{optional}{type=boolean} Set this keyword to get
;  a bold font.
; @returns A string giving the name of the font.
;-
function xidldoc::select_font, big=big, bold=bold
    compile_opt idl2, hidden

    case self.os of
        'windows' : begin
            font = 'Helvetica'
            if keyword_set(big) then font += '*36' else font += '*14'
            if keyword_set(bold) then font += '*Bold'
            return, font
        end
        'unix' : begin
            if keyword_set(big) then font = '9x15' else font = '6x13'
            if keyword_set(bold) then font += 'bold'
            return, font
        end
        else:
    endcase
end



;=============================================================================
;+
; Builds the widget hierarchy. Lots of buttons and fields.
;
; <p>Each widget has a user name (uname) used to identify the widget
; in the <code>get_value</code> and <code>set_value</code> methods.
;-
pro xidldoc::build_widgets
    compile_opt idl2, hidden

    self.top = widget_base(title='IDLdoc', /column, base_align_right=0, $
                           xpad=10, ypad=10)
    widget_control, self.top, set_uvalue=self

    if self.has_image then begin
        self.draw = widget_draw(self.top, xsize=self.image_xs, $
                                ysize=self.image_ys, graphics_level=0, $
                                retain=0, /expose_events, uname='draw')
    endif else begin
        self.draw = -1
        label = widget_label(self.top, value=' ')
        label_row = widget_base(self.top, /row, /align_left, space=15)
        label = widget_label(label_row, value='IDLdoc', $
                             font=self->select_font(/big, /bold))
        label_col = widget_base(label_row, /column, /align_bottom, ypad=5)
        label = widget_label(label_col, $
                             value='An IDL documentation system.', $
                             font=self->select_font())
        label = widget_label(self.top, value=' ')
    endelse

    base = widget_base(self.top, /column, /base_align_right)

    self->make_input_row, base, 'Root', '.'
    self->make_input_row, base, 'Overview', ''
    self->make_input_row, base, 'Output', ''
    self->make_input_row, base, 'Title', 'Research Systems, Inc.', $
                          /no_button
    self->make_input_row, base, 'Subtitle', 'IDL ' + !version.release, $
                          /no_button
    self->make_input_row, base, 'Footer', ''

    doc_level_base = widget_base(self.top, /row)
    label = widget_label(doc_level_base, value='Documentation level:', $
                         font=self->select_font(/bold))

    butn_base = widget_base(doc_level_base, /row, /exclusive)
    butn = widget_button(butn_base, value='User', uname='user', $
        tooltip='Create documentation for users of a library')
    butn = widget_button(butn_base, value='Developer', uname='developer', $
        tooltip='Create documentation for the developers of a library')
    widget_control, butn, set_button=1

    options_base = widget_base(self.top, /row, space=10)
    label = widget_label(options_base, value='Options:  ', $
                         font=self->select_font(/bold))

    check_base1 = widget_base(options_base, /column, /nonexclusive)
    butn = widget_button(check_base1, value='Embed', uname='embed', $
        tooltip='Create documentation where pages can be pulled out individually')
    butn = widget_button(check_base1, value='Statistics', uname='stats', $
        tooltip='Compute complexity statistics of the code')
    butn = widget_button(check_base1, value='Assistant', uname='assist', $
        tooltip='Create documentation for the IDL Assistant')

    check_base2 = widget_base(options_base, /column, /nonexclusive)
    butn = widget_button(check_base2, value='Quiet', uname='quiet', $
        tooltip='Print only error and warning messages')
    butn = widget_button(check_base2, value='Silent', uname='silent', $
        tooltip='Do not print anything')
    butn = widget_button(check_base2, value='Preformat', uname='preform', $
        tooltip='Create documentation from non-IDLdoc''ed code')

    check_base3 = widget_base(options_base, /column, /nonexclusive)
    butn = widget_button(check_base3, value='Navigation Bar', uname='navbar', $
        tooltip='Create documentation with a navbar')
    widget_control, butn, set_button=1
    butn = widget_button(check_base3, value='Browse Window', uname='browse', $
        tooltip='Create documentation with a browse routines window', sensitive=0)

    choice = widget_base(self.top, /row, frame=0, /align_right)

    run = widget_button(choice, value='Run IDLdoc...', uname='run', xsize=100)
    cancel = widget_button(choice, value='Exit', uname='cancel', xsize=100)
end



;=============================================================================
;+
; The actual class destructor. All cleanup code goes here, since it
; can be called directly.
;-
pro xidldoc::destruct
    compile_opt idl2, hidden

    if ptr_valid(self.image) then ptr_free, self.image
end



;=============================================================================
;+
; The official class destructor. This method can't be called
; directly, however, so all code is placed in the
; <code>destruct</code> method instead.
;-
pro xidldoc::cleanup
    compile_opt idl2, hidden

    self->destruct
end



;=============================================================================
;+
; Class constructor, used to load class data. Only one instance of
; xIDLdoc can run at any time.
;
; <p> Note that only a pixel-interleaved RGB image can be displayed at
; the top of the interface.
;
; @keyword header_image {in}{optional}{type=RGB image} A
;  pixel-interleaved RGB image to be displayed at the top of the
;  xIDLdoc interface.
; @returns 1 on success, 0 on failure.
;-
function xidldoc::init, header_image=image
    compile_opt idl2, hidden

    if xregistered(obj_class(self)) then return, 0

    self.os = strlowcase(!version.os_family) ;; 'windows' or 'unix'

    if n_elements(image) ne 0 then begin
        info = size(image, /structure)
        fail = 0
        if info.dimensions[0] ne 3 then ++fail
        if info.n_dimensions ne 3 then ++fail
        if fail eq 0 then begin
            self.has_image = 1
            self.image = ptr_new(image)
            self.image_xs = info.dimensions[1]
            self.image_ys = info.dimensions[2]
        endif
    endif

    self->build_widgets
    self->center_ui
    self->realize
    self->display
    if ~(lmgr(/vm) || lmgr(/runtime)) then self->start_xmanager
    return, 1
end



;=============================================================================
;+
; The xIDLdoc class data definition routine.
;
; @field top The top-level base widget identifier.
; @field draw The draw widget identifier. Only present if an image is
;  to be displayed at the top of the xIDLdoc interface.
; @field win_id The window index of the draw widget, if present.
; @field has_image 1 if an image is present, 0 otherwise.
; @field image A pointer to the image data.
; @field image_xs The xsize of the image.
; @field image_ys The ysize of the image.
; @field os The operating system IDL is running on.
;-
pro xidldoc__define
    compile_opt idl2, hidden

    a = { xidldoc, $
          top       : 0, $
          draw      : 0, $
          win_id    : 0, $
          has_image : 0, $
          image     : ptr_new(), $
          image_xs  : 0, $
          image_ys  : 0, $
          os        : '' $
         }
end



;=============================================================================
;+
; This is a wrapper for simplifying the creation and use of an
; <code>xIDLdoc</code> object.
;
; @file_comments xIDLdoc is a graphical front-end for IDLdoc, the IDL
; documentation system developed by Michael D. Galloy of RSI's Global
; Services Group.
;
; <p> To use xIDLdoc, IDLdoc should already be installed in a user's
; IDL path or compiled in memory. IDLdoc messages, warnings and errors are
; displayed in the IDL output log.
;
; @examples
; <pre>
; IDL> xidldoc
; </pre>
;
; @pre IDLdoc must be in the user's path or already compiled in the
;  user's IDL session.
; @uses Michael D. Galloy's IDLdoc. IDLdoc can be downloaded for free
;  from the RSI codebank: <code>(www.rsinc.com/codebank)</code>.
;  Also SOURCEROOT.
; @todo Save settings between calls in an init file stored with
;  APP_USER_DIR. Requires IDL 6.1.
; @requires IDL 6.0
; @author Mark Piper, RSI, 2004
; @history
;  <ul>
;  <li>2005-03-28, MP: Desensitized checkbox for STATISTICS keyword.
;  <li>2005-07-21, MP: Resensitized checkbox for STATISTICS keyword.
;  Added checkboxes for the ASSISTANT and PREFORMAT keywords.
;  <li>2006-03-11, MG: Added tooltips for buttons, desensitized checkbox for
;  BROWSE_ROUTINES, added text box for LOG_FILE keyword
;  </ul>
;-
pro xidldoc
    compile_opt idl2, logical_predicate

    here = sourceroot()
    file = here + 'idldoc_splash1.png'
    if file_test(file) then begin
        splash_color = read_image(file)
        odoc = obj_new('xidldoc', header_image=splash_color)
    endif else $
        odoc = obj_new('xidldoc')

    if ~obj_valid(odoc) then return

    ;; Start XMANAGER last in runtime/vm mode for IDL < 6.1.
    if lmgr(/vm) || lmgr(/runtime) then odoc->start_xmanager
end
