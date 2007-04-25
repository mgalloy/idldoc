;+
; Wrapper for PRINTF that recognizes LUN=-3 as /dev/null.
;
; @private
; @param lun {in}{required}{type=LUN} logical unit number to direct output to,
;        -3 means /dev/null
; @param data {in}{required}{type=any} data to print
; @keyword _extra {in}{optional}{type=keywords} keywords to PRINTF
;-
pro template_printf, lun, data, _extra=e
    compile_opt idl2

    if (lun eq -3) then return else begin
        if (n_elements(data) gt 1) then begin
            if (size(data, /type) eq 10) then begin
                for i = 0L, n_elements(data) - 1L do begin
                    template_printf, lun, (*data)[i], _extra=e
                endfor
            endif else begin
                printf, lun, transpose(data), _extra=e
            endelse
        endif else begin
            if (size(data, /type) eq 10) then begin
                template_printf, lun, *data, _extra=e
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
; @param otokenizer {in}{required}{type=obj ref} FILE_TOKENIZER object
;        reference to read from template file
; @param variables {in}{required}{type=structure} anonymous structure of
;        variables
; @param output_lun {in}{required}{type=LUN} logical unit number of output file
;-
pro process_if, otokenizer, variables, output_lun
    compile_opt idl2

    expression = ''
    post_delim = ''
    while (strpos(post_delim, '%]') eq -1) do begin
        expression += ' ' + otokenizer->next(post_delim=post_delim)
    endwhile

    tag_names = tag_names(variables)
    for i = 0, n_tags(variables) - 1 do begin
        statement = tag_names[i] + ' = variables.(i)'
        @idldoc_execute
        ;result = execute(tag_names[i] + ' = variables.(i)', 1, 1)
    endfor

    statement = 'condition = ' + expression
    @idldoc_execute
    ;result = execute('condition = ' + expression, 1, 1)
    if (result) then begin
        new_output_lun = condition ? output_lun : -3
    endif else new_output_lun = -3

    process_tokens, otokenizer, variables, new_output_lun, $
        else_clause=else_clause
    if (keyword_set(else_clause)) then begin
        if (result) then begin
            new_output_lun = ~condition ? output_lun : -3
        endif else new_output_lun = output_lun
        process_tokens, otokenizer, variables, new_output_lun
    endif
end


;+
; Process a [% FOREACH %] directive.
;
; @private
; @param otokenizer {in}{required}{type=obj ref} FILE_TOKENIZER object
;        reference to read from template file
; @param variables {in}{required}{type=structure} anonymous structure of
;        variables
; @param output_lun {in}{required}{type=LUN} logical unit number of output file
;-
pro process_foreach, otokenizer, variables, output_lun
    compile_opt idl2
    ;on_error, 2

    loop_variable = otokenizer->next()
    in = otokenizer->next()
    array_variable = otokenizer->next()

    loop_variable = strtrim(loop_variable, 2)
    array_variable = strtrim(array_variable, 2)

    ind = where(tag_names(variables) eq strupcase(array_variable), count)
    if (count eq 0 && process) then begin
        message, 'array variable ' + array_variable + ' for FOR loop not found'
    endif
    array = variables.(ind[0])

    loop_variable_index = n_tags(variables)
    new_variables = create_struct(variables, loop_variable, array[0])
    opos = otokenizer->save_pos()
    for i = 0L, n_elements(array) - 1 do begin
        new_variables.(loop_variable_index) = array[i]
        otokenizer->restore_pos, opos
        process_tokens, otokenizer, new_variables, output_lun
    endfor
    otokenizer->free_pos, opos
end


;+
; Process a [% INCLUDE %] directive.
;
; @private
; @param otokenizer {in}{required}{type=obj ref} FILE_TOKENIZER object
;        reference to read from template file
; @param variables {in}{required}{type=structure} anonymous structure of
;        variables
; @param output_lun {in}{required}{type=LUN} logical unit number of output file
;-
pro process_include, otokenizer, variables, output_lun
    compile_opt idl2
    on_error, 2

    filename_variable = otokenizer->next()
    if (output_lun eq -3) then return
    ind = where(tag_names(variables) eq strupcase(filename_variable), count)
    if (count eq 0) then message, 'variable ' + filename_variable + ' not found'

    filename = variables.(ind[0])

    if (~file_test(filename)) then message, 'filename ' + filename + ' not found'
    openr, insert_lun, filename, /get_lun
    line = ''
    while (~eof(insert_lun)) do begin
        readf, insert_lun, line
        template_printf, output_lun, line
    endwhile
    free_lun, insert_lun
end


;+
; Process a [% INCLUDE_TEMPLATE %] directive.
;
; @private
; @param otokenizer {in}{required}{type=obj ref} FILE_TOKENIZER object
;        reference to read from template file
; @param variables {in}{required}{type=structure} anonymous structure of
;        variables
; @param output_lun {in}{required}{type=LUN} logical unit number of output file
;-
pro process_include_template, otokenizer, variables, output_lun
    compile_opt idl2
    on_error, 2

    filename_variable = otokenizer->next()
    if (output_lun eq -3) then return
    ind = where(tag_names(variables) eq strupcase(filename_variable), count)
    if (count eq 0) then message, 'variable ' + filename_variable + ' not found'

    filename = variables.(ind[0])

    if (~file_test(filename)) then message, 'filename ' + filename + ' not found'

    oinclude = obj_new('template', filename)
    oinclude->process, variables, lun=output_lun
    obj_destroy, oinclude
end


;+
; Process a [% INSERT %] directive.
;
; @private
; @param otokenizer {in}{required}{type=obj ref} FILE_TOKENIZER object
;        reference to read from template file
; @param output_lun {in}{required}{type=LUN} logical unit number of output file
;-
pro process_insert, otokenizer, output_lun
    compile_opt idl2
    on_error, 2

    filename = otokenizer->next()

    if (~file_test(filename)) then message, 'filename ' + filename + ' not found'
    openr, insert_lun, filename, /get_lun
    line = ''
    while (~eof(insert_lun)) do begin
        readf, insert_lun, line
        template_printf, output_lun, line
    endwhile
    free_lun, insert_lun
end


function process_variable_check, variables, name, found=found
    compile_opt strictarr

    error = 0L
    catch, error
    if (error ne 0L) then begin
       catch, /cancel
       found = 0B
       return, -1L
    endif

    ind = where(tag_names(variables) eq strupcase(name), count)
    found = count gt 0
    return, found ? variables.(ind[0]) : -1L
end


;+
; Process a [% var %] directive.
;
; @private
; @param otokenizer {in}{required}{type=object} FILE_TOKENIZER object
; @param expression {in}{required}{type=string} expression containing variable
;        names to insert value of
; @param variables {in}{required}{type=structure} anonymous structure of
;        variables
; @param output_lun {in}{required}{type=LUN} logical unit number of output file
; @keyword post_delim {out}{optional}{type=string} delimiter after the returned token
;-
pro process_variable, otokenizer, expression, variables, output_lun, $
    post_delim=post_delim
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
        template_process_variable_var = process_variable_check(variables, vars[i], found=result)
        statement = vars[i] + ' = template_process_variable_var'
        @idldoc_execute
        ; result = execute(vars[i] + ' = template_process_variable_var', 1, 1)
    endfor

    ; evaluate expression
    statement = 'value = ' + expression
    @idldoc_execute
    ;result = execute('value = ' + expression, 1, 1)
    if (result) then begin
        template_printf, output_lun, value, format='(A, $)'
    endif else begin
        ;message, 'variable ' + variable + ' not found'
    endelse
end


;+
; Process directives or plain text.
;
; @private
; @param otokenizer {in}{required}{type=obj ref} FILE_TOKENIZER object
;        reference to read from template file
; @param variables {in}{required}{type=structure} anonymous structure of
;        variables
; @param output_lun {in}{required}{type=LUN} logical unit number of output file
; @keyword else_clause {out}{optional}{type=boolean} returns 1 if an [% ELSE %]
;          directive was just processed
;-
pro process_tokens, otokenizer, variables, output_lun, else_clause=else_clause
    compile_opt idl2

    while (~otokenizer->done()) do begin
        token = otokenizer->next(pre_delim=pre_delim, newline=newline, post_delim=post_delim)
        if (newline) then template_printf, output_lun, string(10B), format='(A, $)'
        if (strpos(pre_delim, '[%') ne -1) then begin
            n_spaces = strpos(pre_delim, '[') - strpos(pre_delim, ']') - 1L
            spaces = n_spaces le 0 ? '' : string(bytarr(n_spaces) + 32B)
            template_printf, output_lun, spaces, format='(A, $)'
            command = strtrim(token, 2)
            case strlowcase(command) of
            'foreach' : process_foreach, otokenizer, variables, output_lun
            'if' : begin
                    process_if, otokenizer, variables, output_lun
                end
            'include' : process_include, otokenizer, variables, output_lun
            'include_template' : process_include_template, otokenizer, variables, output_lun
            'insert' : process_insert, otokenizer, output_lun
            'end' : return
            'else' : begin
                    else_clause = 1
                    return
                end
            else : process_variable, otokenizer, command, variables, output_lun, $
                post_delim=post_delim
            endcase
        endif else if (strtrim(pre_delim, 2) eq '%]') then begin
            n_spaces = strlen(pre_delim) - strpos(pre_delim, ']') - 1L
            spaces = n_spaces le 0 ? '' : string(bytarr(n_spaces) + 32B)
            template_printf, output_lun, spaces + token, format='(A, $)'
        endif else begin
            template_printf, output_lun, pre_delim + token, format='(A, $)'
        endelse
    endwhile
end


;+
; Process the template with the given variables and send output to the given
; filename.
;
; @param variables {in}{required}{type=structure} anonymous structure
; @param output_filename {in}{optional}{type=string} filename of the output file
; @keyword lun {in}{optional}{type=long} logical unit number of an already open
;          file to send output to
;-
pro template::process, variables, output_filename, lun=output_lun
    compile_opt idl2
    on_error, 2

    otokenizer = obj_new('file_tokenizer', self.template_filename, pattern='(\[\%)|(\%\])| ')
    if (n_elements(output_lun) eq 0) then begin
        openw, output_lun, output_filename, /get_lun
        process_tokens, otokenizer, variables, output_lun
        free_lun, output_lun
    endif else begin
        process_tokens, otokenizer, variables, output_lun
    endelse

    obj_destroy, otokenizer
end


;+
; Frees resources.
;-
pro template::cleanup
    compile_opt idl2

end


;+
; Create a template class for a given template. A template can be used many
; times with different sets of data sent to the process method.
;
; @returns 1 for success, 0 otherwise
; @param template_filename {in}{required}{type=string} filename of the template
;        file
;-
function template::init, template_filename
    compile_opt idl2
    on_error, 2

    if (n_params() ne 1) then begin
        message, 'template filename parameter required'
    endif

    self.template_filename = template_filename

    return, 1
end


;+
; Define instance variables.
;
; @file_comments Allows a text template to be filled in with specific data.
;                The following code will produce a template object and process
;                it with particular data:
; <pre>
; otemplate = obj_new('template', 'T:\\IDL\\lib\\mine\\misc\\template_example.tt')
; otemplate->process, { name:'Mike', cities:['London', 'DC', 'Alb'], $
;     months:['Oct', 'Nov', 'Dec'] }, $
;     'T:\\IDL\\lib\\mine\\misc\\template_example.html'
; obj_destroy, otemplate
; </pre>
;
; The template in this case is:
; <code class="section"> &#60;html&#62;
; &#60;body&#62;
; &#60;h1&#62;[% name %] was here&#60;/h1&#62;
;
; [% IF name eq 'Mike' %]Name was Mike.[% ELSE %]Name was [% name %][% END %]
;
; &#60;h1&#62;Locations&#60;/h1&#62;
; [% FOREACH city IN cities %]
;   [% FOREACH month IN months %]
;     [% city %] in [% month %] &#60;br&#62;
;   [% END %]
; [% END %]
; &#60;/body&#62;
; &#60;/html&#62;</pre>
; This will produce the following output:
; <pre> &#60;html&#62;
; &#60;body&#62;
; &#60;h1&#62;Mike was here&#60;/h1&#62;
;
; Name was Mike.
;
; &#60;h1&#62;Locations&#60;/h1&#62;
;
;
;    London in Oct &#60;br&#62;
;
;    London in Nov &#60;br&#62;
;
;    London in Dec &#60;br&#62;
;
;
;
;    DC in Oct &#60;br&#62;
;
;    DC in Nov &#60;br&#62;
;
;    DC in Dec &#60;br&#62;
;
;
;
;    Alb in Oct &#60;br&#62;
;
;    Alb in Nov &#60;br&#62;
;
;    Alb in Dec &#60;br&#62;
;
;
; &#60;/body&#62;
; &#60;/html&#62; </code>
;
; @field template_filename filename of the template file
; @field template_lun logical unit number of the template file
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
pro template__define
    compile_opt idl2

    define = { template, $
        template_filename:'', $
        template_lun:0L $
        }
end