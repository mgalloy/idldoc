; docformat = 'rst'

;+
; Handles parsing of the standard IDL comment template style comment blocks.
;-


;+
; Handles parsing of a comment block using IDL syntax. 
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
pro docparidlformatparser::parse, lines, routine=routine, file=file, $
                                     markup_parser=markupParser
  compile_opt strictarr
  
  ; TODO: implement this
  
  ; look for section names
  sectionNames = ['NAME', 'PURPOSE', 'CATEGORY', 'CALLING SEQUENCE', $
                  'INPUTS', 'OPTIONAL INPUTS', 'KEYWORD PARAMETERS', $
                  'OUTPUT', 'OPTIONAL OUTPUTS', 'COMMON BLOCKS', $
                  'SIDE EFFECTS', 'RESTRICTIONS', 'PROCEDURE', 'EXAMPLE', $
                  'MODIFICATION HISTORY']
                  
end


pro docparidlformatparser__define
  compile_opt strictarr

  define = { DOCparIDLFormatParser, inherits DOCparFormatParser }
end