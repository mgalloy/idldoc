pro color_cube_6
    compile_opt idl2

    start_t = manual_timer(1)
    
    xsize = 200
    ysize = 200
    cube = bytarr(3, xsize, ysize)

    R = [0., 1.]
    G = [- sqrt(3) / 2., - 1. / 2.]
    B = [sqrt(3) / 2., - 1. / 2.]

    factor = 2

    blue = bindgen(256)
    blue_x = B[0] * bindgen(256)
    blue_y = B[1] * bindgen(256)

    mult = (xsize - 1.) / 510.

    for red = 0, 255, factor do begin
        for green = 0, 255, factor do begin
            color_x = R[0] * red + G[0] * green + blue_x
            color_y = R[1] * red + G[1] * green + blue_y

            color_x = fix((color_x + 255) * mult)
            color_y = fix((color_y + 255) * mult)

            indices = color_x * 3L + color_y * 3L * xsize
            cube[indices] = red
            cube[indices + 1] = green
            cube[indices + 2] = blue
        endfor
    endfor

    end_t = manual_timer(1)
    
    print, 'Color cube constructed in ' + strtrim(end_t - start_t, 2) + ' seconds' 

    window, /free, xsize=xsize, ysize=ysize, retain=2
    tv, cube, true=1
end
