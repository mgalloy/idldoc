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

    'procedures': return, self.procedures->get(/all)
    'functions': return, self.functions->get(/all)
    'variables': return, self.variables->get(/all)
    'common_blocks': return, self.commonBlocks->get(/all)
    'structure_definitions': return, self.structureDefinitions->get(/all)
    'pointers': return, self.pointers->get(/all)
    'objects': return, self.objects->get(/all)
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


function doctreesavfile::loadItem, itemName, $
                                   structure_definition=structureDefinition, $
                                   pointer_heapvar=pointerHeapvar, $
                                   object_heapvar=objectHeapvar
  compile_opt strictarr
  
  switch 1 of
    keyword_set(structureDefinition): begin
        self.savFile->restore, itemName, /structure_definition
        return, create_struct(name=itemName)
      end
      
    keyword_set(pointerHeapvar):
    keyword_set(objectHeapvar): begin
        self.savFile->restore, itemName, new_heapvar=var, $
                               pointer_heapvar=pointerHeapvar, $
                               object_heapvar=objectHeapvar
        return, var           
      end
    
    else: begin
        self.savFile->restore, itemName
        return, scope_varfetch(itemName)      
      end
    endswitch
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
    self.variables->add, var
  endfor

  commonBlockNames = self.savFile->names(count=nCommonBlocks, /common_block)
  for i = 0L, nCommonBlocks - 1L do begin
    varNames = self.savFile->names(common_variable=commonBlockNames[i])
    
    var = obj_new('DOCtreeSavVar', commonBlockNames[i], '', self, system=self.system)
    var->setProperty, declaration='common ' + commonBlockNames[i] + ', ' + strjoin(varNames, ', ')
    self.commonBlocks->add, var
  endfor
  
  structureNames = self.savFile->names(count=nStructureDefinitions, /structure_definition)
  for i = 0L, nStructureDefinitions - 1L do begin
    data = self->loadItem(structureNames[i], /structure_definition)
    
    var = obj_new('DOCtreeSavVar', structureNames[i], data, self, system=self.system)
    self.structureDefinitions->add, var
  endfor
    
  pointerNames = self.savFile->names(count=nPointers, /pointer_heapvar)
  for i = 0L, nPointers - 1L do begin
    data = self->loadItem(pointerNames[i], /pointer_heapvar)
    
    var = obj_new('DOCtreeSavVar', $
                  '&lt;PtrHeapVar' + strtrim(pointerNames[i], 2) + '&gt;', $
                  data, self, system=self.system)
    self.pointers->add, var
  endfor
  
  objectNames = self.savFile->names(count=nObjects, /object_heapvar)
  for i = 0L, nObjects - 1L do begin
    data = self->loadItem(objectNames[i], /object_heapvar)
    
    var = obj_new('DOCtreeSavVar', $
                  '&lt;ObjHeapVar' + strtrim(objectNames[i], 2) + '&gt;', $
                  data, self, system=self.system)
    self.objects->add, var
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
  
  obj_destroy, [self.procedures, $
                self.functions, $
                self.variables, $
                self.structureDefinitions, $
                self.pointers, $
                self.objects]
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
  info = file_info(root + location + self.basename)
  self.modificationTime = systime(0, info.mtime)
  self.size = mg_int_format(info.size) + ' bytes'
  
  self.system->createIndexEntry, self.basename, self
  self.system->print, '  Parsing ' + self.basename + '...'
  
  self.procedures = obj_new('MGcoArrayList', type=7)
  self.functions = obj_new('MGcoArrayList', type=7)
  self.variables = obj_new('MGcoArrayList', type=11)
  self.commonBlocks = obj_new('MGcoArrayList', type=11)
  self.structureDefinitions = obj_new('MGcoArrayList', type=11)
  self.pointers = obj_new('MGcoArrayList', type=11)
  self.objects = obj_new('MGcoArrayList', type=11)
  
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
             variables: obj_new(), $
             commonBlocks: obj_new(), $
             structureDefinitions: obj_new(), $
             pointers: obj_new(), $
             objects: obj_new() $
           }
end