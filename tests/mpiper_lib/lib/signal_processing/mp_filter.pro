;+
; Demonstrates the use of MP_FILTER in a filtering process. A sample
; signal is constructed, then filtered with an order 5 lowpass
; Butterworth filter with a cutoff frequency 0.3 of the Nyquist
; frequency. The results are displayed in a Direct Graphics plot
; window.
;
; @keyword _extra Keyword inheritance.
; @uses MP_FILTER
; @author Mark Piper, RSI, 2001
; @history 
;   2003-02-10, MP: Added better comments to code and better
;   annotation to plot.<br>
;   2004-02-08, MP: Changed program name from MP_FILTER_TEST, since
;   I'm really not testing the program but only showing an example 
;   of its use.<br>
;-
pro mp_filter_ex, _extra=e
    compile_opt idl2

    ;; Generate a data set.
    n = 100
    x = (2*!pi/n)*findgen(n)
    i = where(randomu(123L,n) gt 0.85, n_i)
    s = sin(4*x) + sin(1.5*x)
    s[i] = s[i] + randomn(123L,n_i)
    
    ;; Compute parameters for the filter.
    n = n_elements(s)
    delta = x[1]-x[0]
 
    ;; Construct the filter function using MP_FILTER.
    f_hat = mp_filter(n, delta, $
                      /butterworth, $
                      /lowpass, $
                      cutoff=0.3, $
                      order=5, $
                      _extra=e)
    if (size(f_hat))[0] eq 0 then return

    ;; Transform the signal to the frequency domain.
    s_hat = fft(s)

    ;; Apply the filter to the transformed signal then perform the
    ;; inverse transform. The result is a filtered signal.
    s_f = fft(f_hat*s_hat, /inverse)

    ;; Display the results.
    window, 10, xsize=750, ysize=650, title='mp_filter example'
    !p.multi = [0, 2, 2]
    plot, x, s, $
        psym=7, $
        symsize=0.7, $
        xstyle=1, $
        xtitle='time', $
        ytitle='s', $
        title='Series (time domain)'
    oplot, x, s_f, $
        color=200
    plot, abs(s_hat), $
        xticks=4, $
        xtickname=['0', '+', 'f!LN!N', '-', ' '], $
        xstyle=1, $
        xtitle='frequency', $
        ytitle='s_hat', $
        title='Series (frequency domain)'
    f = fft(f_hat, /inverse)
    plot, indgen(n)-n/2, shift(abs(f), n/2), $
        xrange=[-n/2,n/2], $
        xticks=4, $
        xminor=5, $
        xstyle=1, $
        xtitle='filter index', $
        ytitle='f', $
        title='Filter (time domain)'
    plot, f_hat, $
        xticks=4, $
        xtickname=['0', '+', 'f!LN!N', '-', ' '], $
        xstyle=1, $
        xtitle='frequency', $
        ytitle='f_hat',  $
        title='Filter (frequency domain)', $
        yrange=[0,1.2]
    !p.multi = 0
end


;+ 
; This function is used to construct a filtering function in the
; frequency domain. The filter function is symmetric about the Nyquist
; mode, by default, following the IDL FFT's method of storing Fourier
; coefficients.  An ideal filter is used, by default. Currently this
; routine is limited to constructing one-dimensional filters.  
; <p>
;
; @returns A filter array defined in the frequency domain to be used 
;    with FFT, or the value 0 on failure.
;
; @param n_samples {in}{required}{type=long} The number of elements in
;    the series to be filtered.
; @param sampling_interval {in}{required}{type=float} The interval (in
;    time, space, ...) between the samples.
; @keyword double {optional}{type=boolean} Set to compute the filter
;    using double precision floating point values.
; @keyword debug {optional}{type=boolean} Set to see debugging
;    information.
; @keyword butterworth {optional}{type=boolean} Set to construct a
;    Butterworth filter.
; @keyword exponential {optional}{type=boolean} Set to construct an
;    exponential filter.
; @keyword ideal {optional}{type=boolean} Set to construct an ideal
;    filter. This is the default filter function.
; @keyword lowpass {optional}{type=boolean} Set to perform lowpass
;    filtering. This is the default filtering operation.
; @keyword highpass {optional}{type=boolean} Set to perform highpass
;    filtering.
; @keyword bandpass {optional}{type=boolean} Set to perform bandpass
;    filtering.
; @keyword bandstop {optional}{type=boolean} Set to perform bandstop
;    filtering.
; @keyword cutoff {type=float}{default=0.5} Specify the cutoff
;    frequency of the filter as a fraction of the Nyquist
;    frequency. Needed by all filtering operations.
; @keyword bandwidth {type=float}{default=0.1} Specify the bandwidth
;    of the filter, as a fraction of the Nyquist mode. Needed only for
;    bandpass and bandstop filtering. Must satisfy cutoff + bandwidth
;    < 1.
; @keyword order {optional}{type=float}{default=1} Change the order of
;    the Butterworth or exponential filter function.
; @keyword test {optional}{type=boolean} Set to test the program with
;    a sample data set and display the results.
; @examples See the program MP_FILTER_EX for an example of using
;    this program in a filtering process.
;
; @requires IDL 5.2 or greater
; @history 
;   2002-07-01: IDLdoc'ed.<br>
;   2003-02-03: Fixed a problem where the variables
;   <i>nyquist_mode</i> and <i>cutoff_mode</i> were cast to short int
;   instead of long int.<br>
;   2004-01-27: Cast <i>sampling_interval</i> to float.<br>
;   2004-02-08: Changed the name of the example program.<br>
; @author Mark Piper, RSI, 2001
;-
function mp_filter, n_samples, sampling_interval, $
                    double = dbl, $
                    debug = debug, $
                    butterworth = butterworth, $
                    exponential = exponential, $
                    ideal = ideal, $
                    lowpass = lowpass, $
                    highpass = highpass, $
                    bandpass = bandpass, $
                    bandstop = bandstop, $
                    cutoff = cutoff, $
                    bandwidth = bandwidth, $
                    order = order, $
                    test = test

    compile_opt idl2
    on_error, 2

    ;; Call the example program if the TEST keyword is set.
    if keyword_set(test) then begin
        mp_filter_ex
        return, 0
    endif

    ;; Check that two parameters are passed.
    if n_params() ne 2 then begin
        message, 'Need number of samples and sampling interval.', $
            /informational
        return, 0
    endif

    ;; Make sure the sampling interval is at least a float.
    sampling_interval_local = float(sampling_interval)

    ;; What type of filter function is desired?  If one is not selected,
    ;; then default to an ideal filter.
    check_filter_function = keyword_set(ideal) + keyword_set(butterworth) $
        + keyword_set(exponential)
    if check_filter_function gt 1 then begin
        message, 'Cannot set more than one filter function.', $
            /informational
        return, 0
    endif
    filter_function = 0 ; ideal filter
    if keyword_set(butterworth) then filter_function = 1
    if keyword_set(exponential) then filter_function = 2

    ;; Which filtering operation to perform?  If one is not selected,
    ;; then default to lowpass filtering.
    check_filter_type = keyword_set(lowpass) + keyword_set(highpass) $
        + keyword_set(bandpass) + keyword_set(bandstop)
    if check_filter_type gt 1 then begin
        message, 'Cannot set more than one filtering operation.', $
            /informational
        return, 0
    endif
    filter_type = 0 ; lowpass filter
    if keyword_set(highpass) then filter_type = 1
    if keyword_set(bandpass) then filter_type = 2
    if keyword_set(bandstop) then filter_type = 3

    ;; Has the DOUBLE keyword been set?
    ftype = keyword_set(dbl) ? 5 : 4 ; choose double or float type

    ;; Where is the frequency cutoff for the filter?  Specify it as
    ;; a float on (0,1), where 0 = dc mode, 1 = Nyquist mode.  If not
    ;; specified, then default to 0.5.
    if n_elements(cutoff) eq 0 then cutoff = 0.5 $
    else begin
        if (cutoff le 0) or (cutoff ge 1) then begin
            message, 'Specify cutoff frequency as a nonzero decimal' $
                + ' fraction of the Nyquist frequency.', /informational
            return, 0
        endif
    endelse

    ;; When performing bandpass or bandstop filtering, what is the
    ;; bandwidth of the filter?  Specify it as a decimal fraction of the
    ;; Nyquist frequency.
    if filter_type ge 2 then begin
        if n_elements(bandwidth) eq 0 then bandwidth = 0.1 $
        else begin
            if (bandwidth le 0) or (bandwidth + cutoff ge 1) then begin
                message, 'Specify bandwidth as a decimal fraction of' $
                    + ' the Nyquist frequency such that bandwidth + cutoff' $
                    + ' < 1.', /informational
                return, 0
            endif
        endelse
    endif

    ;; Test the order of the filter; allow only integral orders.
    if filter_function ge 1 then $
        order = n_elements(order) eq 0 ? 1 : (round(order) > 1)

    ;; Calculate the fundamental frequency of the signal.
    fundamental_freq = fix(1/(n_samples*sampling_interval_local), type=ftype)

    ;; Calculate the Nyquist frequency of the signal.
    nyquist_freq = fix(1/(2*sampling_interval_local), type=ftype)
    if keyword_set(debug) then help, nyquist_freq

    ;; Make a filter function that is symmetric about the Nyquist 
    ;; frequency.
    filter = fix(dist(n_samples,1)*fundamental_freq, type=ftype)
    if keyword_set(debug) then help, filter

    ;; Calculate the cutoff frequency, given the cutoff fraction of the
    ;; Nyquist frequency.
    cutoff_freq = fix(nyquist_freq*cutoff, type=ftype)
    if keyword_set(debug) then help, cutoff_freq

    ;; Calculate the bandwidth interval and center frequency. Band
    ;; filtering is done on the interval [cutoff_freq, bandwidth_freq].
    if filter_type ge 2 then begin
        bandwidth_freq = cutoff_freq + fix(nyquist_freq*bandwidth, $
                                           type=ftype)
        center_freq = (cutoff_freq + bandwidth_freq)/2.
        if keyword_set(debug) then help, bandwidth_freq, center_freq
    endif

    ;; Define some numbers near zero used to avoid floating point divide
    ;; by zero operations.
    a = machar(double=keyword_set(double))
    n_small = a.eps
    e_small = ceil(alog(a.xmin))

    ;; Change !except to store accumulated math errors.
    orig_except = !except
    !except = 0

    ;;   Construct the filter.
    case filter_function of

    0:  begin ; Ideal
        case filter_type of
        ;; Lowpass
        0: filter = filter le cutoff_freq
        ;; Highpass
        1: filter = filter ge cutoff_freq
        ;; Bandpass
        2: filter = filter ge cutoff_freq and filter le bandwidth_freq
        ;; Bandstop
        3: filter = filter le cutoff_freq or filter ge bandwidth_freq
        endcase
        end

    1:  begin ; Butterworth
        case filter_type of
        ;; Lowpass
        0: filter = (1 + (filter/cutoff_freq)^(2*order))^(-1)
        ;; Highpass
        1: filter = (1 + (cutoff_freq/(filter > n_small))^(2*order))^(-1)
        ;; Bandpass
        2: filter = 1 - (1 + ( (filter * bandwidth * nyquist_freq) / $
            (filter^2 - center_freq^2) )^(2*order))^(-1)
        ;; Bandstop
        3: filter = (1 + ( (filter * bandwidth * nyquist_freq) / $
            (filter^2 - center_freq^2) )^(2*order))^(-1)
        endcase
        end

    2:  begin ; Exponential
        case filter_type of
        ;; Lowpass
        0: filter = exp(-(filter/cutoff_freq)^order > e_small)
        ;; Highpass
        1: filter = 1 - exp(-(filter/cutoff_freq)^order > e_small)
        ;; Bandpass
        2: filter = exp(-( (filter^2 - center_freq^2) / $
            (filter*bandwidth*nyquist_freq) )^(2*order)) > n_small
        ;; Bandstop
        3: filter = 1 - exp(-( (filter^2 - center_freq^2) / $
            (filter*bandwidth*nyquist_freq > n_small) )^(2*order))
        endcase
        end

    endcase
    
    ;; Reset !except.
    math_error_status = check_math()
    if keyword_set(debug) then print, math_error_status
    !except = orig_except

    ;; Return the filter array.
    return, fix(filter, type=ftype)
end
