;+
; The draw widget event handler in SURFVIEW, used to rotate the
; surface's model via the trackball.
;
; @param event {in}{required}{type=structure} The event structure passed
;	from XMANAGER.
;-
pro surfview_draw, event
	compile_opt idl2

	widget_control, event.top, get_uvalue=pstate

	; Update the trackball and render the view.
	update = (*pstate).oTrack->update(event, transform=new)
	if (update) then begin
		(*pstate).oModel->getProperty, transform=old
		(*pstate).oModel->setProperty, transform=old # new
		(*pstate).oWindow->draw, (*pstate).oView
	endif
end