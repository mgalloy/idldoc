;+
; Implements the getVariable method. This routine returns a value of a 
; variable given the variable's name as a string. The only variable this 
; object should contain is the FOREACH loop index variable.
;
; @private
; @returns any type
; @param name {in}{required}{type=string} name of the variable
; @keyword found {out}{optional}{type=boolean} true if the variable was found
;-
function mgfffortemplate::getVariable, name, found=found
  compile_opt strictarr

  found = 0B
  
  ; variable name must be a string
  if (size(name, /type) ne 7) then return, -1L

  ; compare names case insensitively
  if (strupcase(name) eq strupcase(self.name)) then begin
    found = 1B
    return, *self.value
  endif else return, -1L
end


;+
; Sets the FOREACH loop index variable.
;
; @private
; @param value {in}{required}{type=any} new value of the FOREACH loop index
;        variable
;-
pro mgfffortemplate::setVariable, value
  compile_opt strictarr

  *self.value = value
end


;+
; Free resources.
;
; @private
;-
pro mgfffortemplate::cleanup
  compile_opt strictarr

  ptr_free, self.value
end


;+
; Initialize the instance variables.
;
; @private
; @returns 1L
; @param name {in}{required}{type=string} name of the FOREACH loop index
;        variable
; @param value {in}{required}{type=any} initial value for the FOREACH loop
;        index variable
;-
function mgfffortemplate::init, name, value
  compile_opt strictarr

  self.name = name
  self.value = ptr_new(value)

  return, 1L
end


;+
; Define instance variables. This class is used internally by the
; MGffTemplate class to handle the variable associated with a FOREACH loop.
;
; @private
; @field name name of the FOREACH loop index variable.
; @field value pointer to the value of the FOREACH loop index variable.
;-
pro mgfffortemplate__define
  compile_opt strictarr

  define = { mgfffortemplate, $
             name: '', $
             value: ptr_new() $
           }
end


;+
; Implements the getVariable method. This routine returns a value of a 
; variable given the variable's name as a string. This routine checks its 
; subobjects for the variable.
;
; @private
; @returns any type
; @param name {in}{required}{type=string} name of the variable
; @keyword found {out}{optional}{type=boolean} true if the variable was found
;-
function mgffcompoundtemplate::getVariable, name, found=found
  compile_opt strictarr
  on_error, 2
  
  ; variable name must be a string
  if (size(name, /type) ne 7) then begin
    found = 0B
    return, -1L
  endif

  ; check first template for variable
  if (obj_valid(self.template1)) then begin
    val = self.template1->getVariable(name, found=found)
  endif else found = 0B

  ; check the second template if not found in first
  if (found) then begin
    return, val
  endif else begin
    if (size(*self.template2, /type) eq 11) then begin
      if (obj_valid(self.template2)) then begin
        val = (*self.template2)->getVariable(name, found=found)
        return, found ? val : -1L
      endif else begin
        found = 0B
        return, -1L
      endelse
    endif else if (size(*self.template2, /type) eq 8) then begin
      ind = where(tag_names(*self.template2) eq strupcase(name), count)
      if (count eq 0) then begin
        found = 0B
        return, -1L
      endif else begin
        found = 1B
        return, (*self.template2).(ind[0])
      endelse
    endif
  endelse
end


;+
; Free resources.
;
; @private
;-
pro mgffcompoundtemplate::cleanup
  compile_opt strictarr

  ptr_free, self.template2
end


;+
; Initialize instance variables.
;
; @private
; @returns 1L
; @param template1 {in}{required}{type=object} an object which implements
;        the getVariable method
; @param template2 {in}{required}{type=object} an object which implements
;        the getVariable method or a structure
;-
function mgffcompoundtemplate::init, template1, template2
  compile_opt strictarr
  on_error, 2
  
  if (size(template1, /type) ne 11) then begin
    message, 'invalid type for template1: ' + size(template1, /tname)
  endif
  
  type = size(template2, /type)
  if (type ne 8 && type ne 11) then begin
    message, 'invalid type for template2: ' + size(template2, /tname)
  endif
  
  self.template1 = template1
  self.template2 = ptr_new(template2)

  return, 1
end


;+
; Define instance variables. This class is used internally by the
; MGffTemplate class to handle the variables associated with a SCOPE
; directive.
;
; @private
; @field template1 a subobject implementing the getVariable method
; @field template2 a subobject implementing the getVariable method
;-
pro mgffcompoundtemplate__define
  compile_opt strictarr

  define = { mgffcompoundtemplate, $
             template1: obj_new(), $
             template2: ptr_new() $
           }
end


;+
; Wrapper for PRINTF that recognizes LUN=-3 as /dev/null.
;
; @private
; @param lun {in}{required}{type=LUN} logical unit number to direct output to,
;        -3 means /dev/null
; @param data {in}{required}{type=any} data to print
; @keyword _extra {in}{optional}{type=keywords} keywords to PRINTF
;-
pro mgfftemplate::_printf, lun, data, _extra=e
  compile_opt strictarr

  if (lun eq -3) then return else begin
    if (n_elements(data) gt 1) then begin
      if (size(data, /type) eq 10) then begin
        for i = 0L, n_elements(data) - 1L do begin
          self->_printf, lun, (*data)[i], _extra=e
        endfor
      endif else begin
        printf, lun, transpose(data), _extra=e
      endelse
    endif else begin
      if (size(data, /type) eq 10) then begin
        self->_printf, lun, *data, _extra=e
      endif else begin
        printf, lun, data, _extra=e
      endelse
    endelse
  endelse
end


;+
; Process an [% IF %] directive.
;
; @private
; @param variables {in}{required}{type=structure} anonymous structure of
;        variables
; @param output_lun {in}{required}{type=LUN} logical unit number of output 
;        file
;-
pro mgfftemplate::_process_if, variables, output_lun
  compile_opt strictarr, logical_predicate

  ; get full expression
  expression = ''
  post_delim = ''
  while (strpos(post_delim, '%]') eq -1) do begin
    expression += ' ' + self.tokenizer->next(post_delim=post_delim)
  endwhile

  ; get values of variables in the expression
  delimiters = '"'' +-*/=^<>|&?:.[]{}()#~,'
  vars = strsplit(expression, delimiters, /extract, count=nvars)
  for i = 0, nvars - 1L do begin
    result = self->_getVariable(variables, vars[i], found=varFound)
    if (varFound) then begin
      (scope_varfetch(vars[i], /enter)) = result
    endif
  endfor
    
  ; evaluate the expression
  statement = 'condition = ' + expression
  result = execute(statement, 1, 1)
  if (result) then begin
    new_output_lun = condition ? output_lun : -3
  endif else new_output_lun = -3
  
  self->_process_tokens, variables, new_output_lun, $
                         else_clause=else_clause
  if (keyword_set(else_clause)) then begin
    if (result) then begin
      new_output_lun = ~condition ? output_lun : -3
    endif else new_output_lun = output_lun
    self->_process_tokens, variables, new_output_lun
  endif
end


;+
; Process a [% FOREACH %] directive.
;
; @private
; @param variables {in}{required}{type=structure} anonymous structure of
;        variables
; @param output_lun {in}{required}{type=LUN} logical unit number of output 
;        file
;-
pro mgfftemplate::_process_foreach, variables, output_lun
  compile_opt strictarr
  on_error, 2

  loopVariable = self.tokenizer->next()
  in = self.tokenizer->next()
  arrayVariable = self.tokenizer->next()
  
  loopVariable = strtrim(loopVariable, 2)
  arrayVariable = strtrim(arrayVariable, 2)

  array = self->_getVariable(variables, arrayVariable, found=found)
  if (~found && (output_lun ne -3L)) then begin
    message, 'array variable ' + arrayVariable + ' for FOR loop not found'
  endif

  ofor = obj_new('MGffForTemplate', loopVariable, array[0])
  ocompound = obj_new('MGffCompoundTemplate', ofor, variables)
  pos = self.tokenizer->savePos()
  for i = 0L, n_elements(array) - 1L do begin
      ofor->setVariable, array[i]
      self.tokenizer->restorePos, pos
      self->_process_tokens, ocompound, output_lun
  endfor
  obj_destroy, [ofor, ocompound]
end


;+
; Process an [% INCLUDE filename %] directive. This includes the file 
; specified by the "filename" variable directly (with not processing), as in 
; the INSERT directive except the filename is specified with a variable.
;
; @private
; @param variables {in}{required}{type=structure} anonymous structure of
;        variables
; @param output_lun {in}{required}{type=LUN} logical unit number of output 
;        file
;-
pro mgfftemplate::_process_include, variables, output_lun
  compile_opt strictarr
  on_error, 2

  filenameVariable = self.tokenizer->next()
  if (output_lun eq -3) then return
  
  filename = self->_getVariable(variables, filenameVariable, found=found)

  line = self.tokenizer->getCurrentLine(number=lineNumber)
    
  if (~found) then begin
    message, 'variable ' + filenameVariable + ' not found on line ' $
      + strtrim(lineNumber, 2) + ': ', /informational, /noname, /continue
    message, line, /noname
  endif
  
  if (size(filename, /type) ne 7) then begin
    message, 'Variable ' + filenameVariable + ' must be a string on line ' $
      + strtrim(lineNumber, 2) + ': ', /informational, /noname, /continue
    message, line, /noname
  endif
  
  if (~file_test(filename)) then begin
    message, 'filename ' + filename + ' not found on line ' $
      + strtrim(lineNumber, 2) + ': ', /informational, /noname, /continue
    message, line, /noname
  endif
  
  openr, insertLun, filename, /get_lun
  line = ''
  while (~eof(insertLun)) do begin
    readf, insertLun, line
    self->_printf, output_lun, line
  endwhile
  free_lun, insertLun
end


;+
; Process a [% INCLUDE_TEMPLATE filename %] directive. This includes the 
; file specified by the "filename" variable, processing it as a template with
; the same variables as the current template.
;
; @private
; @param variables {in}{required}{type=structure} anonymous structure of
;        variables
; @param output_lun {in}{required}{type=LUN} logical unit number of output 
;        file
;-
pro mgfftemplate::_process_include_template, variables, output_lun
  compile_opt strictarr
  on_error, 2
  
  filenameVariable = self.tokenizer->next()
  if (output_lun eq -3) then return
  
  filename = self->_getVariable(variables, filenameVariable, found=found)

  line = self.tokenizer->getCurrentLine(number=lineNumber)
  
  if (~found) then begin
    message, 'variable ' + filenameVariable + ' not found on line ' $
      + strtrim(lineNumber, 2) + ': ', /informational, /noname, /continue
    message, line, /noname
  endif
  
  if (size(filename, /type) ne 7) then begin
    message, 'Variable ' + filenameVariable + ' must be a string on line ' $
      + strtrim(lineNumber, 2) + ': ', /informational, /noname, /continue
    message, line, /noname
  endif
  
  if (~file_test(filename)) then begin
    message, 'filename ' + filename + ' not found on line ' $
      + strtrim(lineNumber, 2) + ': ', /informational, /noname, /continue
    message, line, /noname
  endif
  
  oinclude = obj_new('MGffTemplate', filename)
  oinclude->process, variables, lun=output_lun
  obj_destroy, oinclude
end


;+
; Process an [% INSERT filename %] directive. Insert the given filename. Here
; "filename" is not a variable; it is a directly specified filename. The 
; filename can be absolute or relative to the template file.
;
; @private
; @param output_lun {in}{required}{type=LUN} logical unit number of output 
;        file
;-
pro mgfftemplate::_process_insert, output_lun
  compile_opt strictarr
  on_error, 2
  
  filename = self.tokenizer->next()
  
  ; fill out filenames that are relative to the template file
  cd, current=origDir
  cd, file_dirname(self.templateFilename)
  filename = file_expand_path(filename)
  cd, origDir

  if (~file_test(filename)) then begin
    message, 'filename ' + filename + ' not found', /noname
  endif
  
  openr, insertLun, filename, /get_lun
  line = ''
  while (~eof(insertLun)) do begin
    readf, insertLun, line
    self->_printf, output_lun, line
  endwhile
  free_lun, insertLun
end


;+
; Process a [% SCOPE ovariables %] directive. Only valid for a object 
; template.
;
; @private
; @param variables {in}{required}{type=object} object with getVariable method
; @param output_lun {in}{required}{type=LUN} logical unit number of output 
;        file
;-
pro mgfftemplate::_process_scope, variables, output_lun
    compile_opt strictarr
    on_error, 2
    
    if (size(variables, /type) ne 11) then begin
      message, 'SCOPE directive only valid for object templates'
    endif
    
    varname = self.tokenizer->next()
    ovars = variables->getVariable(varname, found=found)

    if (~found) then begin
        line = self.tokenizer->getCurrentLine(number=line_number)
        message, 'variable ' + varname + ' not found on line ' $
            + strtrim(line_number, 2) + ': ', /informational, /noname, $
            /continue
        message, line, /noname
    endif

    if (size(ovars, /type) ne 11) then begin
        self->_process_tokens, ovariables, output_lun
    endif else begin
        ocompound = obj_new('IDLdocCompoundObjTemplate', ovars, ovariables)
        self->_process_tokens, ocompound, output_lun
        obj_destroy, ocompound
    endelse
end


;+
; Finds a given variable name in a structure of variables or calls 
; getVariable if variables is an object.
;
; @returns value of variable or -1L if not found
; @param variables {in}{required}{type=structure} structure of variables
; @param name {in}{required}{type=string} name of a variable
; @keyword found {out}{optional}{type=boolean} true if name is a variable in 
;          variables structure
;-
function mgfftemplate::_getVariable, variables, name, found=found
  compile_opt strictarr

  error = 0L
  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    found = 0B
    return, -1L
  endif

  case size(variables, /type) of
  8 : begin    ; structure
    ind = where(tag_names(variables) eq strupcase(name), count)
    found = count gt 0
    return, found ? variables.(ind[0]) : -1L
  end
  11 : begin    ; object
    result = variables->getVariable(name, found=found)
    return, result
  end
  else : begin
    found = 0B
    return, -1L
  end
  endcase
end


;+
; Process an [% expression %] directive.
;
; @private
; @param expression {in}{required}{type=string} expression containing variable
;        names to insert value of
; @param variables {in}{required}{type=structure} anonymous structure of
;        variables
; @param output_lun {in}{required}{type=LUN} logical unit number of output 
;        file
; @keyword post_delim {out}{optional}{type=string} delimiter after the 
;          returned token
;-
pro mgfftemplate::_process_variable, expression, variables, $
                                     output_lun, post_delim=post_delim
  compile_opt strictarr, logical_predicate
  on_error, 2

  if (output_lun eq -3L) then return

  ; get full expression
  while (strpos(post_delim, '%]') eq -1) do begin
    expression += ' ' + self.tokenizer->next(post_delim=post_delim)
  endwhile

  ; get values of variables in the expression
  delimiters = '"'' +-*/=^<>|&?:.[]{}()#~,'
  vars = strsplit(expression, delimiters, /extract, count=nvars)
  for i = 0, nvars - 1L do begin
    result = self->_getVariable(variables, vars[i], found=varFound)
    if (varFound) then begin
      (scope_varfetch(vars[i], /enter)) = result
    endif
  endfor

  ; evaluate expression
  statement = 'value = ' + expression
  result = execute(statement, 1, 1)
  if (result) then begin
    self->_printf, output_lun, value, format='(A, $)'
  endif else begin
    line = self.tokenizer->getCurrentLine(number=lineNumber)
    message, 'invalid expression on line ' + strtrim(lineNumber, 2)
  endelse
end


;+
; Process directives or plain text.
;
; @private
; @param variables {in}{required}{type=structure} anonymous structure of
;        variables
; @param output_lun {in}{required}{type=LUN} logical unit number of output 
;        file
; @keyword else_clause {out}{optional}{type=boolean} returns 1 if an 
;          [% ELSE %] directive was just processed
;-
pro mgfftemplate::_process_tokens, variables, output_lun, $
                                   else_clause=else_clause
  compile_opt strictarr
  
  while (~self.tokenizer->done()) do begin
    token = self.tokenizer->next(pre_delim=pre_delim, newline=newline, $
                                 post_delim=post_delim)
    if (newline) then begin
      self->_printf, output_lun, string(10B), format='(A, $)'
    endif
    if (strpos(pre_delim, '[%') ne -1) then begin
      n_spaces = strpos(pre_delim, '[') - strpos(pre_delim, ']') - 1L
      spaces = n_spaces le 0 ? '' : string(bytarr(n_spaces) + 32B)
      self->_printf, output_lun, spaces, format='(A, $)'
      command = strtrim(token, 2)
      case strlowcase(command) of
        'foreach' : begin
          self->_process_foreach, variables, output_lun
        end
        'if' : begin
          self->_process_if, variables, output_lun
        end
        'include' : begin
          self->_process_include, variables, output_lun
        end
        'include_template' : begin
          self->_process_include_template, variables, output_lun
        end
        'insert' : begin
          self->_process_insert, output_lun
        end
        'scope' : begin
            self->_process_scope, ovariables, output_lun 
        end       
        'end' : return
        'else' : begin
          else_clause = 1
          return
        end
        else : begin
          self->_process_variable, command, variables, output_lun, $
            post_delim=post_delim
        end
      endcase
    endif else if (strtrim(pre_delim, 2) eq '%]') then begin
      n_spaces = strlen(pre_delim) - strpos(pre_delim, ']') - 1L
      spaces = n_spaces le 0 ? '' : string(bytarr(n_spaces) + 32B)
      self->_printf, output_lun, spaces + token, format='(A, $)'
    endif else begin
      self->_printf, output_lun, pre_delim + token, format='(A, $)'
    endelse
  endwhile
end


;+
; Process the template with the given variables and send output to the given
; filename.
;
; @param variables {in}{required}{type=structure} either a structure or an 
;        object with getVariable method
; @param output_filename {in}{optional}{type=string} filename of the output 
;        file
; @keyword lun {in}{optional}{type=long} logical unit number of an already 
;          open file to send output to
;-
pro mgfftemplate::process, variables, output_filename, lun=output_lun
  compile_opt strictarr
  on_error, 2
  
  if (n_elements(output_lun) eq 0) then begin
    openw, output_lun, output_filename, /get_lun
    self->_process_tokens, variables, output_lun
    free_lun, output_lun
  endif else begin
    self->_process_tokens, variables, output_lun
  endelse

end


;+
; Reset the template to run again from the start of the template.
;-
pro mgfftemplate::reset
  compile_opt strictarr

  self.tokenizer->reset
end


;+
; Frees resources.
;-
pro mgfftemplate::cleanup
  compile_opt strictarr

  obj_destroy, self.tokenizer
end


;+
; Create a template class for a given template. A template can be used many
; times with different sets of data sent to the process method.
;
; @returns 1 for success, 0 otherwise
; @param template_filename {in}{required}{type=string} filename of the 
;        template file
;-
function mgfftemplate::init, template_filename
  compile_opt strictarr
  on_error, 2
  
  if (n_params() ne 1) then begin
    message, 'template filename parameter required'
  endif
  
  self.templateFilename = template_filename

  self.tokenizer = obj_new('MGffTokenizer', template_filename, $
      pattern='(\[\%)|(\%\])| ')
      
  return, 1
end


;+
; Define instance variables.
;
; @file_comments Allows a text template to be filled in with specific data 
;                from a structure. 
; @field templateFilename filename of the template file
; @field tokenizer MGffTokenizer used to break a template into tokens
; 
; @requires IDL 6.1
; @uses MGffTokenizer class
;
; @categories input/output
;
; @author Michael Galloy
;-
pro mgfftemplate__define
  compile_opt strictarr
  
  define = { MGffTemplate, $
             templateFilename: '', $
             tokenizer: obj_new() $
           }
end
