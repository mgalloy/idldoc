pro reverse_indices_test, system=system, screen=screen
    compile_opt idl2

    N = 10L ^ (indgen(5) + 3)
    times = fltarr(2, n_elements(N))

    print, 'REVERSE_INDICES speed test'
    print

    for i = 0, n_elements(N) - 1 do begin
        arr1 = fix(2 * randomu(seed, N[i]))
        arr2 = arr1

        start_t = manual_timer(1)
        ind = where(arr1 eq 0, count)
        if (count ne 0) then arr1[ind] = -1 else continue
        end_t = manual_timer(1)
        times[0, i] = end_t - start_t

        start_t = manual_timer(1)
        h = histogram(arr2, reverse_indices=r)
        if (r[0] ne r[1]) then arr2[r[r[0]:r[1]-1]] = -1
        end_t = manual_timer(1)
        times[1, i] = end_t - start_t

        print, string(N[i], format='(E8.1)') + ' elements: ' $
            + string(times[0, i], format='(E8.1)') + ' seconds, ' $
            + string(times[1, i], format='(E8.1)') $
            + ' seconds; factor = ' $
            + string(times[0, i] / times[1, i], format='(E8.1)') $
            + (array_equal(arr1, arr2) ? '' : ' not equal')
    endfor

    manual_output, N, times, filename='reverse_indices', $
        title=system, xtitle='Number of elements in array', $
        ytitle='Time (seconds)', /xlog, /ylog, $
        screen=keyword_set(screen)
end
