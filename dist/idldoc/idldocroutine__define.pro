;+
; Removes the "at"tagname at the beginning of the lines.
;
; @private
; @returns string array
; @param lines {in}{required}{type=strarr} lines of comment (no ;'s)
; @param tag_name {in}{required}{type=string} tag name to remove
;-
function remove_tag, lines, tag_name
    compile_opt idl2, hidden

    rlines = lines

    pos = strpos(rlines[0], '@' + tag_name)
    rlines[0] = strmid(lines[0], pos + strlen(tag_name) + 1)

    return, rlines
end


;+
; Gives lines back without leading semicolon.
;
; @private
; @returns string array
; @param lines {in}{required}{type=strarr} lines to remove comments of
;-
function remove_semicolon, lines
    compile_opt idl2, hidden

    rlines = lines
    com_re = ';(.*)'
    com_pos = stregex(rlines, com_re, /subexpr)

    for i = 0, n_elements(rlines) - 1 do begin
        rlines[i] = strmid(rlines[i], com_pos[1, i] > 0)
    endfor

    return, rlines
end


;+
; Change a line of text to spaces.
;
; @private
; @param line {in}{out}{required}{type=string} line to change
;-
pro change_to_space, line
    compile_opt idl2, hidden

    chars = strlen(line)
    strput, line, ' ', chars - 1
end


;+
; Returns the lines of text between the special comment-plus and comment-minus
; characters.
;
; @private
; @returns string array of comments
; @param comments {in}{required}{type=strarr} string array of comments
;-
function keep_between_pm, comments
    compile_opt idl2

    start = 0
    endl = 0

    for i = 0, n_elements(comments) - 1 do begin
        if (strmid(comments[i], 0, 2) eq ';+') then begin
            start = i
            break
        endif
    endfor

    for i = start + 1, n_elements(comments) - 1 do begin
        if (strmid(comments[i], 0, 2) eq ';-') then begin
            endl = i
            break
        endif
    endfor

    return, comments[start:endl]
end


;+
; Gets the portion of the file's search string for this routine.
;
; @returns string
;-
function IDLdocRoutine::get_search_string
    compile_opt idl2

    return, strjoin(*self.header, ' ')
end


;+
; Returns 1B if routine has no ";+" comments , 0B otherwise.
;
; @returns 0B or 1B
;-
function IDLdocRoutine::no_header
    compile_opt idl2

    return, self.no_header
end


;+
; Returns comments about the file.
;
; @returns string array of file comments or the empty string if no file
;          comments present
; @keyword empty {out}{optional}{type=boolean} 1 if no file comments, 0
;          otherwse
;-
function IDLdocRoutine::get_file_comments, empty=empty
    compile_opt idl2

    val = self.file_comments->to_array(empty=empty)
    return, empty ? '' : val
end


;+
; Stores the comments in the "comments" field.  Goes through the code stored
; in the "code" field line by line storing the lines until it hits a "PRO"
; or "FUNCTION".
;
; @private
; @keyword line {out}{required}{type=integral} line number of the file to
;          begin processing
; @keyword warnings {in}{out}{type=integral} a named variable to return the
;          number of warning messages
;-
pro IDLdocRoutine::strip_comments, line=line, warnings=warnings
    compile_opt idl2, hidden

    total_lines = n_elements(*self.header)
    line = 0
    self.comments = obj_new('array_list', type=7)

    first_word = (strsplit((*self.header)[line], /extract))[0] ; first word
    hit_end = 0B

    while ((strupcase(first_word) ne 'FUNCTION') and $
        (strupcase(first_word) ne 'PRO')) do begin

        if (strmid(first_word, 0, 2) eq ';-') then hit_end = 1B
        if (not hit_end) then self.comments->add, (*self.header)[line]

        line = line + 1
        if (line ge total_lines) then return

        first_word = (strsplit((*self.header)[line], /extract))[0] ; first word
    endwhile
end


;+
; Stores a parameter name.
;
; @private
; @param param {in}{required}{type=string} parameter name
;-
pro IDLdocRoutine::add_param, param
    compile_opt idl2, hidden

    filename = idldoc_pro_to_html(self.filename)
    filename = char_replace(filename, '\', '/')

    self.system->getProperty, index=index
    index->add_item, $
        name=param, $
        url=filename + '#_' + self.name, $
        description='a parameter from the routine ' + filename

    self.parameter_order->add, param
    self.parameters->put, strlowcase(param), obj_new('IDLdocParam', self, name=param)
end


;+
; Stores a keyword name.
;
; @private
; @param keyword_pair {in}{required}{type=string} a keyword declaration in the
;        form "kword_name=kword_value"; the "kword_name" is stored
;-
pro IDLdocRoutine::add_keyword, keyword_pair
    compile_opt idl2, hidden

    keyword = strtrim((strsplit(keyword_pair, '=', /extract))[0], 2)

    filename = idldoc_pro_to_html(self.filename)
    filename = char_replace(filename, '\', '/')

    self.system->getProperty, index=index
    index->add_item, $
        name=keyword, $
        url=filename + '#_' + self.name, $
        description='a keyword from the routine ' + self.name

    self.keyword_order->add, keyword
    self.keywords->put, strlowcase(keyword), obj_new('IDLdocParam', self, name=keyword)
end


;+
; Handles any comments and attributes in a param or keyword tag.
;
; @private
; @param lines {in}{required}{type=strarr} string array of lines after "at"
;        sign
; @param tag_name {in}{required}{type=string} tag name to process
; @keyword line_number {in}{required}{type=integer} line number of first line
;          of lines parameter, used for error messages
;-
pro IDLdocRoutine::handle_param, lines, tag_name, line_number=line_number
    compile_opt idl2

    pname = strlowcase(tag_name) eq 'param' ? 'Parameter' : 'Keyword'

    lines = remove_tag(lines, tag_name)
    idldoc_escape_slashes, lines
    full_line = strjoin(lines, ' ')

    pos = stregex(full_line, '[_$[:alnum:]]+', len=len)
    if (pos eq -1) then begin
        msg = pname + ' name not found in routine ' + self.name $
            + ' on line ' + strtrim(line_number, 2) + ' of ' $
            + self.filename
        self.system->addWarning, msg
        return
    endif

    param_name = strmid(full_line, pos, len)

    oparam = strlowcase(tag_name) eq 'keyword' $
        ? self.keywords->get(strlowcase(param_name), found=found) $
        : self.parameters->get(strlowcase(param_name), found=found)


    if (not found) then begin
        msg = 'Unknown ' + strlowcase(tag_name) + ' "' + param_name $
            + '" in routine ' + self.name + ' on line ' $
            + strtrim(line_number, 2) + ' of ' + self.filename
        self.system->addWarning, msg
        return
    endif

    current_pos = pos + len
    temp_line = strmid(full_line, pos+len)

    attr_pos = stregex(temp_line, '{([^}]*)}', len=attr_len, /subexpr)
    while (attr_pos[0] ne -1) do begin
        attr = strmid(temp_line, attr_pos[1], attr_len[1])

        ; handle attribute
        if (attr eq '') then begin
            msg = 'Empty attribute in ' + strlowcase(pname) + param_name $
                + ' in routine ' + self.name + ' on line ' $
                + strtrim(line_number, 2) + ' of ' + self.filename
            self.system->addWarning, msg
        endif else begin
            oparam->handle_attr, attr
        endelse

        incr = attr_pos[0] + attr_len[0]
        current_pos = current_pos + incr
        temp_line = strmid(temp_line, incr)
        attr_pos = stregex(temp_line, '{([^}]*)}', len=attr_len, /subexpr)
    endwhile

    lines_length = strlen(lines) + 1  ; +1 for the spaces added in STRJOIN
    clines_length = total(lines_length, /cumulative)
    ind = where(clines_length ge current_pos, count)
    comment_line = ind[0]
    comment_pos = current_pos - (clines_length[ind[0]] - lines_length[ind[0]])

    comments = lines[comment_line:*]
    comments[0] = strmid(comments[0], comment_pos)

    oparam->add_comments, comments
end


;+
; Stores any information needed when a given tag is processed.
;
; @private
; @param lines {in}{required}{type=strarr} string array of lines after "at"
;        sign
; @param tag_name {in}{required}{type=string} tag name to process
; @keyword warnings {in}{out}{type=integral} a named variable to return the
;          number of warning messages
; @keyword line_number {in}{required}{type=integer} line number of first line
;          of lines parameter, used for error messages
;-
pro IDLdocRoutine::handle_tag, lines, tag_name, warnings=warnings, $
    line_number=line_number
    compile_opt idl2, hidden

    lines = remove_semicolon(lines)

    case strlowcase(tag_name) of
    'abstract' : begin
            self.abstract = 1
        end
    'author' : begin
            self.attributes = 1B
            lines = remove_tag(lines, tag_name)
            idldoc_escape_slashes, lines
            self.author->add, lines
        end
    'bugs' : begin
            self.attributes = 1B
            lines = remove_tag(lines, tag_name)
            idldoc_escape_slashes, lines
            self.bugs->add, lines
        end
    'categories' : begin
            self.attributes = 1B
            lines = remove_tag(lines, tag_name)
            idldoc_escape_slashes, lines
            self.categories->add, lines

            tags = strsplit(strjoin(lines), ',', /regex, /extract, count=ntags)
            self.system->getProperty, taglisting=taglisting
            for i = 0, ntags - 1L do taglisting->addTag, strtrim(tags[i], 2), self
        end
    'copyright' : begin
            self.attributes = 1B
            lines = remove_tag(lines, tag_name)
            idldoc_escape_slashes, lines
            self.copyright->add, lines
        end
    'customer_id' : begin
            self.attributes = 1B
            lines = remove_tag(lines, tag_name)
            idldoc_escape_slashes, lines
            self.customer_id->add, lines
        end
    'examples' : begin
            self.attributes = 1B
            lines = remove_tag(lines, tag_name)
            idldoc_escape_slashes, lines
            self.examples->add, lines
        end
    'field' : begin
            lines = remove_tag(lines, tag_name)
            idldoc_escape_slashes, lines
            self.file->add_field, lines
        end
    'file_comments' : begin
            self.attributes = 1B
            lines = remove_tag(lines, tag_name)
            idldoc_escape_slashes, lines
            self.file_comments->add, lines
        end
    'hidden_file' : begin
            self.hidden_file = 1
        end
    'hidden' : begin
            self.hidden = 1
        end
    'history' : begin
            self.attributes = 1B
            lines = remove_tag(lines, tag_name)
            idldoc_escape_slashes, lines
            self.history->add, lines
        end
    'inherits' : begin
            self.attributes = 1B
            lines = remove_tag(lines, tag_name)
            idldoc_escape_slashes, lines
            self.inherits->add, lines
        end
    'keyword' : begin
            self->handle_param, lines, tag_name, line_number=line_number
        end
    'obsolete' : begin
            self.obsolete = 1
            self.attributes = 1B
            lines = remove_tag(lines, tag_name)
            idldoc_escape_slashes, lines
            self.obsolete_comments->add, lines
        end
    'param' : begin
            self->handle_param, lines, tag_name, line_number=line_number
        end
    'pre' : begin
            self.attributes = 1B
            lines = remove_tag(lines, tag_name)
            idldoc_escape_slashes, lines
            self.pre->add, lines
        end
    'post' : begin
            self.attributes = 1B
            lines = remove_tag(lines, tag_name)
            idldoc_escape_slashes, lines
            self.post->add, lines
        end
    'private' : begin
            self.private = 1
            self.system->getProperty, user=user
            if (user) then self.hidden = 1
        end
    'private_file' : begin
            self.private_file = 1
            self.system->getProperty, user=user
            if (user) then self.hidden_file = 1
        end
    'returns' : begin
            self.attributes = 1B
            lines = remove_tag(lines, tag_name)
            idldoc_escape_slashes, lines
            self.returns->add, lines
        end
    'restrictions' : begin
            self.attributes = 1B
            lines = remove_tag(lines, tag_name)
            idldoc_escape_slashes, lines
            self.restrictions->add, lines
        end
    'requires' : begin
            self.attributes = 1B
            lines = remove_tag(lines, tag_name)
            idldoc_escape_slashes, lines
            self.requires->add, lines
        end
    'todo' : begin
            self.attributes = 1B
            lines = remove_tag(lines, tag_name)
            idldoc_escape_slashes, lines
            self.todo->add, lines
        end
    'uses' : begin
            self.attributes = 1B
            lines = remove_tag(lines, tag_name)
            idldoc_escape_slashes, lines
            self.uses->add, lines
        end
    'version' : begin
            self.attributes = 1B
            lines = remove_tag(lines, tag_name)
            idldoc_escape_slashes, lines
            self.version->add, lines
        end
    else : begin
            msg = 'Unknown tag @' + tag_name + ' occurred on line ' $
                + strtrim(line_number, 2) + ' of ' + self.filename
            self.system->addWarning, msg
        end
    endcase
end


;+
; Parses the comments and splits the tags to be parsed by the handle_tag
; method.
;
; @private
; @keyword warnings {in}{out}{type=integral} a named variable to return the
;          number of warning messages
;-
pro IDLdocRoutine::parse_comments, warnings=warnings
    compile_opt idl2, hidden

    ; Get comments as array
    comments = self.comments->to_array(empty=empty)
    if (empty) then return

    ; Find "at" signs with regular expression
    tag_re = '[^\]@([_[:alpha:]]+)'
    at_signs = stregex(comments, tag_re, len=at_signs_len, /subexp)
    at_signs_ind = where(at_signs[0, *] ne -1, n_at_signs)

    self.comments->reset

    if (n_at_signs ne 0) then begin
        first_at = at_signs_ind[0]
        if (first_at ne 0) then begin
            proc_comments = comments[0:(first_at - 1)]
        endif
    endif else begin
        last_line = n_elements(comments) - 1 > 0
        proc_comments = comments[0:last_line]
    endelse

    ; Remove semi-colons from proc_comments and put back in self.comments
    if (n_elements(proc_comments) ne 0) then begin
        pln_com = stregex(proc_comments, ';(.*)', /subexpr, len=pln_com_len)
        for i = 0, n_elements(proc_comments) - 1 do begin
            if (pln_com[0, i] ne -1) then begin
                proc_comments[i] $
                    = strmid(proc_comments[i], pln_com[1, i], pln_com_len[1, i])
            endif else proc_comments[i] = ''
        endfor

        plus_pos = strpos(proc_comments[0], '+')
        proc_comments[0] = strmid(proc_comments[0], plus_pos + 1)
        self.comments->add, proc_comments
    endif

    ; Handle tags
    if (n_at_signs eq 0) then return

    tags = strarr(n_at_signs)
    for i = 0, n_at_signs - 1 do begin
        tags[i] = strmid(comments[at_signs_ind[i]], $
            at_signs[1, at_signs_ind[i]], $
            at_signs_len[1, at_signs_ind[i]])
    endfor

    for i = 0, n_at_signs - 1 do begin
        next = i eq n_at_signs - 1 $
            ? n_elements(comments) - 1 $
            : at_signs_ind[i+1] - 1
        lines = comments[at_signs_ind[i]:next]
        self->handle_tag, lines, tags[i], warnings=warnings, $
            line_number=at_signs_ind[i] + self.start_line_number
    endfor
end


;+
; Finds and stores the type, name, parameters, and keywords of a routine.
; Checks the line after the header ends (only the line which begins with
; a "PRO" or a "FUNCTION").
;
; @private
; @keyword line {in}{required}{type=integral} line number of the start of
;          the header
; @keyword warnings {in}{out}{type=integral} a named variable to return the
;          number of warning messages
;-
pro IDLdocRoutine::strip_header, line=line, warnings=warnings
    compile_opt idl2, hidden

    first_word = (strsplit((*self.header)[line], /extract))[0]

    if ((strupcase(first_word) ne 'FUNCTION') and $
        (strupcase(first_word) ne 'PRO')) then $
        return

    self.type = strlowcase(first_word)
    if (self.type eq 'pro') then self.type = 'procedure'

    text = (*self.header)[line]
    text = strtrim(remove_comment(text), 2)
    last_char = last_char(text)
    first_char = strmid(text, 0, 1)

    while ((last_char eq '$') or (first_char eq ';')) do begin
        line = line + 1
        new_text = (*self.header)[line]
        change_to_space, text
        text = text + strtrim(remove_comment(new_text), 2)
        last_char = last_char(text)
        first_char = strmid(strtrim(new_text, 1), 0, 1)
    endwhile

    tokens = strsplit(text, ',', /extract)
    tokens = strtrim(tokens, 2)

    self.name = (strsplit(tokens[0], /extract))[1]

    self.method = strpos(self.name, '::') ne -1

    if (n_elements(tokens) le 1) then return

    for i = 1, n_elements(tokens) - 1 do begin
        eq_pos = strpos(tokens[i], '=')
        if (eq_pos eq -1) then begin
            self->add_param, tokens[i]
        endif else begin
            self->add_keyword, tokens[i]
        endelse
    endfor
end


;+
; Checks to make sure there are visible (non-private) keywords.
;
; @returns 0 if the routine has no visible keywords, 1 otherwise
;-
function IDLdocRoutine::hasVisibleKeywords
    compile_opt idl2

    return, self.nvisiblekeywords gt 0
end


;+
; Checks to make sure there are visible (non-private) parameters.
;
; @returns 0 if the routine has no visible positional parameters, 1 otherwise
;-
function IDLdocRoutine::hasVisibleParameters
    compile_opt idl2

    return, self.nvisibleparameters gt 0
end


;+
; Computes McCabe complexities inside an error handler so McCabe crashes don't
; crash IDLdoc.
;
; @private
;-
pro IDLdocRoutine::compute_mccabe_complexities
    compile_opt strictarr

    error_no = 0
    catch, error_no
    if (error_no ne 0) then begin
        catch, /cancel
        return
    endif

    self.mccabe_cyclomatic_complexity = mccabe_cyclomatic_complexity(*self.code)
    self.mccabe_essential_complexity = mccabe_essential_complexity(*self.code)
    self.mccabe_module_design_complexity = mccabe_module_design_complexity(*self.code)
end


;+
; Do computations involving the text of the code before the output starts.
;-
pro IDLdocRoutine::process_code
    compile_opt idl2

    common_blocks = find_common(*self.code, count=count)
    if (count gt 0) then begin
        self.common_blocks->add, common_blocks
        self.attributes = 1B
    endif

    self.system->getProperty, statistics=statistics
    if (statistics) then begin
        self->compute_mccabe_complexities
    endif

    if ((self.attributes eq 1) or (not self.comments->is_empty())) then begin
        self.documented = 1L
    endif

    self.system->getProperty, user=user

    nTotalParams = 0L
    delim = self.type eq 'function' ? '' : ', '
    oparamList = obj_new('array_list', type=11)
    iter = self.parameter_order->iterator()
    while (~iter->done()) do begin
        param_name = iter->next()
        oparam = self.parameters->get(strlowcase(param_name))
        oparam->get_attr, private=private, hidden=hidden
        if (~(hidden || (private && user))) then begin
            oparamList->add, oparam
            if (++nTotalParams eq 1) then oparam->setFirst
        endif
    endwhile
    self.nvisibleparameters = oparamList->size()
    *self.shown_parameters = oparamList->to_array()
    obj_destroy, [iter, oparamList]

    okeywordList = obj_new('array_list', type=11)
    iter = self.keyword_order->iterator()
    while (~iter->done()) do begin
        keyword_name = iter->next()
        okeyword = self.keywords->get(strlowcase(keyword_name))
        okeyword->get_attr, private=private, hidden=hidden
        if (~(hidden || (private && user))) then begin
            okeywordList->add, okeyword
            if (++nTotalParams eq 1) then okeyword->setFirst
        endif
    endwhile
    self.nvisiblekeywords = okeywordList->size()
    *self.shown_keywords = okeywordList->to_array()
    obj_destroy, [iter, okeywordList]

    if (not self.comments->is_empty()) then begin
        if (self.type eq 'function' and self.returns->is_empty()) then begin
            goto, not_fully_documented
        endif

        ; check for every param having a comment
        params = self.parameter_order->to_array(empty=no_params)
        keywords = self.keyword_order->to_array(empty=no_keywords)

        if (not no_params) then begin
            for i = 0, n_elements(params) - 1 do begin
                oparam = self.parameters->get(strlowcase(params[i]), found=found)
                if (not found) then goto, not_fully_documented
                comments = oparam->get_comments(empty=no_comments)
                if (no_comments) then goto, not_fully_documented
            endfor
        endif

        if (not no_keywords) then begin
            for i = 0, n_elements(keywords) - 1 do begin
                okeyword = self.keywords->get(strlowcase(keywords[i]), found=found)
                if (not found) then goto, not_fully_documented
                comments = okeyword->get_comments(empty=no_comments)
                if (no_comments) then goto, not_fully_documented
            endfor
        endif

        self.documented = 2L
    endif

    not_fully_documented :

    ptr_free, self.code, self.header
end


;+
; Returns the McCabe Cyclomatic Complexity for the routine.
;
; @returns long
; @keyword essential {out}{optional}{type=long} set to a named variable to get
;          the McCabe Essential Complexity
; @keyword module_design {out}{optional}{type=long} set to a named variable to
;          get the McCabe Module Complexity
;-
function IDLdocRoutine::get_mccabe_complexity, essential=essential, module_design=module_design
    compile_opt idl2

    essential = self.mccabe_essential_complexity
    module = self.mccabe_module_design_complexity
    return, self.mccabe_cyclomatic_complexity
end


;+
; Returns any todo items for the routine.
;
; @returns strarr or -1L if no todo items present
; @keyword present {out}{optional}{type=boolean} 1 if todo items present, 0 otherwise
;-
function IDLdocRoutine::get_todo, present=present
    compile_opt idl2

    present = self.todo->is_empty() eq 0
    if (present) then begin
        return, self.todo->to_array()
    endif else begin
        return, -1L
    endelse
end


;+
; Returns any bugs for the routine.
;
; @returns strarr or -1L if no bugs present
; @keyword present {out}{optional}{type=boolean} 1 if bugs present, 0 otherwise
;-
function IDLdocRoutine::get_bugs, present=present
    compile_opt idl2

    present = self.bugs->is_empty() eq 0
    if (present) then begin
        return, self.bugs->to_array()
    endif else begin
        return, -1L
    endelse
end



;+
; Implements the getVariable method so that IDLdocParam can be used as an
; IDLdocObjTemplate output object. This routine returns a value of a variable
; given the variable's name as a string.
;
; @private
; @returns any type
; @param name {in}{required}{type=string} name of the variable
; @keyword found {out}{optional}{type=boolean} true if the variable was found
;-
function IDLdocRoutine::getVariable, name, found=found
    compile_opt strictarr

    if (size(name, /type) ne 7) then begin
        found = 0B
        return, -1L
    endif

    found = 1B
    case strlowcase(name) of
    'routine_name' : return, self.name
    'routine_url' : begin
            self->getProperty, local_url=url
            return, url
        end
    'is_func' : return, self.type eq 'function'
    'obsolete' : return, self.obsolete
    'abstract' : return, self.abstract
    'private' : return, self.private
    'categories_present' : return, ~self.categories->is_empty()
    'categories' : begin
            categories = self.categories->to_array()
            return, categories
        end
    'customer_id_present' : return, ~self.customer_id->is_empty()
    'customer_id' : begin
            customer_id = self.customer_id->to_array()
            return, customer_id
        end
    'ntotalparams' :
    'nparams' : return, self.nvisibleparameters
    'params' : return, *self.shown_parameters
    'nkeywords' : return, self.nvisiblekeywords
    'keywords' : return, *self.shown_keywords
    'short_comment' : begin
            self->getProperty, first_line=first_line
            return, first_line
        end
    'statistics' : begin
            self.system->getProperty, statistics=statistics
            return, statistics
        end
    'mccabe_cyclic' : return, self.mccabe_cyclomatic_complexity
    'mccabe_essential' : return, self.mccabe_essential_complexity
    'mccabe_mod_design' : return, self.mccabe_module_design_complexity
    'routine_comments' : begin
            comments = self.comments->to_array(empty=empty)
            return, empty ? '' : comments
        end
    'preformat' : return, self.preformat
    'returns_present' : return, ~self.returns->is_empty()
    'returns' : return, self.returns->to_array()
    'examples_present' : return, ~self.examples->is_empty()
    'examples' : return, self.examples->to_array()
    'author_present' : return, ~self.author->is_empty()
    'author' : return, self.author->to_array()
    'version_present' : return, ~self.version->is_empty()
    'version' : return, self.version->to_array()
    'history_present' : return, ~self.history->is_empty()
    'history' : return, self.history->to_array()
    'copyright_present' : return, ~self.copyright->is_empty()
    'copyright' : return, self.copyright->to_array()
    'obsolete_comments_present' : return, ~self.obsolete_comments->is_empty()
    'obsolete_comments' : return, self.obsolete_comments->to_array()
    'bugs_present' : return, ~self.bugs->is_empty()
    'bugs' : return, self.bugs->to_array()
    'todo_present' : return, ~self.todo->is_empty()
    'todo' : return, self.todo->to_array()
    'restrictions_present' : return, ~self.restrictions->is_empty()
    'restrictions' : return, self.restrictions->to_array()
    'inherits_present' : return, ~self.inherits->is_empty()
    'inherits' : return, self.inherits->to_array()
    'requires_present' : return, ~self.requires->is_empty()
    'requires' : return, self.requires->to_array()
    'uses_present' : return, ~self.uses->is_empty()
    'uses' : return, self.uses->to_array()
    'common_blocks_present' : return, ~self.common_blocks->is_empty()
    'common_blocks' : return, self.common_blocks->to_array()
    'precondition_present' : return, ~self.pre->is_empty()
    'precondition' : return, self.pre->to_array()
    'postcondition_present' : return, ~self.post->is_empty()
    'postcondition' : return, self.post->to_array()
    else : begin
            found = 0B
            return, -1L
        end
    endcase
end


;+
; Gets complete routine information.
;
; @returns structure
;-
function IDLdocRoutine::get_full_info
    compile_opt strictarr

    rhdata = self->get_header_info()
    comments = self.comments->to_array(empty=empty)
    if (empty) then comments = ''

    self.system->getProperty, statistics=statistics
    mccabe_cyclic = 0L
    mccabe_essential = 0L
    mccabe_mod_design = 0L
    if (statistics) then begin
        mccabe_cyclic = self->get_mccabe_complexity(essential=mccabe_essential, $
            module_design=mccabe_mod_design)
    endif

    rfdata = { $
        statistics : statistics, $
        mccabe_cyclic : mccabe_cyclic, $
        mccabe_essential : mccabe_essential, $
        mccabe_mod_design : mccabe_mod_design, $
        comments : comments, $
        preformat : self.preformat, $
        returns : self.returns->to_array(empty=returns_empty), $
        returns_present : ~returns_empty, $
        examples : self.examples->to_array(empty=examples_empty), $
        examples_present : ~examples_empty, $
        author : self.author->to_array(empty=author_empty), $
        author_present : ~author_empty, $
        version : self.version->to_array(empty=version_empty), $
        version_present : ~version_empty, $
        history : self.history->to_array(empty=history_empty), $
        history_present : ~history_empty, $
        copyright : self.copyright->to_array(empty=copyright_empty), $
        copyright_present : ~copyright_empty, $
        obsolete_comments : self.obsolete_comments->to_array(empty=obsolete_comments_empty), $
        obsolete_comments_present : ~obsolete_comments_empty, $
        bugs : self.bugs->to_array(empty=bugs_empty), $
        bugs_present : ~bugs_empty, $
        todo : self.todo->to_array(empty=todo_empty), $
        todo_present : ~todo_empty, $
        restrictions : self.restrictions->to_array(empty=restrictions_empty), $
        restrictions_present : ~restrictions_empty, $
        inherits : self.inherits->to_array(empty=inherits_empty), $
        inherits_present : ~inherits_empty, $
        requires : self.requires->to_array(empty=requires_empty), $
        requires_present : ~requires_empty, $
        uses : self.uses->to_array(empty=uses_empty), $
        uses_present : ~uses_empty, $
        common_blocks : self.common_blocks->to_array(empty=common_blocks_empty), $
        common_blocks_present : ~common_blocks_empty, $
        precondition : self.pre->to_array(empty=precondition_empty), $
        precondition_present : ~precondition_empty, $
        postcondition : self.post->to_array(empty=postcondition_empty), $
        postcondition_present : ~postcondition_empty $
        }
    rfdata = create_struct(rhdata, rfdata)

    return, rfdata
end


;+
; Gets basic routine information.
;
; @returns structure
;-
function IDLdocRoutine::get_header_info
    compile_opt strictarr

    self.system->getProperty, user=user
    self->getProperty, first_line=first_line

    delim = self.type eq 'function' ? '' : ', '
    oparamList = obj_new('array_list', example={ name:'', optional:0B, delim:'' })
    iter = self.parameter_order->iterator()
    while (~iter->done()) do begin
        param_name = iter->next()
        oparam = self.parameters->get(strlowcase(param_name))
        oparam->get_attr, optional=optional, private=private, hidden=hidden
        if (~(hidden || (private && user))) then begin
            oparamList->add, { name:param_name, optional:optional, delim:delim }
            delim = ', '
        endif
    endwhile
    nparams = oparamList->size()
    params = oparamList->to_array()
    obj_destroy, [iter, oparamList]

    okeywordList = obj_new('array_list', $
        example={ name:'', boolean:0B, optional:0B, out:0B, type:'', delim:'' })
    iter = self.keyword_order->iterator()
    while (~iter->done()) do begin
        keyword_name = iter->next()
        okeyword = self.keywords->get(strlowcase(keyword_name))
        okeyword->get_attr, optional=optional, private=private, $
            hidden=hidden, out=out, type=type
        type = out ? 'named variable' : (type eq '' ? keyword_name : type)
        if (~(hidden || (private && user))) then begin
            okeywordList->add, { name:keyword_name, boolean:type eq 'boolean', $
                optional:optional, out:out, type:type, delim:delim }
            delim = ', '
        endif
    endwhile
    nkeywords = okeywordList->size()
    keywords = okeywordList->to_array()
    obj_destroy, [iter, okeywordList]

    categories = self.categories->to_array(empty=categories_empty)
    self->getProperty, local_url=url

    return, { $
        name : self.name, $
        url : url, $
        is_func : self.type eq 'function', $
        obsolete : self.obsolete, $
        abstract : self.abstract, $
        private : self.private, $
        categories : categories, $
        categories_present : ~categories_empty, $
        ntotalparams : nparams + nkeywords, $
        nparams : nparams, $
        params : params, $
        nkeywords : nkeywords, $
        keywords : keywords, $
        short_comment : first_line $
        }
end


;+
; Returns properties of the routine through keywords.
;
; @keyword first_line {out}{optional}{type=string array} the first line (up to
;          the first period) of the comment for the routine; the first line is
;          intended to be a very brief description of the purpose of the
;          routine
; @keyword method {out}{optional}{type=boolean} 1 if routine is a method; 0
;          otherwise
; @keyword name {out}{optional}{type=string} name of the routine (including
;          "classname::" if the routine is a method
; @keyword type {out}{optional}{type=string} the string "function" or
;          "procedure"
; @keyword url {out}{optional}{type=string} url to routine relative to root
; @keyword local_url {out}{optional}{type=string} url with in the file only;
;          starts with #
; @keyword documented {out}{optional}{type=integer} code for how documented the
;          routine is: 0 => not documented, 1 => partially documented,
;          2 => fully documented
; @keyword filename {out}{optional}{type=string} filename the routine is found in
; @keyword private_routine {out}{optional}{type=boolean} true if routine is private
; @keyword private_file {out}{optional}{type=boolean} true if the routine is in
;          a file that is private
; @keyword hidden_routine {out}{optional}{type=boolean} true if routine is hidden
; @keyword hidden_file {out}{optional}{type=boolean} true if routine is in a file
;          that is hidden
; @keyword obsolete {out}{optional}{type=boolean} true if routine is marked
;          obsolete
; @keyword abstract {out}{optional}{type=boolean} true if routine is marked as
;          abstract
;-
pro IDLdocRoutine::getProperty, first_line=first_line, method=method, $
    name=name, type=type, url=url, local_url=local_url, documented=documented, $
    filename=filename, private_routine=private_routine, $
    private_file=private_file, hidden_routine=hidden_routine, $
    hidden_file=hidden_file, obsolete=obsolete, abstract=abstract

    compile_opt idl2

    first_line = ''
    comments = self.comments->to_array(empty=empty)
    if (not empty) then begin
        comments = strjoin(comments, ' ')
        dot_pos = strpos(comments, '.')
        if (dot_pos eq -1) then begin
            first_line = comments
        endif else begin
            first_line = strmid(comments, 0, dot_pos + 1)
        endelse
    endif

    method = self.method
    name = self.name
    type = self.type
    filename = self.filename
    private_routine = self.private
    private_file = self.private_file
    hidden_routine = self.hidden
    hidden_file = self.hidden_file
    obsolete = self.obsolete
    abstract = self.abstract

    if (arg_present(url) || arg_present(local_url)) then begin
        self.file->getProperty, url=file_url
        ; ASCII 58 (:) -> ASCII 95 (_)
        bname = byte(self.name)
        ;ind = where(bname eq 58B, count)
        ;if (count gt 0) then bname[ind] = 95B
        local_url = '#_' + string(bname)
        url = file_url + local_url
    endif

    documented = self.documented
end


;+
; Free resources.
;
; @private
;-
pro IDLdocRoutine::cleanup
    compile_opt idl2

    obj_destroy, [ $
        self.author, $
        self.bugs, $
        self.categories, $
        self.common_blocks, $
        self.copyright, $
        self.customer_id, $
        self.obsolete_comments, $
        self.pre, $
        self.post, $
        self.requires, $
        self.inherits, $
        self.todo, $
        self.uses, $
        self.version, $
        self.examples, $
        self.file_comments, $
        self.history, $
        self.returns, $
        self.restrictions, $
        self.comments, $
        self.parameter_order, $
        self.keyword_order $
        ]

    params = self.parameters->values(nparams)
    if (nparams gt 0) then obj_destroy, params
    obj_destroy, self.parameters

    keywords = self.keywords->values(nkeywords)
    if (nkeywords gt 0) then obj_destroy, keywords
    obj_destroy, self.keywords

    ;ptr_free, self.code, self.header
    ptr_free, self.shown_parameters, self.shown_keywords
end


;+
; Create a IDLdcRoutine.
;
; @returns 1 if successful
; @param header {in}{required}{type=string array} string array of the lines of
;        the code header to process
; @param code {in}{required}{type=string array} string array of the lines of
;        the code to process
; @keyword filename {in}{type=string} filename of file that contains the
;          routine
; @keyword file_ref {in}{required}{type=object} IDLdocFile object reference of the
;          file containing this routine
; @keyword warnings {out}{type=integral} a named variable to return the number
;          of warning messages
; @keyword start_line_number {in}{required}{type=integer} line number in the
;          file where the routine comments start
; @keyword system {in}{required}{type=object} IDLdocSystem object reference
;-
function IDLdocRoutine::init, header, code, filename=filename, $
    file_ref=file_ref, warnings=warnings, $
    start_line_number=start_line_number, system=system
    compile_opt idl2

    self.system = system

    self.documented = 0L

    self.author = obj_new('array_list', type=7)
    self.bugs = obj_new('array_list', type=7)
    self.categories = obj_new('array_list', type=7)
    self.copyright = obj_new('array_list', type=7)
    self.examples = obj_new('array_list', type=7)
    self.history = obj_new('array_list', type=7)
    self.obsolete_comments = obj_new('array_list', type=7)
    self.pre = obj_new('array_list', type=7)
    self.post = obj_new('array_list', type=7)
    self.requires = obj_new('array_list', type=7)
    self.inherits = obj_new('array_list', type=7)
    self.returns = obj_new('array_list', type=7)
    self.restrictions = obj_new('array_list', type=7)
    self.todo = obj_new('array_list', type=7)
    self.uses = obj_new('array_list', type=7)
    self.version = obj_new('array_list', type=7)

    self.preformat = keyword_set(preformat)

    self.file_comments = obj_new('array_list', type=7)

    self.start_line_number = start_line_number

    self.file = file_ref
    self.filename = filename

    self.code = ptr_new(code)
    self.header = ptr_new(header)

    self.parameters = obj_new('hash_table', key_type=7, value_type=11, $
        array_size=5)
    self.keywords = obj_new('hash_table', key_type=7, value_type=11, $
        array_size=5)
    self.parameter_order = obj_new('array_list', type=7)
    self.keyword_order = obj_new('array_list', type=7)
    self.shown_parameters = ptr_new(/allocate_heap)
    self.shown_keywords = ptr_new(/allocate_heap)

    self.common_blocks = obj_new('array_list', type=7, block_size=5)
    self.customer_id = obj_new('array_list', type=7, block_size=5)

    self->strip_comments, line=line, warnings=warnings
    if (self.comments->is_empty()) then self.no_header = 1B
    self->strip_header, line=line, warnings=warnings
    self->parse_comments, warnings=warnings
    self->process_code

    filename = idldoc_pro_to_html(self.filename)
    filename = char_replace(filename, '\', '/')

    if (self.method) then begin
        colon_pos = strpos(self.name, '::')
        class_name = strmid(self.name, 0, colon_pos)
        short_method_name = strmid(self.name, colon_pos+2)
    endif

    self.system->getProperty, index=index
    index->add_item, $
        name=(self.method ? short_method_name : self.name), $
        url=filename + '#_' + self.name, $
        description='a ' $
            + (self.method $
                ? 'method (' + self.type + ') of ' + class_name $
                : self.type) $
            + ' from the file ' + file_basename(self.filename)

    return, 1
end


;+
; Instance variable declaration.
;
; @file_comments IDLdcRoutine represents a single IDL routine and its comments.
;
; @field code
; @field start_line_number line number of the file where the routine starts
; @field filename
; @field name
; @field type
; @field attributes 1B if has any "attributes", 0B otherwise
; @field abstract 1B if abstract, 0B otherwise
; @field author ARRAY_LIST object of strings for comments
; @field bugs ARRAY_LIST object of strings for comments
; @field copyright ARRAY_LIST object of strings for comments
; @field documented 0 for not documented, 1 for partially documented, 2 for
;        fully documented
; @field examples ARRAY_LIST object of strings for comments
; @field file_comments ARRAY_LIST object of strings for comments
; @field hidden 1B if hidden, 0B otherwise
; @field hidden_file 1B if hidden_file, 0B otherwise
; @field history ARRAY_LIST object of strings for comments
; @field method 1B if a method, 0B otherwise
; @field obsolete 1B if obsolete, 0B otherwise
; @field obsolete_comments ARRAY_LIST object of strings for comments
; @field private
; @field private_file
; @field pre ARRAY_LIST object of strings for comments
; @field post ARRAY_LIST object of strings for comments
; @field requires ARRAY_LIST object of strings for comments
; @field restrictions ARRAY_LIST object for comments
; @field returns ARRAY_LIST object of strings for comments
; @field inherits ARRAY_LIST object of strings for comments
; @field uses ARRAY_LIST object of strings for comments
; @field version ARRAY_LIST object of strings for comments
; @field comments
; @field parameters HASH_TABLE object of strlowcase(name) -> IDLdocParam
; @field parameter_order VECTOR of strings (actual case)
; @field keywords HASH_TABLE object of strlowcase(name) -> IDLdocParam
; @field keyword_order VECTOR of strings (actual case)
; @field file parent IDLdcFile object
;-
pro IDLdocRoutine__define
    compile_opt idl2

    define = { IDLdocRoutine, $
        system : obj_new(), $
        code : ptr_new(), $
        header : ptr_new(), $
        mccabe_cyclomatic_complexity : 0L, $
        mccabe_essential_complexity : 0L, $
        mccabe_module_design_complexity : 0L, $
        documented : 0L, $
        start_line_number : 0L, $
        no_header : 0B, $
        filename : '', $
        name : '', $
        type : '', $
        preformat : 0B, $
        attributes : 0B, $
        abstract : 0B, $
        author : obj_new(), $             ; array_list
        bugs : obj_new(), $               ; array_list
        categories : obj_new(), $         ; array_list
        copyright : obj_new(), $          ; array_list
        common_blocks : obj_new(), $      ; array_list
        customer_id : obj_new(), $        ; array_list
        examples : obj_new(), $           ; array_list
        file_comments : obj_new(), $      ; array_list
        hidden : 0B, $
        hidden_file : 0B, $
        history : obj_new(), $            ; array_list
        method : 0B, $
        obsolete : 0B, $
        obsolete_comments : obj_new(), $  ; array_list
        private : 0B, $
        private_file : 0B, $
        pre : obj_new(), $                ; array_list
        post : obj_new(), $               ; array_list
        requires : obj_new(), $           ; array_list
        restrictions : obj_new(), $       ; array_list
        returns : obj_new(), $            ; array_list
        inherits : obj_new(), $           ; array_list
        uses : obj_new(), $               ; array_list
        todo : obj_new(), $               ; array_list
        version : obj_new(), $            ; array_list
        comments : obj_new(), $           ; array_list
        parameters : obj_new(), $         ; hash_table of name->IDLdocParam
        parameter_order : obj_new(), $    ; vector
        nvisibleparameters : 0L, $
        shown_parameters : ptr_new(), $
        keywords : obj_new(), $           ; hash_table of name->IDLdocParam
        keyword_order : obj_new(), $      ; vector
        nvisiblekeywords : 0L, $
        shown_keywords : ptr_new(), $
        file : obj_new() $                ; IDLdcFile
        }
end
