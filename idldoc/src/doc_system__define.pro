; docformat = 'rst'


;+
; This class represents the entire IDLdoc run. All information/settings for the
; run are stored (or at least accessible from) here.
;
; :Properties:
;    `root` : get
;       the directory containing the code to document
;    `output` : get
;       the directory to which to output the documentation
;    `classes` : get
;       hash table (classname -> DOCtreeClass) containing all class definitions
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
function doc_system::getVariable, name, found=found
  compile_opt strictarr
  
  found = 1B
  case strlowcase(name) of
    'version': return, self.version
    'date': return, systime()
    'title': return, self.title
    'subtitle': return, self.subtitle
    'user': return, self.user
    'statistics': return, self.statistics
    
    'preformat': return, self.preformat
    'embed': return, self.embed
    
    'output_root': return, self.output
    'relative_root': return, ''
        
    'n_dirs': return, self.directories->count()
    'dirs': return, self.directories->get(/all)    
    'n_pro_files': return, self.proFiles->count()
    'pro_files': return, self.proFiles->get(/all)
    'n_sav_files': return, self.savFiles->count()
    'sav_files': return, self.savFiles->get(/all)
    'n_idldoc_files': return, self.idldocFiles->count()
    'idldoc_files': return, self.idldocFiles->get(/all)

    'n_lines': begin
        if (self.proFiles->count() eq 0) then return, '0'
        
        nLines = 0L
        
        proFiles = self.proFiles->get(/all)
        for f = 0L, n_elements(proFiles) - 1L do begin
          proFiles[f]->getProperty, n_lines=fileLines
          nLines += fileLines
        endfor
        
        return, mg_int_format(nLines)
      end
    
    'current_template': return, self.currentTemplate
    'idldoc_header_location' : return, filepath('idldoc-header.tt', $
                                                subdir=['templates'], $
                                                root=self.sourceLocation)    
    'idldoc_footer_location' : return, filepath('idldoc-footer.tt', $
                                                subdir=['templates'], $
                                                root=self.sourceLocation)
    else: begin
        found = 0B
        return, -1L
      end
  endcase
end


;+
; Get properties of the system.
;-
pro doc_system::getProperty, root=root, output=output, classes=classes
  compile_opt strictarr

  if (arg_present(root)) then root = self.root
  if (arg_present(output)) then output = self.output
  if (arg_present(classes)) then classes = self.classes
end


;+
; Print out debugging information about the system object.
;-
pro doc_system::debug
  compile_opt strictarr
  
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
  
  if (~self.quiet && ~self.silent) then print, msg
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
; Get a template by name (as used when loaded in loadTemplates).
; 
; :Returns: template object or -1 if not found
;
; :Params:
;    `name` : in, required, type=string
;       name of template as used when loaded in loadTemplates
;
; :Keywords:
;    `found` : out, optional, type=boolean
;       indicates if the template name was found and returned
;-
function doc_system::getTemplate, name, found=found
  compile_opt strictarr
  
  self.currentTemplate = name
  return, self.templates->get(name, found=found)
end


;+
; Create the templates to be used to generate all the output and store the 
; templates in a hash table.
;-
pro doc_system::loadTemplates
  compile_opt strictarr
  
  templates = ['file-listing', 'all-files', 'dir-listing',  $
               'index', 'overview', 'help', 'warnings', 'index-entries', $
               'categories', 'search', $
               'dir-overview', 'savefile', 'profile', 'idldocfile']
  for t = 0L, n_elements(templates) - 1L do begin
    templateFilename = filepath(templates[t] + '.tt', $
                                subdir=['templates'], $
                                root=self.sourceLocation) 
    self.templates->put, templates[t], $
                         obj_new('MGffTemplate', templateFilename)
  endfor
end


;+
; Get a parser by name (as used when loaded in loadParsers).
; 
; :Returns: parser object or -1 if not found
;
; :Params:
;    `name` : in, required, type=string
;       name of parser as used when loaded in loadTemplates
;
; :Keywords:
;    `found` : out, optional, type=boolean
;       indicates if the parser name was found and returned
;-
function doc_system::getParser, name, found=found
  compile_opt strictarr
  
  return, self.parsers->get(name, found=found)
end


;+
; Create the parsers to be used to parse all the code/input files and store
; the templates in a hash table.
;-
pro doc_system::loadParsers
  compile_opt strictarr
  
  ; file parsers
  self.parsers->put, 'profile', obj_new('DOCparProFileParser', system=self)
  
  ; header comment parsers
  self.parsers->put, 'verbatimformat', obj_new('DOCparVerbatimFormatParser', system=self)
  self.parsers->put, 'rstformat', obj_new('DOCparRSTFormatParser', system=self)
  self.parsers->put, 'idldocformat', obj_new('DOCparIDLdocFormatParser', system=self)
  self.parsers->put, 'idlformat', obj_new('DOCparIDLFormatParser', system=self)
  
  ; markup parsers
  self.parsers->put, 'verbatimmarkup', obj_new('DOCparVerbatimMarkupParser', system=self)
  self.parsers->put, 'rstmarkup', obj_new('DOCparRSTMarkupParser', system=self)
  
  ; tree node parsers
  self.parsers->put, 'htmloutput', obj_new('MGtmHTML')
end


;+
; Generate all output for the run.
;-
pro doc_system::generateOutput
  compile_opt strictarr
  
  ; first, organize the pro/sav/idldoc files
  entries = self.index->values(count=nEntries)
  names = self.index->keys()
  
  if (nEntries gt 0) then begin
    ind = where(obj_isa(entries, 'DOCtreeProFile'), nProFiles)
    if (nProFiles gt 0) then begin
      proFiles = entries[ind]
      proFileNames = names[ind]
      sind = sort(proFileNames)
      self.proFiles->add, proFiles[sind]
    endif
      
    ind = where(obj_isa(entries, 'DOCtreeSavFile'), nSavFiles)
    if (nSavFiles gt 0) then begin
      savFiles = entries[ind]
      savFileNames = names[ind]
      sind = sort(savFileNames)
      self.savFiles->add, savFiles[sind]
    endif
    
    ind = where(obj_isa(entries, 'DOCtreeIDLdocFile'), nIDLdocFiles)
    if (nIDLdocFiles gt 0) then begin
      idldocFiles = entries[ind]
      idldocFileNames = names[ind]
      sind = sort(idldocFileNames)
      self.idldocFiles->add, idldocFiles[sind]
    endif    
  endif
        
  ; generate files per directory
  for d = 0L, self.directories->count() - 1L do begin
    directory = self.directories->get(position=d)
    directory->generateOutput, self.output
  endfor
      
  ; generate all-files
  self->print, 'Generating file listing...'
  allFilesTemplate = self->getTemplate('all-files')
  allFilesTemplate->reset
  allFilesTemplate->process, self, filepath('all-files.html', root=self.output)
    
  ; generate all-dirs
  self->print, 'Generating directory listing...'
  allDirsTemplate = self->getTemplate('dir-listing')
  allDirsTemplate->reset
  allDirsTemplate->process, self, filepath('all-dirs.html', root=self.output)
  
  ; generate overview page
  self->print, 'Generating overview page...'
  overviewTemplate = self->getTemplate('overview')
  overviewTemplate->reset
  overviewTemplate->process, self, filepath('overview.html', root=self.output)
    
  ; generate index entries page
  self->print, 'Generating index entries page...'
  indexEntriesTemplate = self->getTemplate('index-entries')
  indexEntriesTemplate->reset
  indexEntriesTemplate->process, self, filepath('idldoc-index.html', $
                                                root=self.output)
    
  ; generate warnings page
  self->print, 'Generating warnings page...'
  warningsTemplate = self->getTemplate('warnings')
  warningsTemplate->reset
  warningsTemplate->process, self, filepath('idldoc-warnings.html', $
                                            root=self.output)

  ; generate search page
  self->print, 'Generating search page...'
  searchTemplate = self->getTemplate('search')
  searchTemplate->reset
  searchTemplate->process, self, filepath('search.html', $
                                          root=self.output)
                                          
  ; generate categories page
  self->print, 'Generating categories page...'
  categoriesTemplate = self->getTemplate('categories')
  categoriesTemplate->reset
  categoriesTemplate->process, self, filepath('categories.html', $
                                              root=self.output)
  ; generate help page
  self->print, 'Generating help page...'
  helpTemplate = self->getTemplate('help')
  helpTemplate->reset
  helpTemplate->process, self, filepath('idldoc-help.html', root=self.output)
    
  ; generate index.html
  self->print, 'Generating index page...'
  indexTemplate = self->getTemplate('index')
  indexTemplate->reset
  indexTemplate->process, self, filepath('index.html', root=self.output)
end


;+
; Enter the item in the index.
; 
; :Params:
;    `name` : in, required, string
;       name to register the entry under
;    `value` : in, required, type=object
;       tree object (i.e. directory, file, param)
;-
pro doc_system::createIndexEntry, name, value
  compile_opt strictarr
  
  self.index->put, name, value
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


;+
; Creates a directory.
;
; :Params:
;    `dir` : in, required, type=string
;       directory to create
; :Keywords:
;    `error` : out, optional, type=long
;       error code; 0 indicates no error
;-
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
  
  obj_destroy, [self.index, self.proFiles, self.savFiles, self.idldocFiles]
  
  classes = self.classes->values(count=nClasses)
  if (nClasses gt 0) then obj_destroy, classes
  obj_destroy, self.classes
  
  obj_destroy, self.directories
  
  obj_destroy, self.templates->values()
  obj_destroy, self.templates
  obj_destroy, self.parsers->values()
  obj_destroy, self.parsers  
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
                           preformat=preformat, browse_routines=browseRoutines                           
  compile_opt strictarr
  
  self.version = idldoc_version()
  
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
  
  self.title = n_elements(title) gt 0 ? title : 'Documentation for ' + self.root
  self.subtitle = n_elements(subtitle) gt 0 ? subtitle : 'Generated by IDLdoc' 
  self.user = keyword_set(user)
  self.statistics = keyword_set(statistics)
  
  self.preformat = keyword_set(preformat)
  self.assistant = keyword_set(assistant)
  self.embed = keyword_set(embed)
    
  ; test output directory for write permission
  outputError = self->testOutput()
  if (outputError ne 0L) then self->error, 'unable to write to ' + self.output
  
  self.index = obj_new('MGcoHashTable', key_type=7, value_type=11)
  self.classes = obj_new('MGcoHashTable', key_type=7, value_type=11)
  
  self.proFiles = obj_new('MGcoArrayList', type=11)
  self.savFiles = obj_new('MGcoArrayList', type=11)
  self.idldocFiles = obj_new('MGcoArrayList', type=11)
  
  ; copy resources
  self->copyResources
  
  ; initialize some data structures
  self.directories = obj_new('MGcoArrayList', type=11)
  
  ; load templates
  self.templates = obj_new('MGcoHashTable', key_type=7, value_type=11)
  self->loadTemplates
  
  ; load parsers
  self.parsers = obj_new('MGcoHashTable', key_type=7, value_type=11)
  self->loadParsers
  
  ; parse tree of directories, files, routines, parameters 
  self->parseTree
    
  ; generate output for directories, files (of various kinds), index, etc.
  self->generateOutput
  
  nWarnings = self.nWarnings
  
  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    `version`
;       IDLdoc version
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
;    `sourceLocation`
;       directory containing the DOC_System__define.pro file
;    `directories`
;       array list of directories in current run
;    `templates`
;       hash table of template names to template objects
;    `parsers`
;       hash table of parser names to parser objects
;    `title`
;       title of the documentation
;    `subtitle`
;       subtitle of the documentation
;    `user`
;       set to generate user-level documentation (as opposed to developer-level
;       documentation)
;    `statistics`
;       set to generate statistics
;    `preformat`
;       set if comments should be formatted as given in the source
;    `assistant`
;       set to produce IDL Assistant output
;    `embed`
;       set to embed CSS in the HTML output
;    `currentTemplate`
;       most recently asked for template
;    `index`
;       hash table of names to tree objects
;    `proFiles`
;       array list of .pro files in current run
;    `savFiles`
;       array list of .sav files in current run
;    `idldocFiles`
;       array list of .idldoc files in current run
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
              
             templates: obj_new(), $
             parsers: obj_new(), $
             
             title: '', $
             subtitle: '', $
             user: 0B, $
             statistics: 0B, $
             
             preformat: 0B, $             
             assistant: 0B, $
             embed: 0B, $
             
             currentTemplate: '', $
             
             index: obj_new(), $
             classes: obj_new(), $ 
             
             proFiles: obj_new(), $
             savFiles: obj_new(), $
             idldocFiles: obj_new() $                 
           }
end