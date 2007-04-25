pro blas_axpy_test, system=system, screen=screen
    compile_opt idl2

    N = 10 ^ (indgen(5) + 3)
    times = fltarr(2, n_elements(N))

    print, 'BLAS_AXPY speed test'
    print

    for i = 0, n_elements(N) - 1 do begin
        array = randomn(seed, N[i], 7)
        row = randomn(seed, N[i])

        start_t = manual_timer(1)
        array[*, 3] = array[*, 3] + 2. * row
        end_t = manual_timer(1)
        times[0, i] = end_t - start_t

        start_t = manual_timer(1)
        blas_axpy, array, 2., row, 1, [0, 3]
        end_t = manual_timer(1)
        times[1, i] = end_t - start_t     

        print, string(N[i], format='(E8.1)') + ' elements: ' $
            + string(times[0, i], format='(E8.1)') + ' seconds, ' $
            + string(times[1, i], format='(E8.1)') $
            + ' seconds; factor = ' $
            + string(times[0, i] / times[1, i], format='(E8.1)')
    endfor

    manual_output, N, times, filename='blas_axpy', $
        title=system, xtitle='Number of elements in array', $
        ytitle='Time (seconds)', /xlog, /ylog, $
        screen=keyword_set(screen)
end
