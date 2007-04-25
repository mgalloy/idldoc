;+
; Event handler for the radius selection field on the orb_world_property
; dialog.
;
; @private
; @param event {in}{type=structure} event structure
;-
pro orb_world_property_radius, event
    compile_opt idl2

    widget_control, event.top, get_uvalue=pstate

    (*pstate).radius = event.value
end


;+
; Event handler for the OK and cancel buttons on the orb_world_property
; dialog.
;
; @private
; @param event {in}{type=structure} event structure
;-
pro orb_world_property_choice, event
    compile_opt idl2

    widget_control, event.top, get_uvalue=pstate
    uname = widget_info(event.id, /uname)

    case uname of
    'ok' : begin
            (*pstate).cancel = 0
            xpos = widget_info(event.top, find_by_uname='xpos')
            ypos = widget_info(event.top, find_by_uname='ypos')
            zpos = widget_info(event.top, find_by_uname='zpos')
            widget_control, xpos, get_value=xpos_val
            widget_control, ypos, get_value=ypos_val
            widget_control, zpos, get_value=zpos_val
            (*pstate).pos = float([xpos_val, ypos_val, zpos_val])
        end
    'cancel' : (*pstate).cancel = 1
    else :
    end

    widget_control, event.top, /destroy
end


;+
; Event handler for the orb_world_property dialog color button.
;
; @private
; @param event {in}{type=structure} event structure
;-
pro orb_world_property_color, event
    compile_opt idl2

    widget_control, event.top, get_uvalue=pstate

    new_color = dialog_pickcolor(dialog_parent=event.top, $
        init_color=(*pstate).color, cancel=cancel, $
        title='Choose orb color...')
    if (not cancel) then (*pstate).color = new_color
end


;+
; Modal dialog to set the properties of a new orb.
;
; @private
; @returns structure with various properties of the orb; the cancel field of
;          this structure is true if the user selected the "cancel" button and
;          false if "OK" was selected.  The fields are pos (fltarr(3)), color, and radius
; @keyword group_leader {in}{type=widget ID} widget ID of calling widget
;          program
;-
function orb_world_property, group_leader=group_leader
    compile_opt idl2

    tlb = widget_base(title='Create a new orb...', $
        group_leader=group_leader, $
        /column, tlb_frame_attr=1, /modal, /base_align_center)
    color_button = widget_button(tlb, value='Pick color', $
        event_pro='orb_world_property_color')

    pos_base = widget_base(tlb, /row, xpad=0)
    xpos = cw_field(pos_base, title='X: ', value='0.0', $
        uname='xpos', xsize=4)
    ypos = cw_field(pos_base, title='Y: ', value='0.0', $
        uname='ypos', xsize=4)
    zpos = cw_field(pos_base, title='Z: ', value='0.0', $
        uname='zpos', xsize=4)

    radius = cw_slider(tlb, title='Radius', value=0.1, $
        min=0.0, max=1.0, ysize=10, $
        event_pro='orb_world_property_radius')

    choice_row = widget_base(tlb, /row, $
        event_pro='orb_world_property_choice')
    ok = widget_button(choice_row, value='OK', uname='ok', xsize=50)
    cancel = widget_button(choice_row, value='Cancel', $
        uname='cancel', xsize=50)

    widget_control, tlb, cancel_button=cancel, default_button=ok

    widget_control, tlb, /realize

    state = { $
        color:[0B, 255B, 0B], $
        pos:fltarr(3), $
        radius:0.1, $
        cancel:1 $
        }
    pstate = ptr_new(state, /no_copy)
    widget_control, tlb, set_uvalue=pstate

    xmanager, 'orb_world_property', tlb

    state = *pstate
    ptr_free, pstate
    return, state
end


;+
; Handles events from the context menu.
;
; @private
; @param event {in}{type=structure} event structure
;-
pro orb_world_context, event
    compile_opt idl2

    widget_control, event.top, get_uvalue=pstate
    uname = widget_info(event.id, /uname)

    case uname of
    'orb_color' : begin
            (*pstate).current_orb->getProperty, color=color
            new_color = dialog_pickcolor(dialog_parent=event.top, $
                init_color=color, cancel=cancel, $
                title='Choose orb color...')
            if (not cancel) then $
                (*pstate).current_orb->setProperty, color=new_color
            (*pstate).owindow->draw
        end
    'orb_query' : begin
            (*pstate).current_orb->getProperty, color=color, $
                radius=radius, pos=pos
            message = ['Color: [' $
                    + string(fix(color), format='(3I5)') + ']', $
                'Radius: ' + strtrim(radius, 2), $
                'Position: [' + string(pos, format='(3F6.2)') + ']']
            result = dialog_message(message, /information, $
                title='Orb Properties', dialog_parent=event.top)
        end
    'view_color' : begin
            (*pstate).oview->getProperty, color=color
            new_color = dialog_pickcolor(dialog_parent=event.top, $
                init_color=color, cancel=cancel, $
                title='Choose background color...')
            if (not cancel) then $
                (*pstate).oview->setProperty, color=new_color
            (*pstate).owindow->draw
        end
    'new_orb' : begin
            props = orb_world_property(group_leader=event.top)
            if (props.cancel) then break
            new_orb = obj_new('orb', pos=props.pos, $
                radius=props.radius, color=props.color, $
                /select_target)
            (*pstate).omodel->add, new_orb
            (*pstate).owindow->draw
        end
    endcase
end


;+
; Handles events from the draw widget.
;
; @private
; @param event {in}{type=structure} event structure
;-
pro orb_world_draw, event
    compile_opt idl2

    widget_control, event.top, get_uvalue=pstate

    update = (*pstate).otrack->update(event, transform=new_trans)
    if (update) then begin
        (*pstate).omodel->getProperty, transform=old_trans
        (*pstate).omodel->setProperty, $
            transform=old_trans # new_trans
    endif

    if (event.release eq 4) then begin
        select = (*pstate).owindow->select((*pstate).oview, $
            [event.x, event.y])
        if (size(select, /type) eq 3) then begin
            widget_displayContextMenu, event.id, event.x, event.y, $
                (*pstate).viewContext
        endif else begin
            (*pstate).current_orb = select[0]
            widget_displayContextMenu, event.id, event.x, event.y, $
                (*pstate).orbContext
        endelse
    endif

    (*pstate).owindow->draw
end


;+
; Creates the original object graphics scene.
;
; @private
; @param pstate {in}{type=pointer} pointer to state structure
;-
pro orb_world_create_view, pstate
    compile_opt idl2

    sys_colors = widget_info((*pstate).draw, /system_colors)

    (*pstate).oview = obj_new('IDLgrView', color=sys_colors.face_3d)

    light_model = obj_new('IDLgrModel')
    (*pstate).oview->add, light_model

    (*pstate).omodel = obj_new('IDLgrModel')
    light_model->add, (*pstate).omodel

    orb1 = obj_new('orb', pos=[0, 0, 0], radius=0.1, $
        color=[255, 0, 0], /select_target)
    (*pstate).omodel->add, orb1

    orb2 = obj_new('orb', pos=[-0.3, 0.35, 0], radius=0.1, $
        color=[0, 0, 255], /select_target)
    (*pstate).omodel->add, orb2

    light1 = obj_new('IDLgrLight', type=0, intensity=0.5)
    light_model->add, light1

    light2 = obj_new('IDLgrLight', type=1, intensity=0.7, $
        attenuation=[1, 1, 1], location=[-1, 1, 1])
    light_model->add, light2

    (*pstate).owindow->setProperty, graphics_tree=(*pstate).oview
    (*pstate).owindow->draw
end


;+
; Frees resources.
;
; @private
; @param top {in}{type=widget ID} widget ID of the top-level base
;-
pro orb_world_cleanup, top
    compile_opt idl2

    widget_control, top, get_uvalue=pstate

    obj_destroy, (*pstate).otrack
    ptr_free, pstate
end


;+
; ORB_WORLD is a training example program.
;
; @author Michael Galloy
; @copyright RSI, 2002
;-
pro orb_world
    compile_opt idl2

    xsize = 400
    ysize = 400

    tlb = widget_base(title='Orb world', /column)
    draw = widget_draw(tlb, graphics_level=2, /expose_events, $
        xsize=xsize, ysize=ysize, $
        /button_events, /motion_events, $
        event_pro='orb_world_draw')

    orbContext = widget_base(tlb, /context_menu, $
        uname='orbContext', event_pro='orb_world_context')
    orbCColor = widget_button(orbContext, value='Set orb color', $
        uname='orb_color')
    orbCQuery = widget_button(orbContext, value='Query', $
        uname='orb_query')

    viewContext = widget_base(tlb, /context_menu, $
        uname='viewContext', event_pro='orb_world_context')
    viewCColor = widget_button(viewContext, $
        value='Set background color', uname='view_color')
    viewNewObr = widget_button(viewContext, value='Create new orb', $
        uname='new_orb', /separator)

    widget_control, tlb, /realize
    widget_control, draw, get_value=owindow

    owindow->setCurrentCursor, 'ARROW'

    otrack = obj_new('trackball', [xsize, ysize] / 2, xsize / 2)

    state = { $
        draw:draw, $
        owindow:owindow, $
        oview:obj_new(), $
        omodel:obj_new(), $
        otrack:otrack, $
        orbContext:orbContext, $
        viewContext:viewContext, $
        current_orb:obj_new() $
        }
    pstate = ptr_new(state, /no_copy)
    widget_control, tlb, set_uvalue=pstate

    orb_world_create_view, pstate

    xmanager, 'orb_world', tlb, /no_block, $
        cleanup='orb_world_cleanup'
end
