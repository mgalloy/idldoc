; docformat = 'rst'

;+
; Handles parsing of the rst (restructured text) style comment blocks.
;-


;+
; Parse the lines from a tag.
; 
; :Params:
;    `lines` : in, out, required, type=strarr
;
; :Keywords: 
;    has_argument : in, optional, type=boolean
;       set to indicate that this tag has an argument
;    tag : out, optional, type=string
;       set to a named variable to return the name of the tag
;    argument : out, optional, type=string
;       set to a named variable to return the argument
;    n_attributes : out, optional, type=long
;       set to a named variable to return the number of attributes in curly 
;       braces
;    attributes_names : out, optional, type=strarr
;       set to a named variable to return an array of attribute names
;    attributes_values : out, optional, type=strarr
;       set to a named variable to return an array of attribute values (value
;       will be '' if the attribute has no value)
;-
function docparrstformatparser::_parseTag, lines, $
                                              has_argument=hasArgument, $
                                              tag=tag, argument=argument, $
                                              n_attributes=nAttributes, $
                                              attribute_names=attributeNames, $
                                              attribute_values=attributeValues
  ; TODO: implement this
  
  ; this is the part where it knows how tag arguments, attributes, and comments
  ; are formatted
  
  return, lines                                           
end  
         
                                            
;+
; Handles one tag in a file's comments.
; 
; :Params:
;    `tag` : in, required, type=string
;       rst tag, i.e. returns, params, keywords, etc.
;    `lines` : in, required, type=strarr
;       lines of raw text for that tag
;
; :Keywords:
;    `file` : in, required, type=object
;       file tree object 
;    `markup_parser` : in, required, type=object
;       markup parser object
;-
pro docparrstformatparser::_handleFileTag, tag, lines, $
                                           file=file, $
                                           markup_parser=markupParser
  compile_opt strictarr
  
  case strlowcase(tag) of
    'properties': begin
        ; TODO: implement this
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
pro docparrstformatparser::_handleRoutineTag, tag, lines, routine=routine, $
                                              markup_parser=markupParser
  compile_opt strictarr
  
  ; TODO: implement these tags
  case strlowcase(tag) of
    'abstract' :
    'author':
    'bugs':
    'categories':
    'copyright':
    'customer_id':
    'examples':
    'fields' :
    'file_comments':
    'hidden':
    'hidden_file':
    'history':
    'inherits':
    'keywords':
    'obsolete':
    'parameters':
    'post':
    'pre':
    'private':
    'private_file':
    'requires':
    'restrictions':
    'returns' :
    'todo':
    'uses':
    'version':
    else :
  endcase
end


;+
; Handles parsing of a comment block using rst syntax. 
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
pro docparrstformatparser::parseRoutineComments, lines, routine=routine,  $
                                                 markup_parser=markupParser
  compile_opt strictarr
  
  ; TODO: implement this
  ; look for "tags"
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
