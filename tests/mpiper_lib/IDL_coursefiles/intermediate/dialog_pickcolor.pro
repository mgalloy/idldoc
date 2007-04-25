;+
; Event handler for the all events of dialog_pickfile
;
; @private
; @param event {in}{type=structure} event structure
;-
pro dialog_pickcolor_event, event
    compile_opt idl2
    on_error, 2

    widget_control, event.top, get_uvalue=pstate
    widget_control, event.id, get_uvalue=uval

    case uval of
    'color' : (*pstate).color = event.value
    'ok' : widget_control, event.top, /destroy
    'cancel' : begin
            (*pstate).return = 0
            widget_control, event.top, /destroy
        end
    endcase
end


;+
; Color selector dialog.
;
; <br><center><img src="dialog_pickcolor.png" alt="Image of dialog_pickcolor" />
; </center>
;
; @returns RGB triplet or the string 'Cancel'
; @uses <a href="cw_color_cube.html">cw_color_cube</a>
; @keyword dialog_parent {in}{optional}{type=int} Widget ID to ask as parent
; @keyword cancel {out}{optional}{type=int} If a named variable is passed, it will be
;          set to 1 if the user selected 'Cancel' or 0 if the user selected
;          'OK'
; @keyword init_color {in}{optional}{type=bytarr(3)}{default=[255, 255, 255]}
;          initial color selected
; @keyword title {in}{optional}{type=string}{default="Pick a color..."} string
;          displayed in window title bar
; @author Michael D. Galloy
; @copyright RSI, 2001
;-
function dialog_pickcolor, $
    dialog_parent=dialog_parent, $
    cancel=cancel, $
    init_color=init_color, $
    title=title

    compile_opt idl2
    on_error, 2

    button_length = 85

    if (n_elements(dialog_parent) eq 0) then dialog_parent = 0
    if (n_elements(init_color) eq 0) then init_color = [255B, 255B, 255B]
    if (n_elements(title) eq 0) then title = 'Pick a color...'

    tlb = widget_base(group_leader=dialog_parent, title=title, $
        floating=(dialog_parent ne 0), /column, map=(dialog_parent ne 0), $
        tlb_frame_attr=1, modal=(dialog_parent ne 0))
    csel = cw_color_cube(tlb, uvalue='color', init_color=init_color, $
        bar_height=10, bar_width=10)

    controls = widget_base(tlb, /row, /align_center)
    okB = widget_button(controls, value='OK', uvalue='ok')
    cancelB = widget_button(controls, value='Cancel', uvalue='cancel')

    widget_control, okB, xsize=button_length
    widget_control, cancelB, xsize=button_length

    if (dialog_parent eq 0) then $
        widget_control, tlb, map=1 $
    else $
        widget_control, tlb, cancel_button=cancelB, default_button=okB

    widget_control, tlb, /realize

    state = { color:byte(init_color), return:1 }
    pstate = ptr_new(state, /no_copy)
    widget_control, tlb, set_uvalue=pstate

    if (dialog_parent eq 0) then begin
        tlbG = widget_info(tlb, /geometry)
        device, get_screen_size=ss
        widget_control, tlb, $
            tlb_set_xoffset=(ss[0] - tlbG.scr_xsize)/2, $
            tlb_set_yoffset=(ss[1] - tlbG.scr_ysize)/2
    endif

    xmanager, 'dialog_pickcolor', tlb

    color = (*pstate).color
    return = (*pstate).return
    ptr_free, pstate

    cancel = return eq 0
    if (return) then return, color else return, 'Cancel'
end
