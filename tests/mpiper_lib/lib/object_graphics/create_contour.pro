; Copyright (c) 1999-2000, Research Systems, Inc.  All rights reserved.
;       Unauthorized reproduction prohibited.
;+
; NAME:
;	CREATE_CONTOUR
;
; PURPOSE:
;	This procedure creates a simple object hierarchy (based on a
;	contour graphics atom) and optionally returns it to the calling
;	program level.
;
; CATEGORY:
;	Object Graphics.
;
; CALLING SEQUENCE:
;	CREATE_CONTOUR[, Data]
;
; OPTIONAL INPUTS:
;	Data: A two-dimensional array of surface data to be contoured.
;
; KEYWORD PARAMETERS:
;	CONTOUR: Set this keyword to a named variable to accept the contour
;		object reference created in CREATE_CONTOUR.
;	MODEL: Accepts model object.
;	VIEW: Accepts view object.
;
; EXAMPLE:
;	IDL> data = SHIFT(DIST(40),20,20)
;	IDL> CREATE_CONTOUR, data, MODEL=oModel, VIEW=oView, $
;	IDL> 	CONTOUR=oContour
;
; MODIFICATION HISTORY:
;	Written by:     Mark Piper, 8-30-99
;-

pro create_contour, zdata, contour=oC, model=oM, view=oV
compile_opt idl2
on_error, 2

;  Create default data.
if n_params() eq 0 then zdata = dist(30)

;  Create view, model & contour objects.
oV = obj_new('IDLgrView', color=[250,250,250])
oM = obj_new('IDLgrModel')
oC = obj_new('IDLgrContour', zdata, color=[255,0,0], /planar, geomz=0)

;  Load object hierarchy.
oV -> Add, oM
oM -> Add, oC

;  Get the xyz data ranges, using the GetProperty method.
oC -> GetProperty, xrange=xrange, yrange=yrange, zrange=zrange

;  Use NORM_COORD to return scaling factors [s0,s1], where s0 is
;  the offset and s1 is the scaling factor.
xs = norm_coord(xrange)
ys = norm_coord(yrange)
zs = norm_coord(zrange)

;  Adjust the offset (s0) to fit in the default viewplane_rect.
xs[0] = xs[0] - 0.5
ys[0] = ys[0] - 0.5
zs[0] = zs[0] - 0.5

;  Set the correct coords using the SetProperty method;
;  e.g., xcoord_conv=xs gives normalized_x = xs[0] + xs[1]*data_x
oC -> SetProperty, xcoord_conv=xs, ycoord_conv=ys
if size(data, /n_dim) gt 2 then oC -> SetProperty, zcoord_conv=zs

;  Set the default view, using the Rotate method of IDLgrModel.
oM -> Rotate, [1,0,0], -90
oM -> Rotate, [0,1,0], 30
oM -> Rotate, [1,0,0], 30

end