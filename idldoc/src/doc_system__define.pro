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
function doc_system::getVariable, name, found=found
  compile_opt strictarr
  
  found = 1B
  case strlowcase(name) of
    'version': return, self.version
    'date': return, systime()
    'title': return, self.title
    'subtitle': return, self.subtitle
    'output_root': return, self.output
    else: begin
        found = 0B
        return, -1L
      end
  endcase
end


pro doc_system::getProperty, root=root, sav_file_template=savFileTemplate
  compile_opt strictarr

  if (arg_present(root)) then root = self.root
  if (arg_present(savFileTemplate)) then savFileTemplate = self.savFileTemplate
end


;+
; Print out debugging information about the system object.
;-
pro doc_system::debug
  compile_opt strictarr
  
  print, 'ROOT = ' + self.root
  print, 'OUTPUT = ' + self.output
end


;+
; Print error messages respecting /QUIET and /SILENT.
;
; :Params:
;    `msg` : in, required, type=string
;       error message to print 
;-
pro doc_system::error, msg
  compile_opt strictarr
  on_error, 2
  
  message, msg, /noname
end


;+
; Print warning messages respecting /QUIET and /SILENT.
;
; :Params:
;    `msg` : in, required, type=string
;       warning message to print 
;-
pro doc_system::warning, msg
  compile_opt strictarr
  
  if (~self.silent) then message, msg, /informational
  ++self.nWarnings
end


;+
; Print messages respecting /QUIET and /SILENT.
;
; :Params:
;    `msg` : in, required, type=string
;       message to print 
;-
pro doc_system::print, msg
  compile_opt strictarr
  
  if (~self.quiet || ~self.silent) then print, msg
end


;+
; Build the tree of directories, files, routines, and parameters.
;-
pro doc_system::parseTree
  compile_opt strictarr
  
  ; search for special files
  proFiles = file_search(self.root, '*.pro', /test_regular, count=nProFiles)
  savFiles = file_search(self.root, '*.sav', /test_regular, count=nSavFiles)
  idldocFiles = file_search(self.root, '*.idldoc', /test_regular, count=nIDLdocFiles)
  
  ; quit if no files found
  if (nProFiles + nSavFiles + nIDLdocFiles eq 0) then return
  
  ; add all the files together
  allFiles = ['']
  if (nProFiles gt 0) then allFiles = [allFiles, proFiles]
  if (nSavFiles gt 0) then allFiles = [allFiles, savFiles]
  if (nIDLdocFiles gt 0) then allFiles = [allFiles, idldocFiles]
  allFiles = allFiles[1:*]
  
  ; remove the common root location
  allFiles = strmid(allFiles, strlen(self.root))
  
  ; get the unique directories
  dirs = file_dirname(allFiles, /mark_directory)
  uniqueDirIndices = uniq(dirs, sort(dirs))  
  
  ; create the directory objects
  for d = 0L, n_elements(uniqueDirIndices) - 1L do begin
     location = dirs[uniqueDirIndices[d]]
     filesIndices = where(dirs eq location)
     directory = obj_new('DOCtreeDirectory', $
                         location=location, $
                         files=allFiles[filesIndices], $
                         system=self)
     self.directories->add, directory
  endfor
end


;+
; Generate all output for the run.
;-
pro doc_system::generateOutput
  compile_opt strictarr
  on_error, 2
  
  ; generate files per directory
  for d = 0L, self.directories->count() - 1L do begin
    directory = self.directories->get(position=d)
    directory->generateOutput, self.output
  endfor
  
  ; TODO: finish this
    
  ; generate index
  
  ; generate warnings page
  
  ; generate help
  
  ; generate index.html
end


;+
; Determine if the output directory can be written to.
;
; :Returns: error code (0 indicates no error)
;-
function doc_system::testOutput
  compile_opt strictarr
    
  testfile = self.output + 'idldoc.test'
  openw, lun, testfile, error=error, /get_lun
  if (error eq 0L) then free_lun, lun
  file_delete, testfile, /allow_nonexistent
  
  return, error
end


;+
; Copy everything that is in the resources directory of the distribution to
; the idldoc-resources directory in the output root.
;-
pro doc_system::copyResources
  compile_opt strictarr
  
  resourceLocation = filepath('', subdir=['resources'], $
                              root=self.sourceLocation)
  resourceDestination = filepath('', subdir=['idldoc-resources'], $
                                 root=self.output)
  file_delete, resourceDestination, /recursive, /allow_nonexistent
  file_copy, resourceLocation, resourceDestination, /recursive, /overwrite
end


pro doc_system::makeDirectory, dir, error=error
  compile_opt strictarr
  
  error = 0L
  catch, error
  if (error ne 0L) then begin
    catch, /cancel
    return
  endif
  
  file_mkdir, dir
end


;+
; Free resources.
;-
pro doc_system::cleanup
  compile_opt strictarr
  
  obj_destroy, self.directories
  obj_destroy, self.savFileTemplate
end


;+
; Create system object.
; 
; :Returns: 1 for success, 0 for failure
; :Keywords:
;    `root` : in, required, type=string
;       root of directory hierarchy to document
;    `output` : in, optional, type=string
;       directory to place output
;
;    `quiet` : in, optional, type=boolean
;       if set, don't print info messages, only print warnings and errors
;    `silent` : in, optional, type=boolean
;       if set, don't print anything
;    `n_warnings` : out, optional, type=long
;       set to a named variable to return the number of warnings for the run
;    `log_file` : in, optional, type=string
;       if present, send messages to this filename instead of stdout
;    `assistant` : in, optional, type=boolean
;       set to generate docs in IDL Assistant format
;    `embed` : in, optional, type=boolean
;       embed CSS stylesheet instead of linking to it (useful for documentation
;       where individual pages must stand by themselves)
;    `overview` : in, optional, type=string
;       filename of overview text and directory information
;    `footer` : in, optional, type=string
;       filename of file to insert into the bottom of each page of docs
;    `title` : in, optional, type=string
;       title of docs
;    `subtitle` : in, optional, type=string
;       subtitle for docs
;    `nonavbar` : in, optional, type=boolean
;       set to not display the navbar
;
;    `user` : in, optional, type=boolean
;       set to generate user-level docs (private parameters, files are not
;       shown); the default is developer-level docs showing files and 
;       parameters
;    `statistics` : in, optional, type=boolean
;       generate complexity statistics for routines
;
;    `preformat` : in, optional, type=boolean, obsolete
;       no longer used
;    `browse_routines` : in, optional, type=boolean, obsolete
;       no longer used
;-
function doc_system::init, root=root, output=output, $
                           quiet=quiet, silent=silent, n_warnings=nWarnings, $
                           log_file=logFile, $
                           assistant=assistant, embed=embed, overview=overview, $
                           footer=footer, title=title, subtitle=subtitle, $
                           nonavbar=nonavbar, $
                           user=user, statistics=statistics, $
                           preformat=preformat, browse_routines                           
  compile_opt strictarr
  on_error, 2
  
  ; TODO: change to appropriate value on release
  self.version = '3.0 development'
  
  ; check root directory
  if (n_elements(root) gt 0) then begin
    self.root = file_search(root, /mark_directory, /test_directory)
    if (self.root eq '') then self->error, 'ROOT directory does not exist'
  endif else begin
    self->error, 'ROOT keyword must be defined'
  endelse
  
  ; fix up output directory
  if (n_elements(output) gt 0) then begin
    if (~file_test(output)) then begin
      self->makeDirectory, output, error=error
      if (error ne 0L) then self->error, 'can not create output directory'
    endif
    self.output = file_search(output, /mark_directory, /test_directory)
  endif else begin
    self.output = self.root
  endelse
  
  ; get location of IDLdoc in order to find locations of data files like
  ; images, templates, etc.
  self.sourceLocation = mg_src_root()
  
  self.quiet = keyword_set(quiet)
  self.silent = keyword_set(silent)
  
  self.title = n_elements(title) gt 0 ? title : 'Documenation for ' + self.root
  self.subtitle = n_elements(subtitle) gt 0 ? subtitle : 'Generated by IDLdoc' 
  
  ; test output directory for write permission
  outputError = self->testOutput()
  if (outputError ne 0L) then self->error, 'unable to write to ' + self.output
  
  ; copy resources
  self->copyResources
  
  ; initialize some data structures
  self.directories = obj_new('MGcoArrayList', type=11)
  
  ; load templates
  templateFilename = filepath('savefile.tt', $
                              subdir=['templates'], $
                              root=self.sourceLocation)
  self.savFileTemplate = obj_new('MGffTemplate', templateFilename)
  
  ; parse tree of directories, files, routines, parameters 
  self->parseTree
    
  ; generate output for directories, files (of various kinds), index, etc.
  self->generateOutput
  
  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    `root` 
;       root directory of hierarchy to document; full path ending with slash
;    `output`
;       directory to place output
;    `nWarnings` 
;       number of warning messages printed
;    `quiet`
;       set to only print errors and warnings
;    `silent`
;       don't print anything
;-
pro doc_system__define
  compile_opt strictarr
  
  define = { DOC_System, $
             version: '', $
             root: '', $
             output: '', $
             nWarnings: 0L, $
             quiet: 0B, $
             silent: 0B, $
             sourceLocation: '', $
             directories: obj_new(), $  
             savFileTemplate: obj_new(), $  
             title: '', $
             subtitle: '' $         
           }
end