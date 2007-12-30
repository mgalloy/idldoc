; docformat = 'rst'

;+
; Format parsers parse a comment block using a particular format for comments:
; the standard IDL template, IDLdoc style @-tags, or rst style syntax. The 
; format parser will call the markup parser to parse free text comments in the
; comment block.
;
; :Properties:
;    system
;       system object
;-


;+
; Handles parsing of a code block. 
;
; :Abstract:
;
; :Params:
;    lines : in, required, type=strarr
;       all lines of the comment block
;
; :Keywords:
;    routine : in, required, type=object
;       routine tree object 
;    markup_parser : in, required, type=object
;       markup parser object
;-
pro docparformatparser::parseRoutineComments, lines, routine=routine, $
                                               markup_parser=markupParser
  compile_opt strictarr
  
end


;+
; Handles parsing of a comment block associated with a file. 
;
; :Params:
;    lines : in, required, type=strarr
;       all lines of the comment block
;
; :Keywords:
;    file : in, required, type=object
;       file tree object 
;    markup_parser : in, required, type=object
;       markup parser object
;-
pro docparformatparser::parseFileComments, lines, file=file, $
                                           markup_parser=markupParser
  compile_opt strictarr
  
end


;+
; Parse comments in an .idldoc file.
;
; :Params:
;    lines : in, required, type=strarr
;       all lines of the comment block
;
; :Keywords:
;    file : in, required, type=object
;       file tree object 
;    markup_parser : in, required, type=object
;       markup parser object
;-
pro docparformatparser::parseIDLdocComments, lines, file=file, $
                                             markup_parser=markupParser
  compile_opt strictarr

  comments = markupParser->parse(lines)
  file->setProperty, comments=comments  
end


;+
; Handles parsing of a comment block in the overview file using IDLdoc syntax. 
;
; :Params:
;    lines : in, required, type=strarr
;       all lines of the comment block
;
; :Keywords:
;    system : in, required, type=object
;       system object 
;    markup_parser : in, required, type=object
;       markup parser object
;-
pro docparformatparser::parseOverviewComments, lines, system=system, $
                                               markup_parser=markupParser
  compile_opt strictarr
  
end


;+
; Check if there is any class-related information (like heldProperties) waiting
; for this routine.
;
; :Params:
;     routine : in, required, type=object
;        routine tree object
;-
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
  
  
;+
; Free resources.
;-
pro docparformatparser::cleanup
  compile_opt strictarr

  obj_destroy, self.heldProperties
end


;+
; Create a format parser object.
;
; :Returns: 1 for success, 0 for failure
;-
function docparformatparser::init, system=system
  compile_opt strictarr
  
  self.system = system
  self.heldProperties = obj_new('MGcoArrayList', type=11, block_size=5)
  
  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    system
;       system tree object
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