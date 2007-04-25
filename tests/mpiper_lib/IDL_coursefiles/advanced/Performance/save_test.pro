pro save_test, system=system, screen=screen
    compile_opt idl2

    N = 10L ^ (indgen(6) + 2)
    times = fltarr(3, n_elements(N))

    print, 'Saving speed test'
    print

    for i = 0, n_elements(N) - 1 do begin
        arr = findgen(N[i])
        col = findgen(N[i])

        start_t = manual_timer(1)
        openw, lun, 'arr.txt', /get_lun
        printf, lun, arr
        free_lun, lun
        end_t = manual_timer(1)
        times[0, i] = end_t - start_t

        start_t = manual_timer(1)
        save, arr, filename='arr.sav'
        end_t = manual_timer(1)
        times[1, i] = end_t - start_t

        start_t = manual_timer(1)
        openw, lun, 'arr.dat', /get_lun
        writeu, lun, arr
        free_lun, lun
        end_t = manual_timer(1)
        times[2, i] = end_t - start_t

        arr = 0

        print, string(N[i], format='(E8.1)') + ' elements: ' $
            + string(times[0, i], format='(E8.1)') + ' seconds, ' $
            + string(times[1, i], format='(E8.1)') + ' seconds, ' $
            + string(times[2, i], format='(E8.1)') $
            + ' seconds; factor = ' $
            + string(times[0, i] / times[1, i], format='(E8.1)')
    endfor

    manual_output, N, times, filename='save', $
        title=system, xtitle='Number of elements in array', $
        ytitle='Time (seconds)', /xlog, /ylog, $
        screen=keyword_set(screen)
end
