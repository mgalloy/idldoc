; TODO
;     red, green, blue changes brightness to 255 (but not cube's brightness)
;     make faster: make_scale, make_cube (?)

; Convert a single rgb triplet to an xy point in the cube array.
function cw_color_cube_rgb_to_xy, rgb, xsize=xsize, ysize=ysize
    compile_opt idl2, hidden
    on_error, 2

    r_vec = [ - sqrt(3.0) / 2.0, - 1.0 / 2.0 ]
    g_vec = [ 0.0, 1.0 ]
    b_vec = [ sqrt(3.0) / 2.0, - 1.0 / 2.0]

    x = r_vec[0] * rgb[0] + g_vec[0] * rgb[1] + b_vec[0] * rgb[2]
    y = r_vec[1] * rgb[0] + g_vec[1] * rgb[1] + b_vec[1] * rgb[2]

    x = long((x / 255. + 1) * long(xsize - 4) / 2.)
    y = long((y / 255. + 1) * long(ysize - 4) / 2.)

    return, [x, y]
end


; Create the cube -- needs to be done only once.  Use cw_color_cube_set_cube
; to change the cube's brightness.
function cw_color_cube_make_cube, factor=factor, xsize=xsize, ysize=ysize
    compile_opt idl2, hidden
    on_error, 2

    ; Just need to get the colors out of the widget system
    tlb = widget_base()
    sys_colors = widget_info(tlb, /system_colors)
    widget_control, tlb, /destroy

    if (n_elements(xsize) eq 0) then xsize = 400
    if (n_elements(ysize) eq 0) then ysize = 400

    if (n_elements(factor) eq 0) then $
        factor = fix(400 / (xsize > ysize))

    ret = bytarr(3, xsize, ysize, /nozero)
    ret[0, 0, 0] = reform(replicate(sys_colors.face_3d[0], xsize, ysize), $
        1, xsize, ysize)
    ret[1, 0, 0] = reform(replicate(sys_colors.face_3d[1], xsize, ysize), $
        1, xsize, ysize)
    ret[2, 0, 0] = reform(replicate(sys_colors.face_3d[2], xsize, ysize), $
        1, xsize, ysize)

    r_vec = [ - sqrt(3.0) / 2.0, - 1.0 / 2.0 ]
    g_vec = [ 0.0, 1.0 ]
    b_vec = [ sqrt(3.0) / 2.0, - 1.0 / 2.0]

    b = factor * indgen(ceil(256. / factor))

    ; Could call cw_color_cube_rgb_to_xy individually for each [r, g, b], but
    ; that would be really slow.
    for r = 0, 255, factor do $
        for g = 0, 255, factor do begin
            x = r_vec[0] * r + g_vec[0] * g + b_vec[0] * b
            y = r_vec[1] * r + g_vec[1] * g + b_vec[1] * b

            x = long((x / 255. + 1) * long(xsize - 4) / 2.)
            y = long((y / 255. + 1) * long(ysize - 4) / 2.)

            indices = x * 3L + y * 3L * xsize
            ret[indices] = r
            ret[indices + 1] = g
            ret[indices + 2] = b
        endfor

    return, ret
end


; Change the cube's values to compensate for a brightness change.
; (*pstate).cube holds a pristine copy of the cube's data.
pro cw_color_cube_set_cube, pstate
    compile_opt idl2, hidden
    on_error, 2

    ; Create a mask for data values inside the cube.
    mask = bytarr(3, (*pstate).image_xsize, (*pstate).image_ysize)
    mask[0, *, *] = *(*pstate).mask
    mask[1, *, *] = *(*pstate).mask
    mask[2, *, *] = *(*pstate).mask

    newCube = *(*pstate).cube * (1. - mask * (1. - (*pstate).brightness / 255.))
    (*pstate).oCubeImage->setProperty, data=byte(temporary(newCube))
end


; Determines if the point defined by xy is inside the cube.
function cw_color_cube_inside, pstate, xy
    compile_opt idl2, hidden
    on_error, 2

    return, (*pstate).oROI->containsPoints(xy[0], $
        xy[1] - (*pstate).xpad - (*pstate).bar_height - 2) eq 1
end


; Return the scale of colors from [0, 0, 0] to (*pstate).current_color by
; brightness values (we check to make sure current_color has a coordinate with
; value 255 and scale if doesn't).
function cw_color_cube_make_scale, pstate
    compile_opt idl2, hidden
    on_error, 2

    rgb = (*pstate).current_color

    scale = bytarr(3, (*pstate).bar_width, (*pstate).ysize)

    maxRGB = float(max(rgb))

    for bar = 0, (*pstate).ysize - 1 do begin
        scale[0, 0:(*pstate).bar_width-1, bar] = $
            byte(rgb[0] * 255 * float(bar) / maxRGB / ((*pstate).ysize - 1))
        scale[1, 0:(*pstate).bar_width-1, bar] = $
            byte(rgb[1] * 255 * float(bar) / maxRGB / ((*pstate).ysize - 1))
        scale[2, 0:(*pstate).bar_width-1, bar] = $
            byte(rgb[2] * 255 * float(bar) / maxRGB / ((*pstate).ysize - 1))
        ;scale[0, 0, bar] = reform(replicate(temporary(byte(rgb[0] * 255 * float(bar) / maxRGB / ((*pstate).ysize - 1))), (*pstate).bar_width), 1, (*pstate).bar_width, 1)
        ;scale[1, 0, bar] = reform(replicate(temporary(byte(rgb[1] * 255 * float(bar) / maxRGB / ((*pstate).ysize - 1))), (*pstate).bar_width), 1, (*pstate).bar_width, 1)
        ;scale[2, 0, bar] = reform(replicate(temporary(byte(rgb[2] * 255 * float(bar) / maxRGB / ((*pstate).ysize - 1))), (*pstate).bar_width), 1, (*pstate).bar_width, 1)
    endfor

    sys_colors = widget_info((*pstate).draw, /system_colors)

    ; Left-hand side
    scale[0, 0, 0] = reform(replicate(sys_colors.shadow_3d[0], $
        (*pstate).ysize), 1, 1, (*pstate).ysize)
    scale[1, 0, *] = reform(replicate(sys_colors.shadow_3d[1], $
        (*pstate).ysize), 1, 1, (*pstate).ysize)
    scale[2, 0, *] = reform(replicate(sys_colors.shadow_3d[2], $
        (*pstate).ysize), 1, 1, (*pstate).ysize)

    ; Top
    scale[0, *, (*pstate).ysize - 1] = sys_colors.shadow_3d[0]
    scale[1, *, (*pstate).ysize - 1] = sys_colors.shadow_3d[1]
    scale[2, *, (*pstate).ysize - 1] = sys_colors.shadow_3d[2]

    ; Right-hand side
    scale[0, (*pstate).bar_width - 1, *] = sys_colors.light_edge_3d[0]
    scale[1, (*pstate).bar_width - 1, *] = sys_colors.light_edge_3d[1]
    scale[2, (*pstate).bar_width - 1, *] = sys_colors.light_edge_3d[2]

    ; Bottom
    scale[0, 0, 0] = reform(replicate(sys_colors.light_edge_3d[0], $
        (*pstate).bar_width), 1, (*pstate).bar_width, 1)
    scale[1, 0, 0] = reform(replicate(sys_colors.light_edge_3d[1], $
        (*pstate).bar_width), 1, (*pstate).bar_width, 1)
    scale[2, 0, 0] = reform(replicate(sys_colors.light_edge_3d[2], $
        (*pstate).bar_width), 1, (*pstate).bar_width, 1)

    return, scale
end


pro cw_color_cube_set_scale, pstate
    compile_opt idl2, hidden
    on_error, 2

    scale = cw_color_cube_make_scale(pstate)
    (*pstate).oScaleImage->setProperty, data=scale
end


pro cw_color_cube_set_rgb_sliders, pstate
    compile_opt idl2, hidden
    on_error, 2

    val = fix((*pstate).current_color * long((*pstate).brightness) / 255.)

    widget_control, (*pstate).red, set_value=val[0]
    widget_control, (*pstate).green, set_value=val[1]
    widget_control, (*pstate).blue, set_value=val[2]
end


pro cw_color_cube_set_brightness_slider, pstate
    compile_opt idl2, hidden
    on_error, 2

    widget_control, (*pstate).brightnessSlider, set_value=(*pstate).brightness
end


pro cw_color_cube_set_current_color_tab, pstate
    compile_opt idl2, hidden
    on_error, 2

    (*pstate).oViewCurrent->setProperty, $
        color=fix((*pstate).current_color * long((*pstate).brightness) / 255.)
    (*pstate).oWindow->draw, (*pstate).oScene
end


pro cw_color_cube_event_pro, event
    compile_opt idl2, hidden
    on_error, 2

    widget_control, widget_info(event.handler, /child), get_uvalue=pstate
    ret = cw_color_cube_event_func(event)

    if (size(ret, /type) eq 8) then $
        call_procedure, (*pstate).event_pro, ret
end



pro cw_color_cube_move_circle, pstate
    compile_opt idl2, hidden
    on_error, 2

    xy = cw_color_cube_rgb_to_xy((*pstate).current_color, $
        xsize=(*pstate).image_xsize, ysize=(*pstate).image_ysize)
    old_xy = (*pstate).cur_circle_pos
    (*pstate).oCircle->translate, xy[0] - old_xy[0], xy[1] - old_xy[1], 0
    (*pstate).cur_circle_pos = xy
end


pro cw_color_cube_move_bar, pstate
    compile_opt idl2, hidden
    on_error, 2

    old_ht = (*pstate).cur_bar_pos
    (*pstate).cur_bar_pos = (*pstate).brightness * (*pstate).ysize / 255.

    (*pstate).oBarModel->translate, 0, $
                (*pstate).cur_bar_pos - old_ht, 0
end


pro cw_color_cube_draw_event, event
    compile_opt idl2, hidden
    on_error, 2

    widget_control, widget_info(event.handler, /child), get_uvalue=pstate

    case event.type of
    0 : begin ; Button press
            (*pstate).down = 1
            if ((event.x lt (*pstate).image_xsize) and $
                (event.y gt (*pstate).bar_height) and $
                cw_color_cube_inside(pstate, [event.x, event.y])) then begin

                xy = [event.x, event.y - (*pstate).bar_height - (*pstate).ypad]
                rgb = reform((*(*pstate).cube)[*, xy[0], xy[1]], 3)

                (*pstate).current_color = rgb
                cw_color_cube_move_circle, pstate
                cw_color_cube_set_rgb_sliders, pstate
                cw_color_cube_set_current_color_tab, pstate
                cw_color_cube_set_scale, pstate
            endif else (*pstate).return_event = 0
        end
    1 : begin ; Button release
            (*pstate).down = 0
            (*pstate).return_event = 0
        end
    2 : begin ; Motion
            if (not (*pstate).down) then begin
                (*pstate).return_event = 0
                break
            endif

            if ((event.x lt (*pstate).image_xsize) and $
                (event.y gt (*pstate).bar_height) and $
                cw_color_cube_inside(pstate, [event.x, event.y])) then begin

                xy = [(event.x > 0) < ((*pstate).image_xsize - 1), $
                    ((event.y - (*pstate).bar_height - (*pstate).ypad) > 0) < $
                        ((*pstate).image_ysize - 1)]
                rgb = reform((*(*pstate).cube)[*, xy[0], xy[1]], 3)

                (*pstate).current_color = rgb
                cw_color_cube_move_circle, pstate
                cw_color_cube_set_rgb_sliders, pstate
                cw_color_cube_set_current_color_tab, pstate
                cw_color_cube_set_scale, pstate
            endif
        end
    3 : ; Scroll -- shouldn't happen
    4 : begin ; Expose
            (*pstate).return_event = 0
            (*pstate).oWindow->draw, (*pstate).oScene
        end
    endcase
end


function cw_color_cube_event_func, event
    compile_opt idl2, hidden
    on_error, 2

    widget_control, widget_info(event.handler, /child), get_uvalue=pstate
    widget_control, event.id, get_uvalue=uval

    (*pstate).return_event = 1

    case uval of
    'draw' : cw_color_cube_draw_event, event
    'red' : begin
            (*pstate).current_color[0] = event.value
            (*pstate).brightness = max((*pstate).current_color)
            cw_color_cube_set_brightness_slider, pstate
            cw_color_cube_set_cube, pstate
            cw_color_cube_move_circle, pstate
            cw_color_cube_set_current_color_tab, pstate
            cw_color_cube_set_scale, pstate
        end
    'green' : begin
            (*pstate).current_color[1] = event.value
            (*pstate).brightness = max((*pstate).current_color)
            cw_color_cube_set_brightness_slider, pstate
            cw_color_cube_set_cube, pstate
            cw_color_cube_move_circle, pstate
            cw_color_cube_set_current_color_tab, pstate
            cw_color_cube_set_scale, pstate
        end
    'blue' : begin
            (*pstate).current_color[2] = event.value
            (*pstate).brightness = max((*pstate).current_color)
            cw_color_cube_set_brightness_slider, pstate
            cw_color_cube_set_cube, pstate
            cw_color_cube_move_circle, pstate
            cw_color_cube_set_current_color_tab, pstate
            cw_color_cube_set_scale, pstate
        end
    'brightness' : begin
            (*pstate).brightness = event.value
            cw_color_cube_set_cube, pstate
            cw_color_cube_set_rgb_sliders, pstate
            cw_color_cube_move_bar, pstate
            cw_color_cube_set_current_color_tab, pstate
        end
    endcase

    (*pstate).oWindow->draw, (*pstate).oScene

    if ((*pstate).return_event) then $
        return, { cw_color_cube, id:event.handler, top:event.top, $
            handler:event.handler, $
            value:(*pstate).current_color * float((*pstate).brightness) / 255. } $
    else return, 0
end


; Cleanup pointer and object references.  The notify_realize keyword to
; widget_info(tlb, /child) is set to this procedure, so id refers to it (id
; also stores the pstate in its uvalue).
pro cw_color_cube_cleanup, id
    compile_opt idl2, hidden
    on_error, 2

    widget_control, id, get_uvalue=pstate

    obj_destroy, [ (*pstate).oWindow, (*pstate).oROI, (*pstate).oScene ]
    ptr_free, (*pstate).cube, (*pstate).mask
    ptr_free, pstate
end


pro cw_color_cube_set_value, id, value
    compile_opt idl2, hidden
    on_error, 2

    widget_control, widget_info(id, /child), get_uvalue=pstate

    brightness = max(value)
    xy = cw_color_cube_rgb_to_xy(value, xsize=(*pstate).xsize, $
        ysize=(*pstate).ysize)
    height = brightness * (*pstate).ysize / 255.

    cw_color_cube_move_circle, pstate
    cw_color_cube_move_bar, pstate
    cw_color_cube_set_rgb_sliders, pstate
    cw_color_cube_set_brightness_slider, pstate
end


function cw_color_cube_get_value, id
    compile_opt idl2, hidden
    on_error, 2

    widget_control, widget_info(id, /child), get_uvalue=pstate

    return, (*pstate).current_color * float((*pstate).brightness) / 255.
end


pro cw_color_cube_realize, id
    compile_opt idl2, hidden
    on_error, 2

    widget_control, widget_info(id, /child), get_uvalue=pstate

    widget_control, (*pstate).draw, get_value=oWindow
    (*pstate).oWindow = oWindow

    sys_colors = widget_info((*pstate).draw, /system_colors)

    (*pstate).oScene = obj_new('IDLgrScene', color=sys_colors.face_3d)

    (*pstate).oViewInit = obj_new('IDLgrView', color=(*pstate).init_color, $
        location=[0, 0], $
        dimensions=[(*pstate).image_xsize / 2, (*pstate).bar_height], $
        viewplane_rect=[0, 0, (*pstate).image_xsize / 2, (*pstate).bar_height])
    (*pstate).oViewCurrent = obj_new('IDLgrView', $
        color=(*pstate).current_color, $
        location=[(*pstate).image_xsize / 2, 0], $
        dimensions=[(*pstate).image_xsize / 2, (*pstate).bar_height], $
        viewplane_rect=[0, 0, (*pstate).image_xsize / 2, (*pstate).bar_height])
    (*pstate).oViewScale = obj_new('IDLgrView', $
        location=[(*pstate).image_xsize + (*pstate).xpad, 0], $
        dimensions=[(*pstate).bar_width, (*pstate).ysize], $
        viewplane_rect=[0, 0, (*pstate).bar_width, (*pstate).ysize])
    (*pstate).oViewCube = obj_new('IDLgrView', color=sys_colors.face_3d, $
        location=[0, (*pstate).bar_height + (*pstate).ypad], $
        dimensions=[(*pstate).image_xsize, (*pstate).image_ysize], $
        viewplane_rect=[0, 0, (*pstate).image_xsize, (*pstate).image_ysize])

    (*pstate).oScene->add, (*pstate).oViewInit
    (*pstate).oScene->add, (*pstate).oViewCurrent
    (*pstate).oScene->add, (*pstate).oViewScale
    (*pstate).oScene->add, (*pstate).oViewCube

    oModel = obj_new('IDLgrModel')
    (*pstate).oViewInit->add, oModel

    oLinesInit = obj_new('IDLgrPolyline', $
        [0, 0, (*pstate).image_xsize / 2 - 1], $
        [0, (*pstate).bar_height - 1, (*pstate).bar_height - 1], $
        color=sys_colors.shadow_3d)
    oModel->add, oLinesInit
    oLinesInit = obj_new('IDLgrPolyline', $
        [0, (*pstate).image_xsize / 2 - 1, (*pstate).image_xsize / 2 - 1], $
        [0, 0, (*pstate).bar_height - 1], $
        color=sys_colors.light_edge_3d)
    oModel->add, oLinesInit

    oModel = obj_new('IDLgrModel')
    (*pstate).oViewCurrent->add, oModel
    oLinesInit = obj_new('IDLgrPolyline', $
        [0, 0, (*pstate).image_xsize / 2 - 1], $
        [0, (*pstate).bar_height - 1, (*pstate).bar_height - 1], $
        color=sys_colors.shadow_3d)
    oModel->add, oLinesInit
    oLinesInit = obj_new('IDLgrPolyline', $
        [0, (*pstate).image_xsize / 2 - 1, (*pstate).image_xsize / 2 - 1], $
        [0, 0, (*pstate).bar_height - 1], $
        color=sys_colors.light_edge_3d)
    oModel->add, oLinesInit

    oModel = obj_new('IDLgrModel')
    (*pstate).oViewScale->add, oModel
    (*pstate).oScaleImage = obj_new('IDLgrImage', $
        cw_color_cube_make_scale(pstate))
    oModel->add, (*pstate).oScaleImage
    (*pstate).oBarModel = obj_new('IDLgrModel')
    (*pstate).oViewScale->add, (*pstate).oBarModel

    oBar = obj_new('IDLgrPolyline', [0, (*pstate).bar_width-1], [0, 0], $
        [0, 0], color=[255, 255, 0])
    (*pstate).oBarModel->add, oBar

    (*pstate).cur_bar_pos = max((*pstate).current_color) / 255. * $
        ((*pstate).ysize - 1)
    (*pstate).oBarModel->translate, 0, (*pstate).cur_bar_pos, 0

    oModel = obj_new('IDLgrModel')
    (*pstate).cube = ptr_new(cw_color_cube_make_cube(xsize=(*pstate).image_xsize, $
        ysize=(*pstate).image_ysize), /no_copy)
    (*pstate).oViewCube->add, oModel
    (*pstate).oCubeImage = obj_new('IDLgrImage', *(*pstate).cube)
    oModel->add, (*pstate).oCubeImage

    (*pstate).oCircle = obj_new('IDLgrModel')
    (*pstate).oViewCube->add, (*pstate).oCircle
    x = 3 * cos(findgen(11) * 36 * !dtor)
    y = 3 * sin(findgen(11) * 36 * !dtor)
    z = fltarr(11)
    oCirclePoly = obj_new('IDLgrPolyline', x, y, z, color=[255, 255, 0])
    (*pstate).oCircle->add, oCirclePoly

    yellowc = cw_color_cube_rgb_to_xy([255, 255, 0], $
        xsize=(*pstate).image_xsize, ysize=(*pstate).image_ysize)
    redc = cw_color_cube_rgb_to_xy([255, 0, 0], $
        xsize=(*pstate).image_xsize, ysize=(*pstate).image_ysize)

    purplec = cw_color_cube_rgb_to_xy([255, 0, 255], $
        xsize=(*pstate).image_xsize, ysize=(*pstate).image_ysize)
    greenc = cw_color_cube_rgb_to_xy([0, 255, 0], $
        xsize=(*pstate).image_xsize, ysize=(*pstate).image_ysize)

    aquac = cw_color_cube_rgb_to_xy([0, 255, 255], $
        xsize=(*pstate).image_xsize, ysize=(*pstate).image_ysize)
    bluec = cw_color_cube_rgb_to_xy([0, 0, 255], $
        xsize=(*pstate).image_xsize, ysize=(*pstate).image_ysize)

    oModel = obj_new('IDLgrModel')
    (*pstate).oViewCube->add, oModel
    oLine = obj_new('IDLgrPolyline', $
        [redc[0], yellowc[0], greenc[0], aquac[0]], $
        [redc[1], yellowc[1], greenc[1], aquac[1]], $
        color=sys_colors.shadow_3d)
    oModel->add, oLine
    oLine = obj_new('IDLgrPolyline', $
        [redc[0], purplec[0], bluec[0], aquac[0]], $
        [redc[1], purplec[1], bluec[1], aquac[1]], $
        color=sys_colors.light_edge_3d)
    oModel->add, oLine

    (*pstate).oROI = obj_new('IDLanROI', $
        [redc[0], yellowc[0], greenc[0], aquac[0], bluec[0], purplec[0], $
            redc[0]], $
        [redc[1], yellowc[1], greenc[1], aquac[1], bluec[1], purplec[1], $
            redc[1]])

    (*pstate).mask = ptr_new((*pstate).oROI->computeMask(mask_rule=1, $
        dimensions=[(*pstate).image_xsize, (*pstate).image_ysize]) gt 0, /no_copy)

    xy = cw_color_cube_rgb_to_xy((*pstate).init_color, $
        xsize=(*pstate).image_xsize, ysize=(*pstate).image_ysize)
    (*pstate).oCircle->translate, xy[0], xy[1], 0.0
    (*pstate).cur_circle_pos = xy

    oWindow->setCurrentCursor, 'ARROW'
    oWindow->draw, (*pstate).oScene

    cw_color_cube_set_cube, pstate
end


;+
; cw_color_cube
;
; Color selector.
;
; Written by Michael D. Galloy
; Copyright RSI, 2001
;-
function cw_color_cube, parent, $
    bar_height=bar_height, $
    bar_width=bar_width, $
    event_pro=event_pro, $
    font=font, $
    image_xsize=image_xsize, $
    image_ysize=image_ysize, $
    init_color=init_color, $
    uname=uname, $
    uvalue=uvalue, $
    xpad=xpad, $
    ypad=ypad

    compile_opt idl2
    on_error, 2

    if (n_elements(bar_height) eq 0) then bar_height = 10
    if (n_elements(bar_width) eq 0) then bar_width = 10
    if (n_elements(image_xsize) eq 0) then image_xsize = 118
    if (n_elements(image_ysize) eq 0) then image_ysize = 118
    if (n_elements(xpad) eq 0) then xpad = 5
    if (n_elements(ypad) eq 0) then ypad = 8

    xsize = image_xsize + xpad + bar_width
    ysize = image_ysize + ypad + bar_height

    if (n_elements(event_pro) eq 0) then begin
        event_pro = ''
        epro = ''
        efunc = 'cw_color_cube_event_func'
    endif else begin
        epro = 'cw_color_cube_event_pro'
        efunc = ''
    endelse

    if (n_elements(font) eq 0) then font = ''

    if (n_elements(init_color) eq 0) then init_color = [255, 255, 255]

    if (n_elements(uname) eq 0) then uname = ''
    if (n_elements(uvalue) eq 0) then uvalue = ''

    tlb = widget_base(parent, /row, map=0, /base_align_center, $
        event_pro=epro, $
        event_func=efunc, $
        pro_set_value='cw_color_cube_set_value', $
        func_get_value='cw_color_cube_get_value', $
        uname=uname, uvalue=uvalue)
    blank = widget_base(tlb, /column)

    draw = widget_draw(tlb, xsize=xsize, ysize=ysize, $
        /button_events, /motion_events, /expose_events, $
        graphics_level=2, uvalue='draw')

    sliderBase = widget_base(tlb, /column, space=0)
    red = cw_slider(sliderBase, value=init_color[0], minimum=0, maximum=255, $
        /integer, title='Red', font=font, increment=1, uvalue='red', ysize=9)
    green = cw_slider(sliderBase, value=init_color[1], minimum=0, $
        maximum=255, /integer, title='Green', font=font, increment=1, $
        uvalue='green', ysize=9)
    blue = cw_slider(sliderBase, value=init_color[2], minimum=0, maximum=255, $
        /integer, title='Blue', font=font, increment=1, uvalue='blue', ysize=9)

    brightness = cw_slider(sliderBase, value=max(init_color), minimum=0, $
        maximum=255, /integer, title='Brightness', font=font, increment=1, $
        uvalue='brightness', ysize=9)

    state = { $
        cur_circle_pos:[0, 0], $
        cur_bar_pos:0, $
        event_pro:event_pro, $
        draw:draw, $
        down:0, $
        cube:ptr_new(), $
        bar_height:bar_height, bar_width:bar_width, $
        image_xsize:image_xsize, image_ysize:image_ysize, $
        xpad:xpad, ypad:ypad, $
        xsize:xsize, ysize:ysize, $
        oWindow:obj_new(), $
        oCircle:obj_new(), $
        oScene:obj_new(), $
        oCubeImage:obj_new(), $
        oViewInit:obj_new(), $
        oViewCurrent:obj_new(), $
        oViewScale:obj_new(), $
        oBarModel:obj_new(), $
        oScaleImage:obj_new(), $
        oViewCube:obj_new(), $
        oROI:obj_new(), $
        return_event:0, $
        mask:ptr_new(), $
        red:red, green:green, blue:blue, brightnessSlider:brightness, $
        init_color:init_color, $
        current_color:init_color, $
        brightness:max(init_color) $
        }
    pstate = ptr_new(state, /no_copy)
    widget_control, widget_info(tlb, /child), set_uvalue=pstate, $
        kill_notify='cw_color_cube_cleanup'

    ;widget_control, tlb, notify_realize='cw_color_cube_realize'

    widget_control, tlb, map=1
    widget_control, tlb, /realize
    cw_color_cube_realize, tlb

    return, tlb
end