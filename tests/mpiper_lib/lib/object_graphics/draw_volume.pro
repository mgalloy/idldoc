;--------------------------------------------------------------------
;	spaceghost                                                       -
;--------------------------------------------------------------------
pro spaceghost, t
compile_opt idl2
@catch_procedure

;	Retrieve user value from top-level base.
widget_control, t, get_uvalue=pTop

;	Cleanup up object & pointer references.
obj_destroy, *pTop
ptr_free, pTop

end


;--------------------------------------------------------------------
;	rubberducky                                                      -
;--------------------------------------------------------------------
pro rubberducky, event
compile_opt idl2
@catch_procedure

;	Retrieve user value from top-level base.
widget_control, event.top, get_uvalue=pTop

;	Extract objects from the top-level container.
oW = *pTop -> Get(isa='IDLGRWINDOW', /all)
oM = *pTop -> Get(isa='IDLGRMODEL', /all)
oT = *pTop -> Get(isa='TRACKBALL', /all)

;	Handle expose events
if event.type eq 4 then oW -> Draw

;	Handle Trackball motion.
if event.press eq 1 then oW -> SetProperty, uvalue=1
b = oT -> Update(event, transform=updated)
if b then begin
	oM -> GetProperty, transform=old
	oM -> SetProperty, transform=updated ## old
endif
oW -> GetProperty, uvalue=toggle
if event.release eq 1 and toggle then begin
	oW -> Draw
	oW -> SetProperty, uvalue=0
endif

end


;--------------------------------------------------------------------
;	draw_volume                                                      -
;--------------------------------------------------------------------
pro draw_volume
compile_opt idl2
@catch_procedure

;	Call CREATE_VOLUME.
create_volume, view=oV, volume=oVol, model=oM

;	Create a top-level container to store objects.
oTop = obj_new('IDL_Container')
oTop -> Add, [oV, oM, oVol]
;oV -> SetProperty, name='view'
;oM -> SetProperty, name='model'
;oVol -> SetProperty, name='volume'

;	Modify original data.
oVol -> GetProperty, data0=voxel
voxel = bytscl(voxel)
oVol -> SetProperty, data0=voxel

;	Load an IDL color table.
loadct, 5, /silent
colors = bytarr(256,3)
tvlct, colors, /get
oVol -> SetProperty, rgb_table0=colors

;	Build a widget hierarchy to display the volume.
t = widget_base(title='IDLgrVolume Example', /column)
w = widget_draw(t, xsize=400, ysize=400, graphics_level=2, $
	/button_events, /expose_events, /motion_events)
widget_control, t, /realize

;	Set window properties.
widget_control, w, get_value=oW
oW -> SetProperty, graphics_tree=oV, uvalue=0
oTop -> Add, oW

;	Add a Trackball object.
oTrack = obj_new('Trackball', [200,200], 200)
oTop -> Add, oTrack

;	Render view.
oW -> Draw

;	Set pointer to the top-level container as the user value of
;	the top-level widget base.
pTop = ptr_new(oTop)
widget_control, t, set_uvalue=pTop

;	Call XMANAGER.
xmanager, 'toyboat', t, $
	event_handler='rubberducky', $
	cleanup='spaceghost', $
	/no_block

end