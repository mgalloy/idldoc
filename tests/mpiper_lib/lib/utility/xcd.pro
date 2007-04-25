;+
; A graphical interface for changing the current IDL directory. (It's
; just a wrapper around DIALOG_PICKFILE.)
;
; @examples
; <pre>
; IDL> xcd
; % Directory changed to "/home/mpiper/"
; </pre>
; @requires IDL 6.0
; @author Mark Piper, RSI, 2001
;-
pro xcd
    compile_opt idl2

    cd, current=current_dir
    new_dir = dialog_pickfile(/directory, $
        title='Change the current IDL directory to...')
    if file_test(new_dir, /directory) then begin
        cd, new_dir
        message, 'Directory changed to "' + new_dir + '"', /noname, /info
    endif else $
        message, 'Directory remains "' + current_dir + '"', /noname, /info
end
