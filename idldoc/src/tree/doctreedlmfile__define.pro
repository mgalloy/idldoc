; docformat = 'rst'


;+
; Get variables for use with templates.
;
; :Returns: 
;    variable
;
; :Params:
;    name : in, required, type=string
;       name of variable
;
; :Keywords:
;    found : out, optional, type=boolean
;       set to a named variable, returns if variable name was found
;-
function doctreedlmfile::getVariable, name, found=found
  compile_opt strictarr
  
  found = 1B
  switch strlowcase(name) of
    'basename' : return, self.basename
    'local_url' : return, file_basename(self.basename, '.dlm') + '-dlm.html'

    'description': return, ''

    'has_comments': return, obj_valid(self.comments)
    'comments': return, self.system->processComments(self.comments)       
    'comments_first_line': begin
        ; if no file comments, but there is only one routine then return the
        ; first line of the routine's comments           
        if (~obj_valid(self.comments)) then begin
          filename = strlowcase(strmid(self.basename, 0, strpos(self.basename, '.')))
          for r = 0L, self.routines->count() - 1L do begin
            routine = self.routines->get(position=r)
            routine->getProperty, name=routineName
            if (strlowcase(routineName) eq filename) then begin
              return, routine->getVariable('comments_first_line', found=found)
            endif
          endfor
          
          return, ''
        endif
        
        self.firstline = mg_tm_firstline(self.comments)
        return, self.system->processComments(self.firstline)        
      end
    'plain_comments': return, self.system->processPlainComments(self.comments)
        
    'modification_time': return, self.modificationTime
    
    'index_name': return, self.basename
    'index_type': return, '.dlm file in ' + self->getVariable('location')
    'index_url': begin
        return, self.directory->getVariable('url') + self->getVariable('local_url')
      end
    
    else: begin
        ; search in the directory object if the variable is not found here
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
pro doctreedlmfile::getProperty, basename=basename, directory=directory
  compile_opt strictarr
  
  if (arg_present(basename)) then basename = self.basename
  if (arg_present(directory)) then directory = self.directory
end


;+
; Set properties.
;-
pro doctreedlmfile::setProperty
  compile_opt strictarr

end


;+
; All .dlm files are visible.
; 
; :Returns: 
;    1 if visible, 0 if not visible
;-
function doctreedlmfile::isVisible
  compile_opt strictarr
  
  return, 1B
end


pro doctreedlmfile::_loadDLMContents
  compile_opt strictarr
  
end


pro doctreedlmfile::generateOutput, outputRoot, directory
  compile_opt strictarr

  self.system->print, '  Generating output for .dlm file ' + self.basename + '...'
  
  self->_loadDLMContents
  
  dlmFileTemplate = self.system->getTemplate('dlmfile')
  
  outputDir = outputRoot + directory
  outputFilename = outputDir + file_basename(self.basename, '.dlm') + '-dlm.html'
  
  dlmFileTemplate->reset
  dlmFileTemplate->process, self, outputFilename  
end


;+
; Free resources.
;-
pro doctreedlmfile::cleanup
  compile_opt strictarr
  
  obj_destroy, self.firstline
  obj_destroy, self.comments
  
  obj_destroy, self.routines
  
  obj_destroy, [self.author, self.version]
  obj_destroy, self.code
end


;+
; Create DLM file tree object.
;
; :Returns: 1 for success, 0 for failure
;
; :Keywords:
;    basename : in, required, type=string
;       basename of the .dlm file
;    directory : in, required, type=object
;       directory tree object
;    system : in, required, type=object
;       system object
;-
function doctreedlmfile::init, basename=basename, directory=directory, $
                               system=system
  compile_opt strictarr
  
  self.basename = basename
  self.directory = directory
  self.system = system

  self.system->getProperty, root=root
  self.directory->getProperty, location=location
  self.dlmFilename = root + location + self.basename
  
  info = file_info(self.savFilename)
  self.modificationTime = systime(0, info.mtime)
  self.size = mg_int_format(info.size) + ' bytes'
    
  self.routines = obj_new('MGcoArrayList', type=11, block_size=10)

  self.system->getProperty, index_level=indexLevel
  if (indexLevel ge 1L) then self.system->createIndexEntry, self.basename, self
  
  self.system->print, '  Parsing ' + self.basename + '...'
  
  return, 1
end


pro doctreedlmfile__define
  compile_opt strictarr
  
  define = { DOCtreeDLMFile, $
             system: obj_new(), $
             directory: obj_new(), $
             
             basename: '', $
             dlmFilename: '', $
             code: obj_new(), $                          
             
             modificationTime: '', $
             nLines: 0L, $
             format: '', $
             markup: '', $
             
             comments: obj_new(), $
             firstline: obj_new(), $
             
             routines: obj_new(), $
             
             hasAuthorInfo: 0B, $
             author: obj_new(), $
             version: obj_new(), $
             
             hasOthers: 0B $
  }
end