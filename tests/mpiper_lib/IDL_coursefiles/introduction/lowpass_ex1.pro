;+
; An example of lowpass filtering with a Butterworth filter.
; This code is used in the chapter "Analysis" in the
; <i>Introduction to IDL</i> course manual.
;
; @examples
; <pre>
; IDL> lowpass_ex1
; </pre>
; @requires IDL 6.0
; @author Mark Piper, RSI, 2003
;-
pro lowpass_ex1
    compile_opt idl2

    ; El Nino-Southern Oscillation (ENSO) data.
    ; Ask Chris about history. Data are floating point.
    ; Sea surface temps in equatorial Pacific Ocean.
    file = filepath('elnino.dat', subdir=['examples','data'])
    enso = read_binary(file, data_type=4, endian='little')

    ; Create parameters from the dataset.
    ; n_data is the number of elts in the dataset. delta is the time
    ; interval between the points. freq_nyquist is the Nyquist freq.
    ; time is a vector of independent data values.
    n_enso = n_elements(enso)
    delta = 0.25                        ; additional info
    time = findgen(n_enso)*delta + 1871 ; additional info
    freq_nyquist = 0.5/delta

    ; Display the dataset.
    iplot, time, enso, $
        identifier=enso_series, $
        xtitle='Year', color=[0,0,200], $
        ytitle='Temperature Anomaly (!uo!nC)', $
        title='ENSO: Time Series', $
        name='Original Series'
    iplot, time, time*0.0, /overplot

    ; Transform the data to the frequency domain. Display the half
    ; power spectrum of the data plotted versus Fourier mode.
    enso_hat = fft(enso)
    enso_psd = abs(enso_hat)^2
    iplot, enso_psd, $
        color=[0,150,0], $
        identifier=enso_spectrum, $
        xrange=[0,n_enso/2], $
        xtitle='Mode', $
        ytitle='PSD', $
        title='ENSO: Spectrum', $
        name='Spectrum'

    ; Mark the cutoff frequency at two-tenths of the Nyquist frequency.
    ; This translates to a period of roughly 30 months.
    ; Use this to construct an order 5 Butterworth lowpass filter.
    freq_c = 0.2*freq_nyquist
    order  = 5
    kernel = (dist(n_enso))[*,0]/(n_enso*delta)
    filter = 1 / (1 + (kernel/freq_c)^(2*order))

    ; Display the filter on the spectrum plot with a second axis.
    iplot, filter*max(enso_psd), $
        overplot=enso_spectrum, $
        color=[255,220,0], $
        xrange=[0,n_enso/2], $
        yrange=[0,max(enso_psd)], $
        name='Filter'

    ; Apply the filter to the ENSO data.
    enso_lpf = fft(enso_hat*filter, /inverse)

    ; Overplot the filtered signal on the original series.
    iplot, time, enso_lpf, $
        color=[200,0,0], $
        thick=2, $
        overplot=enso_series, $
        name='Filtered Series'

    ; Last, insert a legend by selecting the entire time series plot
    ; and selecting the Insert > Legend menu bar item.
    ; Same for spectrum plot.
end