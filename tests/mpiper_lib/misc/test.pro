

pro test

    ; enter some fake data.  This would be read in from the xml file

    name=make_array(3,/string)
    value = make_array(3,/long)

    name[0] = 'Beau'
    value[0] = 32
    name[1] = 'Fred'
    value[1] = 156
    name[2] = 'David'
    value[2] = 888

    num_total = 3

    ; to move the local variable in the soon-to-be-written pro code into this pro file (test), I need to know
    ; the present scope.

    level = scope_level()

    ; create a dummy pro file where I define the assignments (i.e. Beau = 32  Fred=156 ...).
    ; the assignments are then scoped back to the pro file (test)

    fname=filepath('ASSIGN.PRO',/tmp)
    openw, lun, fname, /get_lun
    printf, lun, 'PRO ASSIGN'

    for i=0,num_total-1 do begin
       fork = "(SCOPE_VARFETCH('"+name[i]+"', /ENTER, LEVEL=("+strtrim(string(level),2)+"))) = "+strtrim(string(value[i]),2)
       printf, lun, fork
    endfor

    printf, lun, 'end'

    close, lun
    free_lun, lun

    ; resolve the dummy pro file.  If an error is thrown here, you need to make sure your temp directory is in
    ; your path (check IDL preferences)

    resolve_routine, file_basename(fname,'.pro')

    ; call the dummy pro file

    call_procedure, 'assign'

    ; delete the dummy pro file
    file_delete, fname

    ; obtain the values of the new assignments in the pro test scope.

    a=dialog_message("Beau is "+string(Beau))
    a=dialog_message("Fred is "+string(Fred))
    a=dialog_message("David is "+string(David))

end