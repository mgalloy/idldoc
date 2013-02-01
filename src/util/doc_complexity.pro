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


function doc_codeparser::bracket_level
  compile_opt strictarr

  return, self.bracket_level
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
        num = stregex(rest_of_line, '^[[:digit:].]*([ed][-\+])?[[:digit:]]*', /extract)
        if (strlen(num) gt 0L) then self->advance_pos, strlen(num)
        return, char + num
      end
    char eq ';': begin
        comment = ';' + rest_of_line
        if (strlen(rest_of_line) gt 0L) then self->advance_pos, strlen(rest_of_line)
        return, comment
      end
    char eq '''': begin
        rest_of_string = stregex(rest_of_line, '^([^'']|(''''))*''', /extract)
        if (rest_of_string eq '') then begin
          self->advance_pos, strlen(rest_of_line)
          return, char + rest_of_line
        endif else begin
          self->advance_pos, strlen(rest_of_string)
          return, char + rest_of_string
        endelse
      end
    char eq '"': begin
        rest_of_string = stregex(rest_of_line, '^([^"]|(""))*"', /extract)
        if (rest_of_string eq '') then begin
          self->advance_pos, strlen(rest_of_line)
          return, char + rest_of_line
        endif else begin
          self->advance_pos, strlen(rest_of_string)
          return, char + rest_of_string
        endelse
      end
    else: begin
        if ((char eq '(') || (char eq '[')) then self.bracket_level++
        if ((char eq ')') || (char eq ']')) then self.bracket_level--
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
  self.bracket_level = 0L

  return, 1
end


pro doc_codeparser__define
  compile_opt strictarr

  define = { doc_codeparser, $
             lines: ptr_new(), $
             line_index: 0L, $
             pos_index: 0L, $
             bracket_level: 0L $
           }
end


function doc_complexity_statement, parser, end_form=end_form
  compile_opt strictarr

  complexities = lonarr(2)
  last_token = ''

  repeat begin
    update_last_token = 1B
    token = parser->next()
    if (n_elements(token) gt 0L) then token = strlowcase(token)
    case 1B of
      token eq 'if': begin
          complexities++
          complexities += doc_complexity_statement(parser, end_form='endif')
        end
      token eq 'else': begin
          complexities += doc_complexity_statement(parser, end_form='endelse')
        end

      token eq 'case': begin
          complexities++
          complexities += doc_complexity_block(parser, end_form='endcase')
        end
      token eq 'switch': begin
          complexities++
          complexities += doc_complexity_block(parser, end_form='endswitch')
        end

      token eq 'while': begin
          complexities++
          complexities += doc_complexity_statement(parser, end_form='endwhile')
        end
      token eq 'repeat': begin
          complexities++
          complexities += doc_complexity_statement(parser, end_form='endrep')
        end
      token eq 'for': begin
          complexities++
          complexities += doc_complexity_statement(parser, end_form='endfor')
        end
      token eq 'foreach': begin
          complexities++
          complexities += doc_complexity_statement(parser, end_form='endforeach')
        end

      token eq ':': begin
          ; this only gets ternary operators that are not inside parentheses or
          ; square brackets and also counts labels (maybe they should be
          ; counted?)
          if (parser->bracket_level() eq 0L) then begin
            complexities++
          endif
        end

      token eq 'begin': begin
          complexities += doc_complexity_block(parser, end_form=end_form)
        end

      (token eq '<newline>') && (last_token ne '$'): return, complexities

      else: begin
          if ((n_elements(token) gt 0L) && (strmid(token, 0, 1) eq ';')) then begin
            update_last_token = 0B
          endif
        end
    endcase

    if (update_last_token) then begin
      last_token = token
    endif
  endrep until (n_elements(token) eq 0L)

  return, complexities
end


function doc_complexity_block, parser, end_form=end_form
  compile_opt strictarr

  complexities = lonarr(2)

  repeat begin
    token = parser->next()
    if (n_elements(token) gt 0L) then token = strlowcase(token)
    case 1B of
      token eq 'if': begin
          complexities++
          complexities += doc_complexity_statement(parser, end_form='endif')
        end

      token eq 'case': begin
          complexities++
          complexities += doc_complexity_block(parser, end_form='endcase')
        end
      token eq 'switch': begin
          complexities++
          complexities += doc_complexity_block(parser, end_form='endswitch')
        end

      token eq 'while': begin
          complexities++
          complexities += doc_complexity_statement(parser, end_form='endwhile')
        end
      token eq 'repeat': begin
          complexities++
          complexities += doc_complexity_statement(parser, end_form='endrep')
        end
      token eq 'for': begin
          complexities++
          complexities += doc_complexity_statement(parser, end_form='endfor')
        end
      token eq 'foreach': begin
          complexities++
          complexities += doc_complexity_statement(parser, end_form='endforeach')
        end

      token eq ':': begin
          ; this should get case/switch statement cases correctly, but only gets
          ; ternary operators that are not inside parentheses or square brackets
          ; and also counts labels (maybe they should be counted?)
          if (parser->bracket_level() eq 0L) then begin
            if ((end_form eq 'endcase') || (end_form eq 'endswitch')) then begin
              ; this is not always correct, a ternary operator might be in a
              ; case/switch block
              complexities[0]++
            endif else begin
              complexities++
            endelse
          endif
        end

      token eq 'begin': complexities += doc_complexity_block(parser, end_form='end')
          
      token eq 'end': return, complexities
      token eq end_form: return, complexities

      else:
    endcase
  endrep until (n_elements(token) eq 0L)

  return, complexities
end


;+
; Computes the cyclomatic complexity (or modified complexity) of a section of
; code.
;
; For more information, see::
;
;    http://en.wikipedia.org/wiki/Cyclomatic_complexity
;
; :Returns:
;    `lonarr(2)`, where the first element is the complexity and the second
;    element is the modified complexity
;
; :Params:
;    lines : in, optional, type=strarr
;       lines of code to analyze
;-
function doc_complexity, lines
  compile_opt strictarr

  complexities = lonarr(2)  ; [complexity, modified_complexity]

  parser = obj_new('doc_codeparser', lines)

  complexities += doc_complexity_block(parser, end_form='end')

  obj_destroy, parser
  return, complexities > 1
end


; main-level example program

lines = ['if(1)then print, 1 else if-1 gt 2 then print, 2 else if+2 gt 3 then print, 3']
print, transpose(lines)
print, '------------------------ (complexity = 3)'
print, doc_complexity(lines)

print
print

lines = ['case 1 of', 'a:print, a', 'b: print, b', 'c:', 'else:', 'endcase']
print, transpose(lines)
print, '------------------------ (complexity = 5)'
print, doc_complexity(lines)

end
