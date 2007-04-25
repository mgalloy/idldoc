;===========================================================================
;+
; Event handler for all image processing operations.
;
; Only standard iTool operations are used here. Making, registering
; and handling iTool operations are covered elsewhere.
;
; @param event {in}{type=structure} The event structure passed from
;    XMANAGER.
;-
pro iimageprocessor_tool_op, event
    compile_opt idl2

    ;; Retrieve the state variable.
    widget_control, event.top, get_uvalue=pstate

    ;; Get the uname of the widget that generated the event.
    uname = widget_info(event.id, /uname)

    ;; Make sure our iTool is the current tool.
    tool_id = (*pstate).otool->getfullidentifier()
    itcurrent, tool_id

    ;; Find the image's iTool id and select it for the operation. Note
    ;; that prior to IDL 6.2.1, '*image*' selected the image. It now
    ;; selects the data space the image belongs to. Changing the
    ;; search string to '*image' fixes this.
    image_id = (*pstate).otool->findidentifiers('*image', /visualizations)
    oimage = (*pstate).otool->getbyidentifier(image_id[0])
    oimage->select

    ;; The uname of the widget is used to identify the
    ;; operation. This is a little sloppy, but it works because the
    ;; FindIdentifiers method uses STREGEX to search for the operation
    ;; by its id.
    op_id = (*pstate).otool->findidentifiers('*'+uname+'*', /operations)

    ;; Perform the operation.
    void = (*pstate).otool->doaction(op_id)
    (*pstate).otool->commitactions
end



;===========================================================================
;+
; Handles events from the iTool system. Currently this routine does
; nothing; everything is handled automatically by the iTool system.
;
; @todo Need to update the virtual size of the draw window when
; another image is read from the file system (Look for
; message_in='filename'). Window resizing is handled in
; CW_ITWINDOW_RESIZE, but the ability to set the virtual dimensions
; isn't exposed. I could write a wrapper, but I don't want to mess
; with this right now because I don't fully understand the
; ramifications of doing so.
;
; @param wtop {in}{type=long} The top-level base widget identifier.
; @param str_id {in}{type=string} A string identifying the source of
;    the message (usually the object identifier of an iTool component
;    object, but it can be any string value).
; @param message_in {in}{type=string}
; @param userdata {in} A value associated with the message being sent.
;-
pro iimageprocessor_tool_callback, wtop, str_id, message_in, userdata
    compile_opt idl2

    ;; Diagnostics.
    ;;print, str_id
    ;;print, message_in
    ;;help, userdata
end



;===========================================================================
;+
; The actual code for resizing the top-level base, called from
; IIMAGEPROCESSOR_TOOL_EVENT. This code is slightly simpler than that
; found in <b>idlitwdtool.pro</b> because here we lack a toolbar; only
; the draw widget and the status bar are resized.
;
; <p> The iTool docs state that it's important to turn on the UPDATE
; keyword on the top-level base on UNIX-based platforms.
;
; @param pstate {in}{type=pointer} The state variable.
; @param deltaw {in}{type=long} The amount the user changed the
;    top-level base width, in pixels.
; @param deltah {in}{type=long} The amount the user changed the
;    top-level base height, in pixels.
;-
pro iimageprocessor_tool_resize, pstate, deltaw, deltah
    compile_opt idl2

    ;; Get the original geometry (prior to the resize) of the iTool
    ;; draw and statusbar widgets.
    drawgeom = widget_info((*pstate).wdraw, /geometry)
    statusgeom = widget_info((*pstate).wstatus, /geometry)

    ;; Compute the updated dimensions of the visible portion
    ;; of the draw widget.
    newvisw = drawgeom.xsize + deltaw
    newvish = drawgeom.ysize + deltah

    ;; Check whether UPDATE is turned on and save the value. On
    ;; UNIX-based platforms, UPDATE must be turned on or windows will
    ;; not resize properly. Turn UPDATE off under Windows to prevent
    ;; window flashing.
    isupdate = widget_info((*pstate).wtop, /update)
    widget_control, (*pstate).wtop, update=(*pstate).unix_platform

    ;; Update the dimensions of the draw widget and the statusbar.
    if (newvisw ne drawgeom.xsize || newvish ne drawgeom.ysize) then $
        cw_itwindow_resize, (*pstate).wdraw, newvisw, newvish
    cw_itstatusbar_resize, (*pstate).wstatus, statusgeom.scr_xsize+deltaw

    ;; Turn UPDATE back on if we turned it off. 
    if (isupdate && ~widget_info((*pstate).wtop, /update)) then $
        widget_control, (*pstate).wtop, /update

    ;; Get and store the new top-level base size.
    if (widget_info((*pstate).wtop, /realized)) then begin
        widget_control, (*pstate).wtop, tlb_get_size=basesize
        (*pstate).basesize = basesize
    endif
end



;===========================================================================
;+
; Top-level base event handler, used here to handle resize, keyboard
; focus and kill request events.
;
; @param event {in}{type=structure} The event structure passed from
;    XMANAGER.
; @uses IIMAGEPROCESSOR_TOOL_RESIZE
;-
pro iimageprocessor_tool_event, event
    compile_opt idl2

    ;; Retrieve the state variable from the top-level base user value.
    widget_control, event.top, get_uvalue=pstate

    case strlowcase(tag_names(event, /structure_name)) of

        ;; To destroy the widget interface, get the shutdown service
        ;; and call DoAction. This code must be here and not in the
        ;; cleanup routine, because the tool may not actually be
        ;; killed. (For example the user may be asked if they want to
        ;; save, and they may hit "Cancel" instead.)
        'widget_kill_request': begin
            if obj_valid((*pstate).oui) then begin
                otool = (*pstate).oui->gettool()
                oshutdown = otool->getservice('shutdown')
                void = (*pstate).oui->doaction(oshutdown->getfullidentifier())
            endif
        end

        ;; If the iTool is gaining the focus, Get the set current tool
        ;; service and call DoAction.
        'widget_kbrd_focus': begin
            if (event.enter && obj_valid((*pstate).oui)) then begin
                otool = (*pstate).oui->gettool()
                osetcurrent = otool->getservice('set_as_current_tool')
                void = otool->doaction(osetcurrent->getfullidentifier())
            endif
        end

        ;; The top-level base was resized. Compute the size change of
        ;; the base relative to its cached former size.
        'widget_base': begin
            ;; Why not event.x & event.y?
            widget_control, event.top, tlb_get_size=newsize
            deltaw = newsize[0] - (*pstate).basesize[0]
            deltah = newsize[1] - (*pstate).basesize[1]
            iimageprocessor_tool_resize, pstate, deltaw, deltah
        end
        
        else: ;; Do nothing

    endcase
end



;===========================================================================
;+
; The kill notify routine for IIMAGEPROCESSOR_TOOL, used to deallocate
; resources (here, the state variable) used by this routine.
;
; @param wtop {in}{type=long} The widget identifier of the top-level
;    base, passed in by XMANAGER.
;-
pro iimageprocessor_tool_cleanup, wtop
    compile_opt idl2

    ;; Check that this is a valid widget.
    if ~widget_info(wtop, /valid) then return
    
    ;; Retrieve the state variable and destroy it.
    widget_control, wtop, get_uvalue=pstate
    if ptr_valid(pstate) then ptr_free, pstate
end



;===========================================================================
;+ 
; The custom iTool UI for iImageprocessor is defined in this program,
; like the widget creation routine of a standard IDL widget
; program. This routine differs from a standard widget creation
; routine in that it is not called directly, it is called from the
; launch routine IIMAGEPROCESSOR, and it contains compound widgets and
; objects defined for communication with the iTool system.
;
; <p> A screenshot of the UI defined here (with a sample image) is
; shown below. Note that the standard iTool Tool bar and some of the
; iTool Menu bar are omitted. The default window size is 400 x 400
; pixels.
;
; <p><a><img src="./iimageprocessor.png" alt="iImageprocessor"
; align="center"></a>
;
; @file_comments The programs in this file are used to define the UI
; and provide event handling for the iImageprocessor iTool. A callback
; is also provided for handling iTool events that occur in this UI.
;
; <p> Much of the code in this file is based on <b>idlitwdtool.pro</b>
; in the <b>lib/itools/ui_widgets</b> subdirectory.  This is the
; standard iTool widget interface; it's a start point for any iTool.
;
; <p> See also <b>example2_wdtool.pro</b> in the
; <b>examples/doc/itools</b> directory.
;
; @param otool {in}{type=object reference} The object reference of the
;    iTool that uses this interface.
; @keyword title {in}{optional}{type=string}{default='iImageProcessor'}
;    The title for the tool, displayed on the system titlebar.
; @keyword location {in}{optional}{type=long} A two-element array
;    [x,y] that specifies where to place the iTool on the display, in
;    pixels.
; @keyword virtual_dimensions {in}{optional}{type=integer} A
;    two-element array [width,height] giving the virtual dimensions of
;    the draw window. Replaces SCR_[XY]SIZE in a standard IDL draw
;    widget.
; @keyword user_interface {out}{type=object} The reference for the
;    user interface object for this iTool.
; @keyword _ref_extra Pass-by-reference keyword inheritance
;    mechanism. 
;
; @uses IIMAGEPROCESSOR, IIMAGEPROCESSOR__DEFINE
; @requires IDL 6.1
; @author Mark Piper, RSI, 2004
;-
pro iimageprocessor_tool, otool, $
                          title=title, $
                          location=loc, $
                          virtual_dimensions=vdim, $
                          user_interface=oui, $
                          _ref_extra=re
    compile_opt idl2
    on_error, 2

    ;; Check that the input iTool object reference is valid.
    if ~obj_valid(otool) then $
        message, 'Tool is not a valid object.'

    ;; Display the hourglass while the iTool is loading.
    widget_control, /hourglass

    ;; Make a top-level base with a menubar. Generate events when the
    ;; base is resized, when it gets/loses keyboard focus and when it
    ;; is dismissed.
    _title = n_elements(title) gt 0 ? title[0] : 'iImageProcessor'
    wtop = widget_base( $
                          /column, $
                          title=_title, $
                          mbar=wmenubar, $
                          /tlb_kill_request_events, $
                          /tlb_size_events, $
                          /kbrd_focus_events, $
                          _extra=re)

    ;; Create a new UI object with the iimageprocessor iTool.
    oui = obj_new('idlitui', otool, group_leader=wtop)

    ;; Make the standard iTool Menu bar, minus the items unregistered
    ;; in the iimageprocessor class and minus the Operations and Help
    ;; menus.
    wfile = cw_itmenu(wmenubar, oui, 'operations/file')
    wedit = cw_itmenu(wmenubar, oui, 'operations/edit')
    wwin = cw_itmenu(wmenubar, oui, 'operations/window')

    ;; Make a base to hold the image processing buttons and the draw
    ;; window.
    wbase = widget_base(wtop, /row)

    ;; A column base to hold a series of image processing
    ;; controls. The widget UNAMEs are used both to identify the
    ;; widget in the event handler as well as identify the name of the
    ;; iTool operation to perform.
    wcontrolbase = widget_base(wbase, /column, $
                               event_pro='iimageprocessor_tool_op')
    wsmooth  = widget_button(wcontrolbase, $
                             value='Smooth', $
                             uname='smooth')
    wmedian  = widget_button(wcontrolbase, $
                             value='Median', $
                             uname='median')
    wusmask  = widget_button(wcontrolbase, $
                             value='Unsharp Mask', $
                             uname='mask')
    wsobel   = widget_button(wcontrolbase, $
                             value='Sobel', $
                             uname='sobel')
    wroberts = widget_button(wcontrolbase, $
                             value='Roberts', $
                             uname='roberts')
    whistog  = widget_button(wcontrolbase, $
                             value='Histogram', $
                             uname='histogram')
    wbscale  = widget_button(wcontrolbase, $
                             value='Byte Scale', $
                             uname='bytscl')
    wneg     = widget_button(wcontrolbase, $
                             value='Negative', $
                             uname='invert')
    wstats   = widget_button(wcontrolbase, $
                             value='Statistics', $
                             uname='statistic')
    
    ;; The compound widget CW_ITWINDOW is used to create a draw widget
    ;; in the iTool system, in place of WIDGET_DRAW. If vdim >
    ;; dimensions, scrollbars are drawn.
    dimensions = [400, 400]
    wdraw = cw_itwindow(wbase, oui, $
                        dimensions=dimensions, $
                        virtual_dimensions=(vdim > dimensions))

    ;; Get the geometry of the top-level base widget.
    geom = widget_info(wtop, /geometry)

    ;; Create the status bar.
    wstatus = cw_itstatusbar(wtop, oui, xsize=geom.xsize-geom.xpad)

    ;; If the user did not specify a location, set the iTool's
    ;; position on the screen. 
    ss = get_screen_size()
    if (n_elements(loc) eq 0) then begin
        location = [(ss[0] - geom.xsize)/2 - 10, $
                    ((ss[1] - geom.ysize)/2 - 100) > 10]
    endif else location = loc
    widget_control, wtop, $
        tlb_set_xoffset=location[0], $
        tlb_set_yoffset=location[1]
    
    ;; Realize the interface, but leave its UI unmapped to avoid
    ;; flashing.
    widget_control, wtop, map=0
    widget_control, wtop, /realize

    ;; Get the initial dimensions and store them; this info is used
    ;; for window resizing in event processing.
    widget_control, wtop, tlb_get_size=basesize

    ;; Create a state structure for the widget and store a pointer to
    ;; the structure in the user value of the top-level base. 
    state = { $
                otool         : otool, $
                oui           : oui, $
                wtop          : wtop, $
                title         : title, $
                basesize      : basesize, $
                wdraw         : wdraw, $
                wstatus       : wstatus, $
                unix_platform : strlowcase(!version.os_family) eq 'unix' $
            }
    pstate = ptr_new(state, /no_copy)
    widget_control, wtop, set_uvalue=pstate

    ;; Register the top-level base widget with the UI object,
    ;; specifying the name of the callback routine that receives
    ;; messages from the iTool components. Returns a string containing
    ;; the identifier of the interface widget.
    id = oui->registerwidget(wtop, 'iimageprocessor_tool', $
                             'iimageprocessor_tool_callback')

    ;; Register the UI to receive messages from the iTool components
    ;; included in the interface, like the Menu and Tool bars.
    oui->addonnotifyobserver, id, otool->getfullidentifier()

    ;; Display the widget interface.
    widget_control, wtop, map=1

    ;; Call XMANAGER. (Note in IDLITWDTOOL, the KILL_NOTIFY routine is
    ;; set on the first child of the top-level base. This appears to
    ;; be a matter of programming style. I prefer to specify the cleanup
    ;; routine on XMANAGER.)
    xmanager, 'iimageprocessor_tool', wtop, $
        /no_block, $
        event_handler='iimageprocessor_tool_event', $
        cleanup='iimageprocessor_tool_cleanup'
end
