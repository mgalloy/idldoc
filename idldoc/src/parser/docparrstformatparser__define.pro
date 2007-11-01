; docformat = 'rst'

;+
; Handles parsing of the rst (restructured text) style comment blocks.
;-


;+
; Parse the lines from a tag; simply removes the tag and passes along the rest.
; 
; :Params:
;    lines : in, out, required, type=strarr
;-
function docparrstformatparser::_parseTag, lines
  compile_opt strictarr
  
  mylines = lines
  pos = stregex(lines[0], '^[[:space:]]*:[[:alpha:]_]+:[[:space:]]*', length=len)
  mylines[0] = strmid(lines[0], pos + len)
  
  return, mylines                                           
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
;       file tree object 
;    markup_parser : in, required, type=object
;       markup parser object
;-
pro docparrstformatparser::_handleFileTag, tag, lines, $
                                           file=file, $
                                           markup_parser=markupParser
  compile_opt strictarr
  
  case strlowcase(tag) of
    'properties': begin        
        file->getProperty, is_class=isClass, class=class
        if (~isClass) then begin
          self.system->warning, 'property not allowed non-class definition file'
        endif                              
        
        ; find number of spaces that properties' names are indented
        l = 1L
        nameIndent = -1L
        while (l lt n_elements(lines) && nameIndent eq -1L) do begin 
          nameIndent = stregex(lines[1], '[[:alnum:]_$]')          
        endwhile
        
        ; must indent property names
        if (nameIndent lt 1) then begin
          self.system->warning, 'invalid properties syntax'
          return
        endif              

        ; find properties' names lines (ignore first line, first property starts 
        ; on the line after :Properties:)        
        propLines = lines[1:*]
        re = string(format='(%"^[ ]{%d}([[:alnum:]_$]+)")', nameIndent)        
        propertyNamesStart = stregex(propLines, re, $
                                     /subexpr, length=propertyNamesLength)
        propertyDefinitionLines = where(propertyNamesStart[1, *] ne -1L, nProperties)
        
        ; add each property
        for p = 0L, nProperties - 1L do begin
         propertyName = strmid(propLines[propertyDefinitionLines[p]], $
                               propertyNamesStart[1, propertyDefinitionLines[p]], $
                               propertyNamesLength[1, propertyDefinitionLines[p]])
         property = class->addProperty(propertyName)
         print, format='(%"-- Adding property: %s")', propertyName
         propertyDefinitionEnd = p eq nProperties - 1L $
                                   ? n_elements(proplines) - 1L $
                                   : propertyDefinitionLines[p + 1L] - 1L
         if (propertyDefinitionLines[p] + 1 le propertyDefinitionEnd) then begin
           comments = propLines[propertyDefinitionLines[p] + 1:propertyDefinitionEnd] 
           property->setProperty, comments=markupParser->parse(comments)        
         endif  
        endfor                     
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
pro docparrstformatparser::_handleRoutineTag, tag, lines, routine=routine, $
                                              markup_parser=markupParser
  compile_opt strictarr
  
  ; TODO: implement these tags
  case strlowcase(tag) of
    'abstract': routine->setProperty, is_abstract=1B
    'author': routine->setProperty, author=markupParser->parse(self->_parseTag(lines))
    'bugs': begin
        routine->setProperty, bugs=markupParser->parse(self->_parseTag(lines))
        self.system->createBugEntry, routine
      end      
    'categories': begin
        comments = self->_parseTag(lines)
        categories = strtrim(strsplit(strjoin(comments), ',', /extract), 2)
        for i = 0L, n_elements(categories) - 1L do begin
          if (categories[i] ne '') then begin
            routine->addCategory, categories[i]
            self.system->createCategoryEntry, categories[i], routine
          endif
        endfor
      end
    'copyright': routine->setProperty, copyright=markupParser->parse(self->_parseTag(lines))
    'customer_id': routine->setProperty, customer_id=markupParser->parse(self->_parseTag(lines))
    'examples': routine->setProperty, examples=markupParser->parse(self->_parseTag(lines))
    
    ; TODO: implement this
    'fields': 
    
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
    
    ; TODO: implement this
    'keywords':
     
    'obsolete': begin
        routine->setProperty, is_obsolete=1B
        self.system->createObsoleteEntry, routine
      end
      
    ; TODO: implement this
    'params':
    
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
    'todo': begin
        routine->setProperty, todo=markupParser->parse(self->_parseTag(lines))
        self.system->createTodoEntry, routine
      end
    'uses': routine->setProperty, uses=markupParser->parse(self->_parseTag(lines))
    'version': routine->setProperty, version=markupParser->parse(self->_parseTag(lines))
    else: begin
        routine->getProperty, name=name
        self.system->warning, 'unknown tag ' + tag + ' in routine ' + name
      end
  endcase
end


;+
; Handles parsing of a comment block using rst syntax. 
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
pro docparrstformatparser::parseRoutineComments, lines, routine=routine,  $
                                                 markup_parser=markupParser
  compile_opt strictarr
  
  ; find tags enclosed by ":"s that are the first non-whitespace character on 
  ; the line
  tagLocations = where(stregex(lines, '^[[:space:]]*:[[:alpha:]_]+:') ne -1L, nTags)
  
  ; parse normal comments
  tagsStart = nTags gt 0 ? tagLocations[0] : n_elements(lines)
  if (tagsStart ne 0) then begin
    comments = markupParser->parse(lines[0:tagsStart - 1L])
    routine->setProperty, comments=comments
  endif  
  
  ; go through each tag
  for t = 0L, nTags - 1L do begin
    tagStart = tagLocations[t]
    tagFull = stregex(lines[tagStart], ':[[:alpha:]_]+:', /extract)
    tag = strmid(tagFull, 1, strlen(tagFull) - 2L)
    tagEnd = t eq nTags - 1L $
               ? n_elements(lines) - 1L $
               : tagLocations[t + 1L] - 1L
    self->_handleRoutineTag, tag, lines[tagStart:tagEnd], $
                             routine=routine, markup_parser=markupParser
  endfor
end


pro docparrstformatparser::parseFileComments, lines, file=file,  $
                                              markup_parser=markupParser
  compile_opt strictarr
  
  ; find tags enclosed by ":"s that are the first non-whitespace character on 
  ; the line
  tagLocations = where(stregex(lines, '^[[:space:]]*:[[:alpha:]_]+:') ne -1L, nTags)
  
  ; parse normal comments
  tagsStart = nTags gt 0 ? tagLocations[0] : n_elements(lines)
  if (tagsStart ne 0) then begin
    comments = markupParser->parse(lines[0:tagsStart - 1L])
    file->setProperty, comments=comments
  endif  
  
  ; go through each tag
  for t = 0L, nTags - 1L do begin
    tagStart = tagLocations[t]
    tagFull = stregex(lines[tagStart], ':[[:alpha:]_]+:', /extract)
    tag = strmid(tagFull, 1, strlen(tagFull) - 2L)
    tagEnd = t eq nTags - 1L $
               ? n_elements(lines) - 1L $
               : tagLocations[t + 1L] - 1L
    self->_handleFileTag, tag, lines[tagStart:tagEnd], $
                          file=file, markup_parser=markupParser
  endfor  
end


pro docparrstformatparser::parseOverviewComments, lines, system=system, $
                                                  markup_parser=markupParser
  compile_opt strictarr

  ; TODO: implement this  
end


;+
; Define instance variables.
;- 
pro docparrstformatparser__define
  compile_opt strictarr

  define = { DOCparRstFormatParser, inherits DOCparFormatParser }
end
