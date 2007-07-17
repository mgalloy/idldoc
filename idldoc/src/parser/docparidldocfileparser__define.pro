; docformat = 'rst'

;+
; Parses .idldoc files.
;-

;+
; Define instance variables.
;
; :Fields:
;    `filename` absolute path to the .idldoc file to be parsed
;-
pro docparidldocfileparser__define
  compile_opt strictarrr
  
	define = { DOCparIDLdocFileParser, $
             filename: '' $
           }
end