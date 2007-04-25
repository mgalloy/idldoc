pro tabbing_ex_event, event
    compile_opt idl2

    widget_control, event.id, get_value=val
    print, val

    return
end

;+
; An example of tabbing between IDL widgets in a form.
;-
pro tabbing_ex
    compile_opt idl2

    top = widget_base( $
          title='Tabbing Example', $
          /column)

    row1 = widget_base(top, /row)
    row2 = widget_base(top, /row)

    button = widget_button(row1, value='Button 1')
    button = widget_button(row1, value='Button 2')
    button = widget_button(row1, value='Button 3')

    button = widget_button(row2, value='Button 4')
    button = widget_button(row2, value='Button 5')
    button = widget_button(row2, value='Button 6')

    widget_control, top, /realize

    xmanager, 'tabbing_ex', top
    return
end
