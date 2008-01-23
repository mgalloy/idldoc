; docformat = 'rst'

;+
; Find the filename in which the given routine is located.
;
; Checks previously compiled routines first, then looks for a file with the
; same name plus .pro in the !path.
;
; :Params:
;    routine_name : in, required, type=string
;       name of routine to find location of
;-
function man_getfilename, routine_name
  compile_opt strictarr
  
  help, /source_files, output=output
  matches = stregex(output, '^' + strupcase(routine_name) + '[[:space:]]+', /boolean)
  ind = where(matches, nmatches)
  if (nmatches eq 0) then begin
    return, file_which(routine_name + '.pro')
   endif else begin
    line = output[ind[0]]
    tokens = strsplit(line, /extract)
    return, tokens[1]
  endelse
end


;+
; Print documentation for routine in output log.
;
; :Params:
;    routine_name : in, required, type=string
;       name of routine to find documentation for
;-
pro man, routine_name
  compile_opt strictarr
  on_error, 2
  
  if (n_params() ne 1) then message, 'routine name required'
  
  ; get location of routine
  filename = man_getfilename(routine_name)
  if (filename eq '') then begin
    print, routine_name + ' not found'
    return
  endif
  
  ; TODO: create DOCtreeFile
  ; TODO: get correct routine out of file
end
