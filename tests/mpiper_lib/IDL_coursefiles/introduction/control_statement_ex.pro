;+
; Examples of selected control statements.
; This code is used in the chapter "Programming"
; in the <i>Introduction to IDL</i> course manual.
;
; @requires IDL 6.0
; @author Mark Piper, RSI, 2003
;-
pro control_statement_ex

    x = randomn(blah)
    print, 'x = ', x

    switch 1 of
    x lt 0: begin
            print, 'x is less than zero.'
            break
        end
    x gt 0: print, 'x is greater than zero.'
    x eq 0: print, 'x is equal to zero.'
    else:
    endswitch

    sequence = findgen(21)
    for j=20, 0, -2 do begin
        print, j, sequence[j], sequence[j] mod 4
    endfor
end