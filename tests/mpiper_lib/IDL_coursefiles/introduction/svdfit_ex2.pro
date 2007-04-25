;+
; An example of using the IDL SVDFIT function. This code
; is used in the chapter "Analysis" in the <i>Introduction to
; IDL</i> course manual.
;
; @examples
; <pre>
; IDL> svdfit_ex2
; </pre>
; @uses WIND_PROFILE_MODEL
; @requires IDL 6.0
; @author Mark Piper, RSI, 2003
;-
pro svdfit_ex2
    compile_opt idl2

    ; Set up wind profile.
    heights = [0.1, 3.0, 5.0, 10.0]
    wind_profile = [0.0, 5.10, 5.67, 6.67]

    ; Plot the wind profile.
    iplot, wind_profile, heights, linestyle=6, sym_index=6, $
        ;sym_size=0.3, $
        ;xrange=[0,10], yrange=[0,12], xstyle=1, ystyle=1, $
        xtitle='wind speed (ms!u-1!n)', $
        ytitle='height (m)', $
        identifier=svdfit_ex

    ; Calculate coefficients of logsquare model for these data.
    c = svdfit(heights, wind_profile, a=fltarr(3)+1, chisq=chisq, $
        sigma=sigma, function_name='wind_profile_model')

    ; Use the fit coefficients to make vectors describing fit.
    z_fit = findgen(60)/5 + heights[0]
    u_fit = c[0] + c[1]*alog(z_fit) + c[2]*alog(z_fit)^2

    ; Overplot the fit.
    iplot, u_fit, z_fit, color=[255,0,0], overplot=svdfit_ex
end
