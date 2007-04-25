;-----------------------------------------------------------------------------
;+ 
; This function is used to build an Object Graphics hierarchy (OGH)
; based on a surface object. Objects in the hierarchy can be
; accessed with the getbyname method.
;
; @returns The topmost container (a view object reference) in the
;   Object Graphics hierarchy.
;
; @param zdata {in}{optional}{type=float} A 2D array of values to be
;   displayed as a surface.
; @keyword make_default_axes {type=boolean} Set this keyword to create
;   axes that can be displayed with the surface. By default, the axes
;   are hidden.
; @keyword make_default_lights {type=boolean} Set this keyword to create
;   two lights to illuminate the surface. By default, one ambient and
;   one positional light source are created.
; @keyword prefix {type=string} Set this keyword to a string that will
;   prefix the name property of each object in the hierarchy. The
;   default is a null string.
; @keyword reset {type=boolean} Set this keyword to use the default
;   orientation of the surface's model object; i.e., a 4x4 identity
;   matrix.
;
; @requires IDL 5.2 or greater
; @author Mark Piper, 2001
; @history 2003-04-08: Added better comments!
; @copyright RSI
;-
function make_surface_view, zdata, $
                            make_default_axes=axes_on, $
                            make_default_lights=lights_on, $
                            prefix=prefix, $
                            reset=reset
    compile_opt idl2

    ;; If no data are passed, make some.
    if n_params() eq 0 then zdata = dist(30)

    ;; Reserve namespace.
    prefix = n_elements(prefix) eq 0 ? '' : prefix

    ;; Create the objects needed to build the object graphics hierarchy.
    v = obj_new('idlgrview', $
                color=[255,255,255], $
                name=prefix+'view')
    m = obj_new('idlgrmodel', $
                name=prefix+'surfacemodel')
    s = obj_new('idlgrsurface', zdata, $
                color=[255,0,0], $
                name=prefix+'surface')

    ;; Build the OGH.
    m->add, s
    v->add, m

    ;; Retrieve the x, y & z ranges from the surface object.
    s->getproperty, xrange=xr, yrange=yr, zrange=zr

    ;; Calculate a set of scaling factors to scale the data from their
    ;; original ranges to the unit cube.
    xs = norm_coord(xr)
    ys = norm_coord(yr)
    zs = norm_coord(zr)

    ;; Subtract 0.5 from the offsets so the data are positioned at the
    ;; center of the view volume.
    xs[0] = xs[0] - 0.5
    ys[0] = ys[0] - 0.5
    zs[0] = zs[0] - 0.5

    ;; Apply the scaling factors to the data in the surface object.
    s->setproperty, xcoord_conv=xs, ycoord_conv=ys, zcoord_conv=zs

    ;; Rotate the model to a standard view.
    m->rotate, [1,0,0], -90
    m->rotate, [0,1,0], 30
    m->rotate, [1,0,0], 30

    ;; If the make_default_axes keyword is set, then create axis
    ;; objects for the three coordinate axes.
    if keyword_set(axes_on) then begin

        xaxis = obj_new('idlgraxis', $
                        direction=0, $
                        color=[0,0,0], $
                        range=xr, $
                        location=[xr[0], yr[0], zr[0]], $
                        xcoord_conv=xs, $
                        ycoord_conv=ys, $
                        zcoord_conv=zs, $
                        hide=1, $
                        name=prefix+'xaxis')
        yaxis = obj_new('idlgraxis', $
                        direction=1, $
                        color=[0,0,0], $
                        range=yr, $
                        location=[xr[0], yr[0], zr[0]], $
                        xcoord_conv=xs, $
                        ycoord_conv=ys, $
                        zcoord_conv=zs, $
                        hide=1, $
                        name=prefix+'yaxis')
        zaxis = obj_new('idlgraxis', $
                        direction=2, $
                        color=[0,0,0], $
                        range=zr, $
                        location=[xr[0], yr[1], zr[0]], $
                        xcoord_conv=xs, $
                        ycoord_conv=ys, $
                        zcoord_conv=zs, $
                        hide=1, $
                        name=prefix+'zaxis')

        ;; Add the axes to the surface model.
        m->add, [xaxis, yaxis, zaxis]

    endif ; axis objects

    ;; If the make_default_lights keyword is set, then create two light
    ;; objects, an ambient source & a positional source.
    if keyword_set(lights_on) then begin

        light1 = obj_new('idlgrlight', $
                         type=0, $
                         intensity=0.4, $
                         name=prefix+'light1')
        light2 = obj_new('idlgrlight', $
                         type=1, $
                         location=[1,1,1], $
                         name=prefix+'light2')
        lightmodel = obj_new('idlgrmodel', $
                             name=prefix+'lightmodel')

        ;; Add the light objects + model to the OGH.
        lightmodel->add, [light1, light2]
        v->add, lightmodel

    endif ; light objects

    ;; Use default orientation.
    if keyword_set(reset) then m->reset

    ;; Return the view object reference.
    return, v

end
