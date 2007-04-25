function scale_vector, vec, min, max
    compile_opt idl2, hidden

    max_vec = max(vec, min=min_vec)
    return, (max - min) / (max_vec - min_vec) * (vec - min_vec) + min
end


pro quadrant_search
    compile_opt idl2

    n_points = 10

    x = 100. * (randomu(seed, n_points) - 0.5)
    y = 100. * (randomu(seed, n_points) - 0.5)

    xx = scale_vector(x, 0., 0.9999999)
    yy = scale_vector(y, 0., 0.9999999)
    result = hist_2d(xx, yy, bin1=0.5, bin2=0.5, min1=0.0, max1=1.0, $
        min2=0.0, max2=1.0)

    print, x
    print
    print, y
    print

    print, result[1, 1], result[0, 1], result[0, 0], result[1, 0]
    print, result[0:1, 0:1]
    print

    index = where(x gt 0 and y gt 0, count1)
    index = where(x lt 0 and y gt 0, count2)
    index = where(x lt 0 and y lt 0, count3)
    index = where(x gt 0 and y lt 0, count4)

    print, count1, count2, count3, count4
end