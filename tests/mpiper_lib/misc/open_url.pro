;+
; Open an url in the default web browser.
;
; @param url {in}{required}{type=string} url to goto in the default web browser
;-
pro open_url, url
    compile_opt strictarr

    case !version.os_family of
    'Windows' : spawn, 'start ' + url, /hide, /nowait
    else : begin
                if (!version.os_name eq 'Mac') then begin
                    spawn, 'Open ' + url + ';', /noshell
                    return
                endif

                dir = app_user_dir('gsg', $
                    'RSI Global Services Group', $
                    'default-browser', $
                    'Default browser location', $
                    'The file ', 1)
                file = filepath('default-browser', root=dir)
                if (file_test(file)) then begin
                    openr, lun, file, /get_lun
                    browser = ''
                    readf, lun, browser
                    free_lun, lun
                    spawn, browser + ' ' + url
                endif else begin
                    f = dialog_pickfile()
                    openw, lun, file, /get_lun
                    printf, lun, f
                    free_lun, lun
                    msg = ['Your browser location has been stored in:', '', $
                        '    ' + file, '']
                    ok = dialog_message(msg, /info)
                    spawn, f + ' ' + url
                endelse
           end
    endcase
end
