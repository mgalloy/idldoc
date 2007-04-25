;-----------------------------------------------------------------------------
;
;   PSG_CREATE_SURFACE_VIEW - This function is used to build an object
;   graphics hierarchy based on a surface object.  The hierarchy is
;   returned to the calling program.
;
function psg_create_surface_view, zdata, $
    make_default_axes=axesOn, $
    make_default_lights=lightsOn, $
    prefix=prefix, $
    reset=reset

    compile_opt idl2

    ; Reserve namespace.
    prefix = n_elements(prefix) eq 0 ? 'psg_' : prefix

    ; Create the objects needed to build the object graphics hierarchy.
    oView = obj_new('IDLgrView', $
        color=[255,255,255], $
        name=prefix+'view')
    oModel = obj_new('IDLgrModel', $
        name=prefix+'surfacemodel')
    oSurface = obj_new('IDLgrSurface', zdata, $
        color=[255,0,0], $
        name=prefix+'surface')

    ; Build the object graphics hierarchy.
    oModel->Add, oSurface
    oView->Add, oModel

    ; Retrieve the x, y & z ranges from the surface object.
    oSurface->GetProperty, xrange=xr, yrange=yr, zrange=zr

    ; Calculate a set of scaling factors to scale the data from their
    ; original ranges to the unit cube.
    xs = norm_coord(xr)
    ys = norm_coord(yr)
    zs = norm_coord(zr)

    ; Subtract 0.5 from the offsets so the data are positioned at the
    ; center of the view volume.
    xs[0] = xs[0] - 0.5
    ys[0] = ys[0] - 0.5
    zs[0] = zs[0] - 0.5

    ; Apply the scaling factors to the data in the surface object.
    oSurface->SetProperty, xcoord_conv=xs, ycoord_conv=ys, zcoord_conv=zs

    ; Rotate the model to a standard view.
    oModel->Rotate, [1,0,0], -90
    oModel->Rotate, [0,1,0], 30
    oModel->Rotate, [1,0,0], 30

    ; If the make_default_axes keyword is set, then create axis
    ; objects for the three coordinate axes.
    if keyword_set(axesOn) then begin

        oXAxis = obj_new('IDLgrAxis', $
            direction=0, $
            color=[0,0,0], $
            range=xr, $
            location=[xr[0], yr[0], zr[0]], $
            xcoord_conv=xs, $
            ycoord_conv=ys, $
            zcoord_conv=zs, $
            hide=1, $
            name=prefix+'xaxis')
        oYAxis = obj_new('IDLgrAxis', $
            direction=1, $
            color=[0,0,0], $
            range=yr, $
            location=[xr[0], yr[0], zr[0]], $
            xcoord_conv=xs, $
            ycoord_conv=ys, $
            zcoord_conv=zs, $
            hide=1, $
            name=prefix+'yaxis')
        oZAxis = obj_new('IDLgrAxis', $
            direction=2, $
            color=[0,0,0], $
            range=zr, $
            location=[xr[0], yr[1], zr[0]], $
            xcoord_conv=xs, $
            ycoord_conv=ys, $
            zcoord_conv=zs, $
            hide=1, $
            name=prefix+'zaxis')

        ; Add the axes to the model.
        oModel->Add, [oXAxis, oYAxis, oZAxis]

    endif ; axis objects

    ; If the make_default_lights keyword is set, then create two light
    ; objects, an ambient source & a positional source.
    if keyword_set(lightsOn) then begin

        ; Make two light objects + a model for them.
        oLight1 = obj_new('IDLgrLight', $
            type=0, $
            intensity=0.4, $
            name=prefix+'light1')
        oLight2 = obj_new('IDLgrLight', $
            type=1, $
            location=[1,1,1], $
            name=prefix+'light2')
        oLightModel = obj_new('IDLgrModel', $
            name=prefix+'lightmodel')

        ; Add the light objects + model to the OGH.
        oLightModel->Add, [oLight1, oLight2]
        oView->Add, oLightModel

    endif ; light objects

    ; Use default orientation.
    if keyword_set(reset) then oModel->Reset

    ; Return the view object reference.
    return, oView

end
