pro clip_ops_execute, oidl, cmd, error=error
    compile_opt strictarr

    error = 0B
    catch, error
    if (error ne 0B) then begin
        catch, /cancel
        error = 1B
        return
    endif

    oidl->execute, cmd
end


function clip_ops_getvar, oidl, var, error=error
    compile_opt strictarr

    error = 0B
    catch, error
    if (error ne 0B) then begin
        catch, /cancel
        error = 1B
        return, -1L
    endif

    image = oidl->getVar(var)
    return, image
end


pro clip_refresh, draw_id, image
    compile_opt strictarr

    sz = size(image, /structure)
    if (sz.n_elements eq 0) then return
    if (sz.n_dimensions lt 2 or sz.n_dimensions gt 3) then return

    wset, draw_id
    erase
    tv, image
end


pro clip_resize, pstate, event
    compile_opt strictarr

    ; query widgets for geometry info
    tlbG = widget_info(event.top, /geometry)

    prompt = widget_info(event.top, find_by_uname='prompt')
    promptG = widget_info(prompt, /geometry)

    commandline = widget_info(event.top, find_by_uname='commandline')

    commandline_base = widget_info(event.top, find_by_uname='commandline_base')
    commandline_baseG = widget_info(commandline_base, /geometry)

    output = widget_info(event.top, find_by_uname='output')
    outputG = widget_info(output, /geometry)

    draw = widget_info(event.top, find_by_uname='draw')

    ; calculate new draw widget, commandline, and output log sizes
    new_draw_xsize =  event.x - 2 * tlbG.xpad
    new_draw_ysize = event.y - 2 * tlbG.ypad - 2 * tlbG.space $
        - outputG.scr_ysize $
        - commandline_baseG.scr_ysize
    new_cl_xsize = event.x - 2 * tlbG.xpad $
        - 2 * commandline_baseG.xpad - commandline_baseG.space $
        - promptG.scr_xsize

    ; set new widget sizes
    widget_control, output, scr_xsize=new_draw_xsize
    widget_control, draw, $
        scr_xsize=new_draw_xsize, $
        scr_ysize=new_draw_ysize
    widget_control, commandline, $
        scr_xsize=new_cl_xsize

    ; refresh graphics
    if (n_elements(*(*pstate).image) ne 0) then begin
        clip_refresh, (*pstate).draw_id, *(*pstate).image
    endif
end

pro clip_event, event
    compile_opt strictarr

    widget_control, event.top, get_uvalue=pstate
    uname = widget_info(event.id, /uname)

    case uname of
    'tlb' : clip_resize, pstate, event
    'commandline' : begin
            widget_control, event.id, get_value=command
            if (n_elements(*(*pstate).commands) eq 0) then begin
                *(*pstate).commands = [command]
            endif else begin
                *(*pstate).commands = [*(*pstate).commands, command]
            endelse

            output = widget_info(event.top, find_by_uname='output')
            widget_control, output, set_value='IDL> ' + command, /append
            widget_control, output, get_value=hist
            widget_control, output, set_text_top_line=(n_elements(hist)-6) > 0

            clip_ops_execute, (*pstate).oidl, command, error=error
            if (~error) then begin
                image = clip_ops_getvar((*pstate).oidl, 'image', error=error)
            endif else begin
                widget_control, output, $
                    set_value='%OPS: error executing command', /append
            endelse

            ; display image
            if (~error) then begin
                *(*pstate).image = image
                clip_refresh, (*pstate).draw_id, image
            endif

            widget_control, event.id, set_value=''
        end
    endcase
end


pro clip_cleanup, tlb
    compile_opt strictarr

    widget_control, tlb, get_uvalue=pstate

    obj_destroy, (*pstate).oidl
    ptr_free, (*pstate).image, (*pstate).commands, pstate
end


pro clip, data
    compile_opt strictarr

    draw_xsize = 700
    draw_ysize = 700

    output_ysize = 6

    tlb = widget_base(title='Command line image processor', /column, $
        /tlb_size_events, uname='tlb')

    commandline_base = widget_base(tlb, /row, xpad=0, uname='commandline_base')
    prompt = widget_label(commandline_base, value='IDL> ', uname='prompt', $
        font='Courier New*bold')
    tlbG = widget_info(tlb, /geometry)
    promptG = widget_info(prompt, /geometry)
    commandline = widget_text(commandline_base, value='', /editable, $
        scr_xsize=draw_xsize - tlbG.space - promptG.scr_xsize, $
        font='Courier New', uname='commandline')

    output = widget_text(tlb, $
        value=['%OPS session starting...', $
        'Variable named "image" is displayed'], $
        scr_xsize=draw_xsize, ysize=output_ysize, /scroll, $
        font='Courier New', uname='output')

    draw = widget_draw(tlb, xsize=draw_xsize, ysize=draw_ysize, uname='draw')

    widget_control, tlb, /realize
    widget_control, draw, get_value=draw_id

    oidl = obj_new('IDL_IDLBridge')

    state = { $
        commands : ptr_new(/allocate_heap), $
        image : ptr_new(/allocate_heap), $
        oidl : oidl, $
        draw_id : draw_id $
    }
    pstate = ptr_new(state, /no_copy)
    widget_control, tlb, set_uvalue=pstate

    xmanager, 'clip', tlb, /no_block, $
        event_handler='clip_event', $
        cleanup='clip_cleanup'
end
