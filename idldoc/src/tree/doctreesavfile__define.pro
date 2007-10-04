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
  switch strlowcase(name) of
    'basename' : return, self.basename
    'local_url' : return, file_basename(self.basename, '.sav') + '-sav.html'
    'creation_date': begin
        contents = self.savFile->contents()
        return, contents.date
      end
    'filename':
    'description': 
    'filetype': 
    'user':
    'host':
    'arch': 
    'os':   
    'release': 
    'n_common':
    'n_var':
    'n_sysvar':
    'n_procedure':
    'n_function':
    'n_object_heapvar':
    'n_pointer_heapvar':
    'n_structdef': begin
        contents = self.savFile->contents()
        ind = where(strupcase(name) eq tag_names(contents))
        return, contents.(ind[0])
      end
    else: begin
        ; search in the system object if the variable is not found here
        var = self.directory->getVariable(name, found=found)
        if (found) then return, var
        
        found = 0B
        return, -1L
      end
  endswitch
end


;+
; Get properties.
;-
pro doctreesavfile::getProperty, basename=basename
  compile_opt strictarr
  
  if (arg_present(basename)) then name = self.basename
end


;+
; Set properties.
;-
pro doctreesavfile::setProperty
  compile_opt strictarr
  
end


pro doctreesavfile::generateOutput, outputRoot, directory
  compile_opt strictarr
  on_error, 2
  
  print, '  Generating output for .sav file ' + self.basename
  
  savFileTemplate = self.system->getTemplate('savefile')
  
  outputDir = outputRoot + directory
  outputFilename = outputDir + file_basename(self.basename, '.sav') + '-sav.html'
  
  savFileTemplate->reset
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
;    `basename` : in, required, type=string
;       basename of filename
;    `directory` : in, required, type=object
;       object representing parent directory
;-
function doctreesavfile::init, basename=basename, directory=directory, $
                               system=system
  compile_opt strictarr
  
  self.basename = basename
  self.directory = directory
  self.system = system
  
  self.system->getProperty, root=root
  self.directory->getProperty, location=location
  
  self.savFile = obj_new('IDL_Savefile', root + location + self.basename)
  
  self.system->createIndexEntry, self.basename, self
  self.system->print, '  Parsing ' + self.basename + '...'
  
  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    `system` system object
;    `directory` directory tree object
;    `basename` basename of file
;    `savFile` IDL_Savefile object corresponding to this sav file
;-
pro doctreesavfile__define
  compile_opt strictarr
  
  define = { DOCtreeSavFile, $
             system: obj_new(), $
             directory: obj_new(), $
             basename: '', $
             savFile: obj_new() $
           }
end