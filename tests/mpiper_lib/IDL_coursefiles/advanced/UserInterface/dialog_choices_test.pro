;+
; Test routine for dialog_choices.
;-
pro dialog_choices_test
    compile_opt idl2

    tlb = widget_base(/column)
    draw = widget_draw(tlb)
    widget_control, tlb, /realize

    xmanager, 'dialog_choices_test', tlb, /no_block

    choice = dialog_choices('Select color for the draw window:', $
        ['Red', 'Green', 'Blue'], dialog_parent=tlb)

    widget_control, draw, get_value=draw_id
    wset, draw_id

    case choice of
    -1 : color = 0L
     0 : color = 255L
     1 : color = 255L * 2L ^8
     2 : color = 255L * 2L ^ 16
    endcase

    device, get_decomposed=old_decomposed
    device, decomposed=1
    erase, color
    device, decomposed=old_decomposed
end
