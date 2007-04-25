;+
; An example of using the routine MP_SPECTRUM.
;
; @author Mark Piper, 2000
;-
pro mp_spectrum_ex
    compile_opt idl2, hidden

    file = filepath('damp_sn.dat', subdir=['examples','data'])
    u = float(read_binary(file))
    n_u = n_elements(u)
    delta = 1.0 ; seconds
    f_N = 0.5/delta

    ;; Compute the power spectrum using MP_SPECTRUM.
    u_spec = mp_spectrum(u, delta, frequency=u_freq, /nodc)

    window, title='mp_spectrum example'
    !p.multi = [0,1,2]
    plot, u, $
        xtitle='time', $
        ytitle='signal'
    plot, u_freq, u_spec, /xlog, /ylog, $
        xtitle='frequency', $
        ytitle='spectral density'
    !p.multi = 0

    ;; Test Parseval's theorem.
    print
    print, " Test Parseval's theorem:"
    tp_freq = total(u_spec)
    tp_phys = total((u-mean(u))^2)
    print, tp_freq, tp_phys, tp_freq/tp_phys

    ;; Test the variance of u.
    print    
    print, " Test variance:"
    tv_freq = total(u_spec)/n_u ; normalize by n_u
    tv_phys = stdev(u)^2*(n_u-1)/n_u ; convert from sample variance
    print, tv_freq, tv_phys, tv_freq/tv_phys
end


;+
; This function computes the periodogram (an estimate of the
; power spectral density) of a one-dimensional input array.
;
; @file_comments This function computes the periodogram (an estimate
;   of the power spectral density) of an input vector.
; @param x {in}{required}{type=float} The input vector.
; @param delta {in}{required}{type=float} The sampling interval of the
;   input vector.
; @keyword frequency {out}{optional}{type=float} Set this keyword to a
;   variable to receive the array of frequencies for the computed
;   power spectrum.
; @keyword nodc {in}{type=boolean} Set this keyword to remove the DC
;   component from the periodogram.
; @returns The periodogram of the input vector.
;
; @examples See the program MP_SPECTRUM_EX.
;
; @author Mark Piper, University of Colorado & RSI, 2000
; @history
;   2004-02-10: Added SMOOTH keyword.<br>
;-
function mp_spectrum, x, delta, $
                      frequency=frequency, $
                      nodc=nodc
    compile_opt idl2
    on_error, 2

    x_info = size(x, /structure)
    n_x = x_info.n_elements
    if n_params() ne 2 or n_x eq 0 then begin
        message, 'Please pass data array and sampling interval.'
        return, 0
    endif
    if x_info.n_dimensions ne 1 then begin
        message, 'The input array must be one-dimensional.'
        return, 0
    endif

    ;; Transform the input array to the frequency domain.
    x_hat = fft(x)

    ;; Compute the power spectrum of the input array.
    spec_x = fltarr(n_x/2+1)    
    spec_x[0] = abs(x_hat[0])^2
    spec_x[1:*] = 2*abs(x_hat[1:n_x/2])^2
    spec_x = temporary(spec_x)*n_x

    ;; Optionally calculate the frequencies of the power spectrum.
    if arg_present(frequency) then begin
        sample_time = n_x * float(delta)
        lowest_freq = 1.0 / sample_time
        n_modes = n_elements(spec_x)
        frequency = (findgen(n_modes))*lowest_freq
        if keyword_set(nodc) then frequency = frequency[1:*]
    endif

    ;; Return the power spectrum to the calling program.
    if keyword_set(nodc) then spec_x = spec_x[1:*]
    return, spec_x
end

