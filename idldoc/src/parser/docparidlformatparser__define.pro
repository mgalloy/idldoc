; docformat = 'rst'

;+
; Handles parsing of the standard IDL comment template style comment blocks.
;-



pro docparidlformatparser::_handleArguments, lines, routine=routine, $
                                             markup_parser=markupParser, $
                                             keyword=keyword, $
                                             optional=optional, $
                                             input=input, $
                                             tag=tag
  compile_opt strictarr
  
  argLines = lines
    
  ; find lines specifying argument names
  argPos = stregex(argLines, '^[[:space:]]*([[:alnum:]_$]+):', $
                   /subexpr, length=argLen)
  
  ; only interested in subexpression
  argPos = argPos[1, *]
  argLen = argLen[1, *]
  args = where(argPos ne -1L, nArgs)
  if (nArgs lt 1) then return
  
  argEnds = nArgs eq 1 ? n_elements(argPos) - 1L : [args[1:*] - 1L, n_elements(argPos) - 1L]
  
  for a = 0L, nArgs - 1L do begin
    argumentName = strmid(argLines[args[a]], argPos[args[a]], argLen[args[a]])
    arg = keyword_set(keyword) $
            ? routine->getKeyword(argumentName, found=found) $
            : routine->getParameter(argumentName, found=found) 

    routine->getProperty, name=routineName
    if (~found) then begin
      self.system->warning, tag + ' ' + argumentName $
                              + ' not found in ' + routineName
      continue
    endif
    
    ; set attributes of the argument
    arg->setProperty, is_optional=keyword_set(optional), $
                      is_required=~keyword_set(optional)
    if (keyword_set(input)) then arg->setProperty, is_input=1B
    
    ; set comments for the argument
    comments = lines[args[a]:argEnds[a]]
    comments[0] = strmid(comments[0], argPos[args[a]] + argLen[args[a]] + 2L)
    arg->setProperty, comments=markupParser->parse(comments)
  endfor
end


;+
; Handles one tag in a file's comments.
; 
; :Params:
;    tag : in, required, type=string
;       rst tag, i.e. returns, params, keywords, etc.
;    lines : in, required, type=strarr
;       lines of raw text for that tag
;
; :Keywords:
;    file : in, required, type=object
;       routine file object 
;    markup_parser : in, required, type=object
;       markup parser object
;-
pro docparidlformatparser::_handleFileTag, tag, lines, $
                                              file=file,  $
                                              markup_parser=markupParser
  compile_opt strictarr
  
  ; TODO: get correct routine and add comments to it
  case strlowcase(tag) of
    ; TODO: might use this to find correct routine
    'name':
    'purpose': routine->setProperty, comments=markupParser->parse(lines)
    'category': 
    'calling sequence':   ; ignore, not used    
    'inputs': 
    'optional inputs': 
    'keyword parameters': 
    'outputs':       
    'optional outputs': 
    'common blocks':
    'side effects': file->setProperty, comments=markupParser->parse(lines)
    'restrictions': file->setProperty, comments=markupParser->parse(lines)
    'procedure': file->setProperty, comments=markupParser->parse(lines)
    'example': begin        
        verbatimParser = self.system->getParser('verbatimmarkup')
                
        dummy = stregex(lines, '^[[:space:]]*[^[:space:]]', length=lengths)
        lengths--   ; remove non-space character
        ind = where(lengths gt 0, nActualLines)
        if (nActualLines eq 0) then return
        indent = min(lengths[ind])
        
        exLines = strmid(lines, indent)
        
        ; remove trailing blank lines
        l = n_elements(exLines) - 1L
        while (l gt 0 && strtrim(exLines[l], 2) eq '') do begin
          exLines = exLines[0L:l-1L]
          l--
        endwhile
        
        examples = verbatimParser->parse(exLines, top='listing')
        file->setProperty, examples=examples
      end
    'modification history': begin
        ; TODO: pull out author information
        file->setProperty, history=markupParser->parse(lines)
      end
    else: begin
        file->getProperty, basename=basename
        self.system->warning, 'unknown tag "' + tag + '" in file ' + basename
      end
  endcase
end


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
    'inputs': self->_handleArguments, lines, routine=routine, markup_parser=markupParser, /input, tag='input'
    'optional inputs': self->_handleArguments, lines, routine=routine, markup_parser=markupParser, /input, /optional, tag='optional input'
    'keyword parameters': self->_handleArguments, lines, routine=routine, markup_parser=markupParser, /input, /keyword, /optional, tag='keyword' 
    'outputs': routine->setProperty, returns=markupParser->parse(lines)      
    'optional outputs': self->_handleArguments, lines, routine=routine, markup_parser=markupParser, tag='optional output'
    'common blocks': routine->setProperty, comments=markupParser->parse(lines)
    'side effects': routine->setProperty, comments=markupParser->parse(lines)
    'restrictions': routine->setProperty, comments=markupParser->parse(lines)
    'procedure': routine->setProperty, comments=markupParser->parse(lines)
    'example': begin        
        verbatimParser = self.system->getParser('verbatimmarkup')
                
        dummy = stregex(lines, '^[[:space:]]*[^[:space:]]', length=lengths)
        lengths--   ; remove non-space character
        ind = where(lengths gt 0, nActualLines)
        if (nActualLines eq 0) then return
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
        ; TODO: pull out author information
        routine->setProperty, history=markupParser->parse(lines)
      end
    else: begin
        routine->getProperty, name=name
        self.system->warning, 'unknown tag "' + tag + '" in routine ' + name
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
                  'outputs', 'optional outputs', 'common blocks', $
                  'side effects', 'restrictions', 'procedure', 'example', $
                  'modification history'] + ':'
  
  tagLocations = bytarr(n_elements(lines))   
  for s = 0L, n_elements(sectionNames) - 1L do begin
    tagLocations or= strlowcase(strtrim(lines, 2)) eq sectionNames[s]
  endfor  
  
  tagStarts = where(tagLocations, nTags)
  if (nTags eq 0) then return
  tagEnds = nTags eq 1 ? n_elements(lines) - 1L : [tagStarts[1:*] - 1L, n_elements(lines) - 1L]
  for t = 0L, nTags - 1L do begin
    tag = strtrim(lines[tagStarts[t]], 2)
    tag = strmid(tag, 0, strlen(tag) - 1L)
    
    if (tagStarts[t] + 1L lt tagEnds[t]) then begin
      self->_handleRoutineTag, tag, lines[tagStarts[t] + 1L:tagEnds[t]], $
                               routine=routine, markup_parser=markupParser
    endif  
  endfor  
end


;+
; Handles parsing of a comment block associated with a file. 
;
; :Params:
;    lines : in, required, type=strarr
;       all lines of the comment block
;
; :Keywords:
;    file : in, required, type=object
;       file tree object 
;    markup_parser : in, required, type=object
;       markup parser object
;-
pro docparidlformatparser::parseFileComments, lines, file=file, $
                                              markup_parser=markupParser
  compile_opt strictarr
  
  if (n_elements(lines) eq 0) then return
  
  ; look for section names
  sectionNames = ['name', 'purpose', 'category', 'calling sequence', $
                  'inputs', 'optional inputs', 'keyword parameters', $
                  'outputs', 'optional outputs', 'common blocks', $
                  'side effects', 'restrictions', 'procedure', 'example', $
                  'modification history'] + ':'
  
  tagLocations = bytarr(n_elements(lines))   
  for s = 0L, n_elements(sectionNames) - 1L do begin
    tagLocations or= strlowcase(strtrim(lines, 2)) eq sectionNames[s]
  endfor  
  
  tagStarts = where(tagLocations, nTags)
  if (nTags eq 0) then return
  tagEnds = nTags eq 1 ? n_elements(lines) - 1L : [tagStarts[1:*] - 1L, n_elements(lines) - 1L]
  for t = 0L, nTags - 1L do begin
    tag = strtrim(lines[tagStarts[t]], 2)
    tag = strmid(tag, 0, strlen(tag) - 1L)
    
    if (tagStarts[t] + 1L lt tagEnds[t]) then begin
      self->_handleFileTag, tag, lines[tagStarts[t] + 1L:tagEnds[t]], $
                            file=file, markup_parser=markupParser
    endif  
  endfor 
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