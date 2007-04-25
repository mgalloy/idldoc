;+
; <center><img src="sierpinski_gasket.jpg"></center><p>
;
; This code generates a picture of the fractal object called
; a Sierpinski gasket.
;
; @param n_points {in}{type=long integer}{default=25000} The number
;   of points in the diagram.
; @examples
;   <code>
;   IDL> sierpinsky_gasket<br>
;   </code>
; @requires IDL 5.3
; @author Mark Piper, 1995-05-23
; @history
;   2000-10-11, MP: Made a new plot.<br>
;   2003-07-16, MP: Added parameter <i>n_points</i>.
;-

pro sierpinsky_gasket, n_points
    compile_opt idl2

    if n_params() eq 0 then n_points=25000

    ; The points defining the Sierpinski gasket.
    p = fltarr(n_points, 2)

    ; A set of uniformly distributed random numbers.
    r = randomu(seed, n_points)

    ; Select the vertices of the triangle.
    A = [-1, 0]
    B = [0, 2]
    C = [1, 0]

    ; Select a starting point within the triangle.
    p[0,0:1] = [0.5, 0.5]

    ; The iterative map.
    for i = 0, n_points-2 do begin

        ; The random number determines which vertex to
        ; move toward from the point p.
        if r[i] lt 1/3. then q=A $
        else if r[i] lt 2/3. then q=B $
        else q=C

        ; The new point is halfway between
        ; the old point & the vertex.
        p[i+1,*] = 0.5*(p[i,*] - q) + q

    endfor

    device, get_screen_size=ss
    window, xsize=ss[0]*0.75, ysize=ss[1]*0.75
    plot, p[*,0], p[*,1], $
        psym=3, $
        xstyle=4, $
        ystyle=4, $
        xmargin=[1,1], $
        ymargin=[1,1]
end
