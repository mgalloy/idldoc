pro for_loop_test, system=system, screen=screen
    compile_opt idl2

    N = 10 ^ (indgen(6) + 3)
    times = fltarr(2, n_elements(N))

    print, 'FOR loop speed test'
    print

    for i = 0, n_elements(N) - 1 do begin
        array = randomn(seed, N[i])

        start_t = manual_timer(1)
        for j = 0, n_elements(array) - 1 do begin
            a = array[j]
        endfor
        end_t = manual_timer(1)
        times[0, i] = end_t - start_t

        start_t = manual_timer(1)
        n_array = n_elements(array) - 1
        for j = 0, n_array do begin
            a = array[j]
        endfor
        end_t = manual_timer(1)
        times[1, i] = end_t - start_t

        print, string(N[i], format='(E8.1)') + ' elements: ' $
            + string(times[0, i], format='(E8.1)') + ' seconds, ' $
            + string(times[1, i], format='(E8.1)') $
            + ' seconds; factor = ' $
            + string(times[0, i] / times[1, i], format='(E8.1)')
    endfor

    manual_output, N, times, filename='for_loop', $
        title=system, xtitle='Number of elements in array', $
        ytitle='Time (seconds)', /xlog, /ylog, $
        screen=keyword_set(screen)
end
