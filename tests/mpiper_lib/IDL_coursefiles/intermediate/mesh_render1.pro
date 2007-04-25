;+
; An early form of mesh_render. No event handling.
;
; @param v0 {in}{optional}{type=float or integer array} A vertex array
; @param p0 {in}{optional}{type=long array} The connectivity list for the
;       vertices
; @author Mark Piper, 1999
; @history Revised 2002, mp
; @copyright RSI
;-
pro mesh_render1, v0, p0
    compile_opt idl2

    ; If no arguments are passed, then read in a sample data file.
    if n_params() ne 2 then begin
        file = filepath('knot.dat', subdir=['examples','demo','demodata'])
        restore, file, /verbose
        v0 = transpose([[x],[y],[z]])
        p0 = mesh
    endif

    ; Retrieve the current IDL color mode & color table, if necessary.
    device, get_decomposed=odec
    if odec eq 0 then begin
        tvlct, r, g, b, /get
        tek_color, 0, 8
    endif else r = (g = (b = 0))

    ; Get statistics on the input data.
    orig_size = size(v0)
    orig_verts = orig_size[2]
    orig_tri = mesh_validate(v0, p0, /remove_nan, /pack_vertices)
    orig_area = mesh_surfacearea(v0, p0)
    minv0 = min(v0, max=maxv0)

    ; Make the top-level base.
    wtop1 = widget_base(title='RSI Training - Polygonal Mesh Renderer', $
        /column, /base_align_center, tlb_frame_attr=1)

    ; Make a draw widget.
    device, get_screen_size=ss
    wdraw = widget_draw(wtop1, xsize=0.5*ss[0], ysize=0.5*ss[1])

    ; Make a set of panels for displaying info about the mesh data set.
    wbase1 = widget_base(wtop1, /row, space=25)
    wbase1a = widget_base(wbase1, /column, /frame)
    wvertslabel = widget_label(wbase1a, value='Vertices', $
        font='Helvetica*14*Bold')
    worigverts = cw_field(wbase1a, title='Original: ', $
        value=orig_verts, xsize=5, /noedit, font='Courier*14')
    wcurrverts = cw_field(wbase1a, title='Current:  ', $
        value=orig_verts, xsize=5, /noedit, uname='currverts', $
        font='Courier*14')
    wbase1b = widget_base(wbase1, /column, /frame)
    wtrilabel = widget_label(wbase1b, value='Triangles', $
        font='Helvetica*14*Bold')
    worigtri = cw_field(wbase1b, title='Original: ', $
        value=orig_tri, xsize=5, /noedit, font='Courier*14')
    wcurrtri = cw_field(wbase1b, title='Current:  ', $
        value=orig_tri, xsize=5, /noedit, uname='currtri', $
        font='Courier*14')
    wbase1c = widget_base(wbase1, /column, /frame)
    warealabel = widget_label(wbase1c, value='Surface Area', $
        font='Helvetica*14*Bold')
    worigarea = cw_field(wbase1c, title='Original: ', $
        value=orig_area, xsize=5, /noedit, font='Courier*14')
    wcurrarea = cw_field(wbase1c, title='Current:  ', $
        value=orig_area, xsize=5, /noedit, uname='currarea', $
        font='Courier*14')

    ; Realize the widget hierarchy.
    widget_control, wtop1, /realize

    ; Get the window index from the draw widget.
    widget_control, wdraw, get_value=win_id

    ; Set up a coordinate system and display the isosurface.
    scale3, xrange=[-maxv0,maxv0], yrange=[-maxv0,maxv0], $
        zrange=[-maxv0,maxv0]
    wset, win_id
    set_shading, reject=0, /gouraud, light=[1,1,1]
    tvscl, polyshade(v0, p0, /t3d, /data)

end
