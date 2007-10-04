; docformat = 'rst'

;+
; Markup parsers are responsible for parsing a free text comment. A free text
; comment is not an entire comment block, but a part of the comment block that 
; the format parser has already decided is associated with a specific item like 
; a routine or argument.
;-


;+
; Takes a string array of free text comments and return a parse tree.
;
; :Returns: object
; :Abstract:
; :Params:
;    `lines` : in, required, type=strarr
;       lines to be parsed
;-
function docparmarkupparser::parse, lines
  compile_opt strictarr
  
  ; TODO: implement this
end


function docparmarkupparser::init, system=system
  compile_opt strictarr
  
  self.system = system
  
  return, 1
end


;+
; Define instance variables.
;-
pro docparmarkupparser__define 
  compile_opt strictarr
  
  define = { DOCparMarkupParser, system: obj_new() }
end