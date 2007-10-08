; docformat = 'rst'

;+
; Get variables for use with templates.
;
; :Returns: variable
; :Params:
;    `name` : in, required, type=string
;       name of variable
;
; :Keywords:
;    `found` : out, optional, type=boolean
;       set to a named variable, returns if variable name was found
;-
function doctreesavfile::getVariable, name, found=found
  compile_opt strictarr
  
  found = 1B
  switch strlowcase(name) of
    'name': return, self.name
    'thumbnail_url': begin
        ; TODO: finish this
        return, self.savFile->getVariable('url')
      end
    else: begin
        ; search in the system object if the variable is not found here
        var = self.savFile->getVariable(name, found=found)
        if (found) then return, var
        
        found = 0B
        return, -1L
      end
  endswitch
end


;+
; Free resources.
;-
pro doctreesavvar::cleanup
  compile_opt strictarr

  ptr_free, self.thumbnail
end


function doctreesavvar::init, name, data, savFile, system=system
  compile_opt strictarr
  
  self.name = name
  self.savFile = savFile
  self.system = system
  
  im = doc_thumbnail(data, valid=valid)
  if (valid) then self.thumbnail = ptr_new(im)
  
  return, 1
end


pro doctreesavvar__define
  compile_opt strictarr
  
  define = { DOCtreeSavVar, $
             system: obj_new(), $
             savFile: obj_new(), $
             
             name: '', $
             thumbnail: ptr_new() $
           }
end