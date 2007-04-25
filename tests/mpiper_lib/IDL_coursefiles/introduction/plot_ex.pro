;+
; Some examples of using the IDL PLOT and IPLOT procedures.
; This code is used in the chapter "Line Plots" in the
; <i>Introduction to IDL</i> course manual.
;
; @examples
; <pre>
; IDL> .run plot_ex
; </pre>
; @uses LOAD_DATA, LOAD_COLORS
; @requires IDL 6.0
; @author Mark Piper, RSI, 2003
;-

temp = load_data('mesa_temp')
dewp = load_data('mesa_dewp')
time = load_data('mesa_time')
help, temp, dewp, time

load_colors
plot, temp
plot, time, temp
time = time/60.0^2
plot, time, temp
plot, time, temp, $
    xtitle='Time (UTC)', $
    ytitle='Temperature (C)'
plot, time, temp, $
    xtitle='Time (UTC)', $
    ytitle='Temperature (C)', $
    title='NCAR Mesa Lab Temperature: 2002-06-26'

plot, time, temp, yrange=[15,35]
plot, time, temp, xrange=[24,0]
plot, time, temp, xrange=[0,24]

plot, time, temp, color=100


wspd = load_data('mesa_wspd')
wdir = load_data('mesa_wdir')
help, wspd, wdir

; method 1
plot, time, wspd, ystyle=4, xstyle=1, /nodata, $
    xtitle='Time (UTC)', xmargin=[10,10]
axis, yaxis=0, ytitle='Wind Speed (m/s)', color=50
max_l_axis = !y.crange[1]
oplot, time, wspd, color=50
axis, yaxis=1, yrange=[0,360], ystyle=1, ytitle='Wind Direction (deg)', $
    color=110, /save
max_r_axis = !y.crange[1]
scale = max_l_axis/max_r_axis
oplot, time, wdir*scale, color=110


; method 2
plot, time, wspd, ystyle=4, xstyle=1, /nodata, $
    xtitle='Time (UTC)', xmargin=[10,10]
axis, yaxis=0, ytitle='Wind Speed (m/s)', color=50
oplot, time, wspd, color=50
axis, yaxis=1, yrange=[0,360], ystyle=1, ytitle='Wind Direction (deg)', $
    color=110, yticks=4, yminor=3, /save ; /save is key!
oplot, time, wdir, color=110


x = findgen(100)/10
y = exp(x)
plot, x, y

end