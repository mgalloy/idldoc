;+
; Makes the map grid.
;-
pro map_addpolyline, label, glon, glat, map, omodel, ocontainer, ofont, $
    longitude=longitude
    compile_opt idl2

    longitude = keyword_set(longitude)

    ; Transform coordinates from lat/lon to Cartesian x/y.
    griduv = map_proj_forward(glon, glat, map=map, polylines=gpoly)
    if n_elements(griduv) lt 2 then return

    if label ne '' then begin
        olabel = obj_new('idlgrtext', label, $
            align = (longitude ? 0.5 : 1), $
            font=ofont, $
            vertical_align=0.5)
        ocontainer->add, olabel
    endif

    ; Create the polyline.
    omodel->add, obj_new('idlgrpolyline', griduv, $
        polyline=gpoly, $
        label_obj=olabel, $
        label_offset = (longitude ? 0.35 : 0), $
        /use_label_orientation, $
        /use_text_align)
end


;+
; An example of using MAP_PROJ_FORWARD to display map projection
; information with Object Graphics.
;-
pro map_proj_forward_ex
    compile_opt idl2

    ; Create a Goodes Homolosine map projection.
    map = map_proj_init(19)

    ; Make a graphics tree.
    omodel = obj_new('idlgrmodel')
    ocontainer = obj_new('idl_container')
    ofont = obj_new('idlgrfont', size=4)
    ocontainer->add, ofont
    deg = string(176B)

    ; Parallels.
    glon = findgen(361) - 180.0
    latitude = indgen(11)*15 - 5
    for i = 0, n_elements(latitude)-1 do begin
        lat = latitude[i]
        glat = replicate(lat, 361)
        label = lat eq 0 ? 'Equ' : $ ; nice trick here.
            strtrim(abs(lat),2) + deg + (['N','S'])[lat lt 0]
        map_addpolyline, label, glon, glat, map, omodel, ocontainer, ofont
    endfor

    ; Meridians.
    glat = findgen(181) - 90.0
    longitude = [(findgen(18) - 9.0)*20.0, -179.999, -20.001, -100.001, $
        -40.001, 80.001]
    for i = 0, n_elements(longitude)-1 do begin
        lon = longitude[i]
        glon = replicate(lon, 181)
        label = strtrim(round(abs(lon)),2) + deg
        if (lon mod 180) ne 0 then $
            label = label + (['E','W'])[lon lt 0]
        if lon ne fix(lon) then label = ''
        map_addpolyline, label, glon, glat, map, omodel, ocontainer, $
            ofont, /longitude
    endfor

    xobjview, omodel, scale=0.9, /block

    obj_destroy, [omodel, ocontainer]
end