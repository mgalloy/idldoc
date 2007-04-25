;+
; An example of "stitching" in Object Graphics and how to correct it.
;
; @uses idlexlightmodel class, set_standard_orientation,
;   set_standard_scaling
;
; @author Mark Piper, 2002
; @copyright RSI
;-
pro depth_offset_test
    compile_opt idl2

    ; Define some data.
    data = dist(30)

    ; Build two object trees based on surface objects that display the data.
    oview1 = create_surface_view(data, /standard_scaling, $
        /standard_orientation)
    oview2 = create_surface_view(data, /standard_scaling, $
        /standard_orientation)

    ; Move the viewports of the two views so they'll be side by side
    ; in a scene.
    oview1->setproperty, units=3, dimensions=[0.5,1.0], location=[0,0]
    oview2->setproperty, units=3, dimensions=[0.5,1.0], location=[0.5,0]

    ; Create a scene & add the two views to it.
    oscene = obj_new('idlgrscene')
    oscene->add, [oview1, oview2]

    ; Create a wire surface & add it to the first object tree.
    omesh1 = obj_new('idlgrsurface', data)
    set_standard_scaling, omesh1
    omodel1 = oview1->getbyname('model')
    omodel1->add, omesh1

    ; Create a second wire surface & add it to the second object tree.
    omodel2 = oview2->getbyname('model')
    omesh2 = obj_new('idlgrsurface', data)
    set_standard_scaling, omesh2
    omodel2->add, omesh2

    ; Make the first surface shaded.
    osurface1 = oview1->getbyname('model/surface')
    osurface1->setproperty, color=[255,200,0], style=2

    ; Make the second surface shaded, but also set the depth_offset keyword
    ; to a value of 1.
    osurface2 = oview2->getbyname('model/surface')
    osurface2->setproperty, color=[255,200,0], style=2, depth_offset=1

    ; Create lighting for the two views.
    olightmodel1 = obj_new('idlexlightmodel', /default_lights)
    olightmodel2 = obj_new('idlexlightmodel', /default_lights)
    oview1->add, olightmodel1
    oview2->add, olightmodel2

    ; Create a title for each view.
    otext1 = obj_new('idlgrtext', 'Without Depth Offset', $
        color=[0,0,200], location=[0,0.7,0], alignment=0.5)
    otext2 = obj_new('idlgrtext', 'With Depth Offset', $
        color=[0,0,200], location=[0,0.7,0], alignment=0.5)

    ; Because the light models are stationary, add the text to them.
    olightmodel1->add, otext1
    olightmodel2->add, otext2

    ; Create a window & render the scene to it.
    owindow = obj_new('idlgrwindow', retain=2, dimensions=[800,400], $
        graphics_tree=oscene, title='Depth Offset Test')
    owindow->draw
end