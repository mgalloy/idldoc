pro temporary_test, system=system, screen=screen
    compile_opt idl2

    N = 10L ^ (indgen(5) + 3)
    times = fltarr(2, n_elements(N))

    print, 'TEMPORARY speed test'
    print

    for i = 0, n_elements(N) - 1 do begin
        array = randomn(seed, N[i])

        help, /memory

        start_t = manual_timer(1)
        array = array * 2.
        end_t = manual_timer(1)
        times[0, i] = end_t - start_t

        help, /memory

        start_t = manual_timer(1)
        array = temporary(array) * 2.
        end_t = manual_timer(1)
        times[1, i] = end_t - start_t

        help, /memory

        print, string(N[i], format='(E8.1)') + ' elements: ' $
            + string(times[0, i], format='(E8.1)') + ' seconds, ' $
            + string(times[1, i], format='(E8.1)') $
            + ' seconds; factor = ' $
            + string(times[0, i] / times[1, i], format='(E8.1)')
    endfor

    manual_output, N, times, filename='temporary', $
        title=system, xtitle='Number of elements in array', $
        ytitle='Time (seconds)', /xlog, /ylog, $
        screen=keyword_set(screen)
end
