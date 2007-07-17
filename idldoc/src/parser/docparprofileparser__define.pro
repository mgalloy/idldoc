; docformat = 'rst'

;+ 
; Parser for .pro files: files containing routines, main-level programs, and 
; batch files. Only one file parser should be created for all .pro files.
;-

;+
; Strip comments from a line of code.
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
    
    looking = 0B
    lookingFor = 0B
    for i = 0L, n_elements(ind) - 1L do begin
      cur = beforeAsBytes[ind[i]]
      
      if (~looking) then begin
        looking = 1B
        lookingFor = cur
        continue
      endif 
      
      if (cur eq lookingFor) then begin
        looking = 0B
        lookingFor = 0B
        continue
      endif
    endfor
    
    ; strings before semicolon is completed so return everything before 
    ; semicolon
    if (~looking) then return, before
    
    ; semicolon is inside a string, so go to the next semicolon
    semicolonPosition = strpos(line, ';', semicolonPosition + 1L)
  endwhile 
  
  ; no comments found
  return, line
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
  
  ; check for docformat change
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