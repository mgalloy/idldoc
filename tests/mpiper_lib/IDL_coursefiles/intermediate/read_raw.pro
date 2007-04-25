;+
;   Reads a 'raw' format data file. These files contain a polygonal mesh
;   array.  The output from this procedure can be read directly into
;   an IDLgrPolygon object.
;
; @param filename {in}{type=string} filename of a .raw file
; @param vertices {out}{type=float array} a 3-by-N output array of vertices
; @param polygons {out}{type=long array} a 4*N/3 connectivity list
;
; @examples If you've installed the training files, try
;   <pre>
;   IDL> file = filepath('pharaoh.raw', subdir='training')<br>
;   IDL> read_raw, file, v, p<br>
;   IDL> o = obj_new('IDLgrPolygon', data=v, polygon=p, color=[255,255,20])<br>
;   IDL> xobjview, o    ; manipulate the polygon!<br>
;   IDL> obj_destroy, o<br>
;   </pre>
;
; @requires IDL 5.4
; @author Mark Piper, 2000
; @copyright RSI
;-

pro read_raw, filename, vertices, polygons

    compile_opt idl2

    on_error, 2

    if n_params() eq 0 then $
        filename = dialog_pickfile(filter='*.raw', path=filepath('', $
            subdir=['mpiper','data']))

    openr, unit, filename, /get_lun, error=err
    if err ne 0 then begin
        message, 'Error opening file. Returning.', /continue
        return
    endif

    line = ''
    readf, unit, line
    count = 0L
    while not eof(unit) do begin
        readf, unit, line
        count = count + 1L
    endwhile
    point_lun, unit, 0L
    readf, unit, line
    vertices = fltarr(3,(count-1)*3)    ; the vertex array
    readf, unit, vertices
    free_lun, unit

    polygons = lonarr(4*count)          ; the connectivity list
    for i=0, count-1 do polygons[i*4:i*4+3] = [3,i*3+lindgen(3)]
end