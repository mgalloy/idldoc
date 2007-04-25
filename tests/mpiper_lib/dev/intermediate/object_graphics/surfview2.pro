pro surfview2_event, event
	compile_opt idl2

	widget_control, event.top, get_uvalue=pstate
	uname = widget_info(event.id, /uname)

	case uname of
	'x' : (*pstate).x_val = event.value
	'y' : (*pstate).y_val = event.value
	'z' : (*pstate).z_val = event.value
	'rotate_timer' : begin
			(*pstate).counter = (*pstate).counter - 2
			(*pstate).omodel->rotate, [(*pstate).x_val, $
				(*pstate).y_val, (*pstate).z_val], 2
			(*pstate).owindow->draw, (*pstate).oview
			if ((*pstate).counter gt 0) then begin
				timer = widget_info(event.top, $
					find_by_uname='rotate_timer')
				widget_control, timer, timer=0.25
			endif
		end
	'rotate' : begin
			(*pstate).counter = 360
			timer = widget_info(event.top, $
				find_by_uname='rotate_timer')
			widget_control, timer, timer=0.25
		end
	'draw' : begin

			select = (*pstate).owindow->select((*pstate).oview, $
				[event.x, event.y])

			if (size(select, /type) eq 11) then begin ; 11 = object
				found = (*pstate).owindow->pickdata( $
					(*pstate).oview, select[0], [event.x, event.y], $
					xyz)
				if (found) then print, xyz
			endif

			update = (*pstate).otrack->update(event, transform=new)
			if (update) then begin
				(*pstate).omodel->getProperty, transform=old
				(*pstate).omodel->setProperty, transform=old # new
				(*pstate).owindow->draw, (*pstate).oview
			endif
		end
	endcase
end


pro surfview2_cleanup, top
	compile_opt idl2

	widget_control, top, get_uvalue=pstate

	obj_destroy, [(*pstate).oview, (*pstate).otrack]
	ptr_free, pstate
end


pro surfview2, zdata
	compile_opt idl2

	if (n_params() ne 1) then zdata = hanning(40, 40)

	tlb = widget_base(title='Surfview 2', /row)

	control_base = widget_base(tlb, /column)
	x_slider = widget_slider(control_base, minimum=-100, $
		maximum=100, value=0, title='X value: ', uname='x')
	y_slider = widget_slider(control_base, minimum=-100, $
		maximum=100, value=0, title='Y value: ', uname='y')
	z_slider = widget_slider(control_base, minimum=-100, $
		maximum=100, value=0, title='Z value: ', uname='z')
	rotate_button = widget_button(control_base, value='Rotate', $
		uname='rotate')

	timer_base = widget_base(control_base, uname='rotate_timer')

	draw = widget_draw(tlb, xsize=400, ysize=400, uname='draw', $
		graphics_level=2, /button_events, /motion_events, retain=2)

	widget_control, tlb, /realize
	widget_control, draw, get_value=owindow

	owindow->setCurrentCursor, 'ARROW'
	sys_colors = widget_info(tlb, /system_colors)

	oview = obj_new('IDLgrView', color=sys_colors.face_3d)

	omodel = obj_new('IDLgrModel')
	oview->add, omodel

	olightmodel = obj_new('IDLgrModel')
	oview->add, olightmodel

	osurface = obj_new('IDLgrSurface', dataz=zdata, $
		datax=indgen(40), datay=indgen(40), $
		style=2, color=[255, 0, 0], bottom=[0, 0, 255])
	omodel->add, osurface

	olight = obj_new('IDLgrLight', type=2, location=[-1, -1, 1])
	olightmodel->add, olight

	osurface->getProperty, xrange=xr, yrange=yr, zrange=zr
	xc = norm_coord(xr)
	yc = norm_coord(yr)
	zc = norm_coord(zr)
	xc[0] = xc[0] - 0.5
	yc[0] = yc[0] - 0.5
	zc[0] = zc[0] - 0.5
	osurface->setProperty, xcoord_conv=xc, ycoord_conv=yc, $
		zcoord_conv=zc

	omodel->rotate, [1, 0, 0], -90
	omodel->rotate, [0, 1, 0], 30
	omodel->rotate, [1, 0, 0], 30

	owindow->draw, oview

	otrack = obj_new('Trackball', [200, 200], 200)

	state = { $
		owindow:owindow, $
		oview:oview, $
		omodel:omodel, $
		otrack:otrack, $
		x_val:0L, $
		y_val:0L, $
		z_val:0L, $
		counter:0L $
		}
	pstate = ptr_new(state, /no_copy)
	widget_control, tlb, set_uvalue=pstate

	xmanager, 'surfview2', tlb, /no_block, $
		event_handler='surfview2_event', $
		cleanup='surfview2_cleanup'
end
