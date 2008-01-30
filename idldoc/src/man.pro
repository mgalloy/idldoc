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
;
; :Keywords:
;    full : in, optional, type=boolean
;       set to list the documentation for the routine, the default is to just
;       list the syntax for the routine
;    file : in, optional, type=boolean
;       set to list all routines in the given file, the default is to assume a 
;       routine name is passed into the routine
;-
pro man, routine_name, full=full, file=file
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
  ; TODO: create a special system object for this
end
