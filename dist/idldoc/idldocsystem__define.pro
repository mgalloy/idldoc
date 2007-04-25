;+
; System service to copy a file.
;
; @param src {in}{required}{type=string} source filename
; @param dst {in}{required}{type=string} destination filename; will overwrite
;        if it already exists
;-
pro idldocsystem::filecopy, src, dst
    compile_opt strictarr

    error = 0
    catch, error
    if (error ne 0) then begin
        catch, /cancel
        self->addWarning, 'Error copying ' + src + ' to ' + dst + '.'
        return
    endif

    file_copy, src, dst, /overwrite
end


;+
; Increments the number of warnings.
;
; @param msg {in}{required}{type=string} message indicating the warning
;-
pro idldocsystem::addWarning, msg
    compile_opt strictarr

    if (~self.silent) then begin
        printf, self.log_lun, 'WARNING: ' + msg
    endif
    self.warnings++
end


;+
; IDLdoc version is returned.
;
; @returns string representing IDLdoc's current version
; @keyword build {in}{optional}{type=boolean} set to return a string with the
;          build date in it also
;-
function idldocsystem::getVersion, build=build
    compile_opt strictarr

    return, self.version $
        + (keyword_set(build) ? (', build date ' + self.build_date) : '')
end


;+
; Retrieve properties of the system object.
;
; @keyword root {out}{optional}{type=string} Root directory of this IDLdoc run.
;          This directory path ends with a slash.
; @keyword idldoc_root {out}{required}{type=string} location of IDLdoc
;          installation directory
; @keyword output {out}{optional}{type=string} location for output
; @keyword index {out}{optional}{type=objref} IDLdocIndex object (contains index
;          information)
; @keyword taglisting {out}{optional}{type=objref} IDLdocTagListing object
;          (contains category information)
; @keyword classhierarchy {out}{opptional}{type=objref} IDLdocClassHierarchy
;          object
; @keyword warnings {out}{optional}{type=integer} number of warnings IDLdoc has
;          issued
; @keyword silent {out}{optional}{type=boolean} true if no messages are to be
;          printed
; @keyword quiet {out}{optional}{type=boolean} true if only errors are to be
;          printed
; @keyword statistics {out}{optional}{type=boolean} true if statistics are to
;          be calculated and for each routine
; @keyword nonavbar {out}{optional}{type=boolean} indicates if the navbar should
;          be present on each main page
; @keyword user {out}{optional}{type=boolean} true if USER documentation is to
;          be produced, false if DEVELOPER documentation is to be produced
; @keyword embed {out}{optional}{type=boolean} true if CSS is to be embedded in
;          the documentation for each page, false if CSS is linked to
; @keyword preformat {out}{optional}{type=boolean} true if comments are to be set
;          in PRE tags
; @keyword title {out}{optional}{type=string} title of the library
; @keyword subtitle {out}{optional}{type=string} subtitle of the library
; @keyword footer {out}{optional}{type=string} filename of footer to place on
;          each main page
; @keyword assistant {out}{optional}{type=boolean} true if producing output for
;          the IDL assistant help system, false if producing output for a web
;          browser
; @keyword template_prefix {out}{optional}{type=string} string to prepend to
;          template names
; @keyword file_template {out}{optional}{type=object} IDLdocObjTemplate object
;          of the pro-file.tt
;-
pro idldocsystem::getProperty, root=root, idldoc_root=idldoc_root, $
    output=output, index=index, taglisting=taglisting, $
    classhierarchy=classhierarchy, $
    warnings=warnings, silent=silent, quiet=quiet, statistics=statistics, $
    nonavbar=nonavbar, user=user, embed=embed, preformat=preformat, $
    title=title, subtitle=subtitle, footer=footer, $
    assistant=assistant, template_prefix=template_prefix, $
    file_template=file_template

    compile_opt strictarr

    idldoc_root = self.idldoc_root
    root = self.root
    output = self.output
    index = self.index
    taglisting = self.taglisting
    classhierarchy = self.classhierarchy

    warnings = self.warnings
    silent = self.silent
    quiet = self.quiet
    statistics = self.statistics

    nonavbar = self.nonavbar
    title = self.title
    subtitle = self.subtitle
    footer = self.footer

    user = self.user
    embed = self.embed
    preformat = self.preformat

    assistant = self.assistant
    template_prefix = self.template_prefix
    file_template = self.file_template
end


;+
; Free resources.
;-
pro idldocsystem::cleanup
    compile_opt strictarr

    if (self.log_lun gt 0) then begin
        msg = strtrim(self.warnings, 2) + ' warning' + (self.warnings eq 1 ? '' : 's')
        printf, self.log_lun, msg
        free_lun, self.log_lun
    endif
    obj_destroy, [self.index, self.taglisting, self.classhierarchy, self.file_template]
end


;+
; System object for IDLdoc. The system object holds all global registries
; and other information needed in many parts of the application.
;
; @returns 1 for success, 0 otherwise
;
; @keyword root {in}{required}{type=string} Root directory of this IDLdoc run
; @keyword idldoc_root {in}{required}{type=string} location of IDLdoc
;          installation directory
; @keyword log_file {in}{required}{type=string} absolute path to a log file or
;          empty string if no log file
; @keyword output {in}{required}{type=string} location for output
; @keyword silent {in}{optional}{type=boolean} set if no messages are to be
;          printed
; @keyword quiet {in}{optional}{type=boolean} set if only errors are to be
;          printed
; @keyword statistics {in}{optional}{type=boolean} set if statistics are to be
;          computed
; @keyword nonavbar {in}{optional}{type=boolean}{default=false} indicates if
;          the navbar should be present on each main page.
; @keyword user {in}{optional}{type=boolean}{default=false} true if USER
;          documentation is to be produced, false if DEVELOPER documentation is
;          to be produced
; @keyword embed {in}{optional}{type=boolean}{default=false} true if CSS is to
;          be embedded in the documentation for each page, false if CSS is
;          linked to
; @keyword preformat {in}{optional}{type=boolean} true if comments are to be set
;          in PRE tags
; @keyword title {in}{optional}{type=string}{default='IDLdoc API documentation'}
;          title of the library
; @keyword subtitle {in}{optional}{type=string}{default='Produced on ...'}
;          subtitle of the library
; @keyword footer {in}{optional}{type=string} filename of footer to place at
;          the bottom of each main file
; @keyword assistant {in}{optional}{type=boolean} set if producing output for
;          the IDL assistant help system, otherwise producing output for a web
;          browser
; @keyword template_prefix {in}{optional}{type=string} string to prepend to
;          template names
;-
function idldocsystem::init, root=root, idldoc_root=idldoc_root, $
    log_file=log_file, $
    output=output, $
    silent=silent, quiet=quiet, $
    statistics=statistics, $
    nonavbar=nonavbar, user=user, embed=embed, preformat=preformat, $
    title=title, subtitle=subtitle, footer=footer, $
    assistant=assistant, template_prefix=template_prefix

    compile_opt strictarr

    self.idldoc_root = idldoc_root
    self.root = file_expand_path(expand_path(n_elements(root) eq 0 ? '.' : root))
    self.output = file_expand_path(expand_path(output))
    self.log_file = log_file
    if (self.log_file ne '') then begin
        openw, lun, self.log_file, /get_lun
        self.log_lun = lun
    endif else self.log_lun = -2L

    self.title = n_elements(title) eq 0 ? 'IDLdoc API documentation' : title
    self.subtitle = n_elements(subtitle) eq 0 $
        ? 'Produced on ' + systime() $
        : subtitle
    self.nonavbar = keyword_set(nonavbar)
    self.footer = n_elements(footer) eq 0 ? '' : footer
    self.user = keyword_set(user)
    self.embed = keyword_set(embed)
    self.preformat = keyword_set(preformat)
    self.assistant = keyword_set(assistant)

    self.silent = keyword_set(silent)
    self.quiet = keyword_set(quiet)
    self.statistics = keyword_set(statistics)

    ; Calculate IDLdoc version
    self.version = '2.0'

    sav_file = self.idldoc_root + 'idldoc.sav'
    self.build_date = file_test(sav_file) $
        ? systime(0, (file_info(sav_file)).mtime) $
        : ''

    self.index = obj_new('IDLdocIndex')
    self.taglisting = obj_new('IDLdocTagListing')
    self.classhierarchy = obj_new('IDLdocClassHierarchy')

    self.warnings = 0L
    self.template_prefix = n_elements(template_prefix) eq 0 $
        ? '' $
        : template_prefix
    self.template_prefix += keyword_set(assistant) ? 'idla-' : ''

    self.file_template = obj_new('idldocobjtemplate', $
        filepath(self.template_prefix + 'pro-file.tt', subdir=['templates'], $
            root=self.idldoc_root))

    ; write log header if log_file present
    if (self.log_lun gt 0) then begin
        printf, self.log_lun, 'Running IDLdoc on ' + self.root
    endif

    return, 1
end


;+
; Define instance variables for IDLdocSystem class.
;
; @file_comments System object that holds all global information about the run.
; @field idldoc_root location of idldoc installation directory
; @field root The root directory of this IDLdoc run. This is the full expanded
;        path to the top of the directory hierarchy that IDLdoc is documenting.
;        This directory path ends with a (operating system appropriate) slash.
; @field output Directory for output.
; @field version Current version of IDLdoc.
; @field build_date Date of creation of the IDLdoc SAV file.
; @field title
; @field subtitle
; @field nonavbar Indicates if the navbar should be present on each main page.
; @field footer
; @field embed
; @field preformat
; @field user
; @field assistant
; @field silent
; @field quiet
; @field statistics
; @field taglisting IDLdocTagListing object
; @field classHierarchy
; @field warnings number of warnings
;-
pro idldocsystem__define
    compile_opt strictarr

    define = { idldocsystem, $
        idldoc_root     : '', $
        root            : '', $
        output          : '', $
        log_file        : '', $
        log_lun         : 0L, $
        version         : '', $
        build_date      : '', $
        title           : '', $
        subtitle        : '', $
        nonavbar        : 0B, $
        footer          : '', $
        embed           : 0B, $
        preformat       : 0B, $
        user            : 0B, $
        assistant       : 0B, $
        silent          : 0B, $
        quiet           : 0B, $
        statistics      : 0B, $
        index           : obj_new(), $
        taglisting      : obj_new(), $
        classhierarchy  : obj_new(), $
        warnings        : 0L, $
        file_template   : obj_new(), $
        template_prefix : '' $
        }
end