; docformat = 'rst'

;+
; Handles parsing of the rst (restructured text) style comment blocks.
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
pro docparrstformatparser::_handleTag, tag, lines, routine=routine, file=file, $
                                       markup_parser=markupParser
  compile_opt strictarr
  
  case strlowcase(tag) of
  'abstract' :
  'keywords' :
  'params' :
  'returns' :
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
;    `file` : in, required, type=file
;       file tree object
;    `markup_parser` : in, required, type=object
;       markup parser object
;-
pro docparrstformatparser::parse, lines, routine=routine, file=file, $
                                     markup_parser=markupParser
  compile_opt strictarr
  
  ; look for "tags"
end

;+
; Define instance variables.
;- 
pro docparrstformatparser__define
  compile_opt strictarr

  define = { DOCparRstFormatParser, inherits DOCparFormatParser }
end
