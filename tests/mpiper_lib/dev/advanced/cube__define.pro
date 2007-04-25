;+
; Definition of geometry of a cube.
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
pro cube::get_definition, x=x, y=y, z=z, $
    polygon_conn=polygon_conn, polyline_conn=polyline_conn
    compile_opt idl2

    x = [-1, -1, +1, +1, -1, -1, +1, +1] / 2.0
    y = [-1, -1, -1, -1, +1, +1, +1, +1] / 2.0
    z = [-1, +1, +1, -1, -1, +1, +1, -1] / 2.0
    polyline_conn = [5, 0, 1, 2, 3, 0, 5, 4, 5, 6, 7, 4, 2, 0, 4, $
        2, 1, 5, 2, 2, 6, 2, 3, 7]
    polygon_conn = $
        [5, 0, 1, 2, 3, 0, $
         5, 4, 5, 6, 7, 4, $
         5, 1, 5, 6, 2, 1, $
         5, 2, 6, 7, 3, 2, $
         5, 3, 7, 4, 0, 3, $
         5, 0, 4, 5, 1, 0]
end


;+
; Define instance variables.
;
; @file_comments Class representing a cube.
;
; @author Michael Galloy
; @history Created August 1, 2003
;-
pro cube__define
    compile_opt idl2

    define = { cube, inherits polyhedron }
end
