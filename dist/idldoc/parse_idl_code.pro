;+
; Remove spaces, strings, and comments from IDL code
;
; @param code {in}{required}{type=string array} IDL code
;-
 PRO sanitize_idl_code,code

   FOR i=0,N_ELEMENTS(code)-1 DO BEGIN

    ;Remove spaces
       line = STRTRIM(code[i],2)
    ;Remove strings
       IF STRPOS(line,"'") NE -1 OR STRPOS(line,'"') NE -1 THEN BEGIN
            line = ' '+line+' '        ; Pad with leading/trailing spaces to ensure
                                       ; proper calculation of number of tokens (below)
            doubleap = STRPOS(line,'"')
            singleap = STRPOS(line,"'")
         IF doubleap NE -1 AND singleap NE -1 THEN BEGIN
            IF doubleap LT singleap THEN singleap = -1
            IF (singleap LT doubleap) AND (singleap NE -1) THEN doubleap = -1
         ENDIF
         IF singleap NE -1 THEN tokens = STRTOK(line,"'",/Extract)
         IF doubleap NE -1 THEN tokens = STRTOK(line,'"',/Extract)
         IF N_ELEMENTS(tokens) MOD 2 EQ 1 THEN BEGIN   ; Legitimate strings
            idx = INDGEN(N_ELEMENTS(tokens))
            ok = WHERE(idx MOD 2 EQ 0)
            line = STRTRIM(STRJOIN(tokens[ok]),2)
         ENDIF
       ENDIF
    ;Remove comments
       comment_pos = STRPOS(line,';')
       IF comment_pos NE -1 THEN line = STRMID(line,0,comment_pos)

       IF STRMID(line,0,1) NE ' ' THEN code[i] = ' '+STRUPCASE(line) $
          ELSE code[i] = STRUPCASE(line)    ; Insert leading space to identify reserved words
                                            ; at line beginnings
    ENDFOR

END

;+
; Consolidate multiple-line IDL statements onto one line
;
; @param code {in}{required}{type=string array} IDL code
;-
PRO concatenate_multiline_statements,code

   sixo = !version.release EQ '6.0'

   linenumber = 0
    WHILE linenumber LE N_ELEMENTS(code)-1 DO BEGIN

       line = code[linenumber]

       IF STRMID(line,STRLEN(line)-1,1) EQ '$' THEN BEGIN
              startline = linenumber
              finalchar = ' '
              tmpline = STRMID(line,0,STRLEN(line)-1)
              REPEAT BEGIN
                IF sixo THEN void=EXECUTE('linenumber += 1') ELSE linenumber=linenumber+1
                line = code[linenumber]
                finalchar = STRMID(line,STRLEN(line)-1,1)
                nextline = STRMID(line,0,STRLEN(line))
                IF sixo THEN void=EXECUTE('tmpline += nextline') ELSE tmpline=tmpline+nextline
                code[linenumber] = ' '
              ENDREP UNTIL (finalchar NE '$')
              code[startline] = tmpline
        ENDIF

       IF sixo THEN void=EXECUTE('linenumber += 1') ELSE linenumber=linenumber+1

    ENDWHILE

    code = code[WHERE(code NE ' ')]

END

;+
; Separate multiple IDL statements on a single line into different lines
;
; @param code {in}{required}{type=string array} IDL code
;-
PRO split_multistatement_lines,code

   parsedcode = STRARR(N_ELEMENTS(code)*5)
   sixo = !version.release EQ '6.0'

   ampersand = STRPOS(code,'&')
    ampersandidx = WHERE(ampersand NE -1,Count)
    IF Count NE 0 THEN BEGIN
       parsedcodeline = 0

       FOR i=0, N_ELEMENTS(code)-1 DO BEGIN

           line = code[i]

          ; Replace any && operators with an innocuous placeholder

           IF STRPOS(line,'&&') NE -1 THEN BEGIN
              REPEAT BEGIN
                doubleamp = STRPOS(line,'&&')
                line = STRMID(line,0,doubleamp)+'ANDAND'+STRMID(line,doubleamp+2,STRLEN(line)-doubleamp-1)
;                mccabe_dummy_pro
              ENDREP UNTIL STRPOS(line,'&&') EQ -1
           ENDIF

           ampersand = STRPOS(line,'&')
           IF ampersand NE -1 THEN BEGIN
              statements = STRTOK(line,'&',/Extract)
              parsedcode[parsedcodeline:parsedcodeline+N_ELEMENTS(statements)-1] = statements
              IF sixo THEN void=EXECUTE('parsedcodeline += N_ELEMENTS(statements)') ELSE $
                 parsedcodeline = parsedcodeline+N_ELEMENTS(statements)
           ENDIF ELSE BEGIN
                parsedcode[parsedcodeline] = line
                parsedcodeline = parsedcodeline+1
           ENDELSE

       ENDFOR

       code = parsedcode[WHERE(parsedcode NE '')]


    ENDIF

END


;+
; Make all statement syntax explicit (with begin/ends etc.)
;
; @param code {in}{required}{type=string array} IDL code
;-
PRO expand_statements,code

    sixo = !version.release EQ '6.0'
    parsedcode = STRARR(N_ELEMENTS(code)*10)

;-------------------------------------------------------------
    ; Break single-line statements into multiline "blocks"
;-------------------------------------------------------------
    REPEAT BEGIN

       parsed=1
       parsedcodeline = 0

       oddifdo = 0
       oddifcase = 0
       oddifrepeat = 0

       FOR i=0, N_ELEMENTS(code)-1 DO BEGIN
           line = code[i]

         IF (STRPOS(line,' DO ') NE -1 AND STRPOS(line,' DO BEGIN') EQ -1 AND $
            (STRPOS(STRTRIM(line,1),'FOR') EQ 0 OR STRPOS(STRTRIM(line,1),'WHILE') EQ 0)) THEN BEGIN
               parsedcode[parsedcodeline] = STRMID(line,0,STRPOS(line,' DO')+3)+' BEGIN'
               parsedcode[parsedcodeline+1] = STRMID(line,STRPOS(line,' DO')+3, $
                                     STRLEN(line)-STRPOS(line,' DO')+3)
               parsedcode[parsedcodeline+2] = 'ENDDO'
               IF sixo THEN void=EXECUTE('parsedcodeline += 3') ELSE parsedcodeline=parsedcodeline+3
               parsed=0

               ENDIF ELSE BEGIN

               IF (STRPOS(STRTRIM(line,1),'REPEAT ') EQ 0 AND STRPOS(line,' REPEAT BEGIN') EQ -1) THEN BEGIN
                  parsedcode[parsedcodeline] = STRMID(line,0,STRPOS(line,' REPEAT')+7)+' BEGIN'
                  parsedcode[parsedcodeline+1] = STRMID(line,STRPOS(line,' REPEAT')+7, $
                                            STRLEN(line)-STRPOS(line,' REPEAT')+7)
                  parsedcode[parsedcodeline+2] = 'ENDREP'
                  IF sixo THEN void=EXECUTE('parsedcodeline += 3') ELSE parsedcodeline=parsedcodeline+3
                  parsed=0

               ENDIF ELSE BEGIN

               IF (STRPOS(line,' ELSE ') NE -1 AND STRPOS(line,' ELSE BEGIN') EQ -1 AND $
                      STRPOS(STRCOMPRESS(line,/Remove_all),'ELSE:') EQ -1) THEN BEGIN
                   parsedcode[parsedcodeline] = STRMID(line,0,STRPOS(line,' ELSE'))
                   parsedcode[parsedcodeline+1] = ' ELSE BEGIN'
                   parsedcode[parsedcodeline+2] = STRMID(line,STRPOS(line,' ELSE')+5, $
                                     STRLEN(line)-STRPOS(line,' ELSE')+5)
                   parsedcode[parsedcodeline+3] = 'ENDELSE'
                   IF sixo THEN void=EXECUTE('parsedcodeline += 4') ELSE parsedcodeline=parsedcodeline+4
                   parsed=0

               ENDIF ELSE BEGIN

               IF (STRPOS(STRTRIM(line,1),'IF') EQ 0 AND STRPOS(line,' THEN ') NE -1 AND STRPOS(line,' THEN BEGIN') EQ -1) THEN BEGIN
                    parsedcode[parsedcodeline] = STRMID(line,0,STRPOS(line,' THEN')+5)+' BEGIN'
                    parsedcode[parsedcodeline+1] = STRMID(line,STRPOS(line,' THEN')+5, $
                                     STRLEN(line)-STRPOS(line,' THEN')+5)
                    parsedcode[parsedcodeline+2] = 'ENDIF'
                    remainder = STRMID(line,STRPOS(line,' THEN')+5,STRLEN(line)-STRPOS(line,' THEN')+5)
                    IF STRMID(STRTRIM(remainder,1),0,5) EQ 'CASE ' THEN BEGIN
                        parsedcode[parsedcodeline+2] = ''
                        oddifcase = 1
                    ENDIF
                    IF STRPOS(remainder,'DO BEGIN') NE -1 THEN BEGIN
                        parsedcode[parsedcodeline+2] = ''
                        oddifdo = 1
                    ENDIF
                    IF STRPOS(remainder,'REPEAT BEGIN') NE -1 THEN BEGIN
                        parsedcode[parsedcodeline+2] = ''
                        oddifrepeat = 1
                    ENDIF
                    IF sixo THEN void=EXECUTE('parsedcodeline += 3') ELSE parsedcodeline = parsedcodeline+3
                    parsed=0

                ENDIF ELSE BEGIN
                   IF STRCOMPRESS(line,/Remove_all) EQ 'ENDIFELSEBEGIN' THEN BEGIN
                     parsedcode[parsedcodeline] = 'ENDIF'
                     parsedcode[parsedcodeline+1] = ' ELSE BEGIN'
                     IF sixo THEN void=EXECUTE('parsedcodeline +=2') ELSE parsedcodeline=parsedcodeline+2
                     parsed=0
                ENDIF ELSE BEGIN
                IF STRCOMPRESS(line,/Remove_all) EQ 'ENDELSEBEGIN' THEN BEGIN
                     parsedcode[parsedcodeline+1] = ' END '
                     parsedcode[parsedcodeline+1] = ' ELSE BEGIN'
                     IF sixo THEN void=EXECUTE('parsedcodeline +=2') ELSE parsedcodeline=parsedcodeline+2
                     parsed=0
                ENDIF ELSE BEGIN
                IF STRPOS(line,' ELSE BEGIN') NE -1 AND STRCOMPRESS(line,/Remove_all) NE 'ELSEBEGIN' THEN BEGIN
                      parsedcode[parsedcodeline] = STRMID(line,0,STRPOS(line,'ELSE'))
                      parsedcode[parsedcodeline+1] = ' ELSE BEGIN'
                      IF sixo THEN void=EXECUTE('parsedcodeline +=2') ELSE parsedcodeline=parsedcodeline+2
                      parsed=0
                ENDIF ELSE BEGIN
                IF (STRTRIM(line,2) EQ 'ENDFOR' OR STRTRIM(line,2) EQ 'ENDWHILE') AND oddifdo THEN BEGIN
                      parsedcode[parsedcodeline] = 'ENDDO'
                      parsedcode[parsedcodeline+1] = 'ENDIF'
                      IF sixo THEN void=EXECUTE('parsedcodeline +=2') ELSE parsedcodeline=parsedcodeline+2
                      parsed=0
                      oddifdo = 0
                ENDIF ELSE BEGIN
                IF STRTRIM(line,2) EQ 'ENDCASE' AND oddifcase THEN BEGIN
                      parsedcode[parsedcodeline] = 'ENDCASE'
                      parsedcode[parsedcodeline+1] = 'ENDIF'
                      IF sixo THEN void=EXECUTE('parsedcodeline +=2') ELSE parsedcodeline=parsedcodeline+2
                      parsed=0
                      oddifcase = 0
                 ENDIF ELSE BEGIN
                 IF STRTRIM(line,2) EQ 'ENDREP' AND oddifrepeat THEN BEGIN
                      parsedcode[parsedcodeline] = 'ENDREP'
                      parsedcode[parsedcodeline+1] = 'ENDIF'
                      IF sixo THEN void=EXECUTE('parsedcodeline +=2') ELSE parsedcodeline=parsedcodeline+2
                      parsed=0
                      oddifrepeat = 0

                 ENDIF ELSE BEGIN
                           parsedcode[parsedcodeline] = line
                           IF sixo THEN void=EXECUTE('parsedcodeline += 1') ELSE parsedcodeline=parsedcodeline+1


                   ENDELSE
                 ENDELSE
               ENDELSE
             ENDELSE
            ENDELSE
           ENDELSE
          ENDELSE
         ENDELSE
        ENDELSE
       ENDELSE


      ENDFOR

       code = parsedcode[WHERE(parsedcode NE '')]

   ENDREP UNTIL (parsed EQ 1)

;-------------------------------------------------------------------
 ; Change any interior ENDs to their more informative counterpart
;-------------------------------------------------------------------
   REPEAT BEGIN

       parsed=1
       parsedcodeline = 0

       stack = [0]          ; For tracking statement blocks closed with plain END (rather than ENDIF, ENDCASE...)

       FOR i=0, N_ELEMENTS(code)-1 DO BEGIN

           line = code[i]

           IF STRTRIM(line,2) EQ 'END' AND (stack[0] EQ 6 OR stack[0] EQ 8 OR $
                                            stack[0] EQ 10 OR stack[0] EQ 12 OR $
                                            stack[0] EQ 4 OR stack[0] EQ 16) THEN BEGIN
                      CASE stack[0] OF
                        4: parsedcode[parsedcodeline] = 'CASENODEEND'
                        6: BEGIN
                             parsedcode[parsedcodeline] = 'ENDIF'
                          END
                        8: BEGIN
                            parsedcode[parsedcodeline] = 'ENDELSE'
                          END
                        10: BEGIN
                            parsedcode[parsedcodeline] = 'ENDDO'
                          END
                        12: BEGIN
                            parsedcode[parsedcodeline] = 'ENDREP'
                            END
                        16: BEGIN
                           parsedcode[parsedcodeline] = 'ENDCASE'
                          END
                       ENDCASE
                       stack = stack[1:N_ELEMENTS(stack)-1]
                       parsedcodeline=parsedcodeline+1

            ENDIF ELSE BEGIN

            IF (STRTRIM(line,2) EQ 'ENDCASE' AND stack[0] EQ 4) THEN BEGIN
                      parsedcode[parsedcodeline] = 'CASENODEEND'
                      IF sixo THEN void=EXECUTE('parsedcodeline += 1') ELSE parsedcodeline=parsedcodeline+1
                      stack = stack[1:N_ELEMENTS(stack)-1]
           ENDIF ELSE BEGIN

           IF (STRTRIM(line,2) EQ 'ENDELSE' AND stack[0] EQ 4) THEN BEGIN
                      parsedcode[parsedcodeline] = 'CASENODEEND'
                      IF sixo THEN void=EXECUTE('parsedcodeline += 1') ELSE parsedcodeline=parsedcodeline+1
                      stack = stack[1:N_ELEMENTS(stack)-1]
           ENDIF ELSE BEGIN

           IF STRPOS(line,':') NE -1 AND STRPOS(STRCOMPRESS(line,/Remove_all),':BEGIN') EQ -1 AND stack[0] EQ 16 THEN BEGIN
                      parsedcode[parsedcodeline] = STRMID(line,0,STRPOS(line,':')+1)+'BEGIN'
                      parsedcode[parsedcodeline+1] = STRMID(line,STRPOS(line,':')+1, $
                                                     STRLEN(line)-STRPOS(line,':')+1)
                      parsedcode[parsedcodeline+2] = 'CASENODEEND'
                      IF sixo THEN void=EXECUTE('parsedcodeline += 3') ELSE parsedcodeline = parsedcodeline+3
                      parsed=0
           ENDIF ELSE BEGIN

               parsedcode[parsedcodeline] = line
               IF sixo THEN void=EXECUTE('parsedcodeline += 1') ELSE parsedcodeline=parsedcodeline+1

               IF STRPOS(line,'THEN BEGIN') NE -1 THEN stack = [6,stack]
               IF STRPOS(line,'ELSE BEGIN') NE -1 THEN stack = [8,stack]
               IF STRPOS(line,'DO BEGIN') NE -1 THEN stack = [10,stack]
               IF STRPOS(line,'REPEAT BEGIN') NE -1 THEN stack = [12,stack]
               IF STRPOS(line,' CASE ') NE -1 THEN stack = [16,stack]
               IF STRPOS(line,' SWITCH ') NE -1 THEN stack = [16,stack]
               IF STRPOS(STRCOMPRESS(line,/Remove_all),':BEGIN') NE -1 AND stack[0] EQ 16 THEN stack = [4,stack]


               IF ((STRPOS(line,'ENDIF') NE -1 OR STRPOS(line,'ENDELSE') NE -1 OR $
                   STRPOS(line,'ENDDO') NE -1 OR STRPOS(line,'ENDFOR') NE -1 OR $
                   STRPOS(line,'ENDWHILE') NE -1 OR STRPOS(line,'ENDREP') NE -1 OR $
                   STRPOS(line,'ENDCASE') NE -1 OR STRPOS(line,'ENDSWITCH') NE -1 OR $
                   STRPOS(line,'CASENODEEND') NE -1) AND stack[0] NE 0) THEN stack = stack[1:N_ELEMENTS(stack)-1]

            ENDELSE
          ENDELSE
       ENDELSE
      ENDELSE

     ENDFOR

     code = parsedcode[WHERE(parsedcode NE '')]

   ENDREP UNTIL (parsed EQ 1)


END


;+
; Flag nodes
;
; @returns integer array
; @param code {in}{required}{strarr} IDL code
; @keyword user_filenames {in}{optional}{type=string} all filenames to search for routines
; @keyword user_routines {out}{optional}{type=structarray} Array of structures of the form
;                                    {name,path} for each user routine called by originalcode
;-
FUNCTION flag_nodes,code, User_filenames=user_filenames, User_routines=user_routines

    codeflags = INTARR(N_ELEMENTS(code)) + 1  ; Flag everything as a "normal" node by default

    sixo = !version.release EQ '6.0'

   ; Resolve routines (for use in flagging below)

    pathsep = PATH_SEP()
    nfiles = N_ELEMENTS(user_filenames)
    files = user_filenames
    IF sixo THEN $
         FOR i=0,nfiles-1 DO files[i] = (STRTOK(files[i],pathsep,/Extract,Count=count))[count-1]
    IF NOT sixo THEN BEGIN
         FOR i=0,nfiles-1 DO BEGIN
             filesi = STRTOK(files[i],pathsep,/Extract)
             Count = N_ELEMENTS(filesi)
             files[i] = filesi[count-1]
         ENDFOR
    ENDIF
    FOR i=0,nfiles-1 DO files[i] = STRMID(files[i],0,STRPOS(files[i],'.',/Reverse_search))
    FOR i=0,nfiles-1 DO BEGIN
        files[i] = STRMID(files[i],0,STRPOS(files[i],'.',/Reverse_search))
        IF STRPOS(files[i],'__') NE -1 THEN files[i] = STRMID(files[i],0,STRPOS(files[i],'__'))+ $
                       '::'+STRMID(files[i],STRPOS(files[i],'__')+2,STRLEN(files[i])-STRPOS(files[i],'__'))
    ENDFOR
    RESOLVE_ROUTINE, files, /Either, /Compile_full_file, /No_recompile
    pros = ROUTINE_INFO(/Source)
    functions = ROUTINE_INFO(/Functions,/Source)


    FOR i=0,N_ELEMENTS(code)-1 DO BEGIN

      line = code[i]

      routinename = ''
      routinenames = ['']

      ; Routines: pros w/arguments and functs w/multiple arguments (presence of comma)
      comma_pos = STRPOS(line,',')
      IF comma_pos NE -1 THEN BEGIN
         tokens = STRTOK(line,',',/Extract)
         IF (((STRPOS(tokens[0],' FUNCTION ') EQ -1 AND STRPOS(tokens[0],' PRO ') EQ -1 AND $
                  STRPOS(tokens[0],' RETURN') EQ -1)) AND $
                  ((STRPOS(tokens[0],'=') NE -1 AND STRPOS(tokens[0],'(') NE -1) OR $
                  (STRPOS(tokens[0],'=') EQ -1 AND STRPOS(tokens[0],'(') EQ -1))) THEN BEGIN
             IF STRPOS(tokens[0],'=') EQ -1 THEN BEGIN
                routinename = STRTRIM(tokens[0],2)
                routinenames = [routinename,routinenames]
                ; Check for function calls in the procedure arguments
                IF N_ELEMENTS(tokens) GT 1 THEN BEGIN
                 functline = STRJOIN(tokens[1:N_ELEMENTS(tokens)-1])
                 functokens = STRTOK(functline,'(',/Extract)
                 FOR j=0,N_ELEMENTS(functokens)-1 DO BEGIN
                    functoken = functokens[j]
                    IF STRPOS(functoken,'=') NE -1 THEN $
                        functoken = STRMID(functoken,STRPOS(functoken,'=',/Reverse_search)+1,STRLEN(functoken)-1)
                    IF STRPOS(functoken,' ') EQ -1 AND STRPOS(functoken,'+') EQ -1 AND $
                        STRPOS(functoken,'-') EQ -1 AND STRPOS(functoken,'*') EQ -1 AND $
                        STRPOS(functoken,'/') EQ -1 AND STRPOS(functoken,'[') EQ -1 AND $
                        STRPOS(functoken,']') EQ -1 AND STRPOS(functoken,')') EQ -1 THEN $
                           routinenames = [functoken, routinenames]
                 ENDFOR
               ENDIF
            ENDIF
            IF STRPOS(tokens[0],'=') NE -1 THEN BEGIN   ;Function call
               tokenseq = STRTOK(tokens[0],'=',/Extract)
               tokens1 = tokenseq[1]
               tokensparen = STRTOK(tokens1,'(',/Extract)
               routinename = STRTRIM(tokensparen[0],2)
               routinenames = [routinename,routinenames]
               ; Check for function calls in the function arguments
              IF N_ELEMENTS(tokens) GT 1 THEN BEGIN
                 functline = STRJOIN(tokens[1:N_ELEMENTS(tokens)-1])
                 functokens = STRTOK(functline,'(',/Extract)
                 FOR j=0,N_ELEMENTS(functokens)-1 DO BEGIN
                    functoken = functokens[j]
                    IF STRPOS(functoken,'=') NE -1 THEN $
                        functoken = STRMID(functoken,STRPOS(functoken,'=',/Reverse_search)+1,STRLEN(functoken)-1)
                    IF STRPOS(functoken,' ') EQ -1 AND STRPOS(functoken,'+') EQ -1 AND $
                        STRPOS(functoken,'-') EQ -1 AND STRPOS(functoken,'*') EQ -1 AND $
                        STRPOS(functoken,'/') EQ -1 AND STRPOS(functoken,'[') EQ -1 AND $
                        STRPOS(functoken,']') EQ -1 AND STRPOS(functoken,')') EQ -1 THEN $
                           routinenames = [functoken, routinenames]
                 ENDFOR
               ENDIF
            ENDIF
            codeflags[i] = 2
         ENDIF
       ENDIF

       ; One-or-zero-argument function-call case
       paren_pos = STRPOS(line,'(')
       IF paren_pos NE -1 THEN BEGIN
         tokens = STRTOK(line,'(',/Extract)
         IF STRPOS(tokens[0],'=') NE -1 AND STRPOS(tokens[0],',') EQ -1 $
              AND STRMID(tokens[0],STRLEN(tokens[0])-1,1) NE '=' THEN BEGIN
          tokenseq = STRTOK(line,'=',/Extract)
          parenstok = STRTOK(tokenseq[1],'(',/Extract)
             FOR j=0,N_ELEMENTS(parenstok)-1 DO BEGIN
                routinenames = [(STRTOK(parenstok[j],')',/Extract))[0],routinenames]
             ENDFOR
            codeflags[i] = 2
          ENDIF ELSE BEGIN   ; Special cases
            tokens0 = STRCOMPRESS(tokens[0],/Remove_all)
            IF STRPOS(tokens0,'+',/Reverse_search) NE -1 THEN $
                routinename = STRMID(tokens0,STRPOS(tokens0,'+',/Reverse_search)+1,$
                        STRLEN(tokens0)-STRPOS(tokens0,'+',/Reverse_search))
            IF STRPOS(tokens0,'-',/Reverse_search) NE -1 THEN $
                routinename = STRMID(tokens0,STRPOS(tokens0,'-',/Reverse_search)+1,$
                        STRLEN(tokens0)-STRPOS(tokens0,'-',/Reverse_search))
            IF STRPOS(tokens0,'*',/Reverse_search) NE -1 THEN $
                routinename = STRMID(tokens0,STRPOS(tokens0,'*',/Reverse_search)+1,$
                        STRLEN(tokens0)-STRPOS(tokens0,'*',/Reverse_search))
            IF STRPOS(tokens0,'/',/Reverse_search) NE -1 THEN $
                routinename = STRMID(tokens0,STRPOS(tokens0,'/',/Reverse_search)+1,$
                        STRLEN(tokens0)-STRPOS(tokens0,'/',/Reverse_search))
            codeflags[i] = 2
          ENDELSE
       ENDIF

       routinenames = [routinename,routinenames]

       ; Zero-argument procedure calls
       IF STRPOS(STRTRIM(line,2),' ') EQ -1 AND STRPOS(line,',') EQ -1 AND STRPOS(line,'=') EQ -1  $
         AND STRPOS(line,':') EQ -1 AND STRPOS(line,'->') EQ -1 THEN BEGIN
          routinename = STRTRIM(line,2)
          codeflags[i] = 2
       ENDIF

       IF routinename NE '' THEN routinenames = [routinename,routinenames]


        ; Find embedded function calls
        spacetok = STRTOK(line,' ',/Extract)
;        ok = WHERE(STRPOS(spacetok,'(') NE -1 AND STRMID(spacetok,0,1) NE '(',Count)
        ok = WHERE(STRPOS(spacetok,'(') NE -1,Count)
        IF Count NE 0 THEN BEGIN
             newroutinenames = STRARR(N_ELEMENTS(ok))
             FOR k=0,N_ELEMENTS(ok)-1 DO newroutinenames[k] = (STRTOK(spacetok[ok[k]],'(',/ext))[0]
             routinenames = [routinenames,newroutinenames]
             IF routinename NE '' THEN routinenames = [routinename,routinenames]
             codeflags[i] = 2
        ENDIF

        ; Object methods
        IF STRPOS(line,'->') NE -1 THEN BEGIN
          tokens = STRTOK(line,'->',/Extract)
          call = tokens[1]
          IF STRPOS(call,'(') THEN BEGIN
              tokensparen = STRTOK(call,'(',/Extract)
              routinename = tokensparen[0]
          ENDIF
          IF STRPOS(call,'(') EQ -1 AND STRPOS(call,',') NE -1 THEN BEGIN
              tokenscomma = STRTOK(call,',',/Extract)
              routinename = tokenscomma[0]
          ENDIF
          IF (STRPOS(call,'(') EQ -1 AND STRPOS(call,',') EQ -1) THEN routinename=call
          codeflags[i] = 2
        ENDIF

       IF routinename NE '' THEN routinenames = [routinename,routinenames]

       ; User routine?
       FOR m=0,N_ELEMENTS(routinenames)-1 DO BEGIN
         routinename = routinenames[m]
         IF routinename NE '' THEN BEGIN
            yespro = WHERE(pros.name EQ routinename,Countpro)
            yesfunct = WHERE(functions.name EQ routinename,Countfunct)
            IF (Countpro NE 0 OR Countfunct NE 0) THEN BEGIN
                IF Countpro NE 0 THEN BEGIN
                    index = yespro[0]
                    thispath = pros[index].path
                    thisroutine = pros[index]
                    root = STRMID(thispath,0,StrPos(thispath, pathSep, /Reverse_Search) + 1)
                ENDIF ELSE BEGIN
                    index = yesfunct[0]
                    thispath = functions[index].path
                    thisroutine = functions[index]
                    root = STRMID(thispath,0,StrPos(thispath, pathSep, /Reverse_Search) + 1)
                ENDELSE
           fileok = WHERE(STRUPCASE(thispath) EQ user_filenames,Countfile)
             IF Countfile NE 0 THEN BEGIN
                codeflags[i] = 3
                idx = WHERE(user_routines.name EQ thisroutine.name,Countidx)
                IF Countidx EQ 0 THEN user_routines = [user_routines,thisroutine]
             ENDIF ELSE codeflags[i] = 2
            ENDIF
         ENDIF
       ENDFOR

      ; Case/switch
      IF STRPOS(STRCOMPRESS(line,/Remove_all),':BEGIN') NE -1 THEN codeflags[i] = 4
      IF STRPOS(line,'CASENODEEND') NE -1 THEN codeflags[i] = 5
      IF STRPOS(line,'ENDCASE') NE -1 THEN codeflags[i] = 17
      IF STRPOS(line,'ENDSWITCH') NE -1 THEN codeflags[i] = 1

      ; Conditionals
      IF STRPOS(line,' THEN BEGIN') NE -1 THEN codeflags[i] = 6
      IF STRPOS(line,'ENDIF') NE -1 THEN codeflags[i] = 7
      IF STRPOS(line,' ELSE BEGIN') NE -1 THEN codeflags[i] = 8
      IF STRPOS(line,'ENDELSE') NE -1 THEN codeflags[i] = 9

      ; Top-test loops
      IF STRPOS(line,' DO BEGIN') NE -1 THEN codeflags[i] = 10
      IF (STRPOS(line,'ENDDO') NE -1 OR STRPOS(line,'ENDFOR') NE -1 OR $
            STRPOS(line,'ENDWHILE') NE -1) THEN codeflags[i] = 11

      ; Bottom-test loops
      IF STRPOS(line,' REPEAT BEGIN') NE -1 THEN codeflags[i] = 12
      IF STRPOS(line,'ENDREP') NE -1 THEN codeflags[i] = 13

      ; Jumps
      IF STRPOS(line,' BREAK') NE -1 OR STRPOS(line,' GOTO') NE -1 THEN codeflags[i] = 14

      ; End of program
      IF STRTRIM(line,2) EQ 'END' THEN codeflags[i] = 15

    ENDFOR

    ok = WHERE(user_routines.name NE '',Countok)
       IF Countok GT 0 THEN user_routines = user_routines[ok] ELSE user_routines = [{name:'',path:''}]

    RETURN,codeflags

END


;+
; Parse IDL code (written for McCabe complexity metric calculation)
;
; @file_comments The parse_idl_code routine parses IDL code for the purpose
;                of calculating McCabe complexity metrics (cyclomatic complexity,
;                design complexity, and essential complexity).
; @returns integer array
; @param originalcode {in}{required}{strarr} IDL code
; @keyword parsedcode {out}{optional}{type=string} if set, return the
;          parsed code
; @keyword user_filenames {in}{optional}{type=string} all filenames to search for routines
; @keyword user_routines {out}{optional}{type=structarray} Array of structures of the form
;                                    {name,path} for each user routine called by originalcode
; @author DDL, RSI, September 2003
; @categories introspection
; @todo <ul><li>Search SAV files for user routines?</li>
;         <li>Generalize the "oddif" handling in expand_statements to handle similar constructs for else, for, etc.
;                e.g. (from FreeLook viewer_files.pro):<code class="section">
; for i=0, num_bands-1 do $
;   if (data.p_data(9+i) eq 0) then begin
;     handle_value, data.h_data(13+i,data.hdp), d_image, /no_copy
;     s_image = congrid(d_image, rns, rnl)
;     handle_value, data.h_data(13+i,data.hdp), d_image, /set, /no_copy
;     handle_value, data.h_data(9+i,data.hdp), s_image, /set, /no_copy
;   endif</code><br/>
;           Currently, code containing constructs like those above (except for if statements) will not
;           parse correctly and the correct metrics will not be returned.</li>
;         <li>Change flag_nodes to use lists of user pros/functions passed in from idldoc (lists generated
;           by idldoc) rather than generating these lists with RESOLVE_ROUTINE and ROUTINE_INFO</li></ul>
;-
 FUNCTION parse_idl_code, originalcode, Parsedcode=parsedcode, User_filenames=user_filenames, $
       User_routines=user_routines
    COMPILE_OPT idl2

;    CATCH, errornum
;    IF (errornum NE 0) THEN BEGIN
;       CATCH,/Cancel
;       HELP,/Last_message, Output=errormessage
;       PRINT, errormessage
;       RETURN,0
;    ENDIF

    code = originalcode

    IF N_ELEMENTS(user_filenames) EQ 0 THEN user_filenames = $
           FILE_SEARCH(STRUPCASE(sourceroot()),'*.pro',/Fully)
    user_filenames = STRUPCASE(user_filenames)
    user_routines = [{name:'',path:''}]

    ; First strip off spaces/comments and uppercase everything
      sanitize_idl_code,code

    ; Next concatenate statements spanning more than one line onto one line
      concatenate_multiline_statements,code

    ; Break multiple-statement lines onto different lines
      split_multistatement_lines,code

    ; Break multinode statements onto different lines
      expand_statements,code

    ; Finally, flag the different types of nodes
      codeflags = flag_nodes(code,user_filenames=user_filenames,user_routines=user_routines)

    ; Snip off extraneous lines
    endoffile = WHERE(codeflags EQ 15,Count)
    codeflags = codeflags[0:endoffile[0]]

    parsedcode=code[0:endoffile[0]]

    RETURN, codeflags

END



