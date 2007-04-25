; Copyright (c) 1999-2000, Research Systems, Inc.  All rights reserved.
;       Unauthorized reproduction prohibited.
;+
; NAME:
;	CREATE_IMAGE
;
; PURPOSE:
;	This procedure creates a simple object hierarchy (based on a
;	image graphics atom) and optionally returns it to the calling
;	program level.
;
; CATEGORY:
;	Object Graphics.
;
; CALLING SEQUENCE:
;	CREATE_IMAGE[, Data]
;
; OPTIONAL INPUTS:
;	Data: A two-dimensional array of image data.
;
; KEYWORD PARAMETERS:
;	IMAGE: Set this keyword to a named variable to accept the image
;		object reference created in CREATE_IMAGE.
;	MODEL: Accepts model object.
;	VIEW: Accepts view object.
;
; EXAMPLE:
;	IDL> idata = SHIFT(DIST(40),20,20)
;	IDL> CREATE_IMAGE, idata, MODEL=oModel, VIEW=oView, $
;	IDL> 	IMAGE=oImage
;
; MODIFICATION HISTORY:
;	Written by:     Mark Piper, 3-15-00
;-

pro create_image, idata, image=oI, model=oM, view=oV
compile_opt idl2
on_error, 2

;  Create default data, if necessary.
if n_params() eq 0 then zdata = dist(30)

;  Create view, model & image objects.
oV = obj_new('IDLgrView', color=[250,250,250])
oM = obj_new('IDLgrModel')
oI = obj_new('IDLgrImage', idata)

;  Load object hierarchy.
oV -> Add, oM
oM -> Add, oI

;  Get the xyz data ranges, using the GetProperty method.
oI -> GetProperty, xrange=xrange, yrange=yrange

;  Use NORM_COORD to return scaling factors [s0,s1], where s0 is
;  the offset and s1 is the scaling factor.
xs = norm_coord(xrange)
ys = norm_coord(yrange)

;  Adjust the offset (s0) to fit in the default viewplane_rect.
xs[0] = xs[0] - 0.5
ys[0] = ys[0] - 0.5

;  Set the correct coords using the SetProperty method;
;  e.g., xcoord_conv=xs gives normalized_x = xs[0] + xs[1]*data_x
oI -> SetProperty, xcoord_conv=xs*1.5, ycoord_conv=ys*1.5


end