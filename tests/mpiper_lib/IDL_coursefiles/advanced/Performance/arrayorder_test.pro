pro arrayorder_test, system=system, screen=screen
    compile_opt idl2

    N = 1000L * (indgen(6) + 1)
    times = fltarr(2, n_elements(N))

    print, 'Array order speed test'
    print

    for i = 0, n_elements(N) - 1 do begin
        array = fltarr(N[i], N[i])

        start_t = manual_timer(1)
        for j = 0, N[i] - 1 do begin
            col = array[j, *]
        endfor
        end_t = manual_timer(1)
        times[0, i] = end_t - start_t

        start_t = manual_timer(1)
        for j = 0, N[i] - 1 do begin
            row = array[*, j]
        endfor
        end_t = manual_timer(1)
        times[1, i] = end_t - start_t

        print, string(N[i], format='(E8.1)') + ' elements: ' $
            + string(times[0, i], format='(E8.1)') + ' seconds, ' $
            + string(times[1, i], format='(E8.1)') $
            + ' seconds; factor = ' $
            + string(times[0, i] / times[1, i], format='(E8.1)')
    endfor

    manual_output, N, times, filename='arrayorder', $
        title=system, xtitle='Number of elements in each ' + $
        'dimension of a 2-dimensional array', $
        ytitle='Time (seconds)', /ylog, $
        screen=keyword_set(screen)
end
