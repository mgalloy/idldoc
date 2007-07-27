; docformat = 'rst'

;+
; Verbatim parsing just makes everything text and inserts the end-of-line 
; nodes.
;-


;+
; Takes a string array of free text comments and return a parse tree.
;
; :Returns: object
; :Abstract:
; :Params:
;    `lines` : in, required, type=strarr
;       lines to be parsed
;-
function docparverbatimmarkupparser::parse, lines
  compile_opt strictarr
  
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
pro docparverbatimmarkupparser__define
  compile_opt strictarr
  
  define = { DOCparVerbatimMarkupParser, inherits DOCparMarkupParser }
end