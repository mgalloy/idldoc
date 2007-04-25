;+
; This function returns a windowing array.  The array can be applied
; to a data array before computing an FFT.
; <p>
;
; Reference: Priestley, M.B., 1981: <i>Spectral Analysis and Time
;   Series.</i> Academic Press, 890 pp.
;
; @returns An array the same length as the input series containing
;   a windowing function.
;
; @param n {in}{type=long} A value giving the size (number of elements)
;   of the window to be generated.
; @keyword bartlett {type=boolean} Set to return a Bartlett window.
; @keyword connes {type=boolean} Set to return a Connes window.
; @keyword cosine {type=boolean} Set to return a cosine window.
; @keyword gaussian {type=boolean} Set to return a Gaussian window.
; @keyword hanning {type=boolean} Set to return a Hanning window.
; @keyword hamming {type=boolean} Set to return a Hamming window.
; @keyword rectangular {type=boolean} Set to return a rectangular window.
; @keyword welch {type=boolean} Set to return a Welch window.
; @keyword bell_taper {type=boolean} Set to return a bell taper window.
; @keyword double {type=boolean} Set to use double precision.
;
; @examples
; <pre>
; IDL> n_u = 100<br>
; IDL> x = (!pi/n_u)*findgen(n_u)<br>
; IDL> u = sin(4*x) + sin(1.5*x) + 0.1*randomn(seed,n_u)<br>
; IDL> u_hat = fft(u*mp_window(n_u, /hanning), -1)<br>
; </pre>
;
; @requires IDL 5.2 or greater
; @history IDLdoc'ed, 2002
; @author Mark Piper, 2000
;-

function mp_window, n, $
    bartlett=bwin, $
    connes=cwin, $
    cosine=coswin, $
    gaussian=gwin, $
    hanning=hanwin, $
    hamming=hamwin, $
    rectangular=rwin, $
    welch=wwin, $
    bell_taper=belwin, $
    double=dbl

    compile_opt idl2
    on_error, 2

    ; Check the input parameter.
    if n_elements(n) eq 0 then begin
        message, 'A default window array size of 100 elts will be used.', $
            /info, /noname
        n = 100
    endif

    ; Determine a windowing array type.
    if keyword_set(bwin) then winchoice=1
    if keyword_set(cwin) then winchoice=2
    if keyword_set(coswin) then winchoice=3
    if keyword_set(gwin) then winchoice=4
    if keyword_set(hanwin) then winchoice=5
    if keyword_set(hamwin) then winchoice=6
    if keyword_set(rwin) then winchoice=7
    if keyword_set(wwin) then winchoice=8
    if keyword_set(belwin) then winchoice=9
    if n_elements(winchoice) eq 0 then winchoice = 1

    ; Check for the double keyword.
    wtype = keyword_set(dbl) ? 5 : 4

    ; Compute the elements of the windowing array, depending
    ; on the choice of windowing array.
    x = 2*indgen(n, type=wtype)/n - 1
    case winchoice of
    1:  win = 1 - abs(x)            ; Bartlett
    2:  win = (1 - x^2)^2           ; Connes
    3:  win = cos(!pi/2*x)          ; Cosine
    4:  win = exp(-x^2/2)           ; Gaussian
    5:  win = hanning(n,alpha=0.54) ; Hamming
    6:  win = hanning(n,alpha=0.5)  ; Hanning
    7:  win = fltarr(n) + 1.0       ; Rectangular
    8:  win = 1 - x^2               ; Welch
    9:  begin                       ; Bell taper
        l_taper = fix(0.1*n)
        y = findgen(l_taper)/l_taper
        win = fltarr(n) + 1.0
        front_taper = sin(!pi/2*y)^2
        rear_taper  = cos(!pi/2*y)^2
        win[0:l_taper-1]   = front_taper
        win[n-l_taper:n-1] = rear_taper
        end
    else: begin
        message, 'Invalid window choice.', /info
        return, -1
        end
    endcase

    ; Return the windowing array to the calling program.
    return, fix(win, type=wtype)

end