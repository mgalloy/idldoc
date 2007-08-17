; docformat = 'rst'

;+ 
; Parser for .pro files: files containing routines, main-level programs, and 
; batch files. This parser is responsible for finding comments (but not parsing 
; them) and parsing IDL code.
;
; Only one file parser should be created for all .pro files.
;-


;+
; Return the contents of a .pro file.
;
; :Returns: strarr or -1L if empty file
;
; :Params:
;    `filename` : in, required, type=string
;       filename of .pro file to read
; :Keywords:
;    `empty` : out, optional, type=boolean
;       returns whether the file was empty
;-
function docparprofileparser::_readFile, filename, empty=empty
  compile_opt strictarr
  
  nLines = file_lines(filename)
  if (nLines eq 0) then begin
    empty = 1B
    return, -1L
  endif
  
  code = strarr(nLines)
  
  empty = 0B
  openr, lun, filename, /get_lun
  readf, lun, code
  free_lun, lun
  
  return, code
end


;+
; Finds docformat string.
;
; :Returns: 1B if docformat found, 0 if not
;
; :Params:
;    `line` : in, required, type=string
;       first line of a .pro file
;
; :Keywords:
;    `format`: out, optional, type=string
;       format string: either idldoc, idl, or rst
;    `markup` : out, optional, type=string 
;       markup string: either verbatim or rst; defaults to rst if format is
;       rst or verbatim if markup is specified but not rst 
;-
function docparprofileparser::_checkDocformatLine, line, $
                                                   format=format, $
                                                   markup=markup
  compile_opt strictarr

  ; if first non-whitespace character is not a semicolon, then not a comment 
  ; and no docformat
  trimLine = strtrim(line, 2)
  if (strmid(trimLine, 0, 1) ne ';') then return, 0B
  
  ; remove semicolon and any whitespace
  trimLine = strtrim(strmid(trimLine, 1), 2)
  
  ; return negative if no "docformat"
  if (strlowcase(strmid(trimLine, 0, 9)) ne 'docformat') then return, 0B
  
  ; remove "docformat" and any whitespace
  trimLine = strtrim(strmid(trimLine, 10), 2)
  
  ; return negative if no =
  if (strmid(trimLine, 0, 1) ne '=') then return, 0B
  
  ; remove "=" and any whitespace
  trimLine = strtrim(strmid(trimLine, 1), 2)
  
  ; must have matching quotes
  first = strmid(trimLine, 0, 1)
  last = strmid(trimLine, 0, 1, /reverse_offset)
  if (first ne last) then return, 0B
  if (first ne '''' and first ne '"') then return, 0B
  trimLine = strmid(trimLine, 1, strlen(trimLine) - 2L)
  
  ; set format and/or markup depending on the number of tokens
  tokens = strsplit(trimLine, /extract, count=nTokens)
  case nTokens of
    0 : return, 0B
    1 : begin
      format = strlowcase(tokens[0])
      markup = format eq 'rst' ? 'rst' : 'verbatim'
      return, 1B
    end
    else : begin
      format = strlowcase(tokens[0])
      markup = strlowcase(tokens[1])
      return, 1B
    end
  endcase
end


;+
; Parse comments for a routine and update the information for the routine.
; 
; :Params:
;    `routine` : in, required, type=object
;       routine tree object
;    `comments` : in, required, type=strarr
;       comments to parse
;
; :Keywords:
;    `format` : in, required, type=string
;       format type: idldoc, idl, rst
;    `markup` : in, required, type=string
;       markup type: verbatim, rst
;-
pro docparprofileparser::_parseRoutineComments, routine, comments, $
                                                format=format, markup=markup
  compile_opt strictarr
  
  ; TODO: implement this
  ; lookup correct format and markup parsers
  ; call format parser's "parse" method
end


;+
; Parse arguments/keywords of the routine header. 
; 
; :Params:
;    `routine` : in, required, type=object
;       routine tree object
;    `cmd` : in, required, type=string
;       header line (comments stripped already)
;
; :Keywords:
;    `first_line` : in, optional, type=boolean
;       set if this is the first line of the routine header
;-
pro docparprofileparser::_parseHeader, routine, cmd, first_line=firstLine
  compile_opt strictarr
  
  args = strsplit(cmd, ',', /extract, count=nargs)
  
  ; skip first "argument" if this is the first line (the "pro routine_name" 
  ; part)
  for a = keyword_set(firstLine), nargs - 1L do begin
    argument = strcompress(args[a], /remove_all)
    if (argument eq '$') then continue
    if (strpos(argument, '=') ne -1) then begin
      ; add text before "=" as keyword to routine
      name = (strsplit(argument, '=', /extract))[0]
      keyword = obj_new('DOCtreeArgument', routine, name=name, /is_keyword)
      routine->addKeyword, keyword
    endif else begin
      ; add param as a positional parameter to routine
      param = obj_new('DOCtreeArgument', routine, name=argument)
      routine->addParameter, param
    endelse
  endfor
end


;+
; Parse the lines of a .pro file, ripping out comments.
;
; :Params:
;    `lines` : in, required, type=strarr
;       text of .pro file
;    `file` : in, required, type=object
;       file tree object
;
; :Keywords:
;    `format` : in, required, type=string, default=self.format
;       format of comments 
;    `markup` : in, required, type=string, default=self.markup
;       markup format for comments
;-
pro docparprofileparser::_parseLines, lines, file, format=format, markup=markup
  compile_opt strictarr, logical_predicate
  
  insideComment = 0B
  justFinishedComment = 0L
  headerContinued = 0B
  codeLevel = 0L
  currentComments = obj_new('MGcoArrayList', type=7)
  
  tokenizer = obj_new('DOCparProFileTokenizer', lines)
  
  endVariants = ['end', 'endif', 'endelse', 'endcase', 'endswitch', 'endfor', $
                 'endwhile', 'endrep']
                 
  while (tokenizer->hasNext()) do begin
    ; determine if line has: ;+, ;-, pro/function, begin, end*
    command = tokenizer->next()
    
    if (strmid(command, 0, 2) eq ';-' && insideComment) then begin
      insideComment = 0B
      justFinishedComment = 2L
    endif    
    if (strmid(command, 0, 1) eq ';' && codeLevel eq 0L && insideComment) then begin
      currentComments->add, strmid(command, 2)
    endif
    if (strmid(command, 0, 2) eq ';+') then insideComment = 1B
    
    tokens = strsplit(command, /extract, count=nTokens)
    if (nTokens eq 0) then continue
    
    firstToken = strlowcase(tokens[0])
    lastToken = strlowcase(tokens[nTokens - 1L])
    
    ; if ends with "begin" then codeLevel++
    if (lastToken eq 'begin' && ~insideComment) then codeLevel++
    
    ; if starts with end* then codeLevel--
    ind = where(firstToken eq endVariants, nEndsFound)
    if (nEndsFound gt 0) then codeLevel--
    
    ; process keywords/params in continued header
    if (headerContinued) then begin
      ; comment lines in the header automatically continue the header
      if (strmid(command, 0, 1) eq ';') then continue
      
      self->_parseHeader, routine, command
      
      ; might be continued more
      headerContinued = lastToken eq '$' ? 1B : 0B
    endif
    
    ; if starts with pro or function then codeLevel++
    if (firstToken eq 'pro' || firstToken eq 'function') then begin
      codeLevel++
      insideComment = 0B
      
      if (lastToken eq '$') then headerContinued = 1B
      
      routine = obj_new('DOCtreeRoutine', file)
      file->addRoutine, routine
      
      routine->setProperty, name=(strsplit(tokens[1], ',', /extract))[0]
      if (strpos(tokens[1], '::') ne -1) then routine->setProperty, is_method=1B
      if (firstToken eq 'function') then routine->setProperty, is_function=1B   
         
      self->_parseHeader, routine, command, /first_line
            
      if (currentComments->count() gt 0) then begin
        self->_parseRoutineComments, routine, currentComments->get(/all), $
                                     format=format, markup=markup
        
        currentComments->remove, /all
      endif
    endif else if (justFinishedComment eq 1 && currentComments->count() gt 0) then begin
      ; TODO: associate comments with file
      currentComments->remove, /all
    endif
    
    justFinishedComment--
  endwhile
  
  ; if the codeLevel ends up negative then the file had a main-level program
  file->setProperty, has_main_level=codeLevel lt 0
  
  ; if there are not routines in the file and it doesn't have a main-level
  ; program, then it's batch file
  file->getProperty, n_routines=nRoutines, has_main_level=hasMainLevel
  if (~hasMainLevel && nRoutines eq 0) then begin
    file->setProperty, is_batch=1B
  endif
  
  obj_destroy, [tokenizer, currentComments]
end


;+
; Parse the given .pro file.
; 
; :Returns: file tree object
; :Params:
;    `filename` : in, required, type=string
;       absolute path to .pro file to be parsed
;
; :Keywords:
;    `found` : out, optional, type=boolean
;       returns 1 if filename found, 0 otherwise
;-
function docparprofileparser::parse, filename, found=found
  compile_opt strictarr
  
  ; sanity check
  found = file_test(filename)
  if (~found) then return, obj_new()
  
  ; create file
  file = obj_new('DOCtreeFile', name=file_basename(filename))
  
  ; get the contents of the file
  lines = self->_readFile(filename, empty=empty)
  
  ; if the file is empty, no parsing needs to be done
  if (empty) then begin
    file->setProperty, is_batch=1B
    return, file
  endif
  
  ; check for docformat change
  foundFormat = self->_checkDocformatLine(lines[0], $ 
                                          format=format, $ 
                                          markup=markup)
  if (~foundFormat) then begin
    format = self.format
    markup = self.markup
  endif
  
  ; parse lines of file
  self->_parseLines, lines, file, format=format, markup=markup
  
  ; return independent file
  return, file
end


;+
; Create a file parser.
;
; :Keywords:
;    `format` : in, optional, type=string, default=idldoc
;       format of comments: IDLdoc, IDL, or rst
;    `markup` : in, optional, type=string, default=verbatim
;       style of markup: verbatim or rst
;-
function docparprofileparser::init, format=format, markup=markup
  compile_opt strictarr
  
  self.format = n_elements(format) eq 0 ? 'idldoc' : format
  self.markup = n_elements(markup) eq 0 ? 'verbatim' : markup
  
  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    `format`
;       format of the comments
;    `markup` 
;       markup style of the comments
;-
pro docparprofileparser__define
  compile_opt strictarr
  
  define = { DOCparProFileParser, $
             format: '', $
             markup: '' $
           }
end