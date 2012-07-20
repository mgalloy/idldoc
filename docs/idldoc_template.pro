; docformat = 'rst'

;+
; Begin comments about the entire file here; this is particularly useful for
; class definitions where the methods are commonly placed in a single file.
;-


;+
; Begin by stating what your routine does here. Use the active, present tense.
;
; You might have more paragraphs about the details of the procedure/algorithm
; used in the routine.
;
; :Categories:
;    a comma separated list of categories, like: object graphics, mathematics
;
; :Examples:
;    Provide a simple example or two that should run "as is" for users, i.e.,
;    that don't rely on data files that are not present in the IDL 
;    distribution. Your example should execute properly if typed in at the IDL
;    command line with no other preparation::
;
;       IDL> idldoc_template
;       This is an example header file for documenting IDL routines
;
;    In can also be helpful to include these examples in a main-level program
;    at the end of the file, so that running the file will execute the
;    example::
;
;       IDL> .run idldoc_template
;
; :Params:
;    param1 : in, required, type=fltarr
;       describe the positional input parameter
;    param2 : in, optional, type=integer, default=0
;       describe the optional input parameter; give a description of how
;       the default value is found if it is complicated
;
; :Returns:
;    describe the return value of the function, omit this section for
;    procedures; make sure to describe the type of the return value
;
; :Keywords:
;    KEY1:
;       Document keyword parameters like this. Note that the keyword
;       is shown in ALL CAPS!
;    KEY2:
;       Yet another keyword. Try to use the active, present tense
;       when describing your keywords.  For example, if this keyword
;       is just a set or unset flag, say something like:
;       "Set this keyword to use foobar subfloatation. The default
;       is foobar superfloatation."
;    OUTPUT_KEYWORD : out, optional, type=any
;       Describe optional outputs here.  If the routine doesn't have any,
;       just delete this section.
;
; :History:
;    mgalloy, 20 July 2012: initial template
;    mgalloy, 21 July 2012: added the examples section
;-
pro idldoc_template
  compile_opt strictarr
  
  print, 'This is an example header file for documenting IDL routines'
end


; main-level example program

idldoc_template

end


