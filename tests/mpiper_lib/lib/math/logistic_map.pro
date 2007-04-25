;+
; <center><img src="logistic_map.jpg"></center><p>
;
; This code generates a bifurcation diagram for the logistic map.
; It uses a one-pass approach through the diagram. For each value of
; <i>r</i>, the logistic map is assigned a random starting point on
; [0,1). The map is then iterated until a value of <i>x</i> is reached
; for that <i>r</i>.
; <p>
; This approach is simplistic. It doesn't make as nice a diagram as one
; that follows multiple paths through the logistic map (e.g., see the
; program BIFURCATION in the training files). On the other hand, it
; gives a decent-looking diagram with one vector of abscissas
; (<i>r</i>) and one vector of ordinates (<i>x</i>).
; <p>
; This code is used in the chapter "Line Plots" in the
; <i>Introduction to IDL</i> training manual.
;
; @keyword n_points {in}{optional}{type=long}{default=10000} The number
;   of points to be displayed in the bifurcation diagram. Increasing
;   this number gives a more detailed plot, at the expense of time and
;   memory.
; @keyword itermax {in}{optional}{type=long}{default=200} The number
;   of times the map is iterated. Increasing this number gives better
;   convergence, at the expense of time.
; @keyword debug {in}{optional}{type=boolean} Set this keyword to see
;   debugging options.
; @keyword plot_diagram {in}{optional}{type=boolean} Set this keyword
;   to display the bifurcation diagram with PLOT.
; @keyword r {out}{optional}{type=float} Set this keyword to a named
;   variable to receive a vector of n_points <i>r</i> values.
; @keyword x {out}{optional}{type=float} Set this keyword to a named
;   variable to receive a vector of n_points <i>x</i> values.
;
; @examples
;   <code>
;   IDL> logistic_map, /plot<br>
;   </code>
;
; @requires IDL 6.0
; @author Mark Piper, 1995
; @history
;   2003-10-01, MP: Cleaned up and documented code.
;   2003-10-01, MG: Vectorized code, giving 15x speed increase!
;   2003-10-02, MP: Optimization, 4x increase!
;-

pro logistic_map, n_points=n_points, debug=debug, plot_diagram=plot, $
    r=r, x=x, itermax=itermax
    compile_opt idl2

    if ~keyword_set(n_points) then n_points = 10000 $
    else if (n_points lt 1 or n_points gt 2e5) then n_points = 10000

    if keyword_set(debug) then t0 = systime(1)

    ; Define tuning parameter r & population x.
    r = findgen(n_points) / n_points * 3 + 1
    x = randomu(123, n_points)

    ; Iterate the logistic map. The value of itermax is arbitrary; 200
    ; gives good visual results.
    if ~keyword_set(itermax) then itermax = 200
    for j = 0, itermax do begin
        x = r * x * (1.0-x)
    endfor

    if keyword_set(debug) then $
        print, 'time elapsed (s): ', systime(1)-t0

    ; Make a pretty plot.
    if keyword_set(plot) then begin
        plot, r, x, psym=3, $
            title='Bifurcation Diagram of the Logistic Map', $
            xtitle='r', ytitle='x'
        wshow
    endif
end
