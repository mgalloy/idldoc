;+
; Rotates a model object into a familiar orientation.
;
; @param model {in}{type=object reference} A model object reference.
;
; @author Mark Piper, 2002
; @copyright RSI
;-
pro set_standard_orientation, model

    if strlowcase(obj_class(model)) ne 'idlgrmodel' then begin
        message, 'Input needs to be a model object.', /info
        return
    endif

    model->rotate, [1,0,0], -90
    model->rotate, [0,1,0], 30
    model->rotate, [1,0,0], 30
end
