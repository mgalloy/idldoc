FUNCTION make_tetra, _EXTRA = e

;	Original: Beau Legeer
;	Modified: Mark Piper, 07/30/01


n = 3
verts = fltarr(3,n+1)
verts[0,0] = 0.0
verts[1,0] = 0.0
verts[2,0] = 0.1
t = 0.0
tinc = (2.*!PI)/float(n)
for i=1,n do begin
    verts[0,i] = 0.1*cos(t)
    verts[1,i] = 0.1*sin(t)
    verts[2,i] = -0.1
    t = t + tinc
    end
conn = fltarr(4*n+(n+1))
i = 0
conn[0] = n
for i=1,n do conn[i] = (n-i+1)
j = n+1
for i=1,n do begin
    conn[j] = 3
    conn[j+1] = i
    conn[j+2] = 0
    conn[j+3] = i + 1
    if (i EQ n) then conn[j+3] = 1
    j = j + 4
endfor

return, obj_new('IDLgrPolygon',verts,poly=conn,$
            _EXTRA = e)
END