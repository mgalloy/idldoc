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
    'modification_time': return, self.modificationTime
    'size': return, self.size
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
        val = contents.(ind[0])
        return, mg_is_int(val) ? mg_int_format(val) : val
      end
    'vars': return, self.vars->get(/all)
    'procedures': return, self.procedures->get(/all)
    'functions': return, self.functions->get(/all)
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
pro doctreesavfile::getProperty, basename=basename, directory=directory
  compile_opt strictarr
  
  if (arg_present(basename)) then basename = self.basename
  if (arg_present(directory)) then directory = self.directory
end


function doctreesavfile::loadItem, itemName, _extra=e
  compile_opt strictarr
  
  self.savFile->restore, itemName, _strict_extra=e
  
  return, scope_varfetch(itemName)
end


pro doctreesavfile::loadSavContents
  compile_opt strictarr

  procedureNames = self.savFile->names(count=nProcedures, /procedure)
  if (nProcedures gt 0) then self.procedures->add, procedureNames
  
  functionNames = self.savFile->names(count=nFunctions, /function)
  if (nFunctions gt 0) then self.functions->add, functionNames
  
  varNames = self.savFile->names(count=nVars)
  for i = 0L, nVars - 1L do begin
    data = self->loadItem(varNames[i])
    
    var = obj_new('DOCtreeSavVar', varNames[i], data, self, system=self.system)
    self.vars->add, var
  endfor
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
  
  self.system->print, '  Generating output for .sav file ' + self.basename
  
  self->loadSavContents
  
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
  
  obj_destroy, [self.procedures, self.functions, self.vars, self.savFile]
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
  info = file_info(root + location + self.basename)
  self.modificationTime = systime(0, info.mtime)
  self.size = mg_int_format(info.size) + ' bytes'
  
  self.system->createIndexEntry, self.basename, self
  self.system->print, '  Parsing ' + self.basename + '...'
  
  self.procedures = obj_new('MGcoArrayList', type=7)
  self.functions = obj_new('MGcoArrayList', type=7)
  self.vars = obj_new('MGcoArrayList', type=11)
  
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
             
             savFile: obj_new(), $
             modificationTime: '', $
             size: '', $
             
             procedures: obj_new(), $
             functions: obj_new(), $
             vars: obj_new() $
           }
end