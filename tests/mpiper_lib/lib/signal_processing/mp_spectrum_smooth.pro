pro mp_spectrum_smooth_ex, u, _extra=e
compile_opt idl2
@catch_procedure

;   Count the number of elements in the input array.
n_u = n_elements(u)

;   Compute smoothed and unsmoothed periodograms of u using
;   SPW_POWER_SPEC and SPW_POWER_SPEC_SMOOTH.
delta = 0.1 ; seconds
u_spec = spw_power_spec(u, delta, frequency=u_freq)
u_sspec = spw_power_spec_smooth(u, delta, frequency=u_sfreq, $
    /logbin, smooth_param=35)

;   Plot the periodogram and the smoothed periodogram.
plot, u_freq[1:*], u_spec[1:*], _extra=e
oplot, u_sfreq, u_sspec, color=120, psym=-5, _extra=e

;   Test Parseval's theorem.
print, " Test Parseval's theorem:"
TP_freq = total(u_sspec)
udev = u - mean(u)
TP_phys = total(udev^2)
print, TP_freq, TP_phys, TP_freq/TP_phys

;   Test the variance of u.
print, " Test variance:"
TV_freq = total(u_sspec)/n_u       ; normalize by n_u
TV_phys = stdev(u)^2*(n_u-1)/n_u    ; convert from sample variance
print, TV_freq, TV_phys, TV_freq/TV_phys

end


; Copyright (c) 2000, Research Systems, Inc.  All rights reserved.
;   Unauthorized reproduction prohibited.
;+
; NAME:
;   SPW_POWER_SPEC_SMOOTH
;
; PURPOSE:
;   This function computes an averaged estimate of the power
;   spectral density of an input array.
;
; CATEGORY:
;   Analysis.
;
; CALLING SEQUENCE:
;   Spectrum = SPW_POWER_SPEC_SMOOTH(X, Delta)
;
; OPTIONAL INPUTS:
;   X:      An input array.
;   Delta:    The sampling interval of the input array.
;
; KEYWORD PARAMETERS:
;   SUM: The spectral density is estimated by summing the
;     periodogram estimates in a series of successive bins.
;   COMPOSITE: The spectral density is estimated by compositing
;     several time series.
;   LOGBIN: The spectral density is estimated by logarithmically
;     binning the periodogram values.
;   SMOOTH_PARAM: Used to set the smoothing intensity for the
;     three methods.
;   FREQUENCY: Set this keyword to a variable to receive the
;     array of frequencies for the computed power spectrum.
;
; EXAMPLE:
;   IDL> file = '/home/staff/mpiper/data/d79h03_03.dat'
;   IDL> sdata = READ_SONIC_DATA(file, 6000, 3000)
;   IDL> u = REFORM(sdata[1,*])   ; wind speed in m/s
;   IDL> delta = 0.1 ; seconds
;   IDL> u_spec = SPW_POWER_SPEC_SMOOTH(u, delta, /LOGBIN, $
;      SMOOTH_PARAM=10, FREQUENCY=u_freq)
;   IDL> plot, u_freq, u_spec, /XLOG, /YLOG
;
; MODIFICATION HISTORY:
;   Written by:     Mark Piper, 6-01-00
;-

function mp_spectrum_smooth, $
    x, $               ; input array
    delta, $             ; sampling interval in seconds
    smooth_param=sparam, $     ; smoothing parameter (in)
    frequency=frequency, $     ; frequency array (out)
    sum=sum, $           ; sum method (behavior)
    composite=composite, $     ; composite method (behavior)
    logbin=logbin, $      ; logarithmic bin method (behavior)
    check=check              ; check results (behavior)
compile_opt idl2
on_error, 2

;   Test the input parameters.
n_x = n_elements(x)
if n_params() ne 2 or n_x eq 0 then begin
    message, 'Please pass data array and sampling interval. ' + $
       'Returning', /continue
    return, -1
endif

;   Determine which smoothing method to use.
if keyword_set(sum) then schoice = 0
if keyword_set(composite) then schoice = 1
if keyword_set(logbin) then schoice = 2
if n_elements(schoice) eq 0 then schoice = 2

;   Force the value of the smoothing parameter to be odd.
sparam = n_elements(sparam) eq 0 ? 5L : long(sparam)
if (sparam mod 2) eq 0 then sparam = sparam + 1

;   Smooth, depending on case of schoice.
case schoice of
0:  begin
;   Sum periodogram estimates. This method preserves the property
;   that the sum of the PSD estimates equals the mean square value
;   of the function. Here, the smoothing param is a frequency
;   interval. Var(P_k) = E(P_k)^2 / K
    spec_x = spw_power_spec(x, delta, frequency=freq_x)
    n_modes = n_elements(spec_x)
    smooth_spec_x = fltarr(n_modes/sparam) ; integer division
    smooth_freq_x = smooth_spec_x
    i = n_modes - 1
    k = n_modes/sparam - 1
    while i ge sparam do begin
       j = i - lindgen(sparam)
       smooth_spec_x[k] = total(spec_x[j])/n_elements(spec_x[j])
       smooth_freq_x[k] = freq_x[j[2]]
       i = i - sparam
       k = k - 1
    endwhile
    ;  Check results.  Note: this method omits the zero mode!
    if keyword_set(check) then begin
       print, 'Compare sums of original and smoothed periodograms:'
       print, total(spec_x[1:*]), total(smooth_spec_x)
    endif
    end
1:  begin
;   Composite and average several periodograms over the same frequency
;   interval. Var(P_k) = E(P_k)^2 / K
    n_partitions = sparam + 1
    n_points = n_x / n_partitions  ; integer division
    spec_xp = 0.0
    for i = 0,sparam-1 do begin
       p0 = i*n_points
       p1 = (i+2)*n_points-1 ; 50% overlapping partitions
       xp = x[p0:p1]
       ;xp = xp*spw_window(n_elements(xp), /welch)
       spec_xp = spec_xp + spw_power_spec(xp, delta, freq=freq_xp)
    endfor
    smooth_spec_x = spec_xp / sparam
    smooth_freq_x = freq_xp
    end
2:  begin
;   Group the spectral density estimates into logarithmically
;   spaced bins -- on a log plot of frequencies, the bins will
;   be evenly spaced.  This method produces a very smooth spectral
;   density estimate.
    spec_x = spw_power_spec(x, delta, frequency=freq_x)
    n_modes = n_elements(spec_x)
    partition = findgen_alog10(freq_x[1], $    ; Don't use DC mode
       freq_x[n_modes-1], $          ; Nyquist freq
       2*sparam+1)                ; Double # for center freq
    smooth_spec_x = fltarr(sparam)
    smooth_freq_x = partition[2*indgen(sparam)+1]
    for i = 0, 2*(sparam-1), 2 do begin
       index = where(freq_x ge partition[i] and $
         freq_x lt partition[i+2], n_values)
       if n_values le 2 then begin
         smooth_spec_x[i/2] = !values.f_NaN
       endif else begin
         moments = moment(spec_x[index])
         smooth_spec_x[i/2] = moments[0]
       endelse
    endfor
    end
else:
endcase

;   Optionally return the frequencies of the smoothed power spectrum.
if arg_present(frequency) then frequency = smooth_freq_x

;   Return the smoothed power spectrum.
return, smooth_spec_x

end
