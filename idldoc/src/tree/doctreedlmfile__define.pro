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
  case strlowcase(name) of
    'basename' : return, self.basename
    'local_url' : return, file_basename(self.basename, '.dlm') + '-dlm.html'

    'description': return, ''

    'has_comments': return, self.comments ne ''
    'comments': return, self.comments
    'comments_first_line': return, self.comments
    'plain_comments': return, self.comments

    'has_dlm_info': return, self.author ne '' || self.version ne '' || self.moduleName ne '' || self.build_date ne '' || self.comments ne ''
    
    'has_author': return, self.author ne ''
    'author': return, self.author
    'plain_author': return, self.author

    'has_version': return, self.version ne ''
    'version': return, self.version

    'has_module_name': return, self.moduleName ne ''
    'module_name': return, self.moduleName

    'has_build_date': return, self.buildDate ne ''
    'build_date': return, self.buildDate
            
    'modification_time': return, self.modificationTime

    'n_routines' : return, self.routines->count()
    'routines' : return, self.routines->get(/all)
    'n_visible_routines' : return, self.routines->count()
    'visible_routines' : return, self.routines->get(/all)
    
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
  endcase
end


;+
; Get properties.
;-
pro doctreedlmfile::getProperty, basename=basename, directory=directory, $
                                 has_class=hasClass
  compile_opt strictarr
  
  if (arg_present(basename)) then basename = self.basename
  if (arg_present(directory)) then directory = self.directory
  if (arg_present(hasClass)) then hasClass = 0B
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


pro doctreedlmfile::_addRoutine, line, is_function=isFunction
  compile_opt strictarr
  
  tokens = strsplit(line, /extract, count=ntokens)
  
  routine = obj_new('DOCtreeRoutine', self, system=self.system)
  self.routines->add, routine  

  routine->setProperty, name=tokens[1], is_function=keyword_set(isFunction)
  
  minParams = long(tokens[2])
  maxParams = long(tokens[3])
  
  for p = 0L, maxParams -1L do begin
    paramName = 'param' + strtrim(p, 2)
    param = obj_new('DOCtreeArgument', routine, name=paramName, $
                    system=self.system)
    param->setProperty, is_optional=p lt minParams
    routine->addParameter, param
  endfor

  for options = 4, ntokens - 1L do begin
    case strlowcase(tokens[options]) of
      'keywords': begin
          keyword = obj_new('DOCtreeArgument', routine, name='KEYWORDS', $
                            /is_keyword, system=self.system)                          
          routine->addKeyword, keyword
        end
      'obsolete': routine->setProperty, is_obsolete=1B
      else:
    endcase
  endfor  
end


pro doctreedlmfile::_loadDLMContents
  compile_opt strictarr
  
  ; read DLM file
  nlines = file_lines(self.dlmFilename)
  lines = strarr(nlines)
  openr, lun, self.dlmFilename, /get_lun
  readf, lun, lines
  free_lun, lun
  
  ; parse file
  for i = 0L, nlines - 1L do begin
    tokens = strsplit(lines[i], length=len)
    case strlowcase(strmid(lines[i], tokens[0], len[0])) of
      'module': self.moduleName = strtrim(strmid(lines[i], tokens[0] + len[0]), 2)
      'description': self.comments = strtrim(strmid(lines[i], tokens[0] + len[0]), 2)
      'version': self.version = strtrim(strmid(lines[i], tokens[0] + len[0]), 2)
      'build_date': self.buildDate = strtrim(strmid(lines[i], tokens[0] + len[0]), 2)
      'source': self.author = strtrim(strmid(lines[i], tokens[0] + len[0]), 2)
      'checksum': self.checksum = strtrim(strmid(lines[i], tokens[0] + len[0]), 2)
      'structure': self.structure = strtrim(strmid(lines[i], tokens[0] + len[0]), 2)
      'procedure': self->_addRoutine, lines[i]
      'function': self->_addRoutine, lines[i], /is_function
      else:
    endcase
  endfor
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
    
  obj_destroy, self.routines
  
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
  
  info = file_info(self.dlmFilename)
  self.modificationTime = systime(0, info.mtime)
    
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
             moduleName: '', $
             buildDate: '', $  
             checksum: '', $
             structure: '', $           
             code: obj_new(), $                          
             
             modificationTime: '', $
             nLines: 0L, $
             format: '', $
             markup: '', $
                          
             comments: '', $
             firstline: '', $
             
             routines: obj_new(), $
             
             hasAuthorInfo: 0B, $
             author: '', $
             version: '', $
             
             hasOthers: 0B $
  }
end