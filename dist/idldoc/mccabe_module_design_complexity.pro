;+
; Calculate McCabe module design complexity
;
; @returns integer
; @param code {in}{required}{strarr} IDL code
; @author DDL, RSI, September 2003
;-

FUNCTION mccabe_module_design_complexity,code
    COMPILE_OPT idl2

    flags = parse_idl_code(code, Parsedcode=parsedcode)
    topflags = flags*0
    condflags = flags*0
    bottomflags = flags*0
    caseflags = flags*0
    elseflags = flags*0

    topflag = 0
    condflag = 0
    bottomflag = 0
    caseflag = 0
    elseflag = 0


    ; Flag structure depths
    FOR i=0,N_ELEMENTS(flags)-1 DO BEGIN
      IF flags[i] EQ 6 THEN condflag = condflag+1
      condflags[i] = condflag
      IF flags[i] EQ 7 THEN condflag = condflag-1
      IF flags[i] EQ 10 THEN topflag = topflag+1
      topflags[i] = topflag
      IF flags[i] EQ 11 THEN topflag = topflag-1
      IF flags[i] EQ 12 THEN bottomflag = bottomflag+1
      bottomflags[i] = bottomflag
      IF flags[i] EQ 13 THEN bottomflag = bottomflag-1
      IF flags[i] EQ 4 THEN caseflag = caseflag+1
      caseflags[i] = caseflag
      IF flags[i] EQ 5 THEN caseflag = caseflag-1
      IF flags[i] EQ 8 THEN elseflag = elseflag+1
      elseflags[i] = elseflag
      IF flags[i] EQ 9 THEN elseflag = elseflag-1
    ENDFOR

    blocktypes = ['cond','top','bottom','case','else']

    FOR i=0,N_ELEMENTS(blocktypes)-1 DO BEGIN
       CASE blocktypes[i] OF
         'cond': BEGIN
          maxdepth = MAX(condflags)
          blockstart = 6
          blockend = 7
          blockflags = condflags
          END
         'top': BEGIN
          maxdepth = MAX(topflags)
          blockstart = 10
          blockend = 11
          blockflags = topflags
          END
         'bottom': BEGIN
          maxdepth = MAX(bottomflags)
          blockstart = 12
          blockend = 13
          blockflags = bottomflags
          END
          'case': BEGIN
          maxdepth = MAX(caseflags)
          blockstart = 4
          blockend = 5
          blockflags = caseflags
          END
          'else': BEGIN
          maxdepth = MAX(elseflags)
          blockstart = 8
          blockend = 9
          blockflags = elseflags
          END
       ENDCASE

       FOR depth=maxdepth,1,-1 DO BEGIN
          ok = WHERE(blockflags EQ depth)
          blocks = flags[ok]
          startok = WHERE(blocks EQ blockstart,sCount)
          endok = WHERE(blocks EQ blockend,eCount)
          IF (sCount GT 0 AND eCount GT 0 AND sCount EQ eCount) THEN BEGIN
              starts = ok[WHERE(blocks EQ blockstart)]
              ends = ok[WHERE(blocks EQ blockend)]
              FOR j=0,N_ELEMENTS(starts)-1 DO BEGIN
                block = flags[starts[j]:ends[j]]
                calls = WHERE(block EQ 3,Count)
                IF Count EQ 0 THEN flags[starts[j]:ends[j]] = 0
              ENDFOR
          ENDIF
        ENDFOR

   ENDFOR

   complexity = mccabe_cyclomatic_complexity(parsedcode,Flags=flags)

   RETURN, complexity

END

