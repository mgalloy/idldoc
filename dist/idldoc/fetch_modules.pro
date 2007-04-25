;+
; Returns the code of each routine in a file.
;
; @returns array of pointers to string arrays
; @param file {in}{required}{type=string} filename of file to grab routines from
; @categories introspection
; @author DDL, RSI
;-
function fetch_modules,file

    openr,lun,file,/Get_lun

    str = ''
    nmodules = 0

    sixo = !version.release EQ '6.0'

    while (not eof(lun)) do begin
       readf,lun,str
       str = STRUPCASE(STRTRIM(str,2))
       IF STRMID(str,0,9) EQ 'FUNCTION ' OR STRMID(str,0,4) EQ 'PRO ' THEN BEGIN
        IF sixo THEN void=EXECUTE('nmodules += 1') ELSE $
            nmodules = nmodules+1
       ENDIF
    endwhile

    nlinesmods = LONARR(nmodules)

    point_lun,lun,0
    FOR i=0,nmodules-1 DO BEGIN
    nlines = 1
    readf,lun,str
    incase = 0
    WHILE (STRUPCASE(STRTRIM(str,2)) NE 'END') OR $
        (STRUPCASE(STRTRIM(str,2)) EQ 'END' AND (incase NE 0)) DO BEGIN
       readf,lun,str
       str = STRUPCASE(STRTRIM(str,2))
       IF STRMID(str,0,5) EQ 'CASE ' THEN BEGIN
            IF sixo THEN void=EXECUTE('incase +=1') ELSE incase=incase+1
       ENDIF
       IF incase GT 0 AND STRMID(str,0,3) EQ 'END' OR STRMID(str,0,7) EQ 'ENDCASE'THEN BEGIN
            IF sixo THEN void=EXECUTE('incase -=1') ELSE incase=incase-1
       ENDIF
       IF sixo THEN void=EXECUTE('nlines +=1') ELSE nlines=nlines+1
    ENDWHILE
    nlinesmods[i] = nlines
    ENDFOR

    codes = PTRARR(nmodules)

    point_lun,lun,0
    FOR i=0,nmodules-1 DO BEGIN
    nlines = nlinesmods[i]
    code = strarr(nlines)
    readf,lun,code
    codes[i] = PTR_NEW(code)
    ENDFOR

    free_lun,lun

    return,codes

end


