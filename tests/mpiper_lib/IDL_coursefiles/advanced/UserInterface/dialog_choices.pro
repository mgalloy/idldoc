pro dialog_choices_choice_event, event
    compile_opt idl2

    widget_control, event.top, get_uvalue=pstate
    widget_control, event.id, get_uvalue=choice_number

    (*pstate).choice = choice_number
end


pro dialog_choices_done, event
    compile_opt idl2

    widget_control, event.top, get_uvalue=pstate
    uname = widget_info(event.id, /uname)

    case uname of
    'ok' : begin
            (*pstate).ok = 1
            widget_control, event.top, /destroy
        end
    'cancel' : begin
            (*pstate).ok = 0
            (*pstate).choice = -1
            widget_control, event.top, /destroy
        end
    endcase
end


;+
; Modal dialog to present the user with a choice.
;
; @returns -1 if cancelled, 0..n_elements(choices)-1 for a selection
; @param prompt {in}{type=string} prompt for choices
; @param choices {in}{type=string array} choices
; @keyword dialog_parent {in}{optional}{type=widget ID} widget ID of
;          parent widget hierarchy; the dialog_parent widget will not
;          respond to events until this dialog has been dismissed.
;-
function dialog_choices, prompt, choices, $
    dialog_parent=dialog_parent
    compile_opt idl2

    if (n_elements(dialog_parent) eq 0) then begin
        group_leader = 0
        modal = 0
    endif else begin
        group_leader = dialog_parent
        modal = 1
    endelse

    tlb = widget_base(title='Please make a selection', /column, $
        modal=modal, group_leader=group_leader, tlb_frame_attr=1)

    main_base = widget_base(tlb, /row, /base_align_center)

    draw = widget_draw(main_base, xsize=64, ysize=64, retain=2)

    space = widget_base(main_base, xsize=20)

    selection_base = widget_base(main_base, /column)

    prompt = widget_label(selection_base, value=prompt, /align_left)

    choices_base = widget_base(selection_base, /column, /exclusive, $
        event_pro='dialog_choices_choice_event')

    for i = 0L, n_elements(choices) - 1 do begin
        c_button = widget_button(choices_base, value=choices[i], $
            uvalue=i)
        if (i eq 0) then widget_control, c_button, /set_button
    endfor

    control_base = widget_base(tlb, /row, event_pro='dialog_choices_done', $
        /align_center)
    ok_button = widget_button(control_base, value='OK', uname='ok', $
        xsize=75)
    cancel_button = widget_button(control_base, value='Cancel', $
        uname='cancel', xsize=75)

    widget_control, tlb, /realize

    widget_control, tlb, default_button=ok_button
    widget_control, tlb, cancel_button=cancel_button

    ; Display image
    widget_control, draw, get_value=draw_id
    wset, draw_id

    help_file = filepath('help.bmp', subdir=['resource', 'bitmaps'])
    help_icon = read_image(help_file, r, g, b)

    device, get_decomposed=old_decomposed
    device, decomposed=0

    sys_colors = widget_info(tlb, /system_colors)
    tvlct, old_r, old_g, old_b, /get

    r[8] = sys_colors.face_3d[0]
    g[8] = sys_colors.face_3d[1]
    b[8] = sys_colors.face_3d[2]
    tvlct, r, g, b
    tv, rebin(help_icon, 64, 64)

    device, decomposed=old_decomposed
    tvlct, old_r, old_g, old_b

    state = { $
        ok:0, $
        choice:0L $
        }
    pstate = ptr_new(state, /no_copy)
    widget_control, tlb, set_uvalue=pstate

    xmanager, 'dialog_choices', tlb

    choice = (*pstate).choice
    ok = (*pstate).ok
    ptr_free, pstate

    return, ok ? choice : -1
end
