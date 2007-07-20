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
;       markup string: either verbatim or rst
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
; Parse the lines of a .pro file, ripping out comments.
;
; :Params:
;    `lines` : in, required, type=strarr
;       text of .pro file
;    `file` : in, required, type=object
;       file tree object
;
; :Keywords:
;    `format` : in, optional, type=string, default=self.format
;       format of comments 
;    `markup` : in, optional, type=string, default=self.markup
;       markup format for comments
;-
pro docparprofileparser::_parseLines, lines, file, format=format, markup=markup
  compile_opt strictarr, logical_predicate
  
  insideComment = 0B
  justFinishedComment = 0L
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
    if (strmid(command, 0, 2) eq '; ' && codeLevel eq 0L && insideComment) then begin
      currentComments->add, strmid(command, 2)
    endif
    if (strmid(command, 0, 2) eq ';+') then insideComment = 1B
    
    tokens = strsplit(command, /extract, count=nTokens)
    if (nTokens eq 0) then continue
    
    ; if ends with begin then codeLevel++
    if (strlowcase(tokens[nTokens - 1L]) eq 'begin' && ~insideComment) then codeLevel++
    
    ; if starts with end* then codeLevel--
    ind = where(strlowcase(tokens[0]) eq endVariants, nEndsFound)
    if (nEndsFound gt 0) then codeLevel--
    
    ; if starts with pro or function  then codeLevel++
    if (strlowcase(tokens[0]) eq 'pro' $
        || strlowcase(tokens[0]) eq 'function') then begin
      codeLevel++
      routine = obj_new('DOCtreeRoutine')
      file->addRoutine, routine
      ; TODO: parse arguments and add to routine object
      if (currentComments->count() gt 0) then begin
        ; TODO: parse and add comments to routine 
        currentComments->remove, /all
      endif
    endif else if (justFinishedComment eq 1 && currentComments->count() gt 0) then begin
      ; TODO: associate comments with file
      currentComments->remove, /all
    endif
    
    justFinishedComment--
  endwhile
  
  obj_destroy, [tokenizer, currentComments]
end


;+
; Parse the given .pro file.
; 
; :Returns: file tree object
; :Params:
;    `filename` : in, required, type=string
;       absolute path to .pro file to be parsed
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
;    `format` format of the comments
;    `markup` markup style of the comments
;-
pro docparprofileparser__define
  compile_opt strictarr
  
  define = { DOCparProFileParser, $
             format: '', $
             markup: '' $
           }
end