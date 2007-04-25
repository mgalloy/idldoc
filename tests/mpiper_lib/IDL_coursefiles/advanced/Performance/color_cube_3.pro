pro color_cube_3
    compile_opt idl2

    start_t = manual_timer(1)
    
    xsize = 400
    ysize = 400
    cube = bytarr(3, xsize, ysize)

    R = [0., 1.]
    G = [-sqrt(3) / 2., - 1. / 2.]
    B = [sqrt(3) / 2., - 1. / 2.]

    blue = bindgen(256)

    for red = 0, 255 do begin
        for green = 0, 255 do begin
            color_x = R[0] * red + G[0] * green + B[0] * blue
            color_y = R[1] * red + G[1] * green + B[1] * blue

            color_x = fix((color_x + 255) * (xsize - 1.) / 510.)
            color_y = fix((color_y + 255) * (xsize - 1.) / 510.)

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
