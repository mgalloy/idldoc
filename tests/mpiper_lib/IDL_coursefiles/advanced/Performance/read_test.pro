pro read_test, system=system, screen=screen
    compile_opt idl2

    N = 10L ^ (indgen(6) + 2)
    times = fltarr(6, n_elements(N))
    times[0, *] = !values.f_nan

    print, 'Read test'
    print

    for i = 0, n_elements(N) - 1 do begin
        ; ASCII file
        arr = findgen(N[i])
        openw, lun, 'arr.txt', /get_lun
        printf, lun, arr, format='(F20.10)'
        free_lun, lun

        arr_r0 = 0
        check = temporary(arr_r0)

        if (i le 3) then begin
            ; Concatenation
            start_t = manual_timer(1)
            openr, lun, 'arr.txt', /get_lun
            line = ''
            while (not eof(lun)) do begin
                readf, lun, line
                if (n_elements(arr_r0) eq 0) then begin
                    arr_r0 = float(line)
                    n_lines = 1
                endif else begin
                    arr_r0 = [arr_r0, float(line)]
                    n_lines = n_lines + 1
                endelse
            endwhile
            free_lun, lun
            end_t = manual_timer(1)
            times[0, i] = end_t - start_t
        endif

        ; 2 pass: count lines, then read
        start_t = manual_timer(1)
        openr, lun, 'arr.txt', /get_lun
        n_lines = 0
        line = ''
        while (not eof(lun)) do begin
            n_lines = n_lines + 1
            readf, lun, line
        endwhile
        arr_r1 = fltarr(n_lines, /nozero)
        point_lun, lun, 0
        readf, lun, arr_r1
        free_lun, lun
        end_t = manual_timer(1)
        times[1, i] = end_t - start_t

        ; Straigh ASCII read
        start_t = manual_timer(1)
        openr, lun, 'arr.txt', /get_lun
        arr_r = fltarr(N[i], /nozero)
        readf, lun, arr_r
        free_lun, lun
        end_t = manual_timer(1)
        times[2, i] = end_t - start_t

        ; SAV file
        arr = findgen(N[i])
        save, arr, filename='arr.sav'

        start_t = manual_timer(1)
        restore, 'arr.sav'
        end_t = manual_timer(1)
        times[3, i] = end_t - start_t

        ; Binary
        arr = findgen(N[i])
        openw, lun, 'arr.dat', /get_lun
        writeu, lun, arr
        free_lun, lun

        start_t = manual_timer(1)
        arr = fltarr(N[i])
        openr, lun, 'arr.dat', /get_lun
        readu, lun, arr
        free_lun, lun
        end_t = manual_timer(1)
        times[4, i] = end_t - start_t

        ; Binary with compression
        arr = findgen(N[i])
        openw, lun, 'arr_compress.dat', /get_lun, /compress
        writeu, lun, arr
        free_lun, lun

        start_t = manual_timer(1)
        arr = fltarr(N[i])
        openr, lun, 'arr_compress.dat', /get_lun, /compress
        readu, lun, arr
        free_lun, lun
        end_t = manual_timer(1)
        times[5, i] = end_t - start_t

        print, string(N[i], format='(E8.1)') + ' elements: ' $
            + string(times[0, i], format='(E8.1)') + ' seconds, ' $
            + string(times[1, i], format='(E8.1)') + ' seconds, ' $
            + string(times[2, i], format='(E8.1)') + ' seconds, ' $
            + string(times[3, i], format='(E8.1)') + ' seconds, ' $
            + string(times[4, i], format='(E8.1)') + ' seconds, ' $
            + string(times[5, i], format='(E8.1)') + ' seconds '
    endfor

    manual_output, N, times, filename='read', $
        title=system, xtitle='Number of elements in array', $
        ytitle='Time (seconds)', /xlog, /ylog, $
        screen=keyword_set(screen)
end
