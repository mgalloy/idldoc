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
;    `markup_parser` : in, required, type=object
;       markup parser object
;-
pro docparformatparser::parseRoutineComments, lines, routine=routine, $
                                               markup_parser=markupParser
  compile_opt strictarr
  
end


pro docparformatparser::parseFileComments, lines, file=file, $
                                           markup_parser=markupParser
  compile_opt strictarr
  
end


pro docparformatparser::parseIDLdocComments, lines, file=file, $
                                             markup_parser=markupParser
  compile_opt strictarr

  comments = markupParser->parse(lines)
  file->setProperty, comments=comments  
end


pro docparformatparser::parseOverviewComments, lines, system=system, $
                                               markup_parser=markupParser
  compile_opt strictarr
  
end


pro docparformatparser::checkForClass, routine
  compile_opt strictarr
  
  ; before starting on any of the comments associated with the routine, see if
  ; there are any "heldProperties" from a previous file comment that should be
  ; associated with the class represented by this routine
  routine->getProperty, classname=classname, file=file
  if (classname ne '') then begin
    class = file->getClass(classname)
    for p = 0L, self.heldProperties->count() - 1L do begin
      class->addProperty, self.heldProperties->get(position=p)
    endfor        
  endif else begin
    properties = self.heldProperties->get(/all, count=nProps)
    if (nProps gt 0) then obj_destroy, properties
  endelse
  self.heldProperties->remove, /all
end
  
  
pro docparformatparser::cleanup
  compile_opt strictarr

  obj_destroy, self.heldProperties
end


function docparformatparser::init, system=system
  compile_opt strictarr
  
  self.system = system
  self.heldProperties = obj_new('MGcoArrayList', type=11)
  
  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    heldProperties
;       properties waiting to be claimed by a class
;-
pro docparformatparser__define 
  compile_opt strictarr
  
  define = { DOCparFormatParser, $
             system: obj_new(), $
             heldProperties: obj_new() $
           }
end