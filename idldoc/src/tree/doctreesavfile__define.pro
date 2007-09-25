; docformat = 'rst'

;+
; This class represents a information about .pro file.
; 
; :Properties:
;    `name` : get, set, type=string
;       basename of filename
;-


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
  case strlowcase(name) of
    'description': begin
        contents = self.savFile->contents()
        return, contents.description
      end
    'type': begin
        contents = self.savFile->contents()
        return, contents.filetype
      end
    else: begin
        found = 0B
        return, -1L
      end
  endcase
end


;+
; Get properties.
;-
pro doctreesavfile::getProperty, name=name
  compile_opt strictarr
  
  if (arg_present(name)) then name = self.name
end


;+
; Set properties.
;-
pro doctreesavfile::setProperty, name=name
  compile_opt strictarr
  
  if (n_elements(name) ne 0) then self.name = name
end


pro doctreesavfile::generateOutput, outputRoot, directory
  compile_opt strictarr
  on_error, 2
  
  print, '  Generating output for .sav file ' + self.name
  
  self.system->getProperty, sav_file_template=savFileTemplate
  
  outputDir = outputRoot + directory
  if (~file_test(outputDir)) then begin
    self.system->makeDirectory, outputDir, error=error
    if (error ne 0L) then begin
      self.system->error, 'unable to make directory ' + outputDir
    endif
  endif
  outputFilename = outputDir + file_basename(self.name, '.sav') + '-sav.html'
  
  savFileTemplate->process, self, outputFilename
end


;+
; Free resources.
;-
pro doctreesavfile::cleanup
  compile_opt strictarr
  
  obj_destroy, self.savFile
end


;+
; Create file tree object.
;
; :Returns: 1 for success, 0 for failure
; :Keywords:
;    `name` : in, required, type=string
;       basename of filename
;    `directory` : in, required, type=object
;       object representing parent directory
;-
function doctreesavfile::init, name=name, directory=directory, system=system
  compile_opt strictarr
  
  self.name = name
  self.directory = directory
  self.system = system
  
  self.system->getProperty, root=root
  self.directory->getProperty, location=location
  
  self.savFile = obj_new('IDL_Savefile', root + location + self.name)
  
  return, 1
end


;+
; :Fields:
;    `directory` directory tree object
;    `name` basename of file
;-
pro doctreesavfile__define
  compile_opt strictarr
  
  define = { DOCtreeSavFile, $
             system: obj_new(), $
             directory: obj_new(), $
             name: '', $
             savFile: obj_new() $
           }
end