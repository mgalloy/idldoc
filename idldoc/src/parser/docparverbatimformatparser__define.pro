; docformat = 'rst'

;+
; Handles parsing of comment blocks bby just passing comments along.
;-


;+
; Handles parsing of a comment block np special syntax: all comments are passed
; through to the markup parser. 
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
pro docparverbatimformatparser::parseRoutineComments, lines, routine=routine, $
                                                      markup_parser=markupParser
  compile_opt strictarr
  
  comments = markupParser->parse(lines)
  routine->setProperty, comments=comments
end


pro docparverbatimformatparser::parseFileComments, lines, file=file, $
                                                   markup_parser=markupParser
  compile_opt strictarr
  
  comments = markupParser->parse(lines)
  file->setProperty, comments=comments
end


;+
; Define instance variables.
;-
pro docparverbatimformatparser__define
  compile_opt strictarr

  define = { docparverbatimformatparser, inherits DOCparFormatParser }
end