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
;    lines : in, required, type=strarr
;       lines to be parsed
;-
function docparrstmarkupparser::parse, lines
  compile_opt strictarr
  
  ; TODO: finish the implementation
  
  indent = 0L
  code = 0B
  nextIsCode = 0B
  
  tree = obj_new('MGtmTag')
  
  para = obj_new('MGtmTag', type='paragraph')
  tree->addChild, para
  
  for l = 0L, n_elements(lines) - 1L do begin
    cleanLine = strtrim(lines[l], 0)
    dummy = stregex(lines[l], ' *[^[:space:]]', length=currentIndent)
    
    if (cleanLine eq '' && ~code) then begin
      para = obj_new('MGtmTag', type='paragraph')
      tree->addChild, para      
    endif
    
    nextIsCode = strmid(cleanLine, 1, /reverse_offset) eq '::'
    
    if (nextIsCode) then cleanline = strmid(cleanline, 0, strlen(cleanline) - 1)
    
    if (code && (currentIndent eq -1 || currentIndent gt indent)) then begin
      listing->addChild, obj_new('MGtmText', text=strmid(cleanline, indent))
      listing->addChild, obj_new('MGtmTag', type='newline')
    endif else begin     
      para->addChild, obj_new('MGtmText', text=cleanline)
      para->addChild, obj_new('MGtmTag', type='newline')
      code = 0B
    endelse
    
    if (nextIsCode) then begin
      code = 1B
      indent = currentIndent
      
      listing = obj_new('MGtmTag', type='listing')
      para->addChild, listing
    endif
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