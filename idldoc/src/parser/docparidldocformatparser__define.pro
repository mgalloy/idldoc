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
 
  re = '^[[:space:]]*{([^}]*)}.*'
  
  starts = 0
  while (starts[0] ge 0) do begin
    starts = stregex(headerLine, re, /subexpr, length=lengths)
    attribute = strmid(headerLine, starts[1], lengths[1])
    if (starts[0] ge 0) then begin
      equalPos = strpos(attribute, '=')
      if (equalPos eq -1L) then begin   ; boolean attributes
        case strlowcase(attribute) of
          'in': arg->setProperty, is_input=1
          'out': arg->setProperty, is_output=1
          'optional': arg->setProperty, is_optional=1
          'required': arg->setProperty, is_required=1
          'private': arg->setProperty, is_private=1
          'hidden': arg->setProperty, is_hidden=1
          'obsolete': arg->setProperty, is_obsolete=1
          else: begin
              self.system->warning, $
                'unknown argument attribute ' + attributeName + ' for argument ' $
                  + argname + ' in ' + routineName 
            end
        endcase
      endif else begin   ; attributes with name-value
        attributeName = strmid(attribute, 0, equalPos)
        attributeValue = strmid(attribute, equalPos + 1L)
        case strlowcase(attributeName) of
          'type': arg->setProperty, type=attributeValue
          'default': arg->setProperty, default_value=attributeValue
          else: begin
              self.system->warning, $
                'unknown argument attribute ' + attributeName + ' for argument' $
                  + argname + ' in ' + routineName           
            end
        endcase
      endelse
      
      headerLine = strmid(headerLine, starts[1] + lengths[1] + 1L)
    endif
  endwhile
   
  ; put back what's left of headerLine
  lines[0] = headerLine
  
  comments = markupParser->parse(lines)
  arg->setProperty, comments=comments
end


;+
; Removes tag from first line.
;
; :Returns: strarr
; :Params:
;    `lines` : in, required, type=strarr
;-
function docparidldocformatparser::_removeTag, lines
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
  
  ; TODO: finish this
  
  case strlowcase(tag) of
    'abstract': routine->setProperty, is_abstract=1
    'author': routine->setProperty, author=markupParser->parse(self->_removeTag(lines))
    'bugs': routine->setProperty, bugs=markupParser->parse(self->_removeTag(lines))      
    'categories':
    'copyright': routine->setProperty, copyright=markupParser->parse(self->_removeTag(lines))
    'customer_id':
    'examples': routine->setProperty, examples=markupParser->parse(self->_removeTag(lines))
    'field':
    'file_comments': begin
        routine->getProperty, file=file
        file->setProperty, comments=markupParser->parse(self->_removeTag(lines))
      end
    'hidden': routine->setProperty, is_hidden=1
    'hidden_file':
    'history': routine->setProperty, history=markupParser->parse(self->_removeTag(lines))
    'inherits':
    'keyword': self->_handleArgumentTag, tag, lines, routine=routine, markup_parser=markupParser
    'obsolete':
    'param': self->_handleArgumentTag, tag, lines, routine=routine, markup_parser=markupParser
    'post': routine->setProperty, post=markupParser->parse(self->_removeTag(lines))
    'pre': routine->setProperty, pre=markupParser->parse(self->_removeTag(lines))
    'private': routine->setProperty, is_private=1
    'private_file':
    'requires':
    'restrictions':
    'returns': routine->setProperty, returns=markupParser->parse(self->_removeTag(lines))
    'todo':
    'uses':
    'version':
    else: begin
        routine->getProperty, name=name
        self.system->warning, 'unknown tag ' + tag + ' in routine ' + name
      end
  endcase
end


pro docparidldocformatparser::_handleFileTag, tag, lines, $
                                              file=file, $
                                              markup_parser=markupParser
  compile_opt strictarr
  
  ; TODO: finish this
  
  case strlowcase(tag) of
    'property':
    
    'hidden': file->setProperty, is_hidden=1B
    'private': file->setProperty, is_private=1B
    
    'examples': file->setProperty, examples=markupParser->parse(self->_removeTag(lines))
    
    'author': file->setProperty, author=markupParser->parse(self->_removeTag(lines))
    'copyright': file->setProperty, copyright=markupParser->parse(self->_removeTag(lines))
    'history': file->setProperty, history=markupParser->parse(self->_removeTag(lines))
    else:
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
  
  ; find @ symbols that are the first non-whitespace character on the line
  tagLocations = where(stregex(lines, '^[[:space:]]*@') ne -1, nTags)
  
  ; parse normal comments
  tagsStart = nTags gt 0 ? tagLocations[0] : n_elements(lines)
  if (tagsStart ne 0) then begin
    comments = markupParser->parse(lines[0:tagsStart - 1L])
    file->setProperty, comments=comments
  endif

  ; go through each tag
  for t = 0L, nTags - 1L do begin
    tagStart = tagLocations[t]
    tag = strmid(stregex(lines[tagStart], '@[[:alpha:]_]+', /extract), 1)
    tagEnd = t eq nTags - 1L $
               ? n_elements(lines) - 1L $
               : tagLocations[t + 1L] - 1L
    self->_handleFileTag, tag, lines[tagStart:tagEnd], $
                          file=file, markup_parser=markupParser
  endfor
end


pro docparidldocformatparser::parseOverviewComments, lines, system=system, $
                                                     markup_parser=markupParser
  compile_opt strictarr

  ; find @ symbols that are the first non-whitespace character on the line
  tagLocations = where(stregex(lines, '^[[:space:]]*@') ne -1, nTags)
  
  ; parse normal comments
  tagsStart = nTags gt 0 ? tagLocations[0] : n_elements(lines)
  if (tagsStart ne 0) then begin
    comments = markupParser->parse(lines[0:tagsStart - 1L])
    system->setProperty, overview_comments=comments
  endif

  ; go through each tag
  for t = 0L, nTags - 1L do begin
    tagStart = tagLocations[t]
    tag = strmid(stregex(lines[tagStart], '@[[:alpha:]_]+', /extract), 1)
    tagEnd = t eq nTags - 1L $
               ? n_elements(lines) - 1L $
               : tagLocations[t + 1L] - 1L
    tagLines = self->_removeTag(lines[tagStart:tagEnd])
    
    case strlowcase(tag) of
      'dir': begin
          re = '^[[:space:]]*([[:alpha:]._$\-\/]+)[[:space:]]+'
          argStart = stregex(tagLines[0], re, /subexpr, length=argLength)
          if (argStart[0] eq -1L) then begin
            system->getProperty, overview=overview
            system->warning, 'directory argument not present for dir tag in overview file ' + overview
            break            
          endif
          
          dirName = strmid(tagLines[0], argStart[1], argLength[1])
          tagLines[0] = strmid(tagLines[0], argStart[1] + argLength[1])
          
          system->getProperty, directories=directories
          for d = 0L, directories->count() - 1L do begin
            dir = directories->get(position=d)
            dir->getProperty, location=location
            if (dirName eq location) then begin
              tree = markupParser->parse(tagLines)
              dir->setProperty, overview_comments=tree
              break
            endif
          endfor
        end
      else: begin
          system->getProperty, overview=overview
          system->warning, 'unknown tag ' + tag + ' in overview file ' + overview
        end
    endcase
  endfor
end


;+
; Define instance variables.
;-
pro docparidldocformatparser__define
  compile_opt strictarr

  define = { DOCparIDLdocFormatParser, inherits DOCparFormatParser }
end