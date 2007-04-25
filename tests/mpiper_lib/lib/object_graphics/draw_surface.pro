; Copyright (c) 1999-2000, Research Systems, Inc.  All rights reserved.
;       Unauthorized reproduction prohibited.
;+
; NAME:
;	DRAW_SURFACE
;
; PURPOSE:
;	This main-level program calls CREATE_SURFACE and modifies the
;	objects returned from it.
;
; CATEGORY:
;	Object Graphics.
;
; CALLING SEQUENCE:
;	.RUN DRAW_SURFACE
;
; MODIFICATION HISTORY:
;	Written by:     Mark Piper, 5-7-99
;-


;  Generate some interesting data.
x = findgen(40)
coolsurf = sin(2*!pi*!dtor*x) # cos(2*!pi*!dtor*x)

;  Call CREATE_SURFACE, passing coolsurf & retrieving
;  the view object containing the OG hierarchy.
create_surface, coolsurf, VIEW=oView, MODEL=oModel

;  Change the background color.
oView -> SetProperty, COLOR=[150,150,150]

;  Create a light object.
oLight = obj_new('IDLgrLight', LOCATION=[-1,1,1], type=1)
oLightModel = obj_new('IDLgrModel')
oLightModel -> Add, oLight
oView -> Add, oLightModel

;  Create a window object & draw the OG hierarchy.
oWindow = obj_new('IDLgrWindow')
oWindow -> Draw, oView

;  Rotate the OG scene.
for i=0,180 do begin
	oModel -> Rotate, [1,0,0], 2
	oView -> SetProperty, COLOR=[100,100,i]
	oWindow -> Draw, oView
endfor

end
