;+
;   Reads a modified 'off' format file. (header removed, etc.)
;
; @param file {in}{type=string} filename of the .off file
; @param verts {out}{type=float array} the vertex array
; @param mesh {out}{type=long array} the connectivity list
;-
PRO READ_NOFF, file, verts, mesh

    ; Open the file.
    GET_LUN,lun
    OPENR, lun,  file

    ; Read in header information.
    READF, lun, nverts, npatches, nconn, patchSize
    PRINT,'Reading: ', file,' # Patches=',npatches,' # Verts=',nverts

    ; Allocate vertex array.
    verts = FLTARR(3, nverts)

    ; Read in vertices.
    READF, lun, verts

    ; Allocate a connectivity mesh.
    IF (patchSize NE -1) THEN BEGIN
        meshSize = npatches*(patchSize+1)
    ENDIF ELSE BEGIN
        meshSize = nconn+npatches
    ENDELSE
    mesh=LONARR(meshSize)

    ; Read in mesh connectivity.
    j = 0
    s = ' '
    npatchSize = 1
    FOR i=0,npatches-1 DO BEGIN
        IF (patchSize NE -1) THEN BEGIN
            mesh(j) = patchSize
            IF (patchSize EQ 3) THEN BEGIN      ; Triangles.
                READF, lun, dummy, m1, m2, m3
                mesh(j+1)=m1
                mesh(j+2)=m2
                mesh(j+3)=m3
            ENDIF ELSE BEGIN                    ; Quads.
                READF, lun, dummy, m1, m2, m3, m4
                mesh(j+1)=m1
                mesh(j+2)=m2
                mesh(j+3)=m3
                mesh(j+4)=m4
            ENDELSE
            j = j + patchSize+1
        ENDIF ELSE BEGIN
            READF, lun, s                  ; Read a string.
            READS, s, npatchSize           ; Read patchSize from string.
        arr = LONARR(npatchSize+1)
        READS,s,arr                ; Read connectivity from string.
        mesh(j:j+npatchSize) = arr
        j = j + npatchSize+1
        ENDELSE
    ENDFOR

    ; Close the file.
    FREE_LUN, lun

    ; Scale vertices into [-1,-1,-1] to [1,1,1] range, centered on [0,0,0],
    ; maintaining aspect ratio.
    xMin = MIN(verts(0,*), MAX=xMax)
    yMin = MIN(verts(1,*), MAX=yMax)
    zMin = MIN(verts(2,*), MAX=zMax)
    xDelta = xMax-xMin
    yDelta = yMax-yMin
    zDelta = zMax-zMin
    maxDelta = MAX([xDelta, yDelta, zDelta])
    xShift = (maxDelta - xDelta) / 2.
    yShift = (maxDelta - yDelta) / 2.
    zShift = (maxDelta - zDelta) / 2.
    verts(0,*) = 2.*(verts(0,*) - xMin + xShift)/maxDelta-1.
    verts(1,*) = 2.*(verts(1,*) - yMin + yShift)/maxDelta-1.
    verts(2,*) = 2.*(verts(2,*) - zMin + zShift)/maxDelta-1.

END