;+
; An example of using the IDL LINFIT function. This code
; is used in the chapter "Analysis" in the <i>Introduction to
; IDL</i> course manual.
;
; @examples
; <pre>
; IDL> linfit_ex
; </pre>
; @uses LOAD_DATA
; @requires IDL 5.3
; @author Mark Piper, RSI, 2002
;-
pro linfit_ex
    compile_opt idl2

    ; Load data.
    wind = load_data('wind')

    ; Assert the wind speed is increasing linearly with time.
    ; Use LINFIT to determine the coefficients of the fit.
    coefficients = linfit(wind.time, wind.speed, yfit=speed_fit, $
        chisq=chisq, prob=prob, sigma=sigma)

    ; Display the original data & the linear fit.
    plot, wind.time, wind.speed, ynozero=1, yrange=[2,5], psym=1, $
        xtitle='time (s)', $
        ytitle='wind speed (ms!u-1!n)
    oplot, wind.time, speed_fit

    ; Print values of coefficients with error estimates, as well as
    ; the chi-squared value for the fit.
    format='(a15,f5.2,1x,"+/-",f5.2)'
    print, 'intercept:', coefficients[0], sigma[0], format=format
    print, 'slope:', coefficients[1], sigma[1], format=format
    print, 'chi-square value:', chisq
    ;print, prob
end