;+
; Calculates and sets x/y/z coordinate conversion factors for the
; default view volume for any graphical atom with range properties.
;
; @param obj {in}{type=object} the object reference to be scaled into
;       the default view volume
; @author Beau Legeer, 1999
; @copyright RSI
;-

PRO SetCC, Obj

; calculate and set coordinate conversion factors for the
; default viewplane rectangle and zclip for any
; graphical atom with range properties


ERRORno = 0
Catch, ERRORno
if (ERRORno ne 0) then begin
    return
endif

; check the parameter
if (n_params() eq 0) then begin
    message, 'ERROR: no arguments'
    return
endif

for i = 0, n_elements(Obj)-1 do begin
    ; First get the ranges
    Obj[i]->GetProperty, XRANGE = xr, YRANGE = yr, ZRANGE = zr

    ; calculate and set the coordinate conversion factors
    ; such that the data will fall between -0.5 and 0.5 in
    ; all directions. If the default VIEWPLANE_RECT and
    ; ZCLIP is set, the object will fall in the middle of
    ; the destination

    Obj[i]->SetProperty, $
        XCOORD = norm_coord(xr) - [0.5,0.0] , $
        YCOORD = norm_coord(yr) - [0.5,0.0]
    if (Obj_Class(Obj[i]) ne 'IDLGRIMAGE' and $
        Obj_Class(Obj[i]) ne 'IDLGRPLOT') then $
        Obj[i]->SetProperty, $
            ZCOORD = norm_coord(zr) - [0.5,0.0]

endfor

END
