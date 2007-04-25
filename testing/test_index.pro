pro test_index
    compile_opt strictarr

    oindex = obj_new('idldocindex')
    n = 1000L

    vals = byte(randomn(seed, n, /normal) * 4.0 + 77.5)
    for i = 0L, n - 1L do begin
        name = string(vals[i]) +  strtrim(i, 2) + '_name'
        oindex->add_item, name=name, url='./test.pro', description='Some description'
    endfor

    fletters = oindex->get_first_letters()
    divisions = oindex->get_divisions(max_per_page=100, num_letters=nletters)
    for i = 0L, n_elements(nletters) - 1L do begin
        print, fletters[divisions[i]:(divisions[i] + nletters[i] - 1L)]
    endfor

    print, '--'

    obj_destroy, oindex
end