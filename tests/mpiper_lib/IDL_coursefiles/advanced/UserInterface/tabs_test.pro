;+
; Simple test program for cw_tabs.
;-
pro tabs_test
    compile_opt idl2

    tlb = widget_base(title='Tabs test', /column)
    tabs = cw_tabs(tlb, titles=['First', 'Second', 'Third'], $
        bases=bases, buttons=0)

    label = widget_label(bases[0], value='First')
    label = widget_label(bases[1], value='Second')
    label = widget_label(bases[2], value='Third')
    draw = widget_draw(bases[2], xsize=400, ysize=100)

    widget_control, tabs, set_value=1
    widget_control, tabs, get_value=val
    print, val

    widget_control, tlb, /realize
end