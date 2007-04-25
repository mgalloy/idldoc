;+
; Creates an object tree based on a surface object.
;
; @param data {in} A 2D array to be displayed as a surface.
; @returns A view object reference.
; @keyword prefix {in} A string to be used as a prefix on the name property
;   for each object in the tree.
; @keyword standard_orientation {in}{type=boolean} Set to call the helper
;   routine set_standard_orientation.
; @keyword standard_scaling {in}{type=boolean} Set to call the helper
;   routine set_standard_scaling.
; @uses set_standard_scaling, set_standard_orientation
;
; @author Mark Piper, 2002
; @copyright RSI
;-
function create_surface_view, data, $
    prefix=prefix, $
    standard_orientation=orient, $
    standard_scaling=scaling

    compile_opt idl2

    ; Supply missing input data.
    if n_elements(data) eq 0 then data=dist(30)

    ; Reserve namespace.
    prefix = n_elements(prefix) eq 0 ? '' : prefix

    ; Create view, model & surface objects.
    v = obj_new('idlgrview', name=prefix+'view')
    m = obj_new('idlgrmodel', name=prefix+'model')
    s = obj_new('idlgrsurface', data, name=prefix+'surface')

    ; Build the object tree.
    v->add, m
    m->add, s

    ; Set scaling and orientation.
    if keyword_set(scaling) then set_standard_scaling, s
    if keyword_set(orient) then set_standard_orientation, m

    ; Return the view object.
    return, v
end
