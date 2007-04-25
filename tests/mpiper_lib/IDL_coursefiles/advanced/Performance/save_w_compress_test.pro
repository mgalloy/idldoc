function check_size, filename
    compile_opt idl2, hidden

    openr, lun, filename, /get_lun
    fs = fstat(lun)
    free_lun, lun

    return, fs.size
end


pro save_w_compress_test, system=system, screen=screen
    compile_opt idl2

    N = 10L ^ (indgen(6) + 2)
    times = fltarr(4, n_elements(N))
    sizes = fltarr(4, n_elements(N))

    print, 'Saving speed w/ compress test'
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
        sizes[0, i] = check_size('arr.txt')

        start_t = manual_timer(1)
        save, arr, filename='arr.sav'
        end_t = manual_timer(1)
        times[1, i] = end_t - start_t
        sizes[1, i] = check_size('arr.sav')

        start_t = manual_timer(1)
        openw, lun, 'arr.dat', /get_lun
        writeu, lun, arr
        free_lun, lun
        end_t = manual_timer(1)
        times[2, i] = end_t - start_t
        sizes[2, i] = check_size('arr.dat')

        start_t = manual_timer(1)
        openw, lun, 'arr_compress.dat', /get_lun, /compress
        writeu, lun, arr
        free_lun, lun
        end_t = manual_timer(1)
        times[3, i] = end_t - start_t
        sizes[3, i] = check_size('arr_compress.dat')

        arr = 0

        print, string(N[i], format='(E8.1)') + ' elements: ' $
            + string(times[0, i], format='(E8.1)') + ' seconds, ' $
            + string(times[1, i], format='(E8.1)') + ' seconds, ' $
            + string(times[2, i], format='(E8.1)') + ' seconds, ' $
            + string(times[3, i], format='(E8.1)') + ' seconds '
    endfor

    manual_output, N, sizes, filename='save_size', $
        title=system, xtitle='Number of elements in array', $
        ytitle='File size (bytes)', /xlog, /ylog, $
        screen=keyword_set(screen)

    manual_output, N, times, filename='save', $
        title=system, xtitle='Number of elements in array', $
        ytitle='Time (seconds)', /xlog, /ylog, $
        screen=keyword_set(screen)
end
