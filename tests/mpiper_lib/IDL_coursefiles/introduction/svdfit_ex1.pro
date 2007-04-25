;+
; An example of using the IDL SVDFIT function. This code
; is used in the chapter "Analysis" in the <i>Introduction to
; IDL</i> course manual.
;
; @examples
; <pre>
; IDL> svdfit_ex1
; </pre>
; @uses WIND_PROFILE_MODEL, OPLOTERRXY, GET_INTRO_DIR
; @requires IDL 5.3
; @author Mark Piper, RSI, 2003
; @history
;  2005-10, MP: Now uses GET_INTRO_DIR.
;-
pro svdfit_ex1
    compile_opt idl2

    ; Read wind data from file.
    file = filepath('Sprop1.dat', root_dir=get_intro_dir())
    sprop = read_ascii(file, data_start=2, header=h, num_records=3000)

    ; Organize the data into vectors.
    time = reform(sprop.(0)[0,*])
    u03 = reform(sprop.(0)[1,*])
    v03 = reform(sprop.(0)[2,*])
    u05 = reform(sprop.(0)[3,*])
    v05 = reform(sprop.(0)[4,*])
    u10 = reform(sprop.(0)[5,*])
    v10 = reform(sprop.(0)[6,*])

	; Make wind speed vectors at the three heights.
    s03 = sqrt(u03^2 + v03^2)
    s05 = sqrt(u05^2 + v05^2)
    s10 = sqrt(u10^2 + v10^2)

    ; Calculate mean and stdev wind profiles. The heights are from
    ; instrument heights listed in the file header. The first height
    ; is an estimate of the surface roughness height, at which the
    ; wind speed is zero.
    heights = [0.1, 3.0, 5.0, 10.0]
    n_heights = n_elements(heights)
    mean_profile = [0.0, mean(s03), mean(s05), mean(s10)]
    stdev_profile = [0.0, stdev(s03), stdev(s05), stdev(s10)]
    print, 'profile values:', mean_profile

    ; Use SVDFIT to determine coeffs for model, given by the function
    ; WIND_PROFILE_MODEL. An initial guess for the model coeffs
    ; must be provided.
    init_guess = replicate(1.0, n_heights-1)
    c = svdfit(heights, mean_profile, a=init_guess, chisq=chisq, $
        sigma=sigma, function_name='wind_profile_model')
    print, 'fit coeffs:', c
    print, 'fit stdev:', sigma
    print, 'chi-square value:', chisq

    ; Use the coeffs returned from SVDFIT to create a vector
    ; describing the fit.
    n_fit_points = 50
    z_fit = findgen(n_fit_points)/n_fit_points*12 + heights[0]
    u_fit = c[0] + c[1]*alog(z_fit) + c[2]*alog(z_fit)^2

    ; Plot the mean, stdev and fit profiles.
    plot, mean_profile, heights, $
        psym=5, $
        xrange=[0,10], $
        yrange=[0,12], $
        xtitle='wind speed (ms!u-1!n)', $
        ytitle='height (m)'
    oploterrxy, mean_profile, heights, $
        stdev_profile, fltarr(n_heights), /bars
    oplot, u_fit, z_fit, color=100
    wshow
end
