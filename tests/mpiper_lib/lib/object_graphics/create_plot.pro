; Copyright (c) 1999-2000, Research Systems, Inc.  All rights reserved.
;       Unauthorized reproduction prohibited.
;+
; NAME:
;	CREATE_PLOT
;
; PURPOSE:
;	This procedure creates a simple object hierarchy (based on a
;	plot graphics atom) and optionally returns it to the calling
;	program level.
;
; CATEGORY:
;	Object Graphics.
;
; CALLING SEQUENCE:
;	CREATE_PLOT[, pData]
;
; OPTIONAL INPUTS:
;	pData: A one-dimensional array to be plotted.
;
; KEYWORD PARAMETERS:
;	PLOT: Set this keyword to a named variable to accept the plot
;		object reference created in CREATE_PLOT.
;	MODEL: Accepts model object.
;	VIEW: Accepts view object.
;
; EXAMPLE:
;	IDL> pdata = RANDOMN(seed,20)
;	IDL> CREATE_PLOT, pdata, MODEL=oModel, VIEW=oView, $
;	IDL> 	PLOT=oPLOT
;
; MODIFICATION HISTORY:
;	Written by:     Mark Piper, 8-31-99
;-

pro create_plot, pdata, plot=oP, model=oM, view=oV
compile_opt idl2
on_error, 2

;  Create default data.
if n_params() eq 0 then pdata = findgen(30)

;  Create view, model & plot objects.
oV = obj_new('IDLgrView', color=[250,250,250])
oM = obj_new('IDLgrModel')
oP = obj_new('IDLgrPlot', pdata, color=[255,0,0])

;  Load object hierarchy.
oV -> Add, oM
oM -> Add, oP

;  Get the xyz data ranges, using the GetProperty method.
oP -> GetProperty, xrange=xrange, yrange=yrange, zrange=zrange

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
oP -> SetProperty, xcoord_conv=xs, ycoord_conv=ys, zcoord_conv=zs

;  Set the default view, using the Rotate method of IDLgrModel.
oM -> Rotate, [1,0,0], -90
oM -> Rotate, [0,1,0], 30
oM -> Rotate, [1,0,0], 30

end