; docformat = 'rst'

;+
; Routine to parse and output rst.
;
; :Params:
;    lines : in, required, type=strarr
;       lines of rst to parse and output
;
; :Keywords:
;    style : in, optional, type=string, default=html
;       style of output desired: html, latex, or docbook
;    filename : in, optional, type=string
;       filename to write to; outputs to stdout if not present
;-
pro doc_parserst, lines, style=comment_style, filename=filename
  compile_opt strictarr

  ; default comment style is HTML
  _comment_style = n_elements(comment_style) gt 0L ? comment_style : 'html'

  ; create simple system and rst parser
  system = obj_new('DOCparSystem', comment_style=_comment_style)
  parser = obj_new('DOCparRstMarkupParser', system=system)

  ; get the parse tree
  tree = parser->parse(lines)

  ; create correct output generator for the output style
  case _comment_style of
    'latex': output_language = obj_new('MGtmLatex')
    'html': output_language = obj_new('MGtmHTML')
    'docbook': output_language = obj_new('MGtmDocBook')
    'rst': output_language = obj_new('MGtmRst')
    'plain': output_language = obj_new('MGtmPlain')
  endcase

  ; create the output strings
  output_text = output_language->process(tree)

  ; send the output to a file or stdout
  if (n_elements(filename) gt 0L) then begin
    openw, lun, filename, /get_lun
    printf, lun, transpose(output_text)
    free_lun, lun
  endif else begin
    print, transpose(output_text)
  endelse

  ; free resources
  obj_destroy, [output_language, parser, system]
end
