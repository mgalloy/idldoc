pro reform_test, system=system, screen=screen
    compile_opt idl2

    N = 10L ^ (indgen(6) + 2)
    times = fltarr(2, n_elements(N))

    print, 'REFORM speed test'
    print

    for i = 0, n_elements(N) - 1 do begin
        array = randomn(seed, 2, N[i])
        col = findgen(N[i])

        start_t = manual_timer(1)
        array[1, *] = col
        end_t = manual_timer(1)
        times[0, i] = end_t - start_t

        start_t = manual_timer(1)
        array[1, 0] = reform(col, 1, N[i])
        end_t = manual_timer(1)
        times[1, i] = end_t - start_t

        print, string(N[i], format='(E8.1)') + ' elements: ' $
            + string(times[0, i], format='(E8.1)') + ' seconds, ' $
            + string(times[1, i], format='(E8.1)') $
            + ' seconds; factor = ' $
            + string(times[0, i] / times[1, i], format='(E8.1)')
    endfor

    manual_output, N, times, filename='reform', $
        title=system, xtitle='Number of elements in array', $
        ytitle='Time (seconds)', /xlog, /ylog, $
        screen=keyword_set(screen)
end
