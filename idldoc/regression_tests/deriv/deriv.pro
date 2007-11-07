; $Id: //depot/idl/trunk/idldir/lib/deriv.pro#4 $
;
; Copyright (c) 1984-2007, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.
;

Function Deriv, X, Y
;+
; NAME:
;	DERIV
;
; PURPOSE:
;	Perform numerical differentiation using 3-point, Lagrangian 
;	interpolation.
;
; CATEGORY:
;	Numerical analysis.
;
; CALLING SEQUENCE:
;	Dy = Deriv(Y)	 	;Dy(i)/di, point spacing = 1.
;	Dy = Deriv(X, Y)	;Dy/Dx, unequal point spacing.
;
; INPUTS:
;	Y:  Variable to be differentiated.
;	X:  Variable to differentiate with respect to.  If omitted, unit 
;	    spacing for Y (i.e., X(i) = i) is assumed.
;
; OPTIONAL INPUT PARAMETERS:
;	As above.
;
; OUTPUTS:
;	Returns the derivative.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	See Hildebrand, Introduction to Numerical Analysis, Mc Graw
;	Hill, 1956.  Page 82.
;
; MODIFICATION HISTORY:
;	Written, DMS, Aug, 1984.
;	Corrected formula for points with unequal spacing.  DMS, Nov, 1999.
;-
;
; on_error,2              ;Return to caller if an error occurs
n = n_elements(x)
if n lt 3 then message, 'Parameters must have at least 3 points'

if (n_params(0) ge 2) then begin
    if n ne n_elements(y) then message,'Vectors must have same size'

;df/dx = y0*(2x-x1-x2)/(x01*x02)+y1*(2x-x0-x2)/(x10*x12)+y2*(2x-x0-x1)/(x20*x21)
; Where: x01 = x0-x1, x02 = x0-x2, x12 = x1-x2, etc.
    
    type = size(x, /type)       ;If not floating type, ensure floating...
    if (type ne 4) and (type ne 5) and (type ne 6) and (type ne 9) then begin
        xx = float(x)
        x12 = xx - shift(xx,-1) ;x1 - x2
        x01 = shift(xx,1) - xx  ;x0 - x1
        x02 = shift(xx,1) - shift(xx,-1) ;x0 - x2
    endif else begin            ;Already floating or double
        x12 = x - shift(x,-1)   ;x1 - x2
        x01 = shift(x,1) - x    ;x0 - x1
        x02 = shift(x,1) - shift(x,-1) ;x0 - x2
    endelse

    d = shift(y,1) * (x12 / (x01*x02)) + $ ;Middle points
      y * (1./x12 - 1./x01) - $
      shift(y,-1) * (x01 / (x02 * x12))
; Formulae for the first and last points:
    d[0] = y[0] * (x01[1]+x02[1])/(x01[1]*x02[1]) - $ ;First point
      y[1] * x02[1]/(x01[1]*x12[1]) + $
      y[2] * x01[1]/(x02[1]*x12[1])
    n2 = n-2
    d[n-1] = -y[n-3] * x12[n2]/(x01[n2]*x02[n2]) + $ ;Last point
      y[n-2] * x02[n2]/(x01[n2]*x12[n2]) - $
      y[n-1] * (x02[n2]+x12[n2]) / (x02[n2]*x12[n2])

endif else begin                ;Equally spaced point case

    d = (shift(x,-1) - shift(x,1))/2.
    d[0] = (-3.0*x[0] + 4.0*x[1] - x[2])/2.
    d[n-1] = (3.*x[n-1] - 4.*x[n-2] + x[n-3])/2.
endelse
return, d
end
