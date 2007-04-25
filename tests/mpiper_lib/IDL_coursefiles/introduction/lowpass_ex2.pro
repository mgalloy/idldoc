;+
; An example of lowpass filtering with a Butterworth filter.
; This code is used in the chapter "Analysis" in the
; <i>Introduction to IDL</i> training manual.
;
; @requires IDL 6.0
; @author Mark Piper, 2003
;-

; El Nino-Southern Oscillation (ENSO) data.
; Ask Chris about history. Data are floating point.
; Sea surface temps in equatorial Pacific Ocean.
file = filepath('elnino.dat', subdir=['examples','data'])
enso = read_binary(file, data_type=4)


; *** Perform calculations ***


; Create parameters from the dataset.
; n_data is the number of elts in the dataset. delta is the time
; interval between the points. freq_nyquist is the Nyquist freq.
; time is a vector of independent data values.
n_enso = n_elements(enso)
delta = 0.25                        ; additional info
time = findgen(n_enso)*delta + 1871 ; additional info
freq_nyquist = 0.5/delta

; Transform the data to the frequency domain.
enso_hat = fft(enso)
enso_psd = abs(enso_hat)^2

; Mark the cutoff frequency at two-tenths of the Nyquist frequency.
; This translates to a period of roughly 30 months.
; Use this to construct an order 5 Butterworth lowpass filter.
freq_c = 0.2*freq_nyquist
order  = 5
kernel = (dist(n_enso))[*,0]/(n_enso*delta)
filter = 1 / (1 + (kernel/freq_c)^(2*order))

; Apply the filter to the ENSO data.
enso_lpf = fft(enso_hat*filter, /inverse)


; *** Set up visualization ***


; Display the half power spectrum of the data plotted versus
; Fourier mode.
iplot, enso_psd, $
    color=[0,100,0], $
    identifier=enso_plot, $
    xrange=[0,n_enso/2], $
    xtitle='Mode', $
    ytitle='PSD', $
    title='ENSO Temperature Anomaly Record', $
    name='Spectrum'

; Display the filter on the spectrum plot, scaled to fit the
; plot window.
iplot, filter*max(enso_psd), $
    /overplot, $
    color=[100,0,0], $
    xrange=[0,n_enso/2], $
    yrange=[0,max(enso_psd)], $
    name='Filter'

; 1. Move plot window to LL corner of iTool display.
; (2.) Remove the top and right axes.
; 3. Select Window > Layout from menu. Choose "Inset" layout.
; 4. Resize and reposition the inset window, if desired.

; Display the dataset in the inset window.
iplot, time, enso, $
    /overplot, $
    view_number=2, $
    xtitle='Year', color=[0,0,200], $
    ytitle='Temperature Anomaly (!uo!nC)', $
    name='Original'

; Overplot the filtered signal on the original series. Add a zero line.
iplot, time, enso_lpf, $
    color=[200,0,0], $
    thick=2, $
    /overplot, $
    view_number=2, $
    name='Filtered'
iplot, time, time*0.0, /overplot, view_number=2

; 5. Resize and reposition the series plot in the inset window.
; 6. Add appropriate annotation to the display window.

end