; docformat = 'rst'

;+
; Simple system class to replace `DOC_System` class when using parsers outside
; of IDLdoc.
;-


pro docparsystem::warning, msg
  compile_opt strictarr

  print, msg
end


pro docparsystem::getProperty, output=output, comment_style=comment_style
  compile_opt strictarr
  
  if (arg_present(output)) then output = self.output
  if (arg_present(comment_style)) then comment_style = self.comment_style
end


pro docparsystem::setProperty, output=output, comment_style=comment_style
  compile_opt strictarr
  
  if (n_elements(output) gt 0L) then self.output = output
  if (n_elements(comment_style) gt 0L) then self.comment_style = comment_style  
end


function docparsystem::init, _extra=e
  compile_opt strictarr

  self->setProperty, _extra=e

  return, 1
end


pro docparsystem__define
  compile_opt strictarr
  
  define = { DOCparSystem, $
             output: '', $
             comment_style: '' $
           }
end
