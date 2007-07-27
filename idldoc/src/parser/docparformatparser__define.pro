; docformat = 'rst'

;+
; Format parsers parse a comment block using a particular format for comments:
; the standard IDL template, IDLdoc style @-tags, or rst style syntax. The 
; format parser will call the markup parser to parse free text comments in the
; comment block.
;-


;+
; Handles parsing of a code block. 
;
; :Abstract:
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
function docparformatparser::parse, lines, routine=routine, file=file, $
                                    markup_parser=markupParser
  compile_opt strictarr
  
  ; TODO: implement this
end


;+
; Define instance variables.
;-
pro docparformatparser__define 
  compile_opt strictarr
  
  define = { DOCparFormatParser, _: 0L }
end