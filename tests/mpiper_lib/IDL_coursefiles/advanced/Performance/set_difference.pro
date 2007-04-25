function set_difference, a, b

    ; = a and (not b) = elements in A but not in B

    mina = min(a, max=maxa)
    minb = min(b, max=maxb)
    if ((minb gt maxa) or (maxb lt mina)) then return, a
    r = where((histogram(a, min=mina, max=maxa) ne 0) and $
        (histogram(b, min=mina, max=maxa) eq 0), count)
    if (count eq 0) then return, -1 else return, r + mina
end

