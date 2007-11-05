; docformat = 'rst'

;+
; Handles parsing of the standard IDL comment template style comment blocks.
;-


;+
; Handles one tag in a routine's comments.
; 
; :Params:
;    tag : in, required, type=string
;       rst tag, i.e. returns, params, keywords, etc.
;    lines : in, required, type=strarr
;       lines of raw text for that tag
;
; :Keywords:
;    routine : in, required, type=object
;       routine tree object 
;    markup_parser : in, required, type=object
;       markup parser object
;-
pro docparidlformatparser::_handleRoutineTag, tag, lines, $
                                              routine=routine,  $
                                              markup_parser=markupParser
  compile_opt strictarr
  
  case strlowcase(tag) of
    'name':   ; ignore, not used
    'purpose': routine->setProperty, comments=markupParser->parse(lines)
    'category': begin
        categories = strtrim(strsplit(strjoin(lines), '[,.]', /extract, /regex), 2)
        for i = 0L, n_elements(categories) - 1L do begin
          if (categories[i] ne '') then begin
            routine->addCategory, categories[i]
            self.system->createCategoryEntry, categories[i], routine
          endif
        endfor   
      end
    'calling sequence':   ; ignore, not used
    ; TODO: finish implementing
    'inputs':
    ; TODO: finish implementing
    'optional inputs':
    ; TODO: finish implementing
    'keyword parameters':
    ; TODO: finish implementing
    'output':
    ; TODO: finish implementing
    'optional outputs':
    ; TODO: finish implementing
    'common blocks':
    'side effects': routine->setProperty, comments=markupParser->parse(lines)
    'restrictions': routine->setProperty, comments=markupParser->parse(lines)
    'procedure': routine->setProperty, comments=markupParser->parse(lines)
    'example': begin        
        verbatimParser = self.system->getParser('verbatimmarkup')
                
        dummy = stregex(lines, '^[[:space:]]*[^[:space:]]', length=lengths)
        lengths--   ; remove non-space character
        ind = where(lengths gt 0, nActualLines)
        indent = min(lengths[ind])
        
        exLines = strmid(lines, indent)
        
        ; remove trailing blank lines
        l = n_elements(exLines) - 1L
        while (l gt 0 && strtrim(exLines[l], 2) eq '') do begin
          exLines = exLines[0L:l-1L]
          l--
        endwhile
        
        examples = verbatimParser->parse(exLines, top='listing')
        routine->setProperty, examples=examples
      end
    'modification history': begin
        ; TODO: handle author and history tags here
      end
  endcase
end


;+
; Handles parsing of a comment block using IDL syntax. 
;
; :Params:
;    lines : in, required, type=strarr
;       all lines of the comment block

; :Keywords:
;    routine : in, required, type=object
;       routine tree object 
;    markup_parser : in, required, type=object
;       markup parser object
;-
pro docparidlformatparser::parseRoutineComments, lines, routine=routine, $
                                                 markup_parser=markupParser
  compile_opt strictarr
  
  if (n_elements(lines) eq 0) then return
  
  ; look for section names
  sectionNames = ['name', 'purpose', 'category', 'calling sequence', $
                  'inputs', 'optional inputs', 'keyword parameters', $
                  'output', 'optional outputs', 'common blocks', $
                  'side effects', 'restrictions', 'procedure', 'example', $
                  'modification history'] + ':'
  
  tagLocations = bytarr(n_elements(lines))   
  for s = 0L, n_elements(sectionNames) - 1L do begin
    tagLocations or= strlowcase(strtrim(lines, 2)) eq sectionNames[s]
  endfor  
  
  tagStarts = where(tagLocations, nTags)
  if (nTags eq 0) then return
  tagEnds = [tagStarts[1:*] - 1L, n_elements(lines) - 1L]
  for t = 0L, nTags - 1L do begin
    tag = strtrim(lines[tagStarts[t]], 2)
    tag = strmid(tag, 0, strlen(tag) - 1L)
    self->_handleRoutineTag, tag, lines[tagStarts[t] + 1L:tagEnds[t]], $
                             routine=routine, markup_parser=markupParser    
  endfor  
end


pro docparidlformatparser::parseFileComments, lines, file=file, $
                                              markup_parser=markupParser
  compile_opt strictarr
  
  ; TODO: implement this
end


;+
; Handles parsing of a comment block in the overview file using IDLdoc syntax. 
;
; :Params:
;    lines : in, required, type=strarr
;       all lines of the comment block
;
; :Keywords:
;    system : in, required, type=object
;       system object 
;    markup_parser : in, required, type=object
;       markup parser object
;-
pro docparidlformatparser::parseOverviewComments, lines, system=system, $
                                                     markup_parser=markupParser
  compile_opt strictarr

  ; TODO: implement this
end


;+
; Define instance variables.
;-
pro docparidlformatparser__define
  compile_opt strictarr

  define = { DOCparIDLFormatParser, inherits DOCparFormatParser }
end