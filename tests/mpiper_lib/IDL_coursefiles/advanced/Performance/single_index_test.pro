pro single_index_test, system=system, screen=screen
    compile_opt idl2

    N = 10 ^ (indgen(5) + 3)
    times = fltarr(2, n_elements(N))

    print, 'Single index speed test'
    print

    for i = 0, n_elements(N) - 1 do begin
        n_cols = sqrt(N[i])
        n_rows = sqrt(N[i])
        array = randomn(seed, n_cols, n_rows)

        start_t = manual_timer(1)
        for x = 0, n_rows - 1 do $
            for y = 0, n_cols - 1 do $
                array[x, y] = array[x, y] + 1
        end_t = manual_timer(1)
        times[0, i] = end_t - start_t

        start_t = manual_timer(1)
        for idx = 0, n_elements(array) - 1 do $
            array[idx] = array[idx] + 1.
        end_t = manual_timer(1)
        times[1, i] = end_t - start_t


        print, string(N[i], format='(E8.1)') + ' elements: ' $
            + string(times[0, i], format='(E8.1)') + ' seconds, ' $
            + string(times[1, i], format='(E8.1)') $
            + ' seconds; factor = ' $
            + string(times[0, i] / times[1, i], format='(E8.1)')
    endfor

    manual_output, N, times, filename='single_index', $
        title=system, xtitle='Number of elements in array', $
        ytitle='Time (seconds)', /xlog, /ylog, $
        screen=keyword_set(screen)
end
