; docformat = 'rst'

;+
; This parser handles overview files. The format for an overview file is a 
; section of free comments followed by an optional list of of `dir` tags.
;-


;+
; Parse the given overview file.
; 
; :Returns: file tree object
; :Params:
;    `filename` : in, required, type=string
;       absolute path to .pro file to be parsed
; :Keywords:
;    `found` : out, optional, type=boolean
;       returns 1 if filename found, 0 otherwise
;-
function docparoverviewfileparser::parse, filename, found=found
  compile_opt strictarr
  
  ; TODO: implement this
end


;+
; Define instance variables.
; 
; :Fields:
;    `filename` absolute path to overview file to be parsed
;-
pro docparoverviewfileparser__define
  compile_opt strictarr
  
	define = { DOCparOverviewFileParser, $
             filename: '' 
           }
end