; docformat = 'rst'

;+
; Parse rst style comments into a parse tree.
; 
; The markup parser recognizes:
;   #. paragraphs separated by a blank line
;   #. (not implemented) lists (numbered, bulleted, and definition)
;   #. (not implemented) *emphasis* and **bold**
;   #. (not implemented) code can be marked as `a = findgen(10)`
;   #. (not implemented) links: single word and phrase links
;   #. images
;   #. code callouts like::
;  
;        pro test, a
;          compile_opt strictarr
;         
;        end
; 
; :Todo: finish implementation specified above
;-


;+
; Process directives.
;-
pro docparrstmarkupparser::_processDirective, line, pos, len, tree=tree
  compile_opt strictarr
  
  fullDirective = strmid(line, pos + 3L, len)
  tokens = strsplit(fullDirective, '::[[:space:]]+', /regex, /extract)
  
  case strlowcase(tokens[0]) of
    'image': begin
        tag = obj_new('MGtmTag', type='image')
        tag->addAttribute, 'source', tokens[1]
      end
    else: self.system->warning, 'unknown rst directive ' + tokens[0]
  endcase

  beforeDirective = strmid(line, 0, pos)
  afterDirective = strmid(line, pos + len)
  tree->addChild, obj_new('MGtmText', text=beforeDirective)
  tree->addChild, tag
  tree->addChild, obj_new('MGtmText', text=afterDirective)
  tree->addChild, obj_new('MGtmTag', type='newline')
end

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
  
  indent = 0L
  code = 0B
  nextIsCode = 0B
  
  tree = obj_new('MGtmTag')
  
  para = obj_new('MGtmTag', type='paragraph')
  tree->addChild, para
  
  for l = 0L, n_elements(lines) - 1L do begin
    cleanline = strtrim(lines[l], 0)
    dummy = stregex(lines[l], ' *[^[:space:]]', length=currentIndent)
    
    if (cleanLine eq '' && ~code) then begin
      para = obj_new('MGtmTag', type='paragraph')
      tree->addChild, para      
    endif
    
    nextIsCode = strmid(cleanline, 1, /reverse_offset) eq '::'
    
    if (nextIsCode) then cleanline = strmid(cleanline, 0, strlen(cleanline) - 1)
    
    directivePos = stregex(cleanline, '\.\. [[:alpha:]]+:: [[:alnum:]_/.\-]+', $
                           length=directiveLen)
    
    if ((~code || (currentIndent gt -1 && currentIndent le indent)) && directivePos ne -1L) then begin
      self->_processDirective, cleanline, directivePos, directiveLen, tree=para
      code = 0B
    endif else begin
      if (code && (currentIndent eq -1 || currentIndent gt indent)) then begin
        listing->addChild, obj_new('MGtmText', text=strmid(cleanline, indent))
        listing->addChild, obj_new('MGtmTag', type='newline')
      endif else begin     
        para->addChild, obj_new('MGtmText', text=cleanline)
        para->addChild, obj_new('MGtmTag', type='newline')
        code = 0B
      endelse
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