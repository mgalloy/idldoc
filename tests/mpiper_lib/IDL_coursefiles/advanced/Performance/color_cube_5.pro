pro color_cube_5
    compile_opt idl2

    start_t = manual_timer(1)

    xsize = 400L
    ysize = 400L
    cube = bytarr(3, xsize, ysize)

    sqrt3d2 = sqrt(3.) / 2.

    R = [0., 1.]
    G = [-sqrt3d2, - 1./2.]
    B = [sqrt3d2, - 1./2.]

    blue = bindgen(256)
    blue_x = B[0] * bindgen(256)
    blue_y = B[1] * bindgen(256)

    mult = (xsize - 1.) / 510.

    for red = 0., 255. do begin
        for green = 0., 255. do begin
            color_x = R[0] * red + G[0] * green + blue_x
            color_y = R[1] * red + G[1] * green + blue_y

            color_x = fix((color_x + 255L) * mult)
            color_y = fix((color_y + 255L) * mult)

            indices = color_x * 3L + color_y * 3L * xsize

            cube[indices] = red
            cube[indices + 1] = green
            cube[indices + 2] = blue
        endfor
    endfor

    end_t = manual_timer(1)

    print, 'Color cube constructed in ' + strtrim(end_t - start_t, 2) + ' seconds'

    window, /free, xsize=xsize, ysize=400
    tv, cube, true=1
end
