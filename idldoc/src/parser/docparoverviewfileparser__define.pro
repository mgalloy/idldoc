; docformat = 'rst'

;+
; This parser handles overview files. The format for an overview file is a 
; section of free comments followed by an optional list of of `dir` tags.
;-

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