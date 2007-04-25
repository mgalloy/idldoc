;+
; Displays the image histogram.<p>
;
; <b>TODO:</b> This method needs to be expanded to plot histograms of
; multiband images. Query the DIMENSIONS and INTERLEAVE properties of
; the image object. Plot RGB[A] bands in different colors on the same
; axes.
;-
pro im_histogram::display
    compile_opt idl2

    self.oimage->getproperty, data=data
    wset, self.win_id
    plot, histogram(data), $
        psym=10, $
        xtitle='pixel value', $
        ytitle='samples'
end


;+
; The setter method for <code>im_histogram</code>.
;
; @keyword image {in}{type=object} An instance of IDLgrImage.
;-
pro im_histogram::set, image=oimage
    compile_opt idl2

    self.oimage = oimage
    if (self->is_visible()) then self->display
end


;+
; Used to clean up the UI programmatically.
;-
pro im_histogram::kill_widgets
    compile_opt idl2

    if self->is_visible() then widget_control, self.top, /destroy
end


;+
; Checks to see if the UI exists.
;-
function im_histogram::is_visible
    compile_opt idl2

    return, widget_info(self.top, /valid_id)
end


;+
; Handles events dispatched from XMANAGER (through the event handling
; procedure HANDLE_EVENTS).
;-
pro im_histogram::handle_events, event
    compile_opt idl2

end


;+
; The kill_notify routine. Nothing to clean up if the UI is dismissed.
;
; @param top {in}{type=long} The top-level base widget identifier.
;-
pro im_histogram::cleanup_widgets, top
    compile_opt idl2

end


;+
; Register the UI and start event handling. No events are generated,
; however, except kill_notify on the top-level base.
;-
pro im_histogram::start_xmanager
    compile_opt idl2

    xmanager, 'im_histogram', self.top, /no_block, $
        event_handler='handle_events', $
        cleanup='cleanup_widgets'
end


;+
; Draws the UI to the screen. Displays image data, if present.
;-
pro im_histogram::realize
    compile_opt idl2

    widget_control, self.top, /realize
    widget_control, self.draw, get_value=win_id
    self.win_id = win_id

    if (obj_valid(self.oimage)) then self->display
end


;+
; Builds the UI to display a histogram.
;-
pro im_histogram::create_widgets
    compile_opt idl2

    self.top = widget_base(title='Histogram', /column, uvalue=self)
    self.draw = widget_draw(self.top, xsize=400, ysize=200)
end


pro im_histogram::cleanup
    compile_opt idl2

end


function im_histogram::init
    compile_opt idl2

    return, 1
end


;+
; The class data definition procedure for <code>im_histogram</code>.<p>
;
; @file_comments This class is used to calculate and display the
; histogram of the image currently being displayed in the IM_ENGINE
; UI. A simple UI consisting of a top-level base and a Direct Graphics
; draw widget are used. XMANAGER is called, but there's no
; interactivity.<p>
;
; @field top The top-level base in the UI.
; @field draw The draw widget used to display the histogram.
; @field win_id The window index of the draw widget.
; @field oimage An instance of <code>IDLgrImage</code>.
;
; @author Mike Galloy, 2002
; @history mutated 2003, Mark Piper
; @copyright RSI
;-
pro im_histogram__define
    compile_opt idl2

    define = { im_histogram, $
               top  : 0, $
               draw : 0, $
               win_id   : 0, $
               oimage   : obj_new() $
             }
end
