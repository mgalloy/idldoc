; docformat = 'rst'

pro doc_parserst, lines, output=output, style=comment_style
  compile_opt strictarr

  _comment_style = n_elements(comment_style) gt 0L ? comment_style : 'html'
  
  system = obj_new('DOCparSystem', output=output, comment_style=_comment_style)
  parser = obj_new('DOCparRstMarkupParser', system=system)
  
  tree = parser->parse(lines)
  
  case _comment_style of
    'latex': output_language = obj_new('MGtmLatex')
    'html': output_language = obj_new('MGtmHTML')
    'docbook': output_language = obj_new('MGtmDocBook')
  endcase
  
  output_text = output_language->process(tree)
  
  obj_destroy, output_language
  
  print, transpose(output_text)
  
  obj_destroy, [parser, system]
end
