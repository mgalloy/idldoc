;+
; Make a new array with...
;
; @author Mark Piper, 1998
;-

function zero_pad, x

    N     = n_elements(x)
    new_N = round(N/10.^level)*10.^level
    new_x = double(new_N)

    if (N lt new_N) then begin
        new_x = [ x[0:N-1], replicate(0.,new_N-N) ]
    endif
    if (N gt new_N) then begin
        new_x = x[0:new_N-1]
    endif
    if (N eq new_N) then begin
        new_x = x
    endif

    return, new_x

end