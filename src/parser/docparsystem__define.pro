; docformat = 'rst'

;+
; Simple system class to replace `DOC_System` class when using parsers outside
; of IDLdoc.
;-


pro docparsystem::warning, msg
  compile_opt strictarr

  print, msg
end


pro docparsystem::getProperty, comment_style=comment_style
  compile_opt strictarr
  
  if (arg_present(comment_style)) then comment_style = self.comment_style
end


pro docparsystem::setProperty, comment_style=comment_style
  compile_opt strictarr
  
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
             comment_style: '' $
           }
end
