pro matrix_multiply_test, system=system, screen=screen
    compile_opt idl2

    N = 10L ^ (indgen(4) + 3)
    times = dblarr(2, n_elements(N))

    print, 'MATRIX_MULTIPLY speed test'
    print

    for i = 0, n_elements(N) - 1 do begin
        A = dindgen(5, N[i])
        B = dindgen(5, N[i])

        start_t = manual_timer(1)
        temp_array_1 = A # transpose(B)
        end_t = manual_timer(1)
        times[0, i] = end_t - start_t

        start_t = manual_timer(1)
        temp_array_2 = matrix_multiply(A, B, /btranspose)
        end_t = manual_timer(1)
        times[1, i] = end_t - start_t

        print, string(5*N[i], format='(E8.1)') + ' elements: ' $
            + string(times[0, i], format='(E8.1)') + ' seconds, ' $
            + string(times[1, i], format='(E8.1)') $
            + ' seconds; factor = ' $
            + string(times[0, i] / times[1, i], format='(E8.1)')
    endfor

    manual_output, 5*N, times, filename='matrix_multiply', $
        title=system, xtitle='Number of elements in array', $
        ytitle='Time (seconds)', /xlog, /ylog, $
        screen=keyword_set(screen)
end
