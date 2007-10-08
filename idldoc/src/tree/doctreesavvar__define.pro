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
function doctreesavvar::getVariable, name, found=found
  compile_opt strictarr
  
  found = 1B
  switch strlowcase(name) of
    'name': return, self.name
    'declaration': return, self.declaration
    'has_thumbnail': return, self.hasThumbnail
    'thumbnail_url': begin
        return, self.savFile->getVariable('url') + self.localThumbnailUrl
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

end


function doctreesavvar::init, name, data, savFile, system=system
  compile_opt strictarr
  
  self.name = name
  self.savFile = savFile
  self.system = system
  
  im = doc_thumbnail(data, valid=valid)
  self.hasThumbnail = valid
  if (self.hasThumbnail) then begin 
    self.savFile->getProperty, directory=directory, basename=basename
    directory->getProperty, location=location
    self.system->getProperty, output=output
    self.localThumbnailUrl = file_basename(basename, '.sav') + '-sav-' + self.name + '.png'
    filename = output + location + self.localThumbnailUrl
    
    write_png, filename, im
  endif
  
  self.declaration = doc_variable_declaration(data)
  
  return, 1
end


pro doctreesavvar__define
  compile_opt strictarr
  
  define = { DOCtreeSavVar, $
             system: obj_new(), $
             savFile: obj_new(), $
             
             name: '', $
             declaration: '', $
             localThumbnailUrl: '', $
             hasThumbnail: 0B $
           }
end