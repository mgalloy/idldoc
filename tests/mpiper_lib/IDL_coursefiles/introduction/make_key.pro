;+
; NAME:
;      MAKE_KEY
;
; PURPOSE:
;      Create a color key for a plot.
;
;
; CALLING SEQUENCE:
;
;    MAKE_KEY,[[X,Y,XSIZE,YSIZE],[[XLABOFF,YLABOFF]]],COLORS=colors
;
;
; INPUTS:
;
;    No direct inputs required, except KEYWORD colors (see below).
;
;
; OUTPUTS:
;   A color key is drawn on the output device.
;
;
; OPTIONAL INPUT PARAMETERS:
;
;   X,Y:  x,y position of lower left corner of key.
;   XSIZE,YSIZE:  x,y size of key.
;       (If the above 4 are not supplied then optimal values are chosen.)
;
;   XLABOFF,YLABOFF:  x,y label offset (relative to lower left of box).
;       (If the above 2 are not supplied then optimal values are chosen.)
;
;	  All positions/sizes are in data coordinates, unless /NORMAL specified.
;
;
; KEYWORD PARAMETERS:
;
;   ALIGNMENT: label justification
;     (0=left (default for ORIENTATION=1), 0.5=center(default), 1=right)
;
;   BCOLOR: index (or scalar) of colors for border (default=!P.color)
;
;   CHARSIZE: size of labels (default=!P.charsize)
;
;   CHARTHICK: thickness of vector drawn characters (default=!P.charthick)
;
;   COLORS: array of Nbox colors for each box (this is required)
;
;   LABELS: array of strings for labels (can have 1 to Nbox+1 labels)
;
;   LINEANGLE: array of orientation angles of box fill lines
;
;   LINESPACING: array of line spacings (in cm) for box fill lines
;
;   NOBORDER: don't put a border around each box.
;
;   NORMAL: use normalized coordinates (default = data)
;
;   ORIENTATION: orientation of key:
;      (0=left to right (default), 1=top to bottom)
;
;   PATTERN: a MxMxNbox array of patterns, Nbox=index, MxM is pattern
;
;   THICK: thickness of border lines (default=!P.thick)
;
;   TITLE: a string to put below or next to the labels.
;
;   UNITS: a string used to label the topmost box (usually the data units)
;
;
;	   If LINESPACING or LINEANGLE are specified then line fills are done.
;	   If PATTERN is specified then pattern fills are done.
;	   Otherwise solid fills using COLORS are done.
;
;
;	   Number of boxes is determined from COLORS, LINE, or PATTERN.
;	   The number of labels (Nlab) is usually equal to or one more than Nbox.
;      If Nbox is an integer multiple of Nlab, then MAKE_KEY
;      will label every Nbox/Nlab box.
;
;
; EXAMPLE:
;
; 	MAKE_KEY, COLORS=[100,150,200,250], LABELS=[0,1,2,3]
;
;
; MODIFICATION HISTORY:
; Written, C. Torrence, Nov. 9, 1993.
; Modified, Frank Evans, CU, 2/24/94
; Modified, C. Torrence, July 1996. Changed INPUTS to optional.
;-
PRO MAKE_KEY,x,y,xsize,ysize,xlaboff,ylaboff, $
	COLORS=colors, LABELS=labels, UNITS=units, ORIENTATION=orientation, $
	NOBORDER=noborder, BCOLOR=bcolor, THICK=thick, NORMAL=normal,$
	PATTERN=pattern, LINESPACING=linespacing, LINEANGLE=lineangle, $
	ALIGNMENT=alignment, CHARSIZE=charsize, CHARTHICK=charthick, $
	TITLE=title

ON_ERROR,2  ;return to caller if error

IF ((N_PARAMS(0) NE 0) AND (N_PARAMS(0) NE 4) AND (N_PARAMS(0) NE 6)) THEN $
	MESSAGE,"You supplied " + STRCOMPRESS(N_PARAMS(0),/REMOVE) + $
		" parameters. Needs 0, 4, or 6 parameters."

;*********************************************************** check KEYWORDS
nbox = N_ELEMENTS(colors)
ON_ERROR,2

IF (nbox LT 1) THEN MESSAGE,'must have at least 1 color'
patflag = (N_ELEMENTS(pattern) GT 0)
IF patflag THEN BEGIN
	tmp = SIZE(pattern)
	IF tmp(0) EQ 3 THEN nbox = tmp(3)
ENDIF

lineflag = (N_ELEMENTS(linespacing) GT 0) OR (N_ELEMENTS(lineangle) GT 0)
if lineflag THEN nbox = N_ELEMENTS(lineangle) < N_ELEMENTS(linespacing)
IF NOT lineflag THEN BEGIN
	lineangle=INTARR(nbox)
	linespacing=INTARR(nbox)
ENDIF

IF nbox EQ 0 THEN MESSAGE, 'MAKEKEY: No boxes specified.'

IF N_ELEMENTS(labels) LE 0 THEN labels=REPLICATE(nbox,'')
s = SIZE(labels)
IF s(s(0) + 1) NE 7 THEN labels = STRTRIM(labels,2)
nlab = N_ELEMENTS(labels)
steplab = FIX((nbox+1)/nlab) > 1

noborder = KEYWORD_SET(noborder)
orientation = KEYWORD_SET(orientation)
normal = KEYWORD_SET(normal)
IF N_ELEMENTS(bcolor) LE 0 THEN bcolor = !P.COLOR
IF N_ELEMENTS(bcolor) EQ 1 THEN bcolor = BYTARR(nbox) + bcolor
IF N_ELEMENTS(charsize) LE 0 THEN charsize = !P.CHARSIZE
IF (charsize EQ 0) THEN charsize = 1
IF N_ELEMENTS(thick) LE 0 THEN thick = !P.THICK
IF N_ELEMENTS(charthick) LE 0 THEN charthick = !P.CHARTHICK

;**************************************** check how many parameters supplied

zero = CONVERT_COORD(0,0,/DEVICE,/TO_DATA)
zero_data = CONVERT_COORD(0,0,/DATA,/TO_NORMAL)
char_size = CONVERT_COORD(!D.X_CH_SIZE,!D.Y_CH_SIZE,/DEVICE,/TO_DATA)
char_size = (char_size - zero)*charsize

IF N_PARAMS(0) EQ 0 THEN BEGIN   ;****** need to create all parameters
	IF orientation THEN BEGIN   ; vertical
		x = !X.CRANGE(1) + char_size(0) ;*(!P.CHARSIZE/charsize)
		y = !Y.CRANGE(0)
		xsize = 2*char_size(0)
		ysize = !Y.CRANGE(1) - !Y.CRANGE(0)
	ENDIF ELSE BEGIN   ; horizontal
		x = !X.CRANGE(0)
		y = !Y.CRANGE(0) - 6*char_size(1) ;*(!P.CHARSIZE/charsize)
		xsize = !X.CRANGE(1) - !X.CRANGE(0)
		ysize = 2*char_size(1)
	ENDELSE
	IF normal THEN BEGIN
		dummy = CONVERT_COORD([x,xsize],[y,ysize],/DATA,/TO_NORMAL)
		x = dummy(0,0)
		y = dummy(1,0)
		xsize = dummy(0,1) - zero_data(0)
		ysize = dummy(1,1) - zero_data(1)
	ENDIF
ENDIF

IF N_PARAMS(0) LT 6 THEN BEGIN   ;****** need to supply label offsets
	IF orientation THEN BEGIN   ; vertical
		xlaboff = 0.6*char_size(0)
		ylaboff = -0.4*char_size(1)
	ENDIF ELSE BEGIN   ; horizontal
		xlaboff = 0.
		ylaboff = -1.4*char_size(1)
	ENDELSE
	IF normal THEN BEGIN
		dummy = CONVERT_COORD(xlaboff,ylaboff,/DATA,/TO_NORMAL)
		xlaboff = dummy(0) - zero_data(0)
		ylaboff = dummy(1) - zero_data(1)
	ENDIF
	xlaboff = xlaboff + xsize*orientation   ;* add in KEY width if vertical
ENDIF


;**************************************************** create POLYFILL arrays
IF orientation THEN BEGIN   ;*********** vertical
	xbox = FLOAT(xsize)
	ybox = FLOAT(ysize)/nbox
	x = FLOAT(x) + FLTARR(nbox+1)
	y = FLOAT(y) + FINDGEN(nbox+1)*ybox
	IF N_ELEMENTS(alignment) LE 0 THEN alignment = 0
ENDIF ELSE BEGIN   ;*********** horizontal
	xbox = FLOAT(xsize)/nbox
	ybox = FLOAT(ysize)
	x = FLOAT(x) + FINDGEN(nbox+1)*xbox
	y = FLOAT(y) + FLTARR(nbox+1)
	IF N_ELEMENTS(alignment) LE 0 THEN alignment = 0.5
ENDELSE


;********************  Make the boxes and draw lines around them (if desired)
FOR i = 0, nbox-1 DO BEGIN
	xx=[x(i),x(i)+xbox,x(i)+xbox,x(i)]
	yy=[y(i),y(i),y(i)+ybox,y(i)+ybox]
	IF patflag THEN POLYFILL,xx,yy,NORMAL=normal,PATTERN=pattern(*,*,i) $
	ELSE IF linespacing(i) THEN POLYFILL,xx,yy, NORMAL=normal, $
		/LINE_FILL, SPACING=linespacing(i), $
		ORIENTATION=lineangle(i), COLOR=colors(i) $
	ELSE POLYFILL,xx,yy, NORMAL=normal,COLOR=colors(i)
	IF noborder EQ 0 THEN PLOTS,[xx,x(i)],[yy,y(i)], normal=normal, $
		COLOR=bcolor(i), /NOCLIP,THICK=thick
ENDFOR

;***********************************************************  Label the boxes
FOR i = 0, nlab-1 DO BEGIN
	XYOUTS,x(i*steplab) + xlaboff,y(i*steplab) + ylaboff, $
		labels(i), NORMAL=normal,ALIGNMENT=alignment, $
		CHARSIZE=charsize,CHARTHICK=charthick
ENDFOR

IF ((N_ELEMENTS(units) GT 0) AND ((nlab-1)*steplab NE nbox)) THEN BEGIN
	XYOUTS,x(nbox) + xlaboff,y(nbox) + ylaboff, $
		units, NORMAL=normal,ALIGNMENT=alignment, $
		CHARSIZE=charsize, CHARTHICK=charthick
ENDIF ;** units

IF (N_ELEMENTS(title) GT 0) THEN BEGIN
	IF orientation THEN BEGIN
		x_title = x(0) + xlaboff + 0.5*xsize*(MAX(STRLEN(labels)) + 1)
		y_title = 0.5*(y(0) + y(nbox - 1) + ybox) 
	ENDIF ELSE BEGIN
		x_title = 0.5*(x(0) + x(nbox - 1) + xbox)
		y_title = y(0) + ylaboff - 0.9*ysize 
	ENDELSE
	XYOUTS,x_title,y_title,title,ORIENTATION=-90*orientation, $
		ALIGNMENT=0.5,CHARTHICK=charthick,CHARSIZE=charsize
ENDIF

END

