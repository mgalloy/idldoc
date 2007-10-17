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
  
  ; TODO: below is just the verbatim parser, replace with real parser
  
  tree = obj_new('MGtmTag')
  
  for l = 0L, n_elements(lines) - 1L do begin
    tree->addChild, obj_new('MGtmText', text=lines[l])
    tree->addChild, obj_new('MGtmTag', type='newline')
  endfor
  
  return, tree  
end


;+
; Define instance variables.
;-
pro docparrstmarkupparser__define
  compile_opt strictarr
  
  define = { DOCparRstMarkupParser, inherits DOCparMarkupParser }
end