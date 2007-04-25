; mesh_render_code1 - a time-saving code snippet.

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
