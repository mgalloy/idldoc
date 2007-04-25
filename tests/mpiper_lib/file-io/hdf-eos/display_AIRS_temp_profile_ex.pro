pro display_AIRS_temp_profile_ex
    compile_opt idl2

    file = dialog_pickfile(filter='*.hdf')
    print, file

    ;; flag '3' returns data from swath into parameter 'buffer'.
    a = read_l12_swath_file(file, 3, buffer)

    ;; temperature profile at one point, logarithmic vertical axis
    plot, buffer.tairstd[*,0,0], buffer.pressstd, xrange=[1e2,3e2], $
        yrange=[1e3,1e-1], /ylog, xtitle='Temperature (K)', $
        ytitle='Pressure (mb)'
end
