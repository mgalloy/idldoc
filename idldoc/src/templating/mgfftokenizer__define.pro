;+
; Restores the tokenizer to the state/location it was in when the given
; memento was produced.
;
; @param memento {in}{required}{type=structure} memento produced by save_pos
;        method
;-
pro mgfftokenizer::restorePos, memento
  compile_opt strictarr

  self.lineNumber = memento.lineNumber
  *self.tokens = memento.tokens
  *self.tokenLength = memento.tokenLength
  self.tokenCounter = memento.tokenCounter
  self.line = memento.line
end


;+
; Saves the current state/location of the tokenizer in a memento structure.
;
; @returns structure
;-
function mgfftokenizer::savePos
  compile_opt strictarr

  memento = { lineNumber : self.lineNumber, $
              tokens : *self.tokens, $
              tokenLength : *self.tokenLength, $
              tokenCounter : self.tokenCounter, $
              line : self.line $
            }

  return, memento
end


;+
; Returns the current line of the tokenized file.
;
; @returns string
; @keyword number {out}{optional}{type=long} line number of returned line
;-
function mgfftokenizer::getCurrentLine, number=number
  compile_opt strictarr
  
  number = self.lineNumber + 1L
  
  return, self.line
end


;+
; Returns the next token of the file.
;
; @returns string
; @keyword pre_delim {out}{optional}{type=string} delimiter before the returned token
; @keyword post_delim {out}{optional}{type=string} delimiter after the returned token
; @keyword newline {out}{optional}{type=boolean} true if token is first on a new line
;-
function mgfftokenizer::next, pre_delim=pre_delim, post_delim=post_delim, newline=newline
  compile_opt strictarr

  if (self->done()) then begin
    pre_delim = ''
    post_delim = ''
    return, ''
  endif
  
  newline = 0B
  
  token_start = (*self.tokens)[self.tokenCounter]
  token_length = (*self.tokenLength)[self.tokenCounter]
  token = strmid(self.line, token_start, token_length)
  
  newline = self.tokenCounter eq 0 and self.lineNumber gt 0

  if (arg_present(pre_delim)) then begin
    if (self.tokenCounter eq 0) then begin
      pre_delim = ''
      if ((*self.tokens)[0] ne 0) then begin
        pre_delim = strmid(self.line, 0, (*self.tokens)[0])
      endif
    endif else begin
      delim_start = (*self.tokens)[self.tokenCounter - 1L] $
                    + (*self.tokenLength)[self.tokenCounter - 1L]
      delim_length = (*self.tokens)[self.tokenCounter] - delim_start
      pre_delim = strmid(self.line, delim_start, delim_length)
    endelse
  endif

  if (arg_present(post_delim)) then begin
    ; if last token on the line
    if (self.tokenCounter eq n_elements(*self.tokens) - 1) then begin
      post_delim = ''
      delim_start $
          = (*self.tokens)[self.tokenCounter] $
          + (*self.tokenLength)[self.tokenCounter]
      if (delim_start lt strlen(self.line) - 1) then begin
        post_delim = strmid(self.line, delim_start)
      endif
    endif else begin
      delim_start = (*self.tokens)[self.tokenCounter] $
                    + (*self.tokenLength)[self.tokenCounter]
      delim_length = (*self.tokens)[self.tokenCounter + 1L] - delim_start
      post_delim = strmid(self.line, delim_start, delim_length)
    endelse
  endif

  ++self.tokenCounter
  return, token
end


;+
; Returns whether there are any more tokens in the file.  Parses a new line of
; the file if necessary.
;
; @returns 1B if no more tokens or 0B otherwise
;-
function mgfftokenizer::done
  compile_opt strictarr
  
  ; already have more tokens in hand, so not done
  if (self.tokenCounter lt n_elements(*self.tokens)) then return, 0B
  
  ; handle: EOF, no tokens
  if (self.lineNumber ge self.nlines - 1L) then return, 1B
  
  ; skip blank lines
  self.line = (*self.data)[++self.lineNumber]
  
  ; new tokens
  *self.tokens = strsplit(self.line, self.pattern, /regex, length=len)
  *self.tokenLength = len
  self.tokenCounter = 0L
  
  return, 0B
end


;+
; Resets the tokenizer to the beginning of the tokenized file.
;-
pro mgfftokenizer::reset
  compile_opt strictarr
  
  ptr_free, self.tokens, self.tokenLength
  
  self.lineNumber = -1L
  self.tokenCounter = 0L
    
  self.tokens = ptr_new(/allocate_heap)
  self.tokenLength = ptr_new(/allocate_heap)
  
  check = self->done()
end


;+
; Frees resources.
;-
pro mgfftokenizer::cleanup
  compile_opt strictarr
  
  ptr_free, self.tokens, self.tokenLength, self.data
end


;+
; Creates a tokenizer for a given file with a given pattern.  Creating the
; tokenizer opens the file.
;
; @returns 1 if successful, 0 otherwise
; @param filename {in}{required}{type=string} filename of the file to be
;        tokenized
; @keyword pattern {in}{optional}{type=string}{default=space} regular expression
;          (as in STRPSLIT) to split the text of the file into tokens
;-
function mgfftokenizer::init, filename, pattern=pattern
  compile_opt strictarr
  on_error, 2
  
  if (n_params() ne 1) then message, 'filename parameter required'
  self.pattern = n_elements(pattern) eq 0 ? '[[:space:]]' : pattern
  
  file_present = file_test(filename)
  if (~file_present) then message, 'file not found: ' + filename
  
  ; read the entire file
  self.nlines = file_lines(filename)
  data = strarr(self.nlines)
  openr, lun, filename, /get_lun
  readf, lun, data
  free_lun, lun
  
  self.data = ptr_new(data)

  self.tokens = ptr_new(/allocate_heap)
  self.tokenLength = ptr_new(/allocate_heap)
  self.tokenCounter = 0L
  
  self.lineNumber = -1L
  
  return, 1
end


;+
; Define instance variables.
;
; @file_comments This class splits files into tokens.
;
; @field data contents of file to be tokenized
; @field pattern regular expression to split lines on
; @field lineNumber indicates the line number in the file of line (starts at 0)
; @field nlines number of lines in file to be tokenized
; @field line current line read by tokenizer
; @field tokens pointer to long array which indicates the beginnings of the
;        tokens in line
; @field tokenLength pointer to long array which indicates the length of the
;        tokens in line
; @field tokenCounter next token in tokens and token_length
;
; @requires IDL 6.0
;
; @categories input/output
;
; @author Michael Galloy
;-
pro mgfftokenizer__define
  compile_opt strictarr
  
  define = { MGffTokenizer, $
             data: ptr_new(), $
             pattern: '', $
             lineNumber: 0L, $
             nlines: 0L, $
             line: '', $
             tokens: ptr_new(), $
             tokenLength: ptr_new(), $
             tokenCounter: 0L $
           }
end
