FUNCTION  make_circle, POS = pos, RADIUS = r, _EXTRA = e

;	Original: Beau Legeer
;	Modified: Mark Piper, 07/30/01

	if (n_elements(pos) ne 3) then pos = [0,0,0]
	if (n_elements(r) ne 1) then r = 1
	x = pos[0]
	y = pos[1]
	zcoords = replicate(pos[2], 361)
	xcoords = x + r * Cos (Indgen (361) * !DtoR)
	ycoords = y + r * Sin (Indgen (361) * !DtoR)

   	oCircle = obj_new('IDLgrPolygon', $
   		xcoords, ycoords, zcoords, $
   		_EXTRA = e)

	return, oCircle

End