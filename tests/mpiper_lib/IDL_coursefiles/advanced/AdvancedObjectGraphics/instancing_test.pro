;+
; An example of instancing in Object Graphics. Redraw only the part of
; the graphical scene that changes.
; <p>
;
; On my desktop, a Dell w/ an 800 MHz processor + NVIDIA TNT2 graphics card,
; running IDL 5.6 Win...
; Instancing with hardware rendering is really slow. Instancing with
; software rendering is much faster, as fast as not instancing with
; software rendering. Hardware rendering, no instancing, is fastest.
;
; @keyword no_instancing {in}{type=boolean} Set to turn off instancing.
;   The default is to use instancing.
; @keyword renderer {in}{type=boolean} Set to turn on software rendering.
;   The default is to use hardware rendering.
;
; @author Mark Piper, 2002
; @copyright RSI
;-
pro instancing_test, $
    no_instancing=noi,$
    renderer=r

    compile_opt idl2

    ; Make a graphics atom & put it in a model that will change.
    o1 = obj_new('idlgrsurface', dist(40), style=2, color=[200,0,0])
    set_standard_scaling, o1
    changing_model = obj_new('idlgrmodel')
    set_standard_orientation, changing_model
    changing_model->add, o1

    ; Make two more atoms & put them in a model that won't change.
    o2 = obj_new('orb', radius=0.1, pos=[0.5,0.5,0.5], color=[0,200,0])
    o3 = obj_new('orb', radius=0.15, pos=[-0.5,-0.5,0.0], color=[0,0,200])
    unchanging_model = obj_new('idlgrmodel')
    unchanging_model->add, [o2, o3]

    ; Make lights.
    light_model = obj_new('idlexlightmodel', /default_lights)


    view = obj_new('idlgrview')
    view->add, [changing_model, unchanging_model, light_model]

    ; Make a scene; use it to differentiate changing/unchanging parts of view.
    scene = obj_new('idlgrscene')
    scene->add, view

    win = obj_new('idlgrwindow', dimensions=[400,400], $
        title='Instancing Test', renderer=keyword_set(r))

    if keyword_set(noi) then begin

        ; Spin the changing model.
        for i = 0,360 do begin
            changing_model->rotate, [0,1,0], 1
            win->draw, view, /draw_instance
        endfor

    endif else begin

        ; Remove the changing model from the rendered view.
        changing_model->setproperty, hide=1

        ; Create an instance of the remaining portion of the view.
        win->draw, scene, create_instance=1

        ; Hide the unchanging objects.
        unchanging_model->setproperty, hide=1

        ; Reveal the changing model.
        changing_model->setproperty, hide=0

        ; Set the view object's TRANSPARENT property. This ensures that we
        ; will not erase the instance data (the unchanging part of the scene)
        ;when drawing the changing model.
        view->setproperty, /transparent

        ; Spin the changing model.
        for i = 0,360 do begin
            changing_model->rotate, [0,1,0], 1
            win->draw, view, /draw_instance
        endfor

        ; After the drawing loop is done, ensure nothing is hidden,
        ; and that the view erases as it did before.
        unchanging_model->setproperty, hide=0
        view->setproperty, /transparent
    endelse
end