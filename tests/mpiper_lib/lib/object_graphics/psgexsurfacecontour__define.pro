;============================================================================
;+
; The init method for the class PSGexSurfaceContour.

; @param data {in}{type=array} A two-dimensional array of data that
; can be displayed as a contour & a surface.
; @keyword set_default_view {in}{optional}{type=boolean} When set,
; the atoms are scaled into the unit cube, translated to be centered 
; at the origin & rotated into a familiar view.
;-
function psgexsurfacecontour::init, data, set_default_view=scale, _extra=e
    compile_opt idl2

    ; Call the superclass' init method.
    if 0 eq self->IDLgrModel::init(_extra=e) then return, 0

    ; Make the surface obj.
    self.oSurface = obj_new('IDLgrSurface', name='surface')
    self->add, self.oSurface

    ; Make the contour obj.
    self.oContour = obj_new('IDLgrContour', name='contour')
    self->add, self.oContour

    ; Make the axes. They're hidden, by default.
    for i=0,2 do $
      self.oAxis[i] = obj_new('IDLgrAxis', i, $
                             name='axis' + strtrim(i+1,2), $
                             /hide)
    self->add, self.oAxis
    
    ; Pass the input data to the setProperty method, where it is checked 
    ; and loaded into the atoms.
    if n_elements(data) ne 0 then $
      self->setProperty, data=data, set_default_view=scale, _extra=e
    
    ; If the data are bad, then return fail.
    if self.dataStatus eq -1 then return, 0

    ; Return success.
    return, 1
end


;============================================================================
;+
; The cleanup method for the class PSGexSurfaceContour.
;-
pro psgexsurfacecontour::cleanup
    compile_opt idl2

    ; Clean up class data.
    if obj_valid(self.oSurface) then obj_destroy, self.oSurface
    if obj_valid(self.oContour) then obj_destroy, self.oContour
    obj_destroy, self.oAxis[obj_valid(self.oAxis)]

    ; Call superclass cleanup.
    self->IDLgrModel::cleanup
end


;============================================================================
;+
; The getter method for the class PSGexSurfaceContour.
;-
pro psgexsurfacecontour::getproperty, object=obj, _extra=e
    compile_opt idl2

    ; The param 'obj' is a string corresponding to the name of the atom;
    ; e.g., 'surface', 'contour', 'axisN', where N=1,2,3.
    ; The param 'obj' must be specified in order to access the props
    ; of the atoms; otherwise, only the props of the compound object
    ; can be accessed.
    
end


;============================================================================
;+
; The setter method for the class PSGexSurfaceContour.
;
; Perform all of the coordinate conversions here, so that the same
; code can be used for the init and setProperty methods.
;-
pro psgexsurfacecontour::setproperty, object=obj, data=data, $
                       set_default_view=scale, _extra=e
    compile_opt idl2

    ; Perform tests on input data, if present.
    if n_elements(data) ne 0 then begin

        ; Make sure that the data are of displayable type & dimension.
        info = size(data, /structure)
        if info.n_dimensions ne 2 then begin
            message, 'Input data must be a two-dimensional array.', /info
            self.dataStatus = -1
            return
        endif
        if (info.type eq 0) or (info.type ge 6 and info.type le 11) then begin
            message, 'Input data must be of integer or float type.', /info
            self.dataStatus = -1
            return
        endif   

        ; Load the data into the atoms.
        self.oSurface->setProperty, dataz=data
        self.oContour->setProperty, data_values=data
        self.dataStatus = 1

        ; Set axis properties based on the data values.
        self.oSurface->getProperty, xrange=xr, yrange=yr, zrange=zr
        self.oAxis[0]->setProperty, range=xr, location=[xr[0], yr[0], zr[0]]
        self.oAxis[1]->setProperty, range=yr, location=[xr[0], yr[0], zr[0]]
        self.oAxis[2]->setProperty, range=zr, location=[xr[0], yr[1], zr[0]]
    
    endif ; n_elements(data) ne 0
    
    ; Apply optional scaling to the set of atoms.
    if keyword_set(scale) then self->setDefaultView
    
    ; Pass keyword parameters to the atoms, or to the superclass.
    obj = n_elements(obj) gt 0 ? obj : 'model'
    case obj of
        'surface': self.oSurface->setProperty, _extra=e
        'contour': self.oContour->setproperty, _extra=e
        'axis1': self.oAxis[0]->setProperty, _extra=e
        'axis2': self.oAxis[1]->setProperty, _extra=e
        'axis3': self.oAxis[2]->setProperty, _extra=e
        'axes': for i=0,2 do self.oAxis[i]->setProperty, _extra=e
        'model': self->IDLgrModel::setProperty, _extra=e
    else: message, 'Unknown object.', /info
    endcase
end


;============================================================================
;+
; This method is meant to be internal, called when the user specifies
; the set_default_view keyword in the init or setproperty method.
;-
pro psgexsurfacecontour::setDefaultView
    compile_opt idl2, hidden

    ; The data values need to exist.
    if self.dataStatus ne 1 then begin
        message, 'Data values need to be defined to set default view.', /info
        return
    endif

    ; Determine scaling factors from the data (as stored in the surface obj).
    self.oSurface->getProperty, xrange=xr, yrange=yr, zrange=zr
    xs = norm_coord(xr)
    ys = norm_coord(yr)
    zs = norm_coord(zr)
    xs[0] = xs[0]-0.5
    ys[0] = ys[0]-0.5
    zs[0] = zs[0]-0.5

    ; Apply the scaling factors to the composite object.
    self->scale, xs[1], ys[1], zs[1]
    self->translate, xs[0], ys[0], zs[0]

    ; Rotate the composite object to a familiar view
    self->rotate, [1,0,0], -90
    self->rotate, [0,1,0], 30
    self->rotate, [1,0,0], 30

    ; Set the contour plot to be displayed 2D, below the surface.
    self.oContour->setProperty, /planar, geomz=min(zr)
end


;============================================================================
;+
; The data definition procedure for the class PSGexSurfaceContour.
;-
pro psgexsurfacecontour__define

    define = { psgexsurfacecontour, $
               inherits idlgrmodel, $
               oSurface		: obj_new(), $
               oContour		: obj_new(), $
               oAxis		: objarr(3), $
               dataStatus	: 0L, $ ; -1=bad, 0=none, 1=data present
               showSurface	: 1L, $
               showContour	: 1L, $
               showAxes		: 0L $
             }
end

