;+
; Restores a given variable from a SAV file. Must use strange variable names
; in order to avoid clash with the variable name of the restored variable.
;
; @returns variable restored
; @param idldocsavfile_savefile {in}{required}{type=object} IDL_SaveFile object
; @param idldocsavfile_variable_name {in}{required}{type=string} name of
;        variable to restore
;-
function idldocsavfile::restore_var, $
    idldocsavfile_savefile, $
    idldocsavfile_variable_name

    compile_opt strictarr

    idldocsavfile_error = 0L
    catch, idldocsavfile_error
    if (idldocsavfile_error ne 0) then begin
        catch, /cancel
        return, ''
    endif

    idldocsavfile_savefile->restore, idldocsavfile_variable_name
    statement = 'return, ' + idldocsavfile_variable_name
    @idldoc_execute
    ;idldocsavfile_result = execute('return, ' + idldocsavfile_variable_name, 1, 1)
end


;+
; Creates an PNG image file for a variable.
;
; @returns filename of the image file or '' if none is created
; @param osave {in}{required}{type=object} IDL_SaveFile object
; @param varname {in}{required}{type=string} name of variable in SAV file
; @keyword declaration {out}{optional}{type=string} IDL declaration for the variable
;-
function idldocsavfile::make_image_file, osave, varname, $
    declaration=declaration
    compile_opt strictarr

    var = self->restore_var(osave, varname)
    declaration = idldoc_idl_declaration(var)
    result = idldoc_make_variable_image(var, image=im)
    type = size(var, /type)
    if (type eq 8 || type eq 10) then heap_free, var
    if (type eq 11) then obj_destroy, var
    if result then begin
        filename = 'idldoc-varimage-' + varname + '.png'
        write_png, self.outpath + filename, im
        return, filename
    endif else return, ''
end


;+
; Queries SAV file for variable names and, possibly, additional information.
;
; @returns array of structures with definition
;          <code>{ name:'', declaration:'', filename:''}</code>
; @param osave {in}{required}{type=object} IDL_SAVFile reference
; @keyword count {out}{optional}{type=integer} number of variables found
; @keyword variable {in}{optional}{type=boolean} set to query for regular
;          variables; in this case all information in the return structure
;          is filled in
; @keyword system_variable {in}{optional}{type=boolean} set to query for
;          system variables; in this case only the name field of the return
;          structure is filled in
; @keyword structure_definition {in}{optional}{type=boolean} set to query for
;          structure definitions; in this case the only the name field of the
;          return structure is filled in
; @keyword common_block {in}{optional}{type=boolean} set to query for common
;          block definitions; in this case the name and declaration fields of
;          the return structure are filled in
;-
function idldocsavfile::findVariables, osave, count=nvars, variable=variable, $
    system_variable=system_variable, structure_definition=structure_definition, $
    common_block=common_block
    compile_opt strictarr

    vars = osave->names(count=nvars, system_variable=system_variable, $
        structure_definition=structure_definition, common_block=common_block)
    vars_info = replicate({ name:'', declaration:'', filename:''}, $
        n_elements(vars) > 1)
    for i = 0, nvars - 1L do begin
        vars_info[i].name = vars[i]
        case 1B of
        keyword_set(variable) : begin
                filename = self->make_image_file(osave, vars[i], $
                    declaration=declaration)
                vars_info[i].declaration = declaration
                vars_info[i].filename = filename
            end
        keyword_set(common_block) : begin
                cnames = osave->names(common_variable=vars[i])
                vars_info[i].declaration = 'common ' + vars[i] + ', ' $
                    + strjoin(cnames, ', ')
            end
        else :
        endcase
    endfor

    return, vars_info
end


;+
; Query SAV file for properties.
;
; @keyword url {out}{optional}{type=string} url from root to SAV file
; @keyword nlines {out}{optional}{type=long} number of lines in the file;
;          always set to 0 -- this is only here so that the caller doesn't
;          have to know if the object is a IDLdocSavFile or IDLdocFile
; @keyword n_visible_routines {out}{optional}{type=long} number of visible
;          routines in the file
;-
pro idldocsavfile::getProperty, url=url, n_visible_routines=n_visible_routines, $
    nlines=nlines
    compile_opt strictarr

    url = self.url
    n_visible_routines = self.nfunctions + self.nprocedures
    nlines = 0L
end


;+
; Queries the SAV file for information.
;
; @returns structure of information about the SAV file
; @requires IDL 6.1
;-
function idldocsavfile::getData
    compile_opt strictarr

    osave = obj_new('idl_savefile', self.absolute_filename)
    info = osave->contents()

    self.nfunctions = info.n_function
    self.nprocedures = info.n_procedure

    sav_dir = file_dirname(self.filename)
    sav_dir = strlen(sav_dir) eq 2 ? sav_dir : strmid(sav_dir, 2)

    info = { $
        sav_basefilename : file_basename(self.filename), $
        sav_dir : sav_dir, $
        sav_description : info.description, $
        sav_filetype : info.filetype, $
        sav_user : info.user, $
        sav_host : info.host, $
        sav_date : info.date, $
        sav_arch : info.arch, $
        sav_os : info.os, $
        sav_release : info.release, $
        ncommon : info.n_common, $
        common_info : self->findVariables(osave, /common_block), $
        nvar : info.n_var, $
        var_info : self->findVariables(osave, /variable), $
        nsystem : info.n_sysvar, $
        system_info : self->findVariables(osave, /system_variable), $
        nproc : info.n_procedure, $
        proc_info : '', $
        nfunc : info.n_function, $
        func_info : '', $
        nobj : info.n_object_heapvar, $
        nptr : info.n_pointer_heapvar, $
        nstructdef : info.n_structdef, $
        structdef_info : self->findVariables(osave, /structure_definition) $
        }
    obj_destroy, osave

    return, info
end


;+
; Generates output for the entire file in a file with the same name as the
; input .sav file, but with an -sav.html extension.
;-
pro idldocsavfile::output
    compile_opt strictarr

    self.system->getProperty, output=output

    reloutpath = file_dirname(self.filename, /mark_directory)
    self.outpath = output + (strmid(reloutpath, 0, 1) eq '.' ? strmid(reloutpath, 1) : reloutpath)
    outfilename = self.outpath + file_basename(self.filename, '.sav') + '-sav.html'

    slashes = stroccur(self.filename, '\/:', count=levels)
    root = ''
    for i = 0, levels - 2 do root = root + '../'

    if (~file_test(self.outpath, /directory)) then begin
        file_mkdir, self.outpath
    endif

    openw, lun, outfilename, /get_lun, error=error
    if (error ne 0) then begin
        osystem->addWarning, 'Error opening ' + filename + ' for writing.'
        return
    endif

    self.system->getProperty, title=title, subtitle=subtitle, user=user, $
        embed=embed, nonavbar=nonavbar, idldoc_root=idldoc_root, $
        footer=footer, template_prefix=tp, assistant=assistant

    sdata = { $
        version : self.system->getVersion(), $
        date : systime(), $
        embed : embed, $
        root : root, $
        css_location : $
            filepath('main_files.css', subdir=['resource'], root=idldoc_root), $
        print_css_location : $
            filepath('main_files_print.css', subdir=['resource'], root=idldoc_root), $
        title : title, $
        subtitle : subtitle, $
        user : user, $
        nonavbar : nonavbar, $
        navbar_filename : $
            filepath(tp + 'navbar.tt', subdir=['templates'], root=idldoc_root), $
        overview_href : root + (assistant ? 'home.html' : 'overview.html'), $
        overview_selected : 0B, $
        dir_overview_href : '', $
        dir_overview_selected : 0B, $
        categories_href : root + 'idldoc-categories.html', $
        categories_selected : 0B, $
        index_href : root + 'idldoc-index.html', $
        index_selected : 0B, $
        search_href : root + 'search-page.html', $
        search_selected : 0B, $
        file_selected : 1B, $
        source_href : '', $
        source_selected : 0B, $
        help_href : root + 'idldoc-help.html', $
        help_selected : 0B, $
        etc_selected : 0B, $
        next_file_href : '', $
        prev_file_href : '', $
        view_single_page_href : file_basename(self.url), $
        view_frames_href : root + 'index.html', $
        summary_fields_href : '', $
        summary_routine_href : '', $
        details_routine_href : '', $
        footer : footer, $
        tagline_filename : $
            filepath(tp + 'tagline.tt', subdir=['templates'], root=idldoc_root) $
        }

    sdata = create_struct(self->getData(), sdata)

    oTemplate = obj_new('template', $
        filepath(tp + 'sav-file.tt', subdir=['templates'], root=idldoc_root))
    oTemplate->process, sdata, lun=lun
    obj_destroy, oTemplate

    free_lun, lun
end


;+
; Free resources.
;-
pro idldocsavfile::cleanup
    compile_opt strictarr

end


;+
; Initialze the SAV file object.
;
; @returns 1 for success
; @param filename {in}{required}{type=string} filename of SAV file relative to root
; @param absolute_filename {in}{required}{type=string} absolute filename of SAV file
; @keyword system {in}{required}{type=objref} IDLdocSystem object reference
;-
function idldocsavfile::init, filename, absolute_filename, system=system
    compile_opt strictarr

    self.filename = filename
    self.absolute_filename = absolute_filename

    bname = byte(file_dirname(self.filename))
    ; ASCII 92 (backslash) -> ASCII 47 (forward slash)
    ind = where(bname eq 92B, count)
    if (count gt 0) then begin
        bname[ind] = 47B
        self.url = string(bname)
    endif else begin
        self.url = file_dirname(self.filename)
    endelse
    self.url += '/' + file_basename(self.filename, '.sav') + '-sav.html'

    self.system = system

    return, 1
end


;+
; Define instance variables.
;
; @field filename filename of SAV file relative to root
; @field system IDLdocSystem object reference
;-
pro idldocsavfile__define
    compile_opt strictarr

    define = { idldocsavfile, $
        filename : '', $
        absolute_filename : '', $
        outpath : '', $
        url : '', $
        nfunctions : 0L, $
        nprocedures : 0L, $
        system : obj_new() $
        }
end
