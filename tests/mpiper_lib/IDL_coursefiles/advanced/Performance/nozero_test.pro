pro nozero_test, system=system, screen=screen
    compile_opt idl2

    N = long(10L ^ (0.5 * lindgen(7) + 5))
    times = fltarr(2, n_elements(N))

    print, 'NOZERO speed test'
    print

    for i = 0, n_elements(N) - 1 do begin
        start_t = manual_timer(1)
        new1 = fltarr(N[i])
        end_t = manual_timer(1)
        times[0, i] = end_t - start_t
        new1 = 0

        start_t = manual_timer(1)
        new2 = fltarr(N[i], /nozero)
        end_t = manual_timer(1)
        times[1, i] = end_t - start_t
        new2 = 0

        print, string(N[i], format='(E8.1)') + ' elements: ' $
            + string(times[0, i], format='(E8.1)') + ' seconds, ' $
            + string(times[1, i], format='(E8.1)') $
            + ' seconds; factor = ' $
            + string(times[0, i] / times[1, i], format='(E8.1)')
    endfor

    manual_output, N, times, filename='nozero', $
        title=system, xtitle='Number of elements in array', $
        ytitle='Time (seconds)', /xlog, /ylog, $
        screen=keyword_set(screen)
end
