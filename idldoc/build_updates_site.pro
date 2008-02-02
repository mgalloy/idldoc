; docformat = 'rst'

;+
; Build all the files necessary for the updates.idldev.com site to give 
; updates for IDLdoc through the IDL Workbench.
;-
pro build_updates_site
  compile_opt strictarr
  
  root = mg_src_root()
  vars = { version: idldoc_version() }
    
  ttfile = filepath('site.xml.tt', root=root)
  outfile = filepath('site.xml', subdir='updates.idldev.com', root=root)
  
  template = obj_new('MGffTemplate', ttfile)
  template->process, vars, outfile
  obj_destroy, template
end