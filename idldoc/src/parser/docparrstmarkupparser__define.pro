; docformat = 'rst'

;+
; Parse rst style comments into a parse tree.
;-


;+
; Takes a string array of rst style comments and return a parse tree.
;
; :Returns: object
; :Abstract:
; :Params:
;    `lines` : in, required, type=strarr
;       lines to be parsed
;-
function docparrstmarkupparser::parse, lines
  compile_opt strictarr
  
  ; TODO: implement this
end


;+
; Define instance variables.
;-
pro docparrstmarkupparser__define
  compile_opt strictarr
  
  define = { DOCparRstMarkupParser, inherits DOCparMarkupParser }
end