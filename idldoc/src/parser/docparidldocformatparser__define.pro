; docformat = 'rst'

;+
; Handles parsing of IDLdoc syntax comment blocks.
;-


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
; Define instance variables.
;-
pro docparidldocformatparser__define
  compile_opt strictarr

  define = { DOCparIDLdocFormatParser, inherits DOCparFormatParser }
end