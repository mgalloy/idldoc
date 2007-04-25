pro initialize_test, system=system, screen=screen
    compile_opt idl2

    N = 10L ^ (indgen(5) + 3)
    times = fltarr(4, n_elements(N))

    print, 'Initialize speed test'
    print

    for i = 0, n_elements(N) - 1 do begin
        start_t = manual_timer(1)
        temp = fltarr(N[i], /nozero)
        temp[*] = 5.
        end_t = manual_timer(1)
        times[0, i] = end_t - start_t
        temp = 0

        start_t = manual_timer(1)
        temp = fltarr(N[i]) + 5.
        end_t = manual_timer(1)
        times[1, i] = end_t - start_t
        temp = 0

        start_t = manual_timer(1)
        temp = replicate(5., N[i])
        end_t = manual_timer(1)
        times[2, i] = end_t - start_t
        temp = 0

        start_t = manual_timer(1)
        temp = fltarr(N[i], /nozero)
        replicate_inplace, temp, 5.
        end_t = manual_timer(1)
        times[3, i] = end_t - start_t
        temp = 0

        print, string(N[i], format='(E8.1)') + ' elements: ' $
            + string(times[0, i], format='(E8.1)') + ' seconds, ' $
            + string(times[1, i], format='(E8.1)') + ' seconds, ' $
            + string(times[2, i], format='(E8.1)') + ' seconds, ' $
            + string(times[3, i], format='(E8.1)') + ' seconds'
    endfor

    manual_output, N, times, filename='initialize', $
        title=system, xtitle='Number of elements in array', $
        ytitle='Time (seconds)', /xlog, /ylog, $
        screen=keyword_set(screen)
end
