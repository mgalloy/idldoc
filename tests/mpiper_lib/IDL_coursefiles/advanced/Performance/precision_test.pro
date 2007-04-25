pro precision_test, system=system, screen=screen
    compile_opt idl2

    N = 10 ^ (indgen(5) + 3)
    times = fltarr(2, n_elements(N))

    print, 'Precision speed test'
    print

    for i = 0, n_elements(N) - 1 do begin
        farray1 = 200 * randomn(seed, N[i])
        farray2 = 200 * randomn(seed, N[i])

        barray1 = byte(farray1)
        barray2 = byte(farray2)

        start_t = manual_timer(1)
        farray = farray1 * farray2
        end_t = manual_timer(1)
        times[0, i] = end_t - start_t

        start_t = manual_timer(1)
        barray = barray1 * barray2
        end_t = manual_timer(1)
        times[1, i] = end_t - start_t


        print, string(N[i], format='(E8.1)') + ' elements: ' $
            + string(times[0, i], format='(E8.1)') + ' seconds, ' $
            + string(times[1, i], format='(E8.1)') $
            + ' seconds; factor = ' $
            + string(times[0, i] / times[1, i], format='(E8.1)')
    endfor

    manual_output, N, times, filename='precision', $
        title=system, xtitle='Number of elements in array', $
        ytitle='Time (seconds)', /xlog, /ylog, $
        screen=keyword_set(screen)
end
