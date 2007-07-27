; docformat = 'rst'

;+
; Handles parsing of IDLdoc syntax comment blocks.
;-


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
;    `file` : in, required, type=file
;       file tree object
;    `markup_parser` : in, required, type=object
;       markup parser object
;-
pro docparidldocformatparser::_handleTag, tag, lines, $
                                          routine=routine, file=file, $
                                          markup_parser=markupParser
  compile_opt strictarr
  
  ; TODO: implement this
  
  ; here are all the tags
  case strlowcase(tag) of
    'abstract' :
    'author' :
    'bugs' :
    'categories' :
    'copyright' :
    'customer_id' :
    'examples' :
    'field' :
    'file_comments' :
    'hidden' :
    'hidden_file' :
    'history' :
    'inherits' :
    'keywords' :
    'obsolete' :
    'params' :
    'post' :
    'pre' :
    'private' :
    'private_file' :
    'requires' :
    'restrictions' :
    'returns' :  
    'todo' :
    'uses' :
    'version' :
    else : begin
        ; TODO: throw error (but obey /SILENT and /QUIET keywords)
        self.system->warning, 'unknown tag: ' + tag
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
;    `file` : in, required, type=file
;       file tree object
;    `markup_parser` : in, required, type=object
;       markup parser object
;-
pro docparidldocformatparser::parse, lines, routine=routine, file=file, $
                                     markup_parser=markupParser
  compile_opt strictarr
  
  ; TODO: implement this
  
  ; look for @'s (but not escaped with \'s)
  ; get free text comment for routine
  ; go through each tag
end


;+
; :Returns: 1 for success, 0 for failure
; :Params:
;    `system` : in, required, type=object
;       IDLdoc system object
;-
function docparidldocformatparser::init, system=system
  compile_opt strictarr
  
  self.system = system
  
  return, 1
end


;+
; Define instance variables.
;-
pro docparidldocformatparser__define
  compile_opt strictarr

  define = { DOCparIDLdocFormatParser, inherits DOCparFormatParser, $
             system: obj_new() $
           }
end