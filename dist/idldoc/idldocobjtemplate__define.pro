;+
; Implements the getVariable method so that IDLdocParam can be used as an
; IDLdocObjTemplate output object. This routine returns a value of a variable
; given the variable's name as a string. The only variable this object should
; contain is the FOREACH loop index variable.
;
; @private
; @returns any type
; @param name {in}{required}{type=string} name of the variable
; @keyword found {out}{optional}{type=boolean} true if the variable was found
;-
function idldocforobjtemplate::getVariable, name, found=found
    compile_opt strictarr

    found = 0B
    if (size(name, /type) ne 7) then return, -1L

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
pro idldocforobjtemplate::setVariable, value
    compile_opt strictarr

    *self.value = value
end


;+
; Free resources.
;
; @private
;-
pro idldocforobjtemplate::cleanup
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
function idldocforobjtemplate::init, name, value
    compile_opt strictarr

    self.name = name
    self.value = ptr_new(value)

    return, 1L
end


;+
; Define instance variables. This class is used internally by the
; IDLdocObjTemplate class to handle the variable associated with a FOREACH loop.
;
; @private
; @field name name of the FOREACH loop index variable.
; @field value pointer to the value of the FOREACH loop index variable.
;-
pro idldocforobjtemplate__define
    compile_opt strictarr

    define = { idldocforobjtemplate, $
        name : '', $
        value : ptr_new() $
        }
end



;+
; Implements the getVariable method so that IDLdocParam can be used as an
; IDLdocObjTemplate output object. This routine returns a value of a variable
; given the variable's name as a string. This routine checks its subobjects for
; the variable.
;
; @private
; @returns any type
; @param name {in}{required}{type=string} name of the variable
; @keyword found {out}{optional}{type=boolean} true if the variable was found
;-
function idldoccompoundobjtemplate::getVariable, name, found=found
    compile_opt strictarr

    if (size(name, /type) ne 7) then begin
        found = 0B
        return, -1L
    endif

    if (obj_valid(self.template1)) then begin
        val = self.template1->getVariable(name, found=found)
    endif else found = 0B

    if (found) then begin
        return, val
    endif else begin
        if (obj_valid(self.template2)) then begin
            val = self.template2->getVariable(name, found=found)
            return, found ? val : -1L
        endif else begin
            found = 0B
            return, -1L
        endelse
    endelse
end


;+
; Free resources.
;
; @private
;-
pro idldoccompoundobjtemplate::cleanup
    compile_opt strictarr

end


;+
; Initialize instance variables.
;
; @private
; @returns 1L
; @param template1 {in}{required}{type=object} an object which implements
;        the getVariable method
; @param template2 {in}{required}{type=object} an object which implements
;        the getVariable method
;-
function idldoccompoundobjtemplate::init, template1, template2
    compile_opt strictarr

    self.template1 = template1
    self.template2 = template2

    return, 1
end


;+
; Define instance variables. This class is used internally by the
; IDLdocObjTemplate class to handle the variables associated with a SCOPE
; directive.
;
; @private
; @field template1 a subobject implementing the getVariable method
; @field template2 a subobject implementing the getVariable method
;-
pro idldoccompoundobjtemplate__define
    compile_opt strictarr

    define = { idldoccompoundobjtemplate, $
        template1 : obj_new(), $
        template2 : obj_new() $
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
pro idldocobjtemplate_printf, lun, data, _extra=e
    compile_opt strictarr

    if (lun eq -3) then return else begin
        if (n_elements(data) gt 1) then begin
            if (size(data, /type) eq 10) then begin
                for i = 0L, n_elements(data) - 1L do begin
                    idldocobjtemplate_printf, lun, (*data)[i], _extra=e
                endfor
            endif else begin
                printf, lun, transpose(data), _extra=e
            endelse
        endif else begin
            if (size(data, /type) eq 10) then begin
                idldocobjtemplate_printf, lun, *data, _extra=e
            endif else begin
                printf, lun, data, _extra=e
            endelse
        endelse
    endelse
end


;+
; Process an [% IF cond %] directive.
;
; @private
; @param otokenizer {in}{required}{type=obj ref} FILE_TOKENIZER object
;        reference to read from template file
; @param ovariables {in}{required}{type=object} object with getVariable method
; @param output_lun {in}{required}{type=LUN} logical unit number of output file
;-
pro idldocobjtemplate_process_if, otokenizer, ovariables, output_lun
    compile_opt strictarr, logical_predicate

    ; get full expression
    expression = ''
    post_delim = ''
    while (strpos(post_delim, '%]') eq -1) do begin
        expression += ' ' + otokenizer->next(post_delim=post_delim)
    endwhile

    ; get values of variables in the expression
    vars = strsplit(expression, '"'' +-*/=^<>|&?:.[]{}()#~,', /extract, count=nvars)
    for i = 0, nvars - 1L do begin
        statement = vars[i] + ' = ovariables->getVariable(vars[i])'
        @idldoc_execute
        ;result = execute(vars[i] + ' = ovariables->getVariable(vars[i])', 1, 1)
    endfor

    ; evaluate expression
    statement = 'condition = ' + expression
    @idldoc_execute
    ;result = execute('condition = ' + expression, 1, 1)
    if (result) then begin
        new_output_lun = condition ? output_lun : -3
    endif else new_output_lun = -3

    idldocobjtemplate_process_tokens, otokenizer, ovariables, new_output_lun, $
        else_clause=else_clause
    if (keyword_set(else_clause)) then begin
        if (result) then begin
            new_output_lun = ~condition ? output_lun : -3
        endif else new_output_lun = output_lun
        idldocobjtemplate_process_tokens, otokenizer, ovariables, new_output_lun
    endif
end


;+
; Process a [% FOREACH element IN array %] directive.
;
; @private
; @param otokenizer {in}{required}{type=obj ref} FILE_TOKENIZER object
;        reference to read from template file
; @param ovariables {in}{required}{type=object} object with getVariable method
; @param output_lun {in}{required}{type=LUN} logical unit number of output file
;-
pro idldocobjtemplate_process_foreach, otokenizer, ovariables, output_lun
    compile_opt strictarr
    ;on_error, 2

    loop_variable = otokenizer->next()
    in = otokenizer->next()
    array_variable = otokenizer->next()

    loop_variable = strtrim(loop_variable, 2)
    array_variable = strtrim(array_variable, 2)

    array = ovariables->getVariable(array_variable, found=found)
    if (~found && (output_lun ne -3L)) then begin
        message, 'variable ' + array_variable + ' not found', /informational
        array = ''
    endif

    ofor = obj_new('IDLdocForObjTemplate', loop_variable, array[0])
    ocompound = obj_new('IDLdocCompoundObjTemplate', ofor, ovariables)
    opos = otokenizer->save_pos()
    for i = 0L, n_elements(array) - 1L do begin
        ofor->setVariable, array[i]
        otokenizer->restore_pos, opos
        idldocobjtemplate_process_tokens, otokenizer, ocompound, output_lun
    endfor
    obj_destroy, [ofor, ocompound]

    otokenizer->free_pos, opos
end


;+
; Process a [% INCLUDE filename_variable %] directive.
;
; @private
; @param otokenizer {in}{required}{type=obj ref} FILE_TOKENIZER object
;        reference to read from template file
; @param ovariables {in}{required}{type=object} object with getVariable method
; @param output_lun {in}{required}{type=LUN} logical unit number of output file
;-
pro idldocobjtemplate_process_include, otokenizer, ovariables, output_lun
    compile_opt strictarr
    on_error, 2

    filename_variable = otokenizer->next()
    if (output_lun eq -3) then return
    filename = ovariables->getVariable(filename_variable, found=found)
    if (~found) then message, 'variable ' + filename_variable + ' not found'

    if (~file_test(filename)) then message, 'filename ' + filename + ' not found'
    openr, insert_lun, filename, /get_lun
    line = ''
    while (~eof(insert_lun)) do begin
        readf, insert_lun, line
        idldocobjtemplate_printf, output_lun, line
    endwhile
    free_lun, insert_lun
end


;+
; Process a [% INCLUDE_TEMPLATE filename_variable %] directive.
;
; @private
; @param otokenizer {in}{required}{type=obj ref} FILE_TOKENIZER object
;        reference to read from template file
; @param ovariables {in}{required}{type=object} object with getVariable method
; @param output_lun {in}{required}{type=LUN} logical unit number of output file
;-
pro idldocobjtemplate_process_include_template, otokenizer, ovariables, output_lun
    compile_opt idl2
    ;on_error, 2

    filename_variable = otokenizer->next()
    if (output_lun eq -3) then return
    filename = ovariables->getVariable(filename_variable, found=found)

    line = otokenizer->getCurrentLine(number=line_number)

    if (~found) then begin
        message, 'Variable ' + filename_variable + ' not found on line ' $
            + strtrim(line_number, 2) + ': ', /informational, /noname, /continue
        message, line, /noname
    endif

    if (size(filename, /type) ne 7) then begin
        message, 'Variable ' + filename_variable + ' must be a string on line ' $
            + strtrim(line_number, 2) + ': ', /informational, /noname, /continue
        message, line, /noname
    endif

    if (~file_test(filename)) then begin
        message, 'Filename ' + filename + ' not found on line ' $
            + strtrim(line_number, 2) + ': ', /informational, /noname, /continue
        message, line, /noname
    endif

    oinclude = obj_new('idldocobjtemplate', filename)
    oinclude->process, ovariables, lun=output_lun
    obj_destroy, oinclude
end


;+
; Process a [% INSERT filename %] directive.
;
; @private
; @param otokenizer {in}{required}{type=obj ref} FILE_TOKENIZER object
;        reference to read from template file
; @param output_lun {in}{required}{type=LUN} logical unit number of output file
;-
pro idldocobjtemplate_process_insert, otokenizer, output_lun
    compile_opt idl2
    on_error, 2

    filename = otokenizer->next()

    if (~file_test(filename)) then message, 'filename ' + filename + ' not found'
    openr, insert_lun, filename, /get_lun
    line = ''
    while (~eof(insert_lun)) do begin
        readf, insert_lun, line
        idldocobjtemplate_printf, output_lun, line
    endwhile
    free_lun, insert_lun
end


;+
; Process a [% SCOPE ovariables %] directive.
;
; @private
; @param otokenizer {in}{required}{type=obj ref} FILE_TOKENIZER object
;        reference to read from template file
; @param ovariables {in}{required}{type=object} object with getVariable method
; @param output_lun {in}{required}{type=LUN} logical unit number of output file
;-
pro idldocobjtemplate_process_scope, otokenizer, ovariables, output_lun
    compile_opt strictarr

    varname = otokenizer->next()
    ovars = ovariables->getVariable(varname, found=found)

    if (~found) then begin
        line = otokenizer->getCurrentLine(number=line_number)
        message, 'Variable ' + varname + ' not found on line ' $
            + strtrim(line_number, 2) + ': ', /informational, /noname, /continue
        message, line, /noname
    endif

    if (size(ovars, /type) ne 11) then begin
        idldocobjtemplate_process_tokens, otokenizer, ovariables, output_lun
    endif else begin
        ocompound = obj_new('IDLdocCompoundObjTemplate', ovars, ovariables)
        idldocobjtemplate_process_tokens, otokenizer, ocompound, output_lun
        obj_destroy, ocompound
    endelse
end


;+
; Process a [% variable %] directive.
;
; @private
; @todo Make this an expression instead of just a single variable. This could
;       be done just like how IF statements are processed.
;
; @param otokenizer {in}{required}{type=object} file_tokenizer object
; @param expression {in}{required}{type=string} expression containing variable
;        names to insert value of
; @param ovariables {in}{required}{type=object} object with getVariable method
; @param output_lun {in}{required}{type=LUN} logical unit number of output file
; @keyword post_delim {out}{optional}{type=string} string of deliminator after
;          current token returned by the tokenizer
;-
pro idldocobjtemplate_process_variable, otokenizer, expression, ovariables, $
    output_lun, post_delim=post_delim
    compile_opt strictarr, logical_predicate
    on_error, 2

    if (output_lun eq -3L) then return

    ; get full expression
    while (strpos(post_delim, '%]') eq -1) do begin
        expression += ' ' + otokenizer->next(post_delim=post_delim)
    endwhile

    ; get values of variables in the expression
    vars = strsplit(expression, '"'' +-*/=^<>|&?:.[]{}()#~,', /extract, count=nvars)
    for i = 0, nvars - 1L do begin
        statement = vars[i] + ' = ovariables->getVariable(vars[i])'
        @idldoc_execute
        ;result = execute(vars[i] + ' = ovariables->getVariable(vars[i])', 1, 1)
    endfor

    ; evaluate expression
    statement = 'value = ' + expression
    @idldoc_execute
    ;result = execute('value = ' + expression, 1, 1)

    if (result) then begin
        idldocobjtemplate_printf, output_lun, value, format='(A, $)'
    endif else begin
        line = otokenizer->getCurrentLine(number=line_number)
        print, 'Invalid expression "' + expression + '" on line ' $
            + strtrim(line_number, 2) + ': '
        print, line
    endelse
end


;+
; Process directives or plain text.
;
; @private
; @param otokenizer {in}{required}{type=obj ref} FILE_TOKENIZER object
;        reference to read from template file
; @param ovariables {in}{required}{type=object} object with getVariable method
; @param output_lun {in}{required}{type=LUN} logical unit number of output file
; @keyword else_clause {out}{optional}{type=boolean} returns 1 if an [% ELSE %]
;          directive was just processed
;-
pro idldocobjtemplate_process_tokens, otokenizer, ovariables, output_lun, $
    else_clause=else_clause
    compile_opt idl2
;    on_error, 2

    while (~otokenizer->done()) do begin
        token = otokenizer->next(pre_delim=pre_delim, newline=newline, post_delim=post_delim)
        if (newline) then idldocobjtemplate_printf, output_lun, string(10B), format='(A, $)'
        if (strpos(pre_delim, '[%') ne -1) then begin
            n_spaces = strpos(pre_delim, '[') - strpos(pre_delim, ']') - 1L
            spaces = n_spaces le 0 ? '' : string(bytarr(n_spaces) + 32B)
            idldocobjtemplate_printf, output_lun, spaces, format='(A, $)'
            command = strtrim(token, 2)
            case strlowcase(command) of
            'foreach' : idldocobjtemplate_process_foreach, otokenizer, $
                ovariables, output_lun
            'if' : begin
                    idldocobjtemplate_process_if, otokenizer, ovariables, $
                        output_lun
                end
            'include' : idldocobjtemplate_process_include, otokenizer, $
                ovariables, output_lun
            'include_template' : idldocobjtemplate_process_include_template, $
                otokenizer, ovariables, output_lun
            'insert' : idldocobjtemplate_process_insert, otokenizer, $
                output_lun
            'end' : begin
                    return
                end
            'scope' : idldocobjtemplate_process_scope, otokenizer, ovariables, $
                output_lun
            'else' : begin
                    else_clause = 1
                    return
                end
            else : idldocobjtemplate_process_variable, otokenizer, command, $
                ovariables, output_lun, post_delim=post_delim
            endcase
        endif else if (strtrim(pre_delim, 2) eq '%]') then begin
            n_spaces = strlen(pre_delim) - strpos(pre_delim, ']') - 1L
            spaces = n_spaces le 0 ? '' : string(bytarr(n_spaces) + 32B)
            idldocobjtemplate_printf, output_lun, spaces + token, format='(A, $)'
        endif else begin
            idldocobjtemplate_printf, output_lun, pre_delim + token, format='(A, $)'
        endelse
    endwhile
end


;+
; Process the template with the given variables and send output to the given
; filename.
;
; @param ovariables {in}{required}{type=object} object with a getVariable method
; @param output_filename {in}{optional}{type=string} filename of the output file
; @keyword lun {in}{optional}{type=long} logical unit number of an already open
;          file to send output to
;-
pro idldocobjtemplate::process, ovariables, output_filename, lun=output_lun
    compile_opt idl2
;    on_error, 2
;
;    error = 0L
;    catch, error
;    if (error ne 0L) then begin
;        catch, /cancel
;        message, /reissue_last
;        message, 'Aborting output...'
;    endif

    if (n_elements(output_lun) eq 0) then begin
        openw, output_lun, output_filename, /get_lun
        idldocobjtemplate_process_tokens, self.tokenizer, ovariables, output_lun
        free_lun, output_lun
    endif else begin
        idldocobjtemplate_process_tokens, self.tokenizer, ovariables, output_lun
    endelse
end


;+
; Reset the template to run again from the start of the template.
;-
pro idldocobjtemplate::reset
    compile_opt strictarr

    self.tokenizer->reset
end


;+
; Frees resources.
;-
pro idldocobjtemplate::cleanup
    compile_opt idl2

    obj_destroy, self.tokenizer
end


;+
; Create a template class for a given template. A template can be used many
; times with different sets of data sent to the process method.
;
; @returns 1 for success, 0 otherwise
; @param template_filename {in}{required}{type=string} filename of the template
;        file
;-
function idldocobjtemplate::init, template_filename
    compile_opt idl2
    on_error, 2

    if (n_params() ne 1) then begin
        message, 'template filename parameter required'
    endif

    self.tokenizer = obj_new('file_tokenizer', template_filename, $
        pattern='(\[\%)|(\%\])| ')

    return, 1
end


;+
; Define instance variables.
;
; @file_comments Allows a text template to be filled in with specific data
;    contained in an object. The object must implement a function method called
;    "getVariable" which accepts a string positional parameter and keyword
;    FOUND. Given a variable name as a string in the positional parameter, the
;    function should return the variables value. The FOUND keyword returns if a
;    variable is found.
;
; @field tokenizer FILE_TOKENIZER class
;
; @requires IDL 6.0
; @uses file_tokenizer class
;
; @categories input/output
;
; @author Michael Galloy
; @history Created October, 8, 2003
; @copyright RSI, 2003
;-
pro idldocobjtemplate__define
    compile_opt idl2

    define = { idldocobjtemplate, $
        tokenizer : obj_new() $
        }
end