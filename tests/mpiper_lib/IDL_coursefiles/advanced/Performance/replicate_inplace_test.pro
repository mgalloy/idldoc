pro replicate_inplace_test, system=system, screen=screen
    compile_opt idl2

    N = 10L ^ (indgen(5) + 3)
    times = fltarr(2, n_elements(N))

    print, 'REPLICATE_INPLACE speed test'
    print

    for i = 0, n_elements(N) - 1 do begin
        array = randomn(seed, N[i])

        start_t = manual_timer(1)
        array[*] = 5.
        end_t = manual_timer(1)
        times[0, i] = end_t - start_t

        start_t = manual_timer(1)
        replicate_inplace, array, 5.
        end_t = manual_timer(1)
        times[1, i] = end_t - start_t

        print, string(N[i], format='(E8.1)') + ' elements: ' $
            + string(times[0, i], format='(E8.1)') + ' seconds, ' $
            + string(times[1, i], format='(E8.1)') $
            + ' seconds; factor = ' $
            + string(times[0, i] / times[1, i], format='(E8.1)')
    endfor

    manual_output, N, times, filename='replicate_inplace', $
        title=system, xtitle='Number of elements in array', $
        ytitle='Time (seconds)', /xlog, /ylog, $
        screen=keyword_set(screen)
end
