;+
; An example of using the IDL POLY_FIT function. This code
; is used in the chapter "Analysis" in the <i>Introduction to
; IDL</i> course manual.
;
; @examples
; <pre>
; IDL> polyfit_ex
; </pre>
; @requires IDL 5.3
; @author Mark Piper, RSI, 2002
;-
pro polyfit_ex
    compile_opt idl2

    ; Read data from file.
    file = filepath('damp_sn2.dat', subdir=['examples','data'])
    sine = read_binary(file)

    n_sine = n_elements(sine)
    x = indgen(n_sine)

    coeffs = poly_fit(x, sine, 7, yfit=new_sine)

    plot, x, sine, psym=5, symsize=0.7
    oplot, x, new_sine
end
