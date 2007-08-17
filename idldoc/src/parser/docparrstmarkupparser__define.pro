; docformat = 'rst'

;+
; Parse rst style comments into a parse tree.
; 
; The markup parser recognizes:
;   #. paragraphs separated by a blank line
;   #. lists (numbered, bulleted, and definition)
;   #. *emphasis* and **bold**
;   #. links: single word and phrase links
;   #. code callouts like::
;  
;        pro test, a
;          compile_opt strictarr
;         
;        end 
;-


;+
; Takes a string array of rst style comments and return a parse tree.
;
; :Returns: 
;    object
;
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