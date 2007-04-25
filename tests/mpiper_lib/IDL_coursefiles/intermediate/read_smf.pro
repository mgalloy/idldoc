;+
;   Reads an 'smf' format file.
;
; @param filename {in}{type=string} filename of the .smf file
; @param verts {out}{type=float array} the vertex array
; @param faces {out}{type=long array} the connectivity list
; @requires IDL 5.4
; @copyright RSI
;-
PRO read_smf, filename, verts, faces

    OPENR, lun, filename, /get_lun, ERROR=err
    IF (err NE 0) THEN BEGIN
        PRINTF, -2, !ERR_STRING
        RETURN
    ENDIF
    ; Read header records so we know how much data to read.
    buff = ''
    num_vertices = 0L
    num_faces = 0L
    READF, lun, buff
    IF ( buff NE '#$SMF 1.0') THEN RETURN
    READF, lun, buff
    READF, lun, buff
    IF ( STRMID(buff, 0, 11) NE '#$vertices ') THEN RETURN
    READS, STRMID(buff, 11),  num_vertices
    READF, lun, buff
    READF, lun, buff
    IF ( STRMID(buff, 0, 8) NE '#$faces ') THEN RETURN
    READS, STRMID(buff, 8),  num_faces

    verts=FLTARR(3,num_vertices)
    faces=LONARR(num_faces * 4)

    v = 0L
    f = 0L
    aa = 0L
    bb = 0L
    cc = 0L
    WHILE NOT EOF(lun) DO BEGIN
        READF, lun, buff
        ch = STRMID(buff, 0, 1)
        IF ch EQ 'v' THEN BEGIN
            READS, STRMID(buff, 1), a, b, c
            verts[0,v] = a
            verts[1,v] = b
            verts[2,v] = c
            v = v + 1
        ENDIF ELSE IF ch EQ 'f' THEN BEGIN
            READS, STRMID(buff, 1), aa, bb, cc
            faces[f+0] = 3
            faces[f+1] = aa-1
            faces[f+2] = bb-1
            faces[f+3] = cc-1
            f = f + 4
            ENDIF
        ENDWHILE

    CLOSE, lun
    FREE_LUN, lun
END
