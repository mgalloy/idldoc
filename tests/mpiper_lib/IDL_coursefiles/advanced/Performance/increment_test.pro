;+
; Tests the efficiency of the increment operator. Increment/decrement
; operators are very efficient because the variable is incremented in
; place; no temporary copies of the data are made.
;-
pro increment_test, system=system, screen=screen
    compile_opt idl2

    N = 10L ^ (indgen(6) + 2)
    times = fltarr(4, n_elements(N))

    print, 'Increment operator speed test'
    print

    for i = 0, n_elements(N) - 1 do begin

        start_t = manual_timer(1)
        for j = 0, N[i] - 1 do begin
        endfor
        end_t = manual_timer(1)
        base_t = end_t - start_t

        value = 0
        start_t = manual_timer(1)
        for j = 0, N[i] - 1 do begin
            value = value + 1
        endfor
        end_t = manual_timer(1)
        times[0, i] = end_t - start_t - base_t

        value = 0
        start_t = manual_timer(1)
        for j = 0, N[i] - 1 do begin
            value = temporary(value) + 1
        endfor
        end_t = manual_timer(1)
        times[1, i] = end_t - start_t - base_t

        value = 0
        start_t = manual_timer(1)
        for j = 0, N[i] - 1 do begin
            value++
        endfor
        end_t = manual_timer(1)
        times[2, i] = end_t - start_t - base_t

        value = 0
        start_t = manual_timer(1)
        for j = 0, N[i] - 1 do begin
            ++value ; in theory, prefix is favored over postfix
        endfor
        end_t = manual_timer(1)
        times[3, i] = end_t - start_t - base_t

        print, string(N[i], format='(E8.1)') + ' elements: ' $
            + string(times[0, i], format='(E8.1)') + ' seconds, ' $
            + string(times[1, i], format='(E8.1)') + ' seconds, ' $
            + string(times[2, i], format='(E8.1)') + ' seconds, ' $
            + string(times[3, i], format='(E8.1)') + ' seconds '
    endfor

    manual_output, N, times, filename='increment', $
        title=system, xtitle='Number of elements in array', $
        ytitle='Time (seconds)', /ylog, /xlog, $
        screen=keyword_set(screen)
end
