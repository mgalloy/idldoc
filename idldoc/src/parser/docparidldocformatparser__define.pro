; docformat = 'rst'

;+
; Handles parsing of IDLdoc syntax comment blocks.
;-


;+
; Removes leading blank lines from string arrays.
;
; :Params:
;    lines : in, out, required, type=strarr
;       line from which to remove leading blank lines
;-
pro docparidldocformatparser::_removeSpace, lines
  compile_opt strictarr

  ; line is all space
  re = '^[[:space:]]*$'
  
  ; stop at first line that is not all space
  i = 0
  while (i lt n_elements(lines) && stregex(lines[i], re, /boolean) eq 1) do i++
  
  ; return empty string if no lines left
  lines = i lt n_elements(lines) ? lines[i:*] : ''
end


;+
; Parse the lines from a tag.
; 
; :Params:
;    `lines` : in, out, required, type=strarr
;
; :Keywords: 
;    has_argument : in, optional, type=boolean
;    tag : out, optional, type=string
;    argument : out, optional, type=string
;    n_attributes : out, optional, type=long
;    attributes_names : out, optional, type=strarr
;    attributes_values : out, optional, type=strarr
;-
function docparidldocformatparser::_parseTag, lines, $
                                              has_argument=hasArgument, $
                                              tag=tag, argument=argument, $
                                              n_attributes=nAttributes, $
                                              attribute_names=attributeNames, $
                                              attribute_values=attributeValues
  compile_opt strictarr
  
  myLines = lines
  
  ; find tag
  re = '^[[:space:]]*@([[:alpha:]_]+)'
  tagStart = stregex(myLines[0], re, length=tagLength, /subexpr)
  if (tagStart[0] lt 0) then begin
    self.system->warning, 'invalid syntax: ' + myLines[0]
    return, ''
  endif
  tag = strmid(myLines[0], tagStart[1], tagLength[1])
  myLines[0] = strmid(myLines[0], tagStart[1] + tagLength[1])
  
  if (~keyword_set(hasArgument)) then return, myLines
  
  ; find argument
  
  self->_removeSpace, myLines
  
  re = '^[[:space:]]*([[:alnum:]_$]+)'
  argStart = stregex(myLines[0], re, length=argLength, /subexpr)
  ; if argStart[0] eq -1 then ERROR
  argument = strmid(myLines[0], argStart[1], argLength[1])
  myLines[0] = strmid(myLines[0], argStart[1] + argLength[1])
  
  ; find attributes

  attributeNamesList = obj_new('MGcoArrayList', type=7)
  attributeValuesList = obj_new('MGcoArrayList', type=7)
  
  re = '^[[:space:]]*{([^}]*)}.*'
  starts = 0
  while (starts[0] ge 0) do begin
    self->_removeSpace, myLines
    starts = stregex(myLines[0], re, /subexpr, length=lengths)
    attribute = strmid(myLines[0], starts[1], lengths[1])
    myLines[0] = strmid(myLines[0], starts[1] + lengths[1] + 1L)
    if (starts[0] ge 0) then begin
      equalPos = strpos(attribute, '=')
      if (equalPos ge 0) then begin
        attributeNamesList->add, strmid(attribute, 0L, equalPos)
        attributeValuesList->add, strmid(attribute, equalPos + 1L)
      endif else begin
        attributeNamesList->add, attribute
        attributeValuesList->add, ''
      endelse
    endif
  endwhile
  
  ; return attribute information
  nAttributes = attributeNamesList->count()
  if (nAttributes gt 0) then begin
    attributeNames = attributeNamesList->get(/all)
    attributeValues = attributeValuesList->get(/all)    
  endif
  
  obj_destroy, [attributeNamesList, attributeValuesList]
  
  return, myLines
end


;+
; Handles a tag with attributes (i.e. {} enclosed arguments like in param or 
; keyword).
; 
; :Params:
;    `lines` : in, required, type=strarr
;       lines of raw text for that tag
;
; :Keywords:
;    `routine` : in, required, type=object
;       routine tree object 
;    `markup_parser` : in, required, type=object
;       markup parser object
;-
pro docparidldocformatparser::_handleArgumentTag, lines, $
                                                  routine=routine, $
                                                  markup_parser=markupParser
  compile_opt strictarr
  
  lines = self->_parseTag(lines, /has_argument, $
                          tag=tag, argument=argument, $
                          n_attributes=nAttributes, $
                          attribute_names=attributeNames, $
                          attribute_values=attributeValues) 
  
  case strlowcase(tag) of
    'param': arg = routine->getParameter(argument, found=found)
    'keyword': arg = routine->getKeyword(argument, found=found)
    else:   ; shouldn't happen
  endcase
  
  routine->getProperty, name=routineName
  if (~found) then begin
    self.system->warning, strlowcase(tag) + ' ' + argument $
                            + ' not found in ' + routineName
    return
  endif

  for i = 0L, nAttributes - 1L do begin
    case strlowcase(attributeNames[i]) of
      'in': arg->setProperty, is_input=1
      'out': arg->setProperty, is_output=1
      'optional': arg->setProperty, is_optional=1
      'required': arg->setProperty, is_required=1
      'private': arg->setProperty, is_private=1
      'hidden': arg->setProperty, is_hidden=1
      'obsolete': arg->setProperty, is_obsolete=1

      'type': arg->setProperty, type=attributeValues[i]
      'default': arg->setProperty, default_value=attributeValues[i]
      else: begin
          self.system->warning, $
            'unknown argument attribute ' + attributeNames[i] $
              + ' for argument' + argument + ' in ' + routineName           
        end
    endcase
  endfor
  
  comments = markupParser->parse(lines)
  arg->setProperty, comments=comments
end


;+
; Handles one tag.
; 
; :Params:
;    `tag` : in, required, type=string
;       rst tag, i.e. returns, params, keywords, etc.
;    `lines` : in, required, type=strarr
;       lines of raw text for that tag
;
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
  
  case strlowcase(tag) of
    'abstract': routine->setProperty, is_abstract=1B
    'author': routine->setProperty, author=markupParser->parse(self->_parseTag(lines))
    'bugs': routine->setProperty, bugs=markupParser->parse(self->parseTag(lines))      
    'categories': begin
        comments = self->_parseTag(lines)
        categories = strtrim(strsplit(strjoin(comments), ',', /extract), 2)
        for i = 0L, n_elements(categories) - 1L do begin
          if (categories[i] ne '') then begin
            routine->addCategory, categories[i]
            ; TODO: add to global registry as well
          endif
        endfor
      end
    'copyright': routine->setProperty, copyright=markupParser->parse(self->_parseTag(lines))
    'customer_id': routine->setProperty, customer_id=markupParser->parse(self->_parseTag(lines))
    'examples': routine->setProperty, examples=markupParser->parse(self->_parseTag(lines))
    'field': begin
        routine->getProperty, file=file
        file->getProperty, is_class=isClass, class=class
        if (~isClass) then begin
          self.system->warning, 'field not allowed non-class definition file'
        endif
   
        comments = self->_parseTag(lines, /has_argument, $
                                   argument=fieldName, $
                                   n_attributes=nAttributes, $
                                   attribute_names=attributeNames, $
                                   attribute_values=attributeValues)                                        
        
        field = class->addField(fieldName, /get_only)
        if (obj_valid(field)) then begin        
          field->setProperty, name=fieldName, $
                              comments=markupParser->parse(comments)
        endif else begin
          self.system->warning, 'invalid field ' + fieldName
        endelse
      end
    'file_comments': begin
        routine->getProperty, file=file
        file->setProperty, comments=markupParser->parse(self->_parseTag(lines))
      end
    'hidden': routine->setProperty, is_hidden=1
    'hidden_file': begin
        routine->getProperty, file=file
        file->setProperty, is_hidden=1B
      end
    'history': routine->setProperty, history=markupParser->parse(self->_parseTag(lines))
    'inherits':   ; not used any more
    'keyword': self->_handleArgumentTag, lines, routine=routine, markup_parser=markupParser
    'obsolete': routine->setProperty, is_obsolete=1B
    'param': self->_handleArgumentTag, lines, routine=routine, markup_parser=markupParser
    'post': routine->setProperty, post=markupParser->parse(self->_parseTag(lines))
    'pre': routine->setProperty, pre=markupParser->parse(self->_parseTag(lines))
    'private': routine->setProperty, is_private=1B
    'private_file': begin
        routine->getProperty, file=file
        file->setProperty, is_private=1B
      end
    'requires': begin        
        requires = self->_parseTag(lines)
        
        ; look for an IDL version
        for i = 0L, n_elements(requires) - 1L do begin
          version = stregex(lines[i], '[[:digit:].]+', /extract)
          if (version ne '') then break
        endfor
         
        ; if you have a real version then check in with system
        if (version ne '') then begin
          self.system->checkRequiredVersion, version, routine
        endif
        
        routine->setProperty, requires=markupParser->parse(requires)
      end
    'restrictions': routine->setProperty, restrictions=markupParser->parse(self->_parseTag(lines))
    'returns': routine->setProperty, returns=markupParser->parse(self->_parseTag(lines))
    'todo': routine->setProperty, todo=markupParser->parse(self->_parseTag(lines))
    'uses': routine->setProperty, uses=markupParser->parse(self->_parseTag(lines))
    'version': routine->setProperty, version=markupParser->parse(self->_parseTag(lines))
    else: begin
        routine->getProperty, name=name
        self.system->warning, 'unknown tag ' + tag + ' in routine ' + name
      end
  endcase
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
;    `file` : in, required, type=object
;       file tree object 
;    `markup_parser` : in, required, type=object
;       markup parser object
;-
pro docparidldocformatparser::_handleFileTag, tag, lines, $
                                              file=file, $
                                              markup_parser=markupParser
  compile_opt strictarr
  
  case strlowcase(tag) of
    'property': begin
        file->getProperty, is_class=isClass, class=class
        if (~isClass) then begin
          self.system->warning, 'property not allowed non-class definition file'
        endif
   
        comments = self->_parseTag(lines, /has_argument, $
                                   argument=propertyName, $
                                   n_attributes=nAttributes, $
                                   attribute_names=attributeNames, $
                                   attribute_values=attributeValues)                                        
        
        property = class->addProperty(propertyName)
        property->setProperty, comments=markupParser->parse(comments)
      end
    
    'hidden': file->setProperty, is_hidden=1B
    'private': file->setProperty, is_private=1B
    
    'examples': file->setProperty, examples=markupParser->parse(self->_parseTag(lines))
    
    'author': file->setProperty, author=markupParser->parse(self->_parseTag(lines))
    'copyright': file->setProperty, copyright=markupParser->parse(self->_parseTag(lines))
    'history': file->setProperty, history=markupParser->parse(self->_parseTag(lines))
    'version': file->setProperty, version=markupParser->parse(self->_parseTag(lines))
    
    else: begin
        file->getProperty, basename=basename
        self.system->warning, 'unknown tag ' + tag + ' in file ' + basename
      end
  endcase
end


;+
; Handles parsing of a comment block associated with a routine using IDLdoc 
; syntax. 
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


;+
; Handles parsing of a comment block associated with a file using IDLdoc syntax. 
;
; :Params:
;    `lines` : in, required, type=strarr
;       all lines of the comment block
; :Keywords:
;    `file` : in, required, type=object
;       file tree object 
;    `markup_parser` : in, required, type=object
;       markup parser object
;-
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


;+
; Handles parsing of a comment block in the overview file using IDLdoc syntax. 
;
; :Params:
;    `lines` : in, required, type=strarr
;       all lines of the comment block
; :Keywords:
;    `system` : in, required, type=object
;       system object 
;    `markup_parser` : in, required, type=object
;       markup parser object
;-
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
    tagLines = self->_parseTag(lines[tagStart:tagEnd])
    
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
          if (strmid(dirName, 1, /reverse_offset) ne path_sep()) then begin
            dirName += path_sep()
          endif
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