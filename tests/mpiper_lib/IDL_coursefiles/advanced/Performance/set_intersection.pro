function set_intersection, a, b
    ;Only need intersection of ranges
    minab = min(a, max=maxa) > min(b, max=maxb)
    maxab = maxa < maxb

    ; If either set is empty, or their ranges don't intersect:
    ; result = NULL.
    if ((maxab lt minab) or (maxab lt 0)) then return, -1

    r = where((histogram(a, min=minab, max=maxab) ne 0) and  $
        (histogram(b, min=minab, max=maxab) ne 0), count)

    if (count eq 0) then return, -1 else return, r + minab
end

