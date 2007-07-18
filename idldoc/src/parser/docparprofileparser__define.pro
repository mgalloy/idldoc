; docformat = 'rst'

;+ 
; Parser for .pro files: files containing routines, main-level programs, and 
; batch files. Only one file parser should be created for all .pro files.
;-

;+
; Strip comments from a line of code. Returns the line of code without the 
; comments.
; 
; :Returns: string
;
; :Params:
;    `line` : in, required, type=string
;       line of IDL code
;
; :Keywords:
;    `empty` : out, optional, type=boolean
;       true if there is no IDL statement on the line (only comments or 
;       whitespace)
;-
function docparprofileparser::_stripComments, line, empty=empty
  compile_opt strictarr
  
  semicolonPosition = strpos(line, ';')
  while (semicolonPosition ne -1L) do begin
    before = strmid(line, 0, semicolonPosition)
    
    beforeAsBytes = byte(before)
    ; ' = 39B, " = 34B
    ind = where(beforeAsBytes eq 34B or beforeAsBytes eq 39B, count)
    
    ; the semicolon is not in a string because there are no quotes
    if (count eq 0) then return, before
    
    looking = 0B   ; true if already seen a quote and looking for a match
    lookingFor = 0B   ; which quote to look for, either 39B or 34B
    
    ; loop through each ' or " before the current semicolon
    for i = 0L, n_elements(ind) - 1L do begin
      cur = beforeAsBytes[ind[i]]
      
      if (~looking) then begin
        looking = 1B
        lookingFor = cur
        continue
      endif 
      
      if (cur eq lookingFor) then looking = 0B
    endfor
    
    ; strings before semicolon are completed so return everything before 
    ; the semicolon
    if (~looking) then return, before
    
    ; semicolon is inside a string, so go to the next semicolon
    semicolonPosition = strpos(line, ';', semicolonPosition + 1L)
  endwhile 
  
  ; no comments found
  return, line
end


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

  trimLine = strtrim(line, 2)
  
  ; if not a comment, then no docformat
  if (strmid(trimLine, 0, 1) ne ';') then return, 0B
  
  ; remove semicolon and any whitespace
  trimLine = strtrim(strmid(trimLine, 1), 2)
  
  ; return negative if no "docformat"
  if (strlowcase(strmid(trimLine, 0, 9)) ne 'docformat') then return, 0B
  
  ; remove "docformat" and any whitespace
  trimLine = strtrim(strmid(trimLine, 10), 2)
  
  ; return negative if no =
  if (strmid(trimLine, 0, 1) eq '=') then return, 0B
  
  ; remove "=" and any whitespace
  trimLine = strtrim(strmid(trimLine, 1), 2)
  
  ; must have matching quotes
  first = strmid(trimLine, 0, 1)
  last = strmid(trimLine, 0, 1, /reverse_offset)
  if (first ne last) then return, 0B
  if (first ne '''' or first ne '"') then return, 0B
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
  
  ; check for file comments
  ; go through each routine
  ; check if main-level program present
  
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