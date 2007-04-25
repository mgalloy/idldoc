;+
; Removes a linear, quadratic or cubic trend from a time series,
; using a least squares or a least absolute deviation fit. The default
; is to remove a linear trend using a least absolute deviation fit.
;
; @param y {in}{required}{type=float} A vector of ordinates to be
;    detrended.
; @keyword ld_linear {optional}{type=boolean} Set this keyword to
;    remove a linear trend from the input ordinates. The fit is
;    determined using the LADFIT function.
; @keyword ls_linear {optional}{type=boolean} Set this keyword to
;    remove a linear trend from the input ordinates. The fit is
;    determined using the LINFIT function.
; @keyword ls_quadratic {optional}{type=boolean} Set this keyword to
;    remove a quadratic trend from the input ordinates. The fit is
;    determined using the POLY_FIT function.
; @keyword ls_cubic {optional}{type=boolean} Set this keyword to
;    remove a cubic trend from the input ordinates. The fit is
;    determined using the POLY_FIT function.
; @keyword coefficients {out}{optional}{type=float} Set this keyword
;    to a named variable to receive the coefficients used in creating
;    the fit to the data.
; @keyword double {optional}{type=boolean} Set this keyword to use
;    double precision arithmetic.
; @returns A vector containing the detrended set of ordinates.
;
; @bugs There isn't a nice way to pass back goodness-of-fit parameters
;   from the routines LADFIT, LINFIT & POLY_FIT through the MP_DETREND
;   interface.
; @history
;   2004-01-30, MP: Added COEFFICIENTS keyword.
;
; @examples
; <code>
; IDL> u = findgen(100) + randomn(seed,100)<br>
; IDL> u_d = mp_detrend(u, /ls_linear)<br>
; IDL> plot, u_d<br>
; </code>
; @requires IDL 5.2
; @author Mark Piper, 2000
;-

function mp_detrend, y, $
                     ld_linear=linear_ld, $
                     ls_linear=linear_ls, $
                     ls_quadratic=quadratic_ls, $
                     ls_cubic=cubic_ls, $
                     coefficients=c, $
                     double=dbl
    compile_opt idl2
    on_error, 2

    ; Check the input parameter.
    if n_params() ne 1 then begin
        message, 'Please pass a set of ordinates to be detrended.', /info
        return, 0
    endif

    ; Check for the double keyword.
    wtype = keyword_set(dbl) ? 5 : 4

    ; Determine the number of elts in the input array.
    n_y = n_elements(y)

    ; Generate a set of abscissas.
    x = indgen(n_y, type=wtype)

    ; Select the detrend model.
    detrend_choice = 0
    if keyword_set(linear_ls) then detrend_choice = 1
    if keyword_set(quadratic_ls) then detrend_choice = 2
    if keyword_set(cubic_ls) then detrend_choice = 3

    ; Compute the fit to the data.
    case detrend_choice of
    0:  begin   ; LAD linear detrend
        c = ladfit(x, y, double=(wtype eq 5))
        y_fit = c[0] + c[1]*x
        end
    1:  begin   ; linear LS fit to data
        c = linfit(x, y, double=(wtype eq 5))
        y_fit = c[0] + c[1]*x
        end
    2:  begin   ; quadratic LS fit to data
        c = poly_fit(x, y, 2, double=(wtype eq 5))
        y_fit = c[0] + c[1]*x + c[2]*x^2
        end
    3:  begin   ; cubic LS fit to data
        c = poly_fit(x, y, 3, double=(wtype eq 5))
        y_fit = c[0] + c[1]*x + c[2]*x^2 + c[3]*x^3
        end
    endcase

    ; Compute the new set of detrended ordinates by subtracting
    ; the fit from the original ordinates.
    y_new = y - y_fit

    ; Return the detrended ordinates.
    return, y_new

end
