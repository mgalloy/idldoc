;+
; Document IDL code.
;
; :Keywords:
;    `root` : in, required, type=string
;       root of directory hierarchy to document
;    `output` : in, optional, type=string
;       directory to place output
;    `quiet` : in, optional, type=boolean
;       if set, don't print info messages, only print warnings and errors
;    `silent` : in, optional, type=boolean
;       if set, don't print anything
;-
pro idldoc, root=root, output=output, $
            quiet=quiet, silent=silent
  compile_opt strictarr

  cd, current=startDirectory
  
  system = obj_new('DOC_System', root=root, output=output, $
                   quiet=quiet, silent=silent)
  
  obj_destroy, system
  cd, startDirectory
end