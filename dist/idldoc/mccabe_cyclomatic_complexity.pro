;+
; Calculate McCabe cyclomatic complexity
;
; @returns integer
; @param code {in}{required}{strarr} IDL code
; @keyword flags {in}{optional}{type=integer} if set, do not need to parse code
; @author DDL, RSI, September 2003
;-

 FUNCTION mccabe_cyclomatic_complexity,code,Flags=flags
    COMPILE_OPT idl2

    sixo = !version.release EQ '6.0'

    IF N_ELEMENTS(flags) NE 0 THEN parsedcode=code ELSE $
        flags = parse_idl_code(code, Parsedcode=parsedcode)


    ifthen = WHERE(flags EQ 6,nIfThen)
    casenode = WHERE(flags EQ 4,nCaseNode)
    toptestloop = WHERE(flags EQ 10,nTopTest)
    bottomtestloop = WHERE(flags EQ 12,nBottomTest)

    andand = WHERE(STRPOS(parsedcode,'ANDAND') NE -1,Count)
    nAndAnd = 0
    IF Count NE 0 THEN BEGIN
      FOR i=0,nAndAnd-1 DO BEGIN
       line = parsedcode[andand[i]]
       tokens = STRTOK(line,'ANDAND')
       IF sixo THEN void=EXECUTE('nAndAnd += N_ELEMENTS(tokens)-1') ELSE $
            nAndAnd = nAndAnd + N_ELEMENTS(tokens)-1
      ENDFOR
    ENDIF

    oror = WHERE(STRPOS(parsedcode,'||') NE -1, Count)
    nOrOr = 0
    IF Count NE 0 THEN BEGIN
      FOR i=0,nOrOr-1 DO BEGIN
       line = parsedcode[oror[i]]
       tokens = STRTOK(line,'||')
       IF sixo THEN void=EXECUTE('nOrOr += N_ELEMENTS(tokens)-1') ELSE $
            nOrOr = nOrOr + N_ELEMENTS(tokens)-1
      ENDFOR
    ENDIF

    complexity = nIfThen+nCaseNode+nTopTest+nBottomTest+nAndAnd+nOrOr+1

    RETURN, complexity

END

