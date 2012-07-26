; docformat = 'rst'

;+
; Begin comments about the entire file here. This is particularly useful for
; author/copyright information that describes every routine in a file as well
; as class definitions where the methods are commonly placed in a single
; file. See `idldoc_rst_class_template__define.pro` for an example of a class
; template.
;
; Using the "rst" markup style, you can embed links like this one to the 
; `IDLdoc project site <idldoc.idldev.com>`. By putting an item in backticks,
; you indicate the word or phrase is either code or a reference to a directory,
; file, routine, argument, or keyword. For example, `idldoc_rst_template` should
; link to the main routine in this file.
;
; :Author:
;    Michael Galloy
;
; :History:
;    mgalloy, 20 July 2012: initial template
;    mgalloy, 21 July 2012: added the examples section
;
; :Copyright:
;    IDLdoc is released under a BSD-type license.
;
;    Copyright (c) 2007-2009, Michael Galloy <mgalloy@idldev.com>
;
;    All rights reserved.
;
;    Redistribution and use in source and binary forms, with or without
;    modification, are permitted provided that the following conditions are
;    met:
;
;        a. Redistributions of source code must retain the above copyright
;        notice, this list of conditions and the following disclaimer.
;        
;        b. Redistributions in binary form must reproduce the above
;        copyright notice, this list of conditions and the following
;        disclaimer in the documentation and/or other materials provided with
;        the distribution.
;        
;        c. Neither the name of Michael Galloy nor the names of its
;        contributors may be used to endorse or promote products derived from
;        this software without specific prior written permission.
;
;    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
;    IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
;    TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
;    PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
;    OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
;    EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
;    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;    LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;    NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;-



;+
; Helper routine for main `idldoc_rst_template` routine. This routine is not
; intended to be called from anywhere except `idldoc_rst_template`, so it is
; marked with the `:Private:` tag. Routines/files marked with `:Private:` will
; show up in documentation created for developers (`IDLDOC, USER=0`), but not
; for users (`IDLDOC, /USER`).
;
; :Private:
;-
pro idldoc_rst_template_helper
  compile_opt strictarr, hidden
  
end


;+
; Begin by stating what your routine does here. Use the active, present tense.
;
; You might have more paragraphs about the details of the procedure/algorithm
; used in the routine.
;
; :Categories:
;    a comma separated list of categories, like: object graphics, mathematics
;
; :Requires:
;    the IDL version needed by the routine; IDLdoc finds the routines 
;    requiring the highest IDL version and reports them on the Warnings page
;  
; :Uses:
;    a comma-separated list of any other routines, classes, etc., needed 
;    by this routine
;
; :Examples:
;    Provide a simple example or two that should run "as is" for users, i.e.,
;    that don't rely on data files that are not present in the IDL 
;    distribution. Your example should execute properly if typed in at the IDL
;    command line with no other preparation::
;
;       IDL> idldoc_rst_template
;       This is an example header file for documenting IDL routines
;
;    In can also be helpful to include these examples in a main-level program
;    at the end of the file, so that running the file will execute the
;    example::
;
;       IDL> .run idldoc_rst_template
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
;    keyword1 : in, optional, type=long
;       describe a keyword parameter
;    keyword2 : in, optional, type=boolean
;       keywords with type "boolean" are recognized and marked specially by
;       IDLdoc
;    output_keyword : out, optional, type=any
;       describe optional output keywords; usually should start with the
;       phrase "set to a named variable to return..."
;-
pro idldoc_rst_template
  compile_opt strictarr
  
  print, 'This is an example header file for documenting IDL routines'
end


; main-level example program

idldoc_template

end


