; docformat = 'rst'

;+
; Handles parsing of IDLdoc syntax comment blocks.
;-


pro docparidldocformatparser::_handleArgumentTag, tag, lines, $
                                                  routine=routine, $
                                                  markup_parser=markupParser
  compile_opt strictarr
  
  routine->getProperty, name=routineName
  
  headerLine = lines[0]
  re = '^[[:space:]]*@[[:alpha:]_]+[[:space:]]+([[:alnum:]_$]+)'
  starts = stregex(headerLine, re, /subexpr, length=lengths)
  tokens = strmid(headerLine, starts, lengths)
  
  if (tokens[0] eq '') then begin
    self.system->warning, 'invalid syntax: ' + lines[0]
    return
  endif
  
  argname = tokens[1]
  
  case strlowcase(tag) of
    'param': arg = routine->getParameter(argname, found=found)
    'keyword': arg = routine->getKeyword(argname, found=found)
    else:   ; shouldn't happen
  endcase
  
  if (~found) then begin
    self.system->warning, strlowcase(tag) + ' ' + argname + ' not found in ' + routineName
    return
  endif

  attrStart = starts[1] + lengths[1]
  
  headerLine = strmid(headerLine, attrStart)
 
  re = '^[[:space:]]*({[^}]*}).*'
  
  starts = 0
  while (starts[0] ge 0) do begin
    starts = stregex(headerLine, re, /subexpr, length=lengths)
    headerLine = strmid(headerLine, starts[1] + lengths[1])
  endwhile
   
  ; put back what's left of headerLine
  lines[0] = headerLine
  
  comments = markupParser->parse(lines)
  arg->setProperty, comments=comments
end


function docparidldocformatparser::_removeTag, tag, lines
  compile_opt strictarr
  
  re = '^[[:space:]]*@[[:alpha:]_]+[[:space:]]+'
  start = stregex(lines[0], re, length=length)
  lines[0] = strmid(lines[0], start + length)
  return, lines
end


;+
; Handles one tag.
; 
; :Params:
;    `tag` : in, required, type=string
;       rst tag, i.e. returns, params, keywords, etc.
;    `lines` : in, required, type=strarr
;       lines of raw text for that tag
; :Keywords:
;    `routine` : in, required, type=object
;       routine tree object 
;    `markup_parser` : in, required, type=object
;       markup parser object
;-
pro docparidldocformatparser::_handleRoutineTag, tag, lines, $
                                                 routine=routine,  $
                                                 markup_parser=markupParser
  compile_opt strictarr
  
  ; TODO: implement this
  
  ; here are all the tags
  case strlowcase(tag) of
    'abstract': routine->setProperty, is_abstract=1
    'author':
    'bugs':
    'categories':
    'copyright':
    'customer_id':
    'examples':
    'field':
    'file_comments':
    'hidden': routine->setProperty, is_hidden=1
    'hidden_file':
    'history':
    'inherits':
    'keyword': self->_handleArgumentTag, tag, lines, routine=routine, markup_parser=markupParser
    'obsolete':
    'param': self->_handleArgumentTag, tag, lines, routine=routine, markup_parser=markupParser
    'post':
    'pre':
    'private': routine->setProperty, is_private=1
    'private_file':
    'requires':
    'restrictions':
    'returns': routine->setProperty, returns=markupParser->parse(self->_removeTag(tag, lines))
    'todo':
    'uses':
    'version':
    else: begin
        routine->getProperty, name=name
        self.system->warning, 'unknown tag ' + tag + ' in routine ' + name
      end
  endcase
end


;+
; Handles parsing of a comment block using IDLdoc syntax. 
;
; :Params:
;    `lines` : in, required, type=strarr
;       all lines of the comment block
; :Keywords:
;    `routine` : in, required, type=object
;       routine tree object 
;    `markup_parser` : in, required, type=object
;       markup parser object
;-
pro docparidldocformatparser::parseRoutineComments, lines, routine=routine, $
                                                    markup_parser=markupParser
  compile_opt strictarr

  ; find @ symbols that are the first non-whitespace character on the line
  tagLocations = where(stregex(lines, '^[[:space:]]*@') ne -1, nTags)
  
  ; parse normal comments
  tagsStart = nTags gt 0 ? tagLocations[0] : n_elements(lines)
  if (tagsStart ne 0) then begin
    comments = markupParser->parse(lines[0:tagsStart - 1L])
    routine->setProperty, comments=comments
  endif

  ; go through each tag
  for t = 0L, nTags - 1L do begin
    tagStart = tagLocations[t]
    tag = strmid(stregex(lines[tagStart], '@[[:alpha:]_]+', /extract), 1)
    tagEnd = t eq nTags - 1L $
               ? n_elements(lines) - 1L $
               : tagLocations[t + 1L] - 1L
    self->_handleRoutineTag, tag, lines[tagStart:tagEnd], $
                             routine=routine, markup_parser=markupParser
  endfor
end


pro docparidldocformatparser::parseFileComments, lines, file=file, $
                                                 markup_parser=markupParser                          
  compile_opt strictarr
  
  ; TODO: implement this
  
  ; look for @'s (but not escaped with \'s)
  ; get free text comment for routine
  ; go through each tag
  
  ; tags: properties
end


;+
; Define instance variables.
;-
pro docparidldocformatparser__define
  compile_opt strictarr

  define = { DOCparIDLdocFormatParser, inherits DOCparFormatParser }
end