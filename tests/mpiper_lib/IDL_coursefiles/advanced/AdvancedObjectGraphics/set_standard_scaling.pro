;+
; Scales data contained in an atom to fit within the default view volume.
;
; @param atom {in}{type=object reference} A graphics atom object reference.
; @uses norm_coord
; @history 2002-09-25: Changed the way zcoord_conv is set.
;
; @author Mark Piper, 2002
; @copyright RSI
;-
pro set_standard_scaling, atom

    if obj_isa(atom, 'idlgrgraphic') eq 0 then begin
        message, 'Input needs to be a graphics atom object.', /info
        return
    endif

    atom->getproperty, xrange=xr, yrange=yr, zrange=zr

    xs = norm_coord(xr)
    ys = norm_coord(yr)

    xs[0] = xs[0] - 0.5
    ys[0] = ys[0] - 0.5

    atom->setproperty, xcoord_conv=xs, ycoord_conv=ys

    ; Are the data 3D?
    if max(zr) ne min(zr) then begin
        zs = norm_coord(zr)
        zs[0] = zs[0] - 0.5
        atom->setproperty, zcoord_conv=zs
    endif

end
