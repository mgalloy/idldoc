; docformat = 'rst'

;+
; Begin comments about the entire file here; this is particularly useful for
; class definitions where the methods are commonly placed in a single
; file.
;
; :Properties:
;    property1
;       describe `property1`
;    property2
;       describe `property2`
;
; :Author:
;    Michael Galloy
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
; The standard tags for a routine will also work for a method like `:Params:`,
; `:Keywords:`, `:Returns:`, or `:Examples:`.
;-
pro idldoc_rst_class_template::doAction
  compile_opt strictarr
  
end


;+
; A method that should only be called from the other methods of the object is
; called "Private". There is no way to enforce this through IDL's syntax, but
; it can be signaled through the documentation by using the `:Private:` tag or
; other hints like starting the name with an underscore.
;
; :Private:
;-
pro idldoc_rst_class_template::_privateMethod
  compile_opt strictarr
  
end


;+
; Retrieve properties. No need to document individual keywords here; they will
; be picked up by the `:Properties:` tag in the file comments.
;-
pro idldoc_rst_class_template::getProperty, property1=property1, $
                                            property2=property2
  compile_opt strictarr

  ; get properties
end


;+
; Set properties. No need to document individual keywords here; they will be
; picked up by the `:Properties:` tag in the file comments.
;-
pro idldoc_rst_class_template::setProperty, property1=property1, $
                                            property2=property2
  compile_opt strictarr

  ; set properties
end


;+
; Free resources of the object.
;-
pro idldoc_rst_class_template::cleanup
  compile_opt strictarr
  
end


;+
; Initialize `idldoc_rst_class_template object`.
;
; :Returns:
;    1 for success, 0 for failure
;
; :Keywords:
;    _extra : in, optional, type=keywords
;       keywords to `setProperty`
;-
function idldoc_rst_class_template::init, _extra=e
  compile_opt strictarr
  
  self->setProperty, _extra=e
  
  return, 1
end


;+
; Define member variables of the class.
;
; :Fields:
;    a
;       describe `a` member variable
;    b
;       describe `b` member variable
;    c
;       describe `c` member variable
;-
pro idldoc_rst_class_template__define
  compile_opt strictarr
  
  define = { idldoc_rst_class_template, $
             a: 0.0, $
             b: 0L, $
             c: '' $
           }
end


; main-level example program

t = obj_new('idldoc_rst_class_template')
t->simpleMethod
obj_destroy, t

end


