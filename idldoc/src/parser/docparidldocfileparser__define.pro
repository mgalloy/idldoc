; docformat = 'rst'

;+
; Parses .idldoc files.
;-

;+
; Parse the given .idldoc file.
; 
; :Returns: file tree object
; :Params:
;    `filename` : in, required, type=string
;       absolute path to .pro file to be parsed
; :Keywords:
;    `found` : out, optional, type=boolean
;       returns 1 if filename found, 0 otherwise
;-
function docparidldocfileparser::parse, filename, found=found, directory=directory
  compile_opt strictarr

  file = obj_new('DOCtreeIDLdocFile', $
                 basename=file_basename(filename), $
                 directory=directory, $
                 system=self.system)

  ; TODO: lookup docformat string at beginning of file? at least use defaults 
  ; stored in self.format and self.markup instead of these hard-coded parsers
  formatParser = self.system->getParser('verbatimformat')
  markupParser = self.system->getParser('verbatimmarkup')
    
  nLines = file_lines(filename)
  if (nLines gt 0) then begin
    comments = strarr(nLines)
    openr, lun, filename, /get_lun
    readf, lun, comments
    free_lun, lun
    
    ; call format parser's "parse" method
    formatParser->parseIDLdocComments, comments, file=file, $
                                       markup_parser=markupParser
  endif
                   
  return, file
end


;+
; Create an idldoc file parser.
;
; :Keywords:
;    `format` : in, optional, type=string, default=idldoc
;       format of comments: IDLdoc, IDL, or rst
;    `markup` : in, optional, type=string, default=verbatim
;       style of markup: verbatim or rst
;-
function docparidldocfileparser::init, system=system, format=format, markup=markup
  compile_opt strictarr
  
  self.system = system
  self.format = n_elements(format) eq 0 ? 'idldoc' : format
  self.markup = n_elements(markup) eq 0 ? 'verbatim' : markup
  
  return, 1
end


;+
; Define instance variables.
;
; :Fields:
;    `filename` absolute path to the .idldoc file to be parsed
;-
pro docparidldocfileparser__define
  compile_opt strictarr
  
	define = { DOCparIDLdocFileParser, $
	           system: obj_new(), $
             format: '', $
             markup: '' $
           }
end