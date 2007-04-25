pro sparse_test, system=system, screen=screen
    compile_opt idl2

    percentages = findgen(11) * 0.1
    sizes = fltarr(2, n_elements(percentages))
    array_size = 3e3
    sizes[0, *] = array_size^2 * 4

    print, 'Sparse matrix size test'
    print

    for i = 0, n_elements(percentages) - 1 do begin
        array = randomu(seed, array_size, array_size)
        if (i gt 0) then begin
          zero_indices = randomu(seed, array_size^2 * percentages[i]) $
                  * array_size^2
          array[zero_indices] = 0.0
        endif

        sarray = sprsin(array)
        sizes[1, i] = n_tags(sarray, /length)

        print, string(percentages[i], format='(E8.1)') $
            + '% zero elements: ' $
            + string(sizes[0, i], format='(E8.1)') + ' bytes, ' $
            + string(sizes[1, i], format='(E8.1)') $
            + ' bytes; factor = ' $
            + string(sizes[0, i] / sizes[1, i], format='(E8.1)')
    endfor

    manual_output, percentages, sizes, filename='sparse', $
        title=system, xtitle='Percentage of zero elements', $
        ytitle='Size (bytes)', screen=keyword_set(screen)
end
