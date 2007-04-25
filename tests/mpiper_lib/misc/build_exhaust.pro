pro build_exhaust
    compile_opt strictarr
    on_error, 2
    p1 = [2, 0, 0]
    p2 = [5, 10, 0]
    p = [[p1], [p2]]
    mesh_obj, 6, vertex, poly, p, p1 = 361, p2 = [0, 0, 0], p3 = [0, 1, 0], $
        p4 = 0, p5 = 2*!dpi, /closed
    omodel = obj_new('idlgrmodel')
    ndims = size(vertex, /dimensions)
    vertex += randomn(seed, ndims[0], ndims[1])*1.e-2
    ostipple = stipple_obj()
    opoly = obj_new('idlgrpolygon', vertex, poly = poly, $
        style = 2, color = [255, 255, 255], shading = 1, $
        emission = [255, 0, 0])
    opolymodel = obj_new('idlgrmodel')
    opolymodel->add, opoly
    omodel->add, opolymodel
    opolymodel2 = obj_new('idlgrmodel')
    opolymodel2->scale, .5, 1.5, .5
    opolymodel2->rotate, [0, 1, 0], 73.
    omodel->add, opolymodel2
    opolymodel2->add, opolymodel, /alias
    opolymodel3 = obj_new('idlgrmodel')
    opolymodel3->scale, .75, 1.25, .75
    opolymodel3->add, opolymodel, /alias
    opolymodel3->rotate, [0, 1, 0], 23.
    omodel->add, opolymodel3
    image = bytarr(4, 256, 256)
    redplane = replicate(1B, 256) # Reverse(Bindgen(256)/2 + 150b)
    image[0, *, *] = redplane
    image[1, *, *] = redplane
    oimage = obj_new('idlgrimage', image, transform_mode = 1)
    vertexx = reform(vertex[0, *])
    vertexy = reform(vertex[1, *])
    minvertexx = min(vertexx, max = maxvertexx)
    minvertexy = min(vertexy, max = maxvertexy)
    normalizedx = (vertexx - minvertexx)/(maxvertexx - minvertexx)
    normalizedy = (vertexy - minvertexy)/(maxvertexy - minvertexy)
    texturecoords = transpose([[normalizedx], [normalizedy]])
    opoly->setproperty, texture_map = oimage, $
        texture_coord = texturecoords
    xobjview, omodel, tlb = tlb, background = [0, 0, 0], xsize = 768, ysize=768
    newimage = long(image) + randomn(seed, 4, 256, 256)
    highblue = where(abs(newimage[2, *, *]) gt 2, nhighblue, $
        complement = lowblue, ncomplement = nlowblue)
    if (nhighblue ne 0) then begin
        for i = 0, 2 do begin
            planeimage = reform(newimage[i, *, *], 256l*256)
            planeimage[highblue] = 255
            newimage[i, *, *] = reform(planeimage, 256, 256)
        endfor
    endif
    if (nlowblue ne 0) then begin
        planeimage = reform(newimage[2, *, *], 256l*256)
        planeimage[lowblue] = 0
        newimage[2, *, *] = reform(planeimage, 256, 256)
    endif
    for i = 0, 511 do begin
        newvertex = vertex + randomn(seed, ndims[0], ndims[1])*.2
        opoly->setproperty, data = newvertex
        newimage <= 255b
        oimage->setproperty, data = newimage
        newimage = shift(newimage, 0, 0, 10)
        xobjview_rotate, [1, 0, 1], 1
    endfor
end
