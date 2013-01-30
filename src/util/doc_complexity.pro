; docformat = 'rst'

pro doc_codeparser::advance_pos, length, done=done
  compile_opt strictarr

  done = 0B

  if (self.pos_index ge strlen((*self.lines)[self.line_index])) then begin
    self.line_index++
    self.pos_index = 0L
  endif else self.pos_index += length

  if (self.line_index ge n_elements(*self.lines)) then done = 1B
end


function doc_codeparser::next
  compile_opt strictarr

  ; test if done
  if (self.line_index ge n_elements(*self.lines)) then return, !null

  ; eat whitespace in search of first character
  repeat begin
    char = strmid((*self.lines)[self.line_index], self.pos_index, 1L)
    self->advance_pos, 1L, done=done
  endrep until (~stregex(char, '[[:space:]]', /boolean))

  if (done) then return, char eq '' ? '<newline>' : char
  rest_of_line = char eq '' ? '' : strmid((*self.lines)[self.line_index], self.pos_index)

  case 1B of
    char eq '': return, '<newline>'
    stregex(char, '[[:alpha:]]', /boolean): begin
        id = stregex(rest_of_line, '^[[:alnum:]$_]*', /extract)
        if (strlen(id) gt 0L) then self->advance_pos, strlen(id)
        return, char + id
      end
    stregex(char, '[[:digit:].]', /boolean): begin
        num = stregex(rest_of_line, '^[[:digit:].]*', /extract)
        if (strlen(num) gt 0L) then self->advance_pos, strlen(num)
        return, char + num
      end
    char eq ';': begin
        comment = ';' + rest_of_line
        if (strlen(rest_of_line) gt 0L) then self->advance_pos, strlen(rest_of_line)
      end
    char eq '''':
    char eq '"':
    else: begin
        return, char
      end
  endcase
end


pro doc_codeparser::cleanup
  compile_opt strictarr

  ptr_free, self.lines
end


function doc_codeparser::init, lines
  compile_opt strictarr

  self.lines = ptr_new(lines)

  self.line_index = 0L
  self.pos_index = 0L

  return, 1
end


pro doc_codeparser__define
  compile_opt strictarr

  define = { doc_codeparser, $
             lines: ptr_new(), $
             line_index: 0L, $
             pos_index: 0L $
           }
end


pro doc_complexity_routine, parser, complexity
  compile_opt strictarr

  repeat begin
    token = strlowcase(parser->next())
    case 1B of
      token eq 'function': doc_complexity_routine, parser, complexity
      token eq 'pro': doc_complexity_routine, parser, complexity
      strmid(token, 0, 1) eq ';'
      else:
    endcase
  endrep until (n_elements(token) eq 0L)
end


;+
; Computes the cyclomatic complexity (or conditional complexity) of a section
; of code.
;
; The complexity is::
;
;    p - s + 2
;
; where p is the number of decision points and s is the number of exit points.
;
; For more information, see::
;
;    http://en.wikipedia.org/wiki/Cyclomatic_complexity
;
; :Todo:
;    * should ignore comments and string literals
;    * should add the number of non-else clauses in CASE and SWITCH statements
;
; :Returns:
;    long
;
; :Params:
;    lines : in, optional, type=strarr
;       lines of code to analyze
;-
function doc_complexity, lines
  compile_opt strictarr

  pattern = '[[:>:]]'
  ;pattern = '[[:space:](),-\+]'
  tokenizer = obj_new('MGffTokenizer', lines, /string_array, pattern=pattern)
  complexity = 1L

  while (~tokenizer->done()) do begin
    tok = tokenizer->next(pre_delim=pre, post_delim=post, newline=newline)
    case strlowcase(strtrim(tok, 2)) of
      'if': complexity++
      'case': complexity++   ; really should add the number of non-else cases
      'switch': complexity++ ; really should add the number of non-else cases
      'while': complexity++
      'repeat': complexity++
      'for': complexity++
      'return': complexity--
      else:
    endcase
  endwhile

  obj_destroy, tokenizer
  return, complexity > 1

;  complexity = 1L
;
;  parser = obj_new('doc_codeparser', lines)
;  repeat begin
;    token = strlowcase(parser->next())
;    case 1B of
;      token eq 'function': doc_complexity_routine, parser, complexity
;      token eq 'pro': doc_complexity_routine, parser, complexity
;      strmid(token, 0, 1) eq ';'
;      else:
;    endcase
;  endrep until (n_elements(token) eq 0L)
;
;  obj_destroy, parser
;  return, complexity > 1
end


; main-level example program

lines = ['if(1)then print, 1 else if-1 gt 2 then print, 2 else if+2 gt 3 then print, 3']
print, transpose(lines)
print, '------------------------'
print, doc_complexity(lines)

print
print

lines = ['case 1 of', 'a:print, a', 'b: print, b', 'c:', 'else:', 'endcase']
print, transpose(lines)
print, '------------------------'
print, doc_complexity(lines)

end
