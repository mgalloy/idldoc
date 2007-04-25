;+
; Event handler for any object widget program -- as long as the
; object widget has a method called "handle_events" that takes an
; event structure as a positional parameter.
;
; @author Michael Galloy, 2002
;-
pro handle_events, event
	compile_opt idl2

	widget_control, event.top, get_uvalue=self
	self->handle_events, event
end
