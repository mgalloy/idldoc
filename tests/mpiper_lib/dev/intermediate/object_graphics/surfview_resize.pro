;+
; The top-level base event handler in SURFVIEW, used to resize the draw
; widget when the user resizes the top-level base.
;
; @param event {in}{required}{type=structure} The event structure passed
;	from XMANAGER.
;-
pro surfview_resize, event
	compile_opt idl2

	widget_control, event.top, get_uvalue=pstate

	; Get the new size, in pixels, of the top-level base.
	tlbg = widget_info(event.top, /geometry)

	; Add padding while setting the new draw widget size.
	newx = event.x - 2 * tlbg.xpad
	newy = event.y - 2 * tlbg.ypad
	widget_control, (*pstate).draw, xsize=newx, ysize=newy

	; Render the Object Graphics view.
	(*pstate).oWindow->draw, (*pstate).oView
end