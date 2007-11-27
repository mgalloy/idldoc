; docformat = 'rst'

;+
; Returns IDLdoc version. This file is automatically edited by the build process
; to edit the contents of the version and revision variables below.
;
; :Returns: string
; :Keywords: 
;    full : in, optional, type=boolean
;       set to return Subversion revision as well
;-
function idldoc_version, full=full
  compile_opt strictarr
  
  version = '3.0b1'
  revision = '-r327'
  
  return, version + (keyword_set(full) ? (' ' + revision) : '')
end
