; docformat = 'rst'

;+
; Parses .idldoc files.
;-

;+
; Parse the given .idldoc file.
; 
; :Returns: file tree object
; :Params:
;    `filename` : in, required, type=string
;       absolute path to .pro file to be parsed
; :Keywords:
;    `found` : out, optional, type=boolean
;       returns 1 if filename found, 0 otherwise
;-
function docparidldocfileparser::parse, filename, found=found
  compile_opt strictarr

  ; TODO: implement this, how do we know what the markup will be?
end


;+
; Define instance variables.
;
; :Fields:
;    `filename` absolute path to the .idldoc file to be parsed
;-
pro docparidldocfileparser__define
  compile_opt strictarr
  
	define = { DOCparIDLdocFileParser, $
             filename: '' $
           }
end