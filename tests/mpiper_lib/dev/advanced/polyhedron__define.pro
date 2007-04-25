;+
; Implement this method in a concrete subclass.
;
; @abstract
; @keyword x {out}{optional}{type=numeric vector} x coordinates of vertices
; @keyword y {out}{optional}{type=numeric vector} y coordinates of vertices
; @keyword z {out}{optional}{type=numeric vector} z coordinates of vertices
; @keyword polygon_conn {out}{optional}{type=numeric vector} connectivity
;          array for the polygon
; @keyword polyline_conn {out}{optional}{type=numeric vector} connectivity
;          array for the polyline
;-
pro polyhedron::get_definition, x=x, y=y, z=z, $
    polygon_conn=polygon_conn, polyline_conn=polyline_conn
    compile_opt idl2
end


;+
; Set properties of the polyhedron.
;
; @keyword outline {in}{optional}{type=boolean} whether the tetrahedron is
;          filled or an outline
; @keyword _extra {in}{optional}{type=keywords} keywords of IDLgrModel,
;          IDLgrPolygon, or IDLgrPolyline
;-
pro polyhedron::setProperty, outline=outline, _extra=e
    compile_opt idl2

    self->IDLgrModel::setProperty, _extra=e
    self.opolygon->setProperty, _extra=e
    self.opolyline->setProperty, _extra=e

    if (n_elements(outline) ne 0) then begin
        self.outline = keyword_set(outline)
        self.opolygon->setProperty, hide=keyword_set(self.outline)
        self.opolyline->setProperty, hide=~keyword_set(self.outline)
    endif
end


;+
; Get properties of the polyhedron.
;
; @keyword outline {out}{optional}{type=boolean} whether the tetrahedron is
;          filled or an outline
; @keyword _ref_extra {out}{optional}{type=keywords} keywords of IDLgrModel,
;          IDLgrPolygon, or IDLgrPolyline
;-
pro polyhedron::getProperty, outline=outline, _ref_extra=e
    compile_opt idl2

    self->IDLgrModel::getProperty, _extra=e
    self.opolygon->getProperty, _extra=e
    self.opolyline->getProperty, _extra=e

    outline = self.outline
end


;+
; Build the polyhedron's vertices and connectivity array.
;-
pro polyhedron::build_polygons, pos=pos, scale=scale, _extra=e
    compile_opt idl2

    self->get_definition, x=x, y=y, z=z, $
        polyline_conn=polyline_conn, polygon_conn=polygon_conn

    x *= scale
    y *= scale
    z *= scale

    x += pos[0]
    y += pos[1]
    z += pos[2]

    self.opolyline = obj_new('IDLgrPolyline', x, y, z, $
        polylines=polyline_conn, _extra=e)
    self->add, self.opolyline

    self.opolygon = obj_new('IDLgrPolygon', x, y, z, $
        polygons=polygon_conn, _extra=e)
    self->add, self.opolygon
end


;+
; Free resources.
;-
pro polyhedron::cleanup
    compile_opt idl2

    self->IDLgrModel::cleanup
end


;+
; @keyword pos {in}{optioanl}{type=3-element numeric}{default=[0.0, 0.0, 0.0]}
;          position of the center of the cube
; @keyword scale {in}{optional}{type=numeric}{default=1.0}
; @keyword outline {in}{optional}{type=boolean} set to create an outline of a
;          cube
; @keyword _extra {in}{optional}{type=keywords} keywords to IDLgrModel,
;          IDLgrPolygon, and IDLgrPolyline init methods
;-
function polyhedron::init, pos=pos, scale=scale, outline=outline, _extra=e
    compile_opt idl2

    ; Parent's initialization
    retval = self->IDLgrModel::init(_extra=e)
    if (retval ne 1) then return, retval

    self.outline = keyword_set(outline)

    self->build_polygons, $
        pos=n_elements(pos) eq 0 ? [0.0, 0.0, 0.0] : pos, $
        scale=n_elements(scale) eq 0 ? 1.0 : scale, $
        _extra=e

    (self.outline ? self.opolygon : self.opolyline)->setProperty, hide=1

    return, 1
end


;+
; Define instance variables.
;
; @file_comments Class representing a polyhedron.
; @field opolygon IDLgrPolygon containing the polyhedron
; @field opolyline IDLgrPolyline containing the outline of the polyhedron
;
; @author Michael Galloy, RSI
; @history Created August 1, 2003
;-
pro polyhedron__define
    compile_opt idl2

    define = { polyhedron, inherits IDLgrModel, $
        opolygon:obj_new(), $
        opolyline:obj_new(), $
        outline:0B }
end
