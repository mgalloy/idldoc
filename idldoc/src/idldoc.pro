; docformat = 'rst'

;+
; Generate documentation for IDL code.
;
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
pro idldoc, root=root, output=output, $
            quiet=quiet, silent=silent, n_warnings=nWarnings, log_file=logFile, $
            assistant=assistant, embed=embed, overview=overview, footer=footer, $
            title=title, subtitle=subtitle, nonavbar=nonavbar, $
            user=user, statistics=statistics, $
            preformat=preformat, browse_routines=browseRoutines
  compile_opt strictarr

  ; TODO: make sure to turn debug off before releasing
  debug = 1B
  
  if (~keyword_set(debug)) then begin
    error = 0L
    catch, error
    if (error ne 0L) then begin
      catch, /cancel
      message, !error_state.msg, /informational
      return
    endif
  endif
  
  cd, current=startDirectory
  
  system = obj_new('DOC_System', root=root, output=output, $
                   quiet=quiet, silent=silent, n_warnings=nWarnings, $
                   log_file=logFile, $
                   assistant=assistant, embed=embed, overview=overview, $
                   footer=footer, title=title, subtitle=subtitle, $
                   nonavbar=nonavbar, $
                   user=user, statistics=statistics, $
                   preformat=preformat, browse_routines=browseRoutines)
  
  obj_destroy, system
  cd, startDirectory
end