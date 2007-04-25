;+
; <b>Overplots</b> error bars on abscissas and ordinates.
;
; @param u {in}{type=numeric} The abscissas of the data to plot.
; @param v {in}{type=numeric} The ordinates of the data to plot.
; @param uerr {in}{type=numeric} The magnitude of the error in the x-dir.
; @param verr {in}{type=numeric} The magnitude of the error in the y-dir.
; @keyword bars {in}{type=boolean} Set this keyword to display
;   bar ends on the error estimates.
; @keyword bsize {in}{type=float}{default=1.0} Controls the size of
;   the bar ends.
; @examples
;   <code>
;     IDL> N = 21<br>
;     IDL> x = findgen(N) - (N-1)/2<br>
;     IDL> y = 2*x^2 + 5 + randomn(seed, N)*10<br>
;     IDL> err_x = randomu(seed, N)/2<br>
;     IDL> err_y = randomu(seed, N)*10<br>
;     IDL> plot, x, y, psym=4<br>
;     IDL> oploterrxy, x, y, err_x, err_y, /bars, bsize=1.5<br>
;   </code>
; @author Mark Piper, 1997-07-16
;-

pro oploterrxy, u, v, uerr, verr, BARS=bars, BSIZE=bsize

    if n_elements(bsize) eq 0 then bsize=1.0

    N = n_elements(u)

    for i=0,N-1 do begin
        oplot, [u[i]-uerr[i],u[i]+uerr[i]], [v[i],v[i]]
        oplot, [u[i],u[i]], [v[i]-verr[i],v[i]+verr[i]]
    endfor

    if keyword_set(bars) then begin
        xbarendlength = bsize*0.005*(!x.crange[1]-!x.crange[0])
        ybarendlength = bsize*0.005*(!y.crange[1]-!y.crange[0])
        for i=0,N-1 do begin
            oplot, [u[i]-uerr[i],u[i]-uerr[i]], $
                [v[i]-ybarendlength, v[i]+ybarendlength]
            oplot, [u[i]+uerr[i],u[i]+uerr[i]], $
                [v[i]-ybarendlength, v[i]+ybarendlength]
            oplot, [u[i]-xbarendlength,u[i]+xbarendlength], $
                [v[i]-verr[i],v[i]-verr[i]]
            oplot, [u[i]-xbarendlength,u[i]+xbarendlength], $
                [v[i]+verr[i],v[i]+verr[i]]
        endfor
    endif
end
