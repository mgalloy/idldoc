; docformat = 'rst'

;+ 
; Parser for .pro files: files containing routines, main-level programs, and 
; batch files.
;-

;+
; Define instance variables.
;
; :Fields:
;    `filename` absolute path to .pro file to be parsed
;-
pro docparprofileparser__define
  compile_opt strictarr
  
  define = { DOCparProFileParser, $
             filename: '' $
           }
end