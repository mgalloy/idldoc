;+
; Find the first \@ symbol in a line or lines of comments.
;
; @private
; @param lines {in}{required}{type=string array} lines of IDL comments
; @param line_num {out}{optional}{type=int} line number of the \@ symbol
; @param pos {out}{optional}{type=int} position of the \@ symbol
;-
pro idldoc_find_at_symbol, lines, line_num, pos
    compile_opt strictarr, hidden

    indices = where(strpos(lines, '@') ne -1, count)
    if (count eq 0) then line_num = -1 else begin
        line_num = indices[0]
        pos = strpos(lines[line_num], '@')
    endelse
end


;+
; Changes any file specification notation to the web notation ("/").
;
; @private
; @returns string or string array with path separators changed to "/" since
;          the web always uses "/"
; @param dir {in}{type=string or string array} represents directory path(s)
;-
function idldoc_elim_slash, dir
    compile_opt idl2, hidden

    if (n_elements(dir) eq 1) then begin
        delims = '[]/\:]'
        tokens = strsplit(dir, delims, /extract, /regex)
        if (n_elements(tokens) eq 1) then return, tokens[0]
        if (tokens[0] eq '.') then tokens = tokens[1:*]
        return, strjoin(tokens, '/') ; web always uses /
    endif else begin
        rdir = strarr(n_elements(dir))
        for i = 0, n_elements(dir) - 1 do $
            rdir[i] = idldoc_elim_slash(dir[i])
        return, rdir
    endelse
end


;+
; Process the tags in the overview file.
;
; @private
; @param osystem {in}{required}{type=objref} the IDLdocSystem object reference
; @param tag_lines {in}{type=string array} the portion of the file specified
;        by overview that has at signs in it
; @param pro_dirs {in}{type=string array} directories under root that hold
;        .pro files
; @param comments {in}{out}{type=string array} comments for the pro_dirs
;        directories; matches elementwise
;-
pro idldoc_process_tags, osystem, tag_lines, pro_dirs, comments
    compile_opt idl2, hidden

    big_line = add_lines(tag_lines)
    new_lines = (strsplit(big_line, '@', /extract))[0:*]

    for i = 0, n_elements(new_lines) - 1 do begin
        tokens = strsplit(new_lines[i], /extract)
        case strlowcase(tokens[0]) of
        'dir' : begin
                if (n_elements(tokens) le 3) then return
                s_names = idldoc_elim_slash(pro_dirs)
                indices = where(s_names eq tokens[1], count)
                if (count eq 0) then begin
                    osystem->addWarning, 'Unknown dir tag: ' + tokens[1]
                    return
                endif
                comments[indices[0]] = add_lines(tokens[2:*])
            end
        else : begin
                osystem->addWarning, 'Unknown tag @' + strlowcase(tokens[0])
            end
        endcase
    endfor
end


;+
; Create the warnings page for the library.
;
; @private
; @param osystem {in}{required}{type=objref} the IDLdocSystem object reference
; @param pro_files {in} {type=string array} a string array of all the pro
;        files under the 'root' directory
; @param file_hash {in}{type=obj ref} hash table of file references
;-
pro idldoc_write_warning, osystem, pro_files, file_hash
    compile_opt idl2, hidden

    filename = 'idldoc-warnings.html'
    openw, lun, filename, /get_lun, error=error
    if (error ne 0) then begin
        osystem->addWarning, 'Error opening ' + filename + ' for writing.'
        return
    endif

    osystem->getProperty, idldoc_root=idldoc_root, $
        title=title, subtitle=subtitle, footer=footer, $
        nonavbar=nonavbar, embed=embed, user=user

    sdata = { $
        root : './', $
        version : osystem->getVersion(), $
        date : systime(), $
        embed : embed, $
        css_location : $
            filepath('main_files.css', subdir=['resource'], root=idldoc_root), $
        print_css_location : $
            filepath('main_files_print.css', subdir=['resource'], root=idldoc_root), $
        title : title, $
        subtitle : subtitle, $
        user : user, $
        nonavbar : nonavbar, $
        navbar_filename : $
            filepath('navbar.tt', subdir=['templates'], root=idldoc_root), $
        overview_href : 'overview.html', $
        overview_selected : 0B, $
        dir_overview_href : '', $
        dir_overview_selected : 0B, $
        categories_href : 'idldoc-categories.html', $
        categories_selected : 0B, $
        index_href : 'idldoc-index.html', $
        index_selected : 0B, $
        search_href : 'search-page.html', $
        search_selected : 0B, $
        file_selected : 0B, $
        source_href : '', $
        source_selected : 0B, $
        help_href : 'idldoc-help.html', $
        help_selected : 0B, $
        etc_selected : 1B, $
        next_file_href : '', $
        prev_file_href : '', $
        view_single_page_href : 'idldoc-warnings.html', $
        view_frames_href : 'index.html', $
        summary_fields_href : '', $
        summary_routine_href : '', $
        details_routine_href : '' $
        }

    oBeginTemplate = obj_new('template', $
        filepath('warnings-begin.tt', subdir=['templates'], root=idldoc_root))
    oBeginTemplate->process, sdata, lun=lun
    obj_destroy, oBeginTemplate

    ; handle todos
    oTodoHeaderTemplate = obj_new('template', $
        filepath('warnings-todo-header.tt', subdir=['templates'], root=idldoc_root))
    oTodoHeaderTemplate->process, sdata, lun=lun
    obj_destroy, oTodoHeaderTemplate

    oTodoFileTemplate = obj_new('template', $
        filepath('warnings-todo-file.tt', subdir=['templates'], root=idldoc_root))

    otodos = obj_new('array_list', example={ name:'', url:'', comment:ptr_new() })
    nprofiles = ((size(pro_files, /type) ne 7) || (pro_files[0] eq '')) ? 0 : n_elements(pro_files)
    for i = 0, nprofiles - 1L do begin
        ofile = file_hash->get(pro_files[i])
        oroutines = ofile->get_routines()
        iter = oroutines->iterator()
        while (~iter->done()) do begin
            oroutine = iter->next()
            todo = oroutine->get_todo(present=present)
            if (present) then begin
                oroutine->getProperty, name=routine_name
                oroutine->getProperty, url=url
                otodos->add, { name:routine_name, url:url, comment:ptr_new(todo) }
            endif
        endwhile
        obj_destroy, iter
        items = otodos->to_array(empty=empty)
        if (~empty) then begin
            ofile->getProperty, url=fileurl
            sdata = { $
                filename:pro_files[i], $
                fileurl:fileurl, $
                items:items $
                }
            oTodoFileTemplate->process, sdata, lun=lun
            todos = otodos->to_array()
            ptr_free, todos.comment
            otodos->reset
        endif
    endfor
    obj_destroy, [otodos, oTodoFileTemplate]

    oTodoFooterTemplate = obj_new('template', $
        filepath('warnings-todo-footer.tt', subdir=['templates'], root=idldoc_root))
    oTodoFooterTemplate->process, sdata, lun=lun
    obj_destroy, oTodoFooterTemplate

    oBugsHeaderTemplate = obj_new('template', $
        filepath('warnings-bugs-header.tt', subdir=['templates'], root=idldoc_root))
    oBugsHeaderTemplate->process, sdata, lun=lun
    obj_destroy, oBugsHeaderTemplate

    oBugsFileTemplate = obj_new('template', $
        filepath('warnings-todo-file.tt', subdir=['templates'], root=idldoc_root))

    obugs = obj_new('array_list', example={ name:'', url:'', comment:'' })
    for i = 0, nprofiles - 1L do begin
        ofile = file_hash->get(pro_files[i])
        oroutines = ofile->get_routines()
        iter = oroutines->iterator()
        while (~iter->done()) do begin
            oroutine = iter->next()
            bug = oroutine->get_bugs(present=present)
            if (present) then begin
                oroutine->getProperty, name=routine_name
                oroutine->getProperty, url=url
                obugs->add, { name:routine_name, url:url, comment:strjoin(bug, ' ') }
            endif
        endwhile
        obj_destroy, iter
        items = obugs->to_array(empty=empty)
        if (~empty) then begin
            ofile->getProperty, url=fileurl
            sdata = { $
                filename:pro_files[i], $
                fileurl:fileurl, $
                items:items $
                }
            oBugsFileTemplate->process, sdata, lun=lun
            obugs->reset
        endif
    endfor
    obj_destroy, [obugs, oBugsFileTemplate]

    oBugsFooterTemplate = obj_new('template', $
        filepath('warnings-bugs-footer.tt', subdir=['templates'], root=idldoc_root))
    oBugsFooterTemplate->process, sdata, lun=lun
    obj_destroy, oBugsFooterTemplate

    oUndocHeaderTemplate = obj_new('template', $
        filepath('warnings-undoc-header.tt', subdir=['templates'], root=idldoc_root))
    oUndocHeaderTemplate->process, sdata, lun=lun
    obj_destroy, oUndocHeaderTemplate

    oUndocFileTemplate = obj_new('template', $
        filepath('warnings-undoc-file.tt', subdir=['templates'], root=idldoc_root))

    oundoc = obj_new('array_list', example={ name:'', url:'', partial:0L })
    for i = 0, nprofiles - 1L do begin
        ofile = file_hash->get(pro_files[i])
        oroutines = ofile->get_routines()
        iter = oroutines->iterator()
        while (~iter->done()) do begin
            oroutine = iter->next()
            oroutine->getProperty, documented=partial
            if (partial lt 2) then begin
                oroutine->getProperty, name=routine_name
                oroutine->getProperty, url=url
                oundoc->add, { name:routine_name, url:url, partial:partial }
            endif
        endwhile
        obj_destroy, iter
        routines = oundoc->to_array(empty=empty)
        if (~empty) then begin
            ofile->getProperty, url=fileurl
            sdata = { $
                filename:pro_files[i], $
                fileurl:fileurl, $
                routines:routines $
                }
            oUndocFileTemplate->process, sdata, lun=lun
            oundoc->reset
        endif
    endfor
    obj_destroy, [oundoc, oUndocFileTemplate]

    oUndocFooterTemplate = obj_new('template', $
        filepath('warnings-undoc-footer.tt', subdir=['templates'], root=idldoc_root))
    oUndocFooterTemplate->process, sdata, lun=lun
    obj_destroy, oUndocFooterTemplate

    oObsoleteHeaderTemplate = obj_new('template', $
        filepath('warnings-obsolete-header.tt', subdir=['templates'], root=idldoc_root))
    oObsoleteHeaderTemplate->process, sdata, lun=lun
    obj_destroy, oObsoleteHeaderTemplate

    oObsoleteFileTemplate = obj_new('template', $
        filepath('warnings-obsolete-file.tt', subdir=['templates'], root=idldoc_root))

    oObsolete = obj_new('array_list', example={ name:'', url:'' })
    for i = 0, nprofiles - 1L do begin
        ofile = file_hash->get(pro_files[i])
        oroutines = ofile->get_routines()
        iter = oroutines->iterator()
        while (~iter->done()) do begin
            oroutine = iter->next()
            oroutine->getProperty, obsolete=obsolete
            if (obsolete) then begin
                oroutine->getProperty, name=routine_name
                oroutine->getProperty, url=url
                oObsolete->add, { name:routine_name, url:url }
            endif
        endwhile
        obj_destroy, iter
        routines = oObsolete->to_array(empty=empty)
        if (~empty) then begin
            ofile->getProperty, url=fileurl
            sdata = { $
                filename : pro_files[i], $
                fileurl : fileurl, $
                routines : routines $
                }
            oObsoleteFileTemplate->process, sdata, lun=lun
            oObsolete->reset
        endif
    endfor
    obj_destroy, [oObsolete, oObsoleteFileTemplate]

    oObsoleteFooterTemplate = obj_new('template', $
        filepath('warnings-obsolete-footer.tt', subdir=['templates'], root=idldoc_root))
    oObsoleteFooterTemplate->process, sdata, lun=lun
    obj_destroy, oObsoleteFooterTemplate

    oStatHeaderTemplate = obj_new('template', $
        filepath('warnings-stat-header.tt', subdir=['templates'], root=idldoc_root))
    oStatHeaderTemplate->process, sdata, lun=lun
    obj_destroy, oStatHeaderTemplate

    oStatFileTemplate = obj_new('template', $
        filepath('warnings-stat-file.tt', subdir=['templates'], root=idldoc_root))

    oStat = obj_new('array_list', example={ name:'', url:'', cyclic:0L })
    for i = 0, nprofiles - 1L do begin
        ofile = file_hash->get(pro_files[i])
        oroutines = ofile->get_routines()
        iter = oroutines->iterator()
        while (~iter->done()) do begin
            oroutine = iter->next()
            cyclic = oroutine->get_mccabe_complexity()
            if (cyclic gt 5) then begin
                oroutine->getProperty, name=routine_name
                oroutine->getProperty, url=url
                ostat->add, { name:routine_name, url:url, cyclic:cyclic }
            endif
        endwhile
        obj_destroy, iter
        routines = oStat->to_array(empty=empty)
        if (~empty) then begin
            ofile->getProperty, url=fileurl
            sdata = { $
                filename : pro_files[i], $
                fileurl : fileurl, $
                routines : routines $
                }
            oStatFileTemplate->process, sdata, lun=lun
            ostat->reset
        endif
    endfor
    obj_destroy, [oStat, oStatFileTemplate]

    oStatFooterTemplate = obj_new('template', $
        filepath('warnings-stat-footer.tt', subdir=['templates'], root=idldoc_root))
    oStatFooterTemplate->process, sdata, lun=lun
    obj_destroy, oStatFooterTemplate

    sdata = { $
        version : osystem->getVersion(), $
        date : systime(), $
        footer : footer, $
        tagline_filename : $
            filepath('tagline.tt', subdir=['templates'], root=idldoc_root) $
        }
    oEndTemplate = obj_new('template', $
        filepath('warnings-end.tt', subdir=['templates'], root=idldoc_root))
    oEndTemplate->process, sdata, lun=lun
    obj_destroy, oEndTemplate

    free_lun, lun
end


;+
; Writes the search file.
;
; @private
; @param osystem {in}{required}{type=objref} the IDLdocSystem object reference
; @param pro_dirs {in} {type=string array} a list of the directories containing
;        .pro code below the root directory
; @param pro_files {in} {type=string array} a string array of all the pro
;        files under the 'root' directory
; @keyword file_hash {in}{type=obj ref} hash table of file references
;-
pro idldoc_write_search, osystem, pro_dirs, pro_files, file_hash=file_hash
    compile_opt strictarr

    ; create the HTML page
    filename = 'search-page.html'
    openw, lun, filename, /get_lun, error=error
    if (error ne 0) then begin
        osystem->addWarning, 'Error opening ' + filename + ' for writing.'
        return
    endif

    osystem->getProperty, title=title, subtitle=subtitle, footer=footer, $
        embed=embed, user=user, nonavbar=nonavbar, idldoc_root=idldoc_root

    sdata = { $
        root : './', $
        version : osystem->getVersion(), $
        date : systime(), $
        embed : embed, $
        css_location : $
            filepath('main_files.css', subdir=['resource'], root=idldoc_root), $
        print_css_location : $
            filepath('main_files_print.css', subdir=['resource'], root=idldoc_root), $
        title : title, $
        subtitle : subtitle, $
        user : user, $
        nonavbar : nonavbar, $
        navbar_filename : $
            filepath('navbar.tt', subdir=['templates'], root=idldoc_root), $
        overview_href : 'overview.html', $
        overview_selected : 0B, $
        dir_overview_href : '', $
        dir_overview_selected : 0B, $
        categories_href : 'idldoc-categories.html', $
        categories_selected : 0B, $
        index_href : 'idldoc-index.html', $
        index_selected : 0B, $
        search_href : '', $
        search_selected : 1B, $
        file_selected : 0B, $
        source_href : '', $
        source_selected : 0B, $
        help_href : 'idldoc-help.html', $
        help_selected : 0B, $
        etc_selected : 0B, $
        next_file_href : '', $
        prev_file_href : '', $
        view_single_page_href : 'search-page.html', $
        view_frames_href : 'index.html', $
        summary_fields_href : '', $
        summary_routine_href : '', $
        details_routine_href : '', $
        footer : footer, $
        tagline_filename : $
            filepath('tagline.tt', subdir=['templates'], root=idldoc_root) $
        }
    oTemplate = obj_new('template', $
        filepath('search.tt', subdir=['templates'], root=idldoc_root))
    oTemplate->process, sdata, lun=lun
    obj_destroy, oTemplate

    free_lun, lun

    ; create the Javascript data for the routines
    filename = 'search.js'
    openw, lun, filename, /get_lun, error=error
    if (error ne 0) then begin
        osystem->addWarning, 'Error opening ' + filename + ' for writing.'
        return
    endif

    ofiledata = obj_new('array_list', example={ index:'', filename:'', basename:'', search_string:'' })

    for i = 0, n_elements(pro_files) - 1 do begin
        ofile = file_hash->get(pro_files[i], found=found)
        if (not found) then continue
        basename = file_basename(pro_files[i])
        filename = strjoin(strsplit(pro_files[i], '\', /extract), '/')
        filename = idldoc_pro_to_html(filename)

        ofiledata->add, { $
            index:strtrim(i + 1, 2), $
            filename:filename, $
            basename:basename, $
            search_string:ofile->get_search_string() $
            }
    endfor

    sfiledata = ofiledata->to_array()
    obj_destroy, ofiledata

    sdata = { files:sfiledata }

    oTemplate = obj_new('template', $
        filepath('search-js.tt', subdir=['templates'], root=idldoc_root))
    oTemplate->process, sdata, lun=lun
    obj_destroy, oTemplate

    free_lun, lun
end


;+
; Writes the user defined files: the .idldoc files.
;
; @private
; @param osystem {in}{required}{type=objref} the IDLdocSystem object reference
; @param etc_files {in}{required}{type=strarr} relative filenames of the
;        .idldoc files
; @param abs_etc_files {in}{required}{type=strarr} absolute filenames of the
;        .idldoc files
;
;-
pro idldoc_write_etc, osystem, etc_files, abs_etc_files
    compile_opt idl2

    osystem->getProperty, title=title, subtitle=subtitle, footer=footer, $
        embed=embed, user=user, nonavbar=nonavbar, idldoc_root=idldoc_root

    for i = 0, n_elements(etc_files) - 1 do begin
        html_filename = idldoc_pro_to_html(etc_files[i])
        openw, lun, html_filename, /get_lun, error=error
        if (error ne 0) then begin
            osystem->addWarning, 'Error opening ' + html_filename + ' for writing.'
            return
        endif

        slashes = stroccur(etc_files[i], '\/:', count=levels)
        rel_root = ''
        for j = 0, levels - 2 do rel_root += '../'

        sdata = { $
            root : rel_root, $
            include_filename : abs_etc_files[i], $
            version : osystem->getVersion(), $
            date : systime(), $
            embed : embed, $
            css_location : keyword_set(embed) $
                ? filepath('main_files.css', subdir=['resource'], root=idldoc_root) $
                : rel_root + 'main_files.css', $
            print_css_location : $
                filepath('main_files_print.css', subdir=['resource'], root=idldoc_root), $
            title : title, $
            subtitle : subtitle, $
            user : user, $
            nonavbar : nonavbar, $
            navbar_filename : $
                filepath('navbar.tt', subdir=['templates'], root=idldoc_root), $
            overview_href : rel_root + 'overview.html', $
            overview_selected : 0B, $
            dir_overview_href : '', $
            dir_overview_selected : 0B, $
            categories_href : rel_root + 'idldoc-categories.html', $
            categories_selected : 0B, $
            index_href : rel_root + 'idldoc-index.html', $
            index_selected : 0B, $
            search_href : rel_root + 'search-page.html', $
            search_selected : 0B, $
            file_selected : 0B, $
            source_href : '', $
            source_selected : 0B, $
            help_href : rel_root + 'idldoc-help.html', $
            help_selected : 0B, $
            etc_selected : 1B, $
            next_file_href : '', $
            prev_file_href : '', $
            view_single_page_href : $
                file_basename(etc_files[i], '.idldoc') + '.html', $
            view_frames_href : rel_root + 'index.html', $
            summary_fields_href : '', $
            summary_routine_href : '', $
            details_routine_href : '', $
            footer : footer, $
            tagline_filename : $
                filepath('tagline.tt', subdir=['templates'], root=idldoc_root) $
            }

        oTemplate = obj_new('template', $
            filepath('etc.tt', subdir=['templates'], root=idldoc_root))
        oTemplate->process, sdata, lun=lun

        obj_destroy, oTemplate
        free_lun, lun
    endfor
end


;+
; @private
;
; @param osystem {in}{required}{type=objref} the IDLdocSystem object reference
; @param dir {in}{type=string} directory containing .pro or .sav files below the
;        root directory
; @param pro_files {in}{type=string array} a string array of all the pro
;        files under the 'root' directory
; @param sav_files {in}{type=string array} a string array of all the save
;        files under the 'root' directory
; @keyword file_hash {in}{type=obj ref} hash table of file references
;-
pro idldoc_write_dir_overview, osystem, dir, pro_files, sav_files, file_hash=file_hash
    compile_opt idl2

    filename = dir + 'directory-overview.html'
    openw, lun, filename, /get_lun, error=error
    if (error ne 0) then begin
        osystem->addWarning, 'Error opening ' + filename + ' for writing.'
        return
    endif

    osystem->getProperty, title=title, subtitle=subtitle, footer=footer, $
        nonavbar=nonavbar, embed=embed, user=user, idldoc_root=idldoc_root, $
        root=root

    slashes = stroccur(dir, '\/:', count=levels)
    rel_root = ''
    for i = 0, levels - 2 do rel_root = rel_root + '../'

    if (~file_test(dir, /directory)) then file_mkdir, dir

    nprofiles = ((size(pro_files, /type) ne 7) || (pro_files[0] eq '')) ? 0 : n_elements(pro_files)

    directory = strlen(dir) eq 2 ? dir : strmid(dir, 2)

    doverview = root + dir + 'directory.html'
    if (file_test(doverview)) then begin
        nlines = file_lines(doverview)
        comments = strarr(nlines)
        openr, plun, doverview, /get_lun
        readf, plun, comments
        free_lun, plun
    endif else comments = ''

    oprofiles = obj_new('array_list', example={ name:'', url:'', comment:'' })

    for f = 0L, nprofiles - 1L do begin
        ofile = file_hash->get(pro_files[f])
        show = user ? ~ofile->is_private() : ~ofile->is_hidden()
        ofile->getProperty, url=url
        if (show) then begin
            oprofiles->add, { $
                name:file_basename(pro_files[f]), $
                url:file_basename(pro_files[f], '.pro') + '.html', $
                comment:ofile->get_file_comments(/first_sentence, found=found) $
                }
        endif
    endfor

    profiles = nprofiles eq 0 ? { name:'', url:'', comment:'' } : oprofiles->to_array()
    obj_destroy, oprofiles

    if ((size(sav_files, /type) eq 7) && (sav_files[0] ne '')) then begin
        nsavfiles = n_elements(sav_files)
    endif else begin
        nsavfiles = 0L
    endelse

    savfiles = { url:'', name:'' }
    if (nsavfiles gt 0) then begin
        dfiles = file_basename(sav_files, '.sav')
        dfiles = dfiles[sort(dfiles)]

        savfiles = replicate({ url:'', name:'' }, nsavfiles)
        savfiles.url = dfiles + '-sav.html'
        savfiles.name = dfiles + '.sav'
    endif

    sdata = { $
        root : rel_root, $
        version : osystem->getVersion(), $
        date : systime(), $
        embed : embed, $
        css_location : keyword_set(embed) $
            ? filepath('main_files.css', subdir=['resource'], root=idldoc_root) $
            : rel_root + 'main_files.css', $
        print_css_location : $
            filepath('main_files_print.css', subdir=['resource'], root=idldoc_root), $
        directory : directory, $
        comments : comments, $
        profiles : profiles, $
        nprofiles : nprofiles, $
        savfiles : savfiles, $
        nsavfiles : nsavfiles, $
        title : title, $
        subtitle : subtitle, $
        user : user, $
        nonavbar : nonavbar, $
        navbar_filename : $
            filepath('navbar.tt', subdir=['templates'], root=idldoc_root), $
        overview_href : rel_root + 'overview.html', $
        overview_selected : 0B, $
        dir_overview_href : '', $
        dir_overview_selected : 1B, $
        categories_href : rel_root + 'idldoc-categories.html', $
        categories_selected : 0B, $
        index_href : rel_root + 'idldoc-index.html', $
        index_selected : 0B, $
        search_href : rel_root + 'search-page.html', $
        search_selected : 0B, $
        file_selected : 0B, $
        source_href : '', $
        source_selected : 0B, $
        help_href : rel_root + 'idldoc-help.html', $
        help_selected : 0B, $
        etc_selected : 0B, $
        next_file_href : '', $
        prev_file_href : '', $
        view_single_page_href : './directory-overview.html', $
        view_frames_href : rel_root + 'index.html', $
        summary_fields_href : '', $
        summary_routine_href : '', $
        details_routine_href : '', $
        footer : footer, $
        tagline_filename : $
            filepath('tagline.tt', subdir=['templates'], root=idldoc_root) $
        }

    oTemplate = obj_new('template', $
        filepath('dir-overview.tt', subdir=['templates'], root=idldoc_root))
    oTemplate->process, sdata, lun=lun

    obj_destroy, oTemplate
    free_lun, lun
end


;+
; Loop through all directories and write each one's directory overview.
;
; @private
; @param osystem {in}{required}{type=objref} the IDLdocSystem object reference
; @param dirs {in}{type=string array} a list of the directories containing
;        .pro or .sav files below the root directory
; @param pro_files {in}{type=string array} a string array of all the pro
;        files under the 'root' directory
; @param sav_files {in}{type=string array} a string array of all the save
;        files under the 'root' directory
; @keyword file_hash {in}{type=obj ref} hash table of file references
;-
pro idldoc_write_directory_overviews, osystem, dirs, pro_files, $
    sav_files, file_hash=file_hash
    compile_opt idl2, hidden

    for i = 0, n_elements(dirs) - 1 do begin
        pro_files_path = file_dirname(pro_files) + path_sep()
        sav_files_path = file_dirname(sav_files) + path_sep()
        pro_indices = where(pro_files_path eq dirs[i], proCount)
        sav_indices = where(sav_files_path eq dirs[i], savCount)
        if (proCount gt 0) then begin
            dir_pro_files = pro_files[pro_indices]
        endif else dir_pro_files = ''
        if (savCount gt 0) then begin
            dir_sav_files = sav_files[sav_indices]
        endif else dir_sav_files = ''
        if (proCount gt 0 or savCount gt 0) then begin
            idldoc_write_dir_overview, osystem, dirs[i], dir_pro_files, $
                dir_sav_files, file_hash=file_hash
        endif
    endfor
end


;+
; Create the idldoc-index.html list of index items.
;
; @param osystem {in}{required}{type=objref} the IDLdocSystem object reference
;-
pro idldoc_write_full_index, osystem
    compile_opt strictarr

    osystem->getProperty, idldoc_root=idldoc_root, index=index, $
        title=title, subtitle=subtitle, footer=footer, $
        nonavbar=nonavbar, embed=embed, user=user

    oBeginTemplate = obj_new('template', $
        filepath('full-index-begin.tt', subdir=['templates'], root=idldoc_root))
    oLetterTemplate = obj_new('template', $
        filepath('full-index-letter.tt', subdir=['templates'], root=idldoc_root))
    oEndTemplate = obj_new('template', $
        filepath('full-index-end.tt', subdir=['templates'], root=idldoc_root))

    fletters = index->get_first_letters(empty=emptyIndex)

    if (~emptyIndex) then begin
        divisions = index->get_divisions(max_per_page=100, num_letters=nletters)

        letters = replicate({ letter:'', url:'' }, n_elements(fletters))
        letters.letter = fletters

        all_file_letters = strarr(n_elements(nletters))
        for i = 0L, n_elements(nletters) - 1L do begin
            all_file_letters[i] = '-' $
                + strjoin(fletters[divisions[i]:(divisions[i] + nletters[i] - 1L)])
        endfor
        all_file_letters[0] = ''
        url_letters = strarr(n_elements(fletters))
        for i = 0L, n_elements(nletters) - 1L do begin
            url_letters[divisions[i]:(divisions[i] + nletters[i] - 1L)] = all_file_letters[i]
        endfor
        letters.url = 'idldoc-index' + url_letters + '.html#_' + fletters
    endif else begin
        letters = { letter:'', url:'' }
    endelse

    sdata = { $
        root : './', $
        empty : emptyIndex, $
        letters : letters, $
        version : osystem->getVersion(), $
        date : systime(), $
        embed : embed, $
        css_location : $
            filepath('main_files.css', subdir=['resource'], root=idldoc_root), $
        print_css_location : $
            filepath('main_files_print.css', subdir=['resource'], root=idldoc_root), $
        title : title, $
        subtitle : subtitle, $
        user : user, $
        nonavbar : nonavbar, $
        navbar_filename : $
            filepath('navbar.tt', subdir=['templates'], root=idldoc_root), $
        overview_href : 'overview.html', $
        overview_selected : 0B, $
        dir_overview_href : '', $
        dir_overview_selected : 0B, $
        categories_href : 'idldoc-categories.html', $
        categories_selected : 0B, $
        index_href : '', $
        index_selected : 1B, $
        search_href : 'search-page.html', $
        search_selected : 0B, $
        file_selected : 0B, $
        source_href : '', $
        source_selected : 0B, $
        help_href : 'idldoc-help.html', $
        help_selected : 0B, $
        etc_selected : 0B, $
        next_file_href : '', $
        prev_file_href : '', $
        view_single_page_href : '', $
        view_frames_href : 'index.html', $
        summary_fields_href : '', $
        summary_routine_href : '', $
        details_routine_href : '', $
        footer : footer, $
        tagline_filename : $
            filepath('tagline.tt', subdir=['templates'], root=idldoc_root) $
        }

    for i = 0L, n_elements(nletters) - 1L do begin
        file_letters = fletters[divisions[i]:(divisions[i] + nletters[i] - 1L)]
        filename = 'idldoc-index' + all_file_letters[i] + '.html'
        openw, lun, filename, /get_lun, error=error
        if (error ne 0) then begin
            osystem->addWarning, 'Error opening ' + filename + ' for writing.'
            return
        endif

        sdata.view_single_page_href = filename
        oBeginTemplate->process, sdata, lun=lun

        for l = 0L, n_elements(file_letters) - 1L do begin
            items = index->get_items(file_letters[l])
            ldata = { $
                letter : file_letters[l], $
                items : items $
                }
            oLetterTemplate->process, ldata, lun=lun
        end
        oEndTemplate->process, sdata, lun=lun

        free_lun, lun
    endfor

    obj_destroy, [oBeginTemplate, oLetterTemplate, oEndTemplate]
end


;+
; Write the XML file that specifies the locations of the file/routine help files
; for the IDL assistant help system.
;
; @param osystem {in}{required}{type=objref} the IDLdocSystem object reference
; @param file_hash {in}{type=obj ref} hash table of file references
;-
pro idldoc_write_assistant_adp, osystem, file_hash
    compile_opt strictarr

    openw, lun, 'idldoc-lib.adp', /get_lun

    osystem->getProperty, title=title

    indent = '  '
    printf, lun, '<assistantconfig version="3.3.0">'

    printf, lun, indent + '<profile>'
    printf, lun, indent + indent + '<property name="title">API documentation</property>'
    printf, lun, indent + indent + '<property name="startpage">home.html</property>'
    printf, lun, indent + '</profile>'

    printf, lun, indent + '<DCF ref="home.html" title="' + title + '">'

    filenames = file_hash->keys()
    ofiles = file_hash->values()

    ind = sort(filenames)
    filenames = filenames[ind]
    ofiles = ofiles[ind]

    for f = 0L, n_elements(filenames) - 1L do begin
        ofiles[f]->getProperty, url=url
        oroutines = (ofiles[f]->get_routines())->to_array()
        printf, lun, indent + indent $
            + '<section ref="' + url + '" title="' + file_basename(filenames[f]) + '">'

        if (n_elements(oroutines) gt 1) then begin
            for r = 0L, n_elements(oroutines) - 1L do begin
                oroutines[r]->getProperty, url=url, name=name
                printf, lun, indent + indent + indent $
                    + '<section ref="' + url + '" title="' + name + '">

                colonpos = strpos(name, ':')
                keyword = colonpos eq -1 $
                    ? name $
                    : (strmid(name, 0, colonpos) + strmid(name, colonpos + 1L))
                printf, lun, indent + indent + indent $
                    + '<keyword ref="' + url + '">' + keyword + '</keyword>'

                printf, lun, indent + indent + indent + '</section>'
            endfor
        endif else if (size(oroutines, /type) eq 11) then begin
            oroutines[0]->getProperty, url=url, name=name
            colonpos = strpos(name, ':')
            keyword = colonpos eq -1 $
                ? name $
                : (strmid(name, 0, colonpos) + strmid(name, colonpos + 1L))
            printf, lun, indent + indent + indent $
                + '<keyword ref="' + url + '">' + keyword + '</keyword>'
        endif

        printf, lun, indent + indent + '</section>'
    endfor

    printf, lun, indent + '</DCF>'
    printf, lun, '</assistantconfig>'

    free_lun, lun
end


;+
; Create the idldoc-categories.html list of categories.
;
; @param osystem {in}{required}{type=objref} the IDLdocSystem object reference
;-
pro idldoc_write_categories, osystem
    compile_opt strictarr

    filename = 'idldoc-categories.html'
    openw, lun, filename, /get_lun, error=error
    if (error ne 0) then begin
        osystem->addWarning, 'Error opening ' + filename + ' for writing.'
        return
    endif

    osystem->getProperty, idldoc_root=idldoc_root, taglisting=taglisting, $
        title=title, subtitle=subtitle, footer=footer, $
        nonavbar=nonavbar, embed=embed, user=user

    tag_name = taglisting->getTags(count=ntags)
    tag_name = tag_name[sort(tag_name)]

    sdata = { $
        root : './', $
        ntags : ntags, $
        version : osystem->getVersion(), $
        date : systime(), $
        embed : embed, $
        css_location : $
            filepath('main_files.css', subdir=['resource'], root=idldoc_root), $
        print_css_location : $
            filepath('main_files_print.css', subdir=['resource'], root=idldoc_root), $
        title : title, $
        subtitle : subtitle, $
        user : user, $
        nonavbar : nonavbar, $
        navbar_filename : $
            filepath('navbar.tt', subdir=['templates'], root=idldoc_root), $
        overview_href : 'overview.html', $
        overview_selected : 0B, $
        dir_overview_href : '', $
        dir_overview_selected : 0B, $
        categories_href : '', $
        categories_selected : 1B, $
        index_href : 'idldoc-index.html', $
        index_selected : 0B, $
        search_href : 'search-page.html', $
        search_selected : 0B, $
        file_selected : 0B, $
        source_href : '', $
        source_selected : 0B, $
        help_href : 'idldoc-help.html', $
        help_selected : 0B, $
        etc_selected : 0B, $
        next_file_href : '', $
        prev_file_href : '', $
        view_single_page_href : 'idldoc-categories.html', $
        view_frames_href : 'index.html', $
        summary_fields_href : '', $
        summary_routine_href : '', $
        details_routine_href : '', $
        footer : footer, $
        tagline_filename : $
            filepath('tagline.tt', subdir=['templates'], root=idldoc_root) $
        }

    oStartTemplate = obj_new('template', $
        filepath('categories-begin.tt', subdir=['templates'], root=idldoc_root))
    oStartTemplate->process, sdata, lun=lun

    oTagTemplate = obj_new('template', $
        filepath('categories-tag.tt', subdir=['templates'], root=idldoc_root))

    for t = 0L, ntags - 1L do begin
        oroutines = taglisting->getRoutines(tag_name[t], count=nroutines)
        routines = replicate({ name:'', url:'' }, nroutines)
        for r = 0L, nroutines - 1L do begin
            oroutines[r]->getProperty, name=name, url=url
            routines[r].name = name
            routines[r].url = url
        endfor
        routines = routines[sort(routines.name)]
        stag = { $
            tag : tag_name[t], $
            tag_id : idl_validname(tag_name[t], /convert_spaces), $
            nroutines : strtrim(nroutines, 2), $
            routines : routines $
            }
        oTagTemplate->process, stag, lun=lun
    endfor

    oEndTemplate = obj_new('template', $
        filepath('categories-end.tt', subdir=['templates'], root=idldoc_root))
    oEndTemplate->process, sdata, lun=lun

    obj_destroy, [oStartTemplate, oTagTemplate, oEndTemplate]

    free_lun, lun
end


;+
; Processes the file specified by the OVERVIEW keyword to IDLdoc (if present)
; and creates the 'overview&#046;html' file that shows in the main browser
; frame when loading the 'index&#046;html' file. Always shows at least all
; subdirectories with IDL .pro files in them.
;
; @private
; @param osystem {in}{required}{type=objref} the IDLdocSystem object reference
; @param overview {in} {type=string} filename of the content to be placed in
;        the overview.html file
; @param pro_dirs {in} {type=string array} a list of the directories containing
;        .pro code below the root directory
; @param file_hash {in}{required}{type=object} a hash_table object where the
;        keys are the relative paths to the pro files and the values are the
;        file objects
;-
pro idldoc_write_overview, osystem, overview, pro_dirs, file_hash
    compile_opt idl2, hidden

    osystem->getProperty, title=title, subtitle=subtitle, footer=footer, $
        nonavbar=nonavbar, embed=embed, user=user, idldoc_root=idldoc_root, $
        template_prefix=tp

    if (~file_test(overview)) then begin
        if (overview eq '') then begin
            osystem->addWarning, 'Overview file not found'
        endif else begin
            osystem->addWarning, 'Overview file, ' + overview + ' not found'
        endelse
    endif

    ; process overview file, comments will be an array containing comments
    ; for each directory
    ndirs = n_elements(pro_dirs)
    comments = strarr(ndirs)
    if (overview ne '' && file_test(overview)) then begin
        nlines = file_lines(overview)
        openr, overview_lun, overview, /get_lun

        overview_lines = strarr(nlines)
        readf, overview_lun, overview_lines
        free_lun, overview_lun

        idldoc_find_at_symbol, overview_lines, line_num, pos

        if (line_num eq -1) then begin
            overview_comments = overview_lines
        endif else begin
            overview_comments = strarr(line_num + 1L)
            for i = 0, line_num do begin
                if (i eq line_num) then $
                    overview_comments[i] = strmid(overview_lines[i], 0, pos) $
                else overview_comments[i] = overview_lines[i]
            endfor
            tag_lines = overview_lines[line_num:*]
            tag_lines[0] = strmid(tag_lines[0], pos)
            idldoc_process_tags, osystem, tag_lines, pro_dirs, comments
        endelse
    endif else begin
        overview_comments = ''
        comments = ''
    endelse

    sdir = { name:'', url:'', parity:'', comment:'' }
    if (ndirs gt 0) then begin
        dirs = replicate(sdir, ndirs)
        names = strarr(ndirs)
        for i = 0L, ndirs - 1L do begin
            names[i] = strlen(pro_dirs[i]) eq 2 $
                ? pro_dirs[i] $
                : strmid(pro_dirs[i], 2)
        endfor
        dirs.name = names

        dirs.url =  idldoc_elim_slash(dirs.name) + '/directory-overview.html'
        parity = strarr(ndirs)
        if (ndirs gt 1) then begin
            parity[0:*:2] = 'even'
            parity[1:*:2] = 'odd'
            dirs.parity = parity
        endif
        dirs.comment = comments
    endif else dirs = sdir

    ; compute library statistics
    osystem->getProperty, classhierarchy=och
    och->getProperty, nclasses=nclasses

    nprofiles = 0L
    nsavfiles = 0L
    nlines = 0L
    nroutines = 0L
    files = file_hash->values(nfiles)
    for i = 0L, nfiles - 1L do begin
        files[i]->getProperty, nlines=nl, n_visible_routines=nr
        nlines += nl
        nroutines += nr
        if (obj_isa(files[i], 'IDLdocFile')) then nprofiles++ else nsavfiles++
    endfor

    sdata = { $
        root : './', $
        overview_comments : overview_comments, $
        dirs : dirs, $
        ndirs : ndirs, $
        nprofiles : nprofiles, $
        nsavfiles : nsavfiles, $
        nroutines : nroutines, $
        nlines : nlines, $
        nclasses : nclasses, $
        version : osystem->getVersion(), $
        date : systime(), $
        embed : embed, $
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
        overview_href : '', $
        overview_selected : 1B, $
        dir_overview_href : '', $
        dir_overview_selected : 0B, $
        categories_href : 'idldoc-categories.html', $
        categories_selected : 0B, $
        index_href : 'idldoc-index.html', $
        index_selected : 0B, $
        search_href : 'search-page.html', $
        search_selected : 0B, $
        file_selected : 0B, $
        source_href : '', $
        source_selected : 0B, $
        help_href : 'idldoc-help.html', $
        help_selected : 0B, $
        etc_selected : 0B, $
        next_file_href : '', $
        prev_file_href : '', $
        view_single_page_href : 'overview.html', $
        view_frames_href : 'index.html', $
        summary_fields_href : '', $
        summary_routine_href : '', $
        details_routine_href : '', $
        footer : footer, $
        tagline_filename : $
            filepath(tp + 'tagline.tt', subdir=['templates'], root=idldoc_root) $
        }

    osystem->getProperty, assistant=assistant

    filename = assistant ? 'home.html' : 'overview.html'
    openw, lun, filename, /get_lun, error=error
    if (error ne 0) then begin
        osystem->addWarning, 'Error opening ' + filename + ' for writing.'
        return
    endif

    oTemplate = obj_new('template', $
        filepath(tp + 'overview.tt', subdir=['templates'], root=idldoc_root))
    oTemplate->process, sdata, lun=lun

    obj_destroy, oTemplate
    free_lun, lun
end


;+
; Create "idldoc-help.html" in the root directory.  Assumes the current working
; directory is the root directory.
;
; @private
; @param osystem {in}{required}{type=objref} the IDLdocSystem object reference
;-
pro idldoc_write_help, osystem
    compile_opt strictarr, hidden
    on_error, 2

    filename = 'idldoc-help.html'
    openw, lun, filename, /get_lun, error=error
    if (error ne 0) then begin
        osystem->addWarning, 'Error opening ' + filename + ' for writing.'
        return
    endif

    osystem->getProperty, idldoc_root=idldoc_root, $
        title=title, subtitle=subtitle, footer=footer, $
        nonavbar=nonavbar, embed=embed, user=user

    sdata = { $
        root : './', $
        version : osystem->getVersion(), $
        date : systime(), $
        embed : embed, $
        css_location : $
            filepath('main_files.css', subdir=['resource'], root=idldoc_root), $
        print_css_location : $
            filepath('main_files_print.css', subdir=['resource'], root=idldoc_root), $
        title : title, $
        subtitle : subtitle, $
        user : user, $
        nonavbar : nonavbar, $
        navbar_filename : $
            filepath('navbar.tt', subdir=['templates'], root=idldoc_root), $
        overview_href : 'overview.html', $
        overview_selected : 0B, $
        dir_overview_href : '', $
        dir_overview_selected : 0B, $
        categories_href : 'idldoc-categories.html', $
        categories_selected : 0B, $
        index_href : 'idldoc-index.html', $
        index_selected : 0B, $
        search_href : 'search-page.html', $
        search_selected : 0B, $
        file_selected : 0B, $
        source_href : '', $
        source_selected : 0B, $
        help_href : '', $
        help_selected : 1B, $
        etc_selected : 0B, $
        next_file_href : '', $
        prev_file_href : '', $
        view_single_page_href : 'idldoc-help.html', $
        view_frames_href : 'index.html', $
        summary_fields_href : '', $
        summary_routine_href : '', $
        details_routine_href : '', $
        footer : footer, $
        tagline_filename : $
            filepath('tagline.tt', subdir=['templates'], root=idldoc_root) $
        }

    oTemplate = obj_new('template', $
        filepath('help.tt', subdir=['templates'], root=idldoc_root))
    oTemplate->process, sdata, lun=lun

    obj_destroy, oTemplate
    free_lun, lun
end


;+
; Create "idldoc-dev-help.html" in the root directory.  Assumes the current working
; directory is the root directory.
;
; @private
; @param osystem {in}{required}{type=objref} the IDLdocSystem object reference
;-
pro idldoc_write_dev_help, osystem
    compile_opt strictarr, hidden
    on_error, 2

    osystem->getProperty, idldoc_root=idldoc_root, $
        title=title, subtitle=subtitle, footer=footer, $
        nonavbar=nonavbar, embed=embed, user=user

    sdata = { $
        root : './', $
        idldoc_syntax_filename : $
            filepath('idldoc_syntax.tt', subdir=['templates'], root=idldoc_root), $
        version : osystem->getVersion(), $
        date : systime(), $
        embed : embed, $
        css_location : $
            filepath('main_files.css', subdir=['resource'], root=idldoc_root), $
        print_css_location : $
            filepath('main_files_print.css', subdir=['resource'], root=idldoc_root), $
        title : title, $
        subtitle : subtitle, $
        user : user, $
        nonavbar : nonavbar, $
        navbar_filename : $
            filepath('navbar.tt', subdir=['templates'], root=idldoc_root), $
        overview_href : 'overview.html', $
        overview_selected : 0B, $
        dir_overview_href : '', $
        dir_overview_selected : 0B, $
        categories_href : 'idldoc-categories.html', $
        categories_selected : 0B, $
        index_href : 'idldoc-index.html', $
        index_selected : 0B, $
        search_href : 'search-page.html', $
        search_selected : 0B, $
        file_selected : 0B, $
        source_href : '', $
        source_selected : 0B, $
        help_href : '', $
        help_selected : 1B, $
        etc_selected : 0B, $
        next_file_href : '', $
        prev_file_href : '', $
        view_single_page_href : 'idldoc-dev-help.html', $
        view_frames_href : 'index.html', $
        summary_fields_href : '', $
        summary_routine_href : '', $
        details_routine_href : '', $
        footer : footer, $
        tagline_filename : $
            filepath('tagline.tt', subdir=['templates'], root=idldoc_root) $
        }

    filename = 'idldoc-dev-help.html'
    openw, lun, filename, /get_lun, error=error
    if (error ne 0) then begin
        osystem->addWarning, 'Error opening ' + filename + ' for writing.'
        return
    endif

    oTemplate = obj_new('template', $
        filepath('dev-help.tt', subdir=['templates'], root=idldoc_root))
    oTemplate->process, sdata, lun=lun

    obj_destroy, oTemplate
    free_lun, lun

    filename = 'idldoc-dev-help2.html'
    openw, lun, filename, /get_lun, error=error
    if (error ne 0) then begin
        osystem->addWarning, 'Error opening ' + filename + ' for writing.'
        return
    endif

    sdata.view_single_page_href = 'idldoc-dev-help2.html'

    oTemplate = obj_new('template', $
        filepath('dev-help2.tt', subdir=['templates'], root=idldoc_root))
    oTemplate->process, sdata, lun=lun

    obj_destroy, oTemplate
    free_lun, lun
end

;+
; Create "index.html" in the root directory.  Assumes the current working
; directory is the root directory.
;
; @private
; @param osystem {in}{required}{type=objref} the IDLdocSystem object reference
; @param pro_dirs {in}{required}{type=strarr} directories with .PRO code in them
;-
pro idldoc_write_index, osystem, pro_dirs
    compile_opt strictarr, hidden

    filename = 'index.html'
    openw, lun, filename, /get_lun, error=error
    if (error ne 0) then begin
        osystem->addWarning, 'Error opening ' + filename + ' for writing.'
        return
    endif

    osystem->getProperty, title=title, idldoc_root=idldoc_root
    just_files = n_elements(pro_dirs) eq 1 && pro_dirs[0] eq '.' + path_sep()
    sdata = { $
        title : title, $
        version : osystem->getVersion(), $
        date : systime(), $
        just_files : just_files $
        }

    oTemplate = obj_new('template', $
        filepath('index.tt', subdir=['templates'], root=idldoc_root))
    oTemplate->process, sdata, lun=lun

    obj_destroy, oTemplate
    free_lun, lun
end


;+
; Writes the "dir-files.html" file in each directory that contains the
; links to each of the .pro files in that directory.
;
; @private
; @param osystem {in}{required}{type=objref} the IDLdocSystem object reference
; @param pro_files {in} {type=string array} a string array of all the pro
;        files under the 'root' directory
; @param sav_files {in} {type=string array} a string array of all the save
;        files under the 'root' directory
; @param dir {in} {type=string} string representing the current directory
; @keyword file_hash {in}{required}{type=object} a hash_table object where the
;        keys are the relative paths to the pro files and the values are the
;        file objects
;-
pro idldoc_write_dir_files, osystem, pro_files, sav_files, dir, file_hash=file_hash
    compile_opt idl2, hidden

    filename = dir + 'dir-files.html'
    openw, lun, filename, /get_lun, error=error
    if (error ne 0) then begin
        osystem->addWarning, 'Error opening ' + filename + ' for writing.'
        return
    endif

    osystem->getProperty, embed=embed, idldoc_root=idldoc_root

    slashes = stroccur(dir, '\/:', count=levels)
    rel_root = ''
    for i = 0, levels - 2 do rel_root = rel_root + '../'

    if (~file_test(dir, /directory)) then file_mkdir, pro_dir

    if ((size(pro_files, /type) eq 7) && (pro_files[0] ne '')) then begin
        files_ind = where(file_dirname(pro_files, /mark_directory) eq dir, nfiles)
    endif else begin
        nfiles = 0L
    endelse

    files = -1L
    if (nfiles gt 0) then begin
        dfiles = file_basename(pro_files[files_ind], '.pro')
        dfiles = dfiles[sort(dfiles)]

        files = replicate({ url:'', name:'' }, nfiles)
        files.url = dfiles + '.html'
        files.name = dfiles + '.pro'
    endif

    if ((size(sav_files, /type) eq 7) && (sav_files[0] ne '')) then begin
        files_ind = where(file_dirname(sav_files, /mark_directory) eq dir, nsavfiles)
    endif else begin
        nsavfiles = 0L
    endelse

    savfiles = -1L
    if (nsavfiles gt 0) then begin
        dfiles = file_basename(sav_files[files_ind], '.sav')
        dfiles = dfiles[sort(dfiles)]

        savfiles = replicate({ url:'', name:'' }, nsavfiles)
        savfiles.url = dfiles + '-sav.html'
        savfiles.name = dfiles + '.sav'
    endif

    sdata = { $
        version : osystem->getVersion(), $
        date : systime(), $
        embed : embed, $
        separator : path_sep(), $
        root : rel_root, $
        css_location : keyword_set(embed) $
            ? filepath('listings.css', subdir=['resource'], root=idldoc_root) $
            : rel_root + 'listings.css', $
        dirname : strlen(dir) eq 2 ? dir : strmid(dir, 2), $
        dirurl : 'directory-overview.html', $
        files : files, $
        nfiles : nfiles, $
        savfiles : savfiles, $
        nsavfiles : nsavfiles $
        }

    oTemplate = obj_new('template', $
        filepath('dir-files.tt', subdir=['templates'], root=idldoc_root))
    oTemplate->process, sdata, lun=lun

    obj_destroy, oTemplate
    free_lun, lun
end


;+
; Writes the all-files.html file in the root directory.
;
; @private
; @param osystem {in}{required}{type=objref} the IDLdocSystem object reference
; @param pro_files {in}{required}{type=strarr} a string array of all the pro
;        files under the 'root' directory
; @param sav_files {in}{required}{type=strarr} a string array of all the save
;        files under the 'root' directory
; @keyword file_hash {in}{required}{type=object} a hash_table object where the
;        keys are the relative paths to the pro files and the values are the
;        file objects
;-
pro idldoc_write_all_files, osystem, pro_files, sav_files, file_hash=file_hash
    compile_opt idl2, hidden

    filename = 'all-files.html'
    openw, lun, filename, /get_lun, error=error
    if (error ne 0) then begin
        osystem->addWarning, 'Error opening ' + filename + ' for writing.'
        return
    endif

    osystem->getProperty, embed=embed, user=user, idldoc_root=idldoc_root

    if ((size(pro_files, /type) eq 7) && (pro_files[0] ne '')) then begin
        basenames = file_basename(pro_files)
        bindices = sort(basenames)
        nfiles = n_elements(pro_files)
    endif else nfiles = 0L

    if (nfiles gt 0L) then begin
        ofiles = obj_new('array_list', example={ href:'', name:'' })

        for f = 0L, nfiles - 1L do begin
            ofile = file_hash->get(pro_files[bindices[f]])
            show = user ? ~ofile->is_private() : ~ofile->is_hidden()
            ofile->getProperty, url=url
            if (show) then begin
                ofiles->add, { href:url, name:basenames[bindices[f]] }
            endif
        endfor

        files = ofiles->to_array()
        obj_destroy, ofiles
    endif else files = -1L

    if (size(sav_files, /type) eq 7 && sav_files[0] ne '') then begin
        basenames = file_basename(sav_files)
        bindices = sort(basenames)
        nsavfiles = n_elements(sav_files)
    endif else nsavfiles = 0L

    if (nsavfiles gt 0L) then begin
        ofiles = obj_new('array_list', example={ href:'', name:'' })

        for f = 0L, nsavfiles - 1L do begin
            ofile = file_hash->get(sav_files[bindices[f]])
            ofile->getProperty, url=url
            ofiles->add, { href:url, name:basenames[bindices[f]] }
        endfor

        savfiles = ofiles->to_array()
        obj_destroy, ofiles
    endif else savfiles = -1L

    sdata = { $
        version : osystem->getVersion(), $
        date : systime(), $
        embed : embed, $
        css_location : $
            filepath('listings.css', subdir=['resource'], root=idldoc_root), $
        files : files, $
        nfiles : nfiles, $
        savfiles : savfiles, $
        nsavfiles : nsavfiles $
        }

    oTemplate = obj_new('template', $
        filepath('all-files.tt', subdir=['templates'], root=idldoc_root))
    oTemplate->process, sdata, lun=lun

    obj_destroy, oTemplate
    free_lun, lun
end


;+
; Writes the "all-dirs.html" file in the root directory.
;
; @private
; @param osystem {in}{required}{type=objref} the IDLdocSystem object reference
; @param all_dirs {in}{required}{type=strarr} a string array of all the
;        directories under the 'root' directory that contain .pro or .sav files;
;        may not be valid, must check count gt 0 first
; @param count {in}{required}{type=int} the number of directories in pro_dirs
;-
pro idldoc_write_all_dirs, osystem, all_dirs, count
    compile_opt strictarr, hidden

    filename = 'all-dirs.html'
    openw, lun, filename, /get_lun, error=error
    if (error ne 0) then begin
        osystem->addWarning, 'Error opening ' + filename + ' for writing.'
        return
    endif

    osystem->getProperty, embed=embed, idldoc_root=idldoc_root

    ndirs = n_elements(all_dirs)
    sindices = sort(all_dirs)
    dirs = replicate({ href:'', name:'' }, ndirs)
    for d = 0L, ndirs - 1L do begin
        name = all_dirs[sindices[d]]
        dirs[d].href = idldoc_elim_slash(name) + '/dir-files.html'
        dirs[d].name = strlen(name) eq 2 ? name : strmid(name, 2)
    endfor

    sdata = { $
        version : osystem->getVersion(), $
        date : systime(), $
        embed : embed, $
        css_location : $
            filepath('listings.css', subdir=['resource'], root=idldoc_root), $
        dirs : dirs, $
        ndirs : strtrim(ndirs, 2) + ' director' + (ndirs ne 1 ? 'ies' : 'y') $
        }

    oTemplate = obj_new('template', $
        filepath('all-dirs.tt', subdir=['templates'], root=idldoc_root))
    oTemplate->process, sdata, lun=lun

    obj_destroy, oTemplate
    free_lun, lun
end


;+
; Find the directories with .pro files in them.
;
; @private
; @returns string array of the directories with .pro files in them, or -1 if
;          there are none
; @param files {in}{required}{type=string array} a string array of all the
;        pro files under the 'root' directory
; @param ndirs {out}{required}{type=int} the number of directories under the
;        root directory that contain .pro files
;-
function idldoc_find_dirs, files, ndirs
    compile_opt strictarr, hidden

    nfiles = n_elements(files)
    dirs = strarr(nfiles)
    ndirs = 0

    for i = 0, nfiles - 1 do begin
        ind = where(dirs eq file_dirname(files[i], /mark_directory), count)
        if (count eq 0) then begin
            dirs[ndirs] = file_dirname(files[i], /mark_directory)
            ndirs = ndirs + 1
        endif
    endfor

    return, ndirs gt 0 ? dirs[0:(ndirs-1)] : -1
end


;+
; Calling routine for IDLdoc.
;
; @file_comments IDLdoc is a hypertext documentation system for IDL code.  It
; is intended to show the API of a library of code in an easy to browse
; manner.  It produces HTML pages -- one page per '.pro' file, as
; well as directory listing, overview pages, and an index of files, routines,
; keywords, and parameter names.
;
; <p>Unmarked code may be processed by IDLdoc to produce a browseable
; listing of routines and their arguments.  But to obtain more useful
; results, the source can be marked to produce formatted comments in
; the output. Each routine has special tags to indicate particular
; information for IDLdoc formatting use. HTML markup tags may be used
; anywhere comments are expected.</p>
;
; <p>For a more an example of code that has been documented using IDLdoc,
; check IDLdoc's source for its comments and compare to its output.</p>
;
; <p>Class listings and fields summary will be generated for files which
; end with "__define.pro."  Use the "field" tag to make comments on each
; field of the class/structure defined.</p>
;
;
; <p>This help was produced by IDLdoc.</p>
;
; @examples To run IDLdoc, try:
;      <center><code>idldoc, root='C:\\mycode'</code></center>
;    where C:\\mycode is the root of a directory tree containing IDL
;    .pro files.
;
; @keyword root {in}{required}{type=string} root directory for IDLdoc's
;          recursive search for .pro files.  IDLdoc will find any
;          files with the '.pro' suffix and include them in its file
;          listings.  Only directories with '.pro' files in them are
;          included in the directory listings.
; @keyword footer {in}{optional}{type=string} filename for a footer
;          to be placed at the bottom of files; this file can contain any valid
;          HTML
; @keyword output {in}{optional}{type=string}{default=same as root}
;          directory in which to create the HTML output and possible
;          subdirectories
; @keyword overview {in}{optional}{type=string} filepath to a file containing
;          the summary of the package information about each directory in the
;          package.
; @keyword user {in}{optional}{type=boolean} set to create a
;          listing appropriate for <em>users</em> of the given
;          library hierarchy; the default is to create documentation
;          suited to developers.  If set private routines are not
;          shown in the documentation.
; @keyword quiet {in}{optional}{type=boolean} if set, print only
;          warnings
; @keyword silent {in}{optional}{type=boolean} if set, print no
;          messages
; @keyword embed {in}{optional}{type=boolean} if set, embeds style
;          sheet in each HTML document; if this is not set, each HTML
;          file will be looking for the cascading style sheet idldoc.css
;          in the directory specified for the ROOT keyword
; @keyword log_file {in}{optional}{type=string} set to a filename of a file to
;          contain the error messages generated by the IDLdoc run; useful for
;          automated runs of IDLdoc
; @keyword nonavbar {in}{optional}{type=boolean} set to exclude the
;          navigation bar at the top of each page
; @keyword title {in}{optional}{type=string}{default=Research Systems} title of
;          the library
; @keyword subtitle {in}{optional}{type=string}{default=IDL version} subtitle of
;          the library
; @keyword statistics {in}{optional}{type=boolean} set to calculate several
;          McCabe statistics for each routine
; @keyword n_warnings {out}{optional}{type=integer} set to a named variable to
;          contain the total number of warnings issued during the run
; @keyword browse_routines {in}{optional}{type=boolean} set to include a frame
;          to browse through the routines of the current file
; @keyword preformat {in}{optional}{type=boolean} set to produce output that
;          will look like it does in the code files (line for line)
; @keyword assistant {in}{optional}{type=boolean} set to produce output for the
;          IDL assistant help system instead of optimized for a web browser
;
; @requires IDL 6.0
; @author Michael D. Galloy
; @copyright RSI, 2002
;-
pro idldoc, root=root, output=output, $
    overview=overview, footer=footer, log_file=log_file, $
    user=user, quiet=quiet, silent=silent, embed=embed, nonavbar=nonavbar, $
    title=title, subtitle=subtitle, $
    statistics=statistics, n_warnings=warnings, $
    browse_routines=browse_routines, $
    preformat=preformat, assistant=assistant

    compile_opt idl2

;    catch, error_no
;    if (error_no ne 0) then begin
;        catch, /cancel
;        message, !error_state.msg, /info, /noname ;'IDLdoc failed on error: ' + strmessage(error_no), /info, /noname
;        !path = saved_path
;        cd, start_dir
;        heap_gc
;        return
;    endif

    expanded_log_filename $
        = n_elements(log_file) eq 0 ? '' : file_expand_path(log_file)

    saved_path = !path
    cd, current=start_dir

    total_warnings = 0

    if (n_elements(overview) eq 0) then overview = ''

    if (n_elements(root) eq 0) then $
        message, 'ROOT keyword required'
    if (not file_test(root, /directory)) then $
        message, 'unable to find directory specified by ROOT keyword'

    !path = !path + path_sep(/search_path) + expand_path('+' + file_expand_path(root))

    idldoc_root = sourceroot()
    if (last_char(root) ne path_sep()) then root = root + path_sep()
    if (n_elements(output) eq 0) then output = root
    if (last_char(output) ne path_sep()) then output = output + path_sep()

    osystem = obj_new('IDLdocSystem', $
        root=root, $
        output=output, $
        idldoc_root=idldoc_root, $
        log_file=expanded_log_filename, $
        user=user, embed=embed, preformat=preformat, statistics=statistics, $
        title=title, subtitle=subtitle, nonavbar=nonavbar, $
        silent=silent, quiet=quiet, footer=footer, assistant=assistant)

    cd, root

    pro_files = file_search('.', '*.pro', count=nprofiles)
    etc_files = file_search('.', '*.idldoc', count=n_etc)
    sav_files = file_search('.', '*.sav', count=nsavfiles)

    if (nprofiles gt 0) then begin
        sindices = sort(pro_files)
        pro_files = pro_files[sindices]
    endif

    if (nsavfiles gt 0) then begin
        sindices = sort(sav_files)
        sav_files = sav_files[sindices]
    endif

    abs_etc_files = etc_files
    for i = 0L, n_etc - 1L do abs_etc_files[i] = file_expand_path(etc_files[i])

    abs_sav_files = sav_files
    for i = 0L, nsavfiles - 1L do abs_sav_files[i] = file_expand_path(sav_files[i])

    cd, start_dir

    if (nprofiles gt 0) then begin
        pro_dirs = idldoc_find_dirs(pro_files, nprodirs)
    endif else nprodirs = 0L

    if (nsavfiles gt 0) then begin
        sav_dirs = idldoc_find_dirs(sav_files, nsavdirs)
    endif else nsavdirs = 0L

    if (nprofiles + nsavfiles le 0) then begin
        message, 'No .pro or .sav files in ROOT file hierarchy', /info, /noname
        return
    endif

    cd, current=start_dir

    if (~file_test(output, /directory)) then file_mkdir, output

    if (~keyword_set(quiet) && ~keyword_set(silent)) then begin
        message, 'Copying IDLdoc resources...', /info, /noname
    endif

    if (~keyword_set(assistant)) then begin
        osystem->filecopy, $
            filepath('main_files.css', subdir='resource', root=idldoc_root), $
            filepath('main_files.css', root=output)
        osystem->filecopy, $
            filepath('main_files_print.css', subdir='resource', root=idldoc_root), $
            filepath('main_files_print.css', root=output)
        osystem->filecopy, $
            filepath('listings.css', subdir='resource', root=idldoc_root), $
            filepath('listings.css', root=output)
        osystem->filecopy, $
            filepath('search.css', subdir='resource', root=idldoc_root), $
            filepath('search.css', root=output)
        osystem->filecopy, $
            filepath('tree.js', subdir='resource', root=idldoc_root), $
            filepath('tree.js', root=output)
        osystem->filecopy, $
            filepath('plus.png', subdir='resource', root=idldoc_root), $
            filepath('plus.png', root=output)
        osystem->filecopy, $
            filepath('minus.png', subdir='resource', root=idldoc_root), $
            filepath('minus.png', root=output)
        osystem->filecopy, $
            filepath('page.png', subdir='resource', root=idldoc_root), $
            filepath('page.png', root=output)
        osystem->filecopy, $
            filepath('idldoc.ico', root=idldoc_root), $
            filepath('idldoc.ico', root=output)
    endif else begin
        osystem->filecopy, $
            filepath('prev.gif', subdir='resource', root=idldoc_root), $
            filepath('prev.gif', root=output)
        osystem->filecopy, $
            filepath('next.gif', subdir='resource', root=idldoc_root), $
            filepath('next.gif', root=output)
    endelse

    class_files = file_search(root, '*__define.pro', /fold_case)
    file_hash = obj_new('hash_table', array_size=1001, key_type=7, value_type=11)

    ; Do all parsing of PRO files first...
    for j = 0, nprodirs - 1L do begin
        dpro_files_ind = where(file_dirname(pro_files, /mark_directory) eq pro_dirs[j])
        dpro_files = pro_files[dpro_files_ind]

        for i = 0, n_elements(dpro_files) - 1 do begin
            if (not keyword_set(quiet) and not keyword_set(silent)) then $
                message, 'Parsing ' + $
                    strmid(dpro_files[i], 2) + '...', /info, /noname
            prev = i eq 0 ? '' : dpro_files[i-1]
            next = i eq (n_elements(dpro_files) - 1) ? '' : dpro_files[i+1]
            file = obj_new('IDLdocFile', $
                dpro_files[i], $
                output=output, $
                root=root, $
                next=next, $
                prev=prev, $
                system=osystem)
            file_hash->put, dpro_files[i], file
        endfor
    endfor

    ; Then do output for all PRO files
    for j = 0, nprodirs - 1L do begin
        dpro_files_ind = where(file_dirname(pro_files, /mark_directory) eq pro_dirs[j])
        dpro_files = pro_files[dpro_files_ind]

        for i = 0, n_elements(dpro_files) - 1 do begin
            if (not keyword_set(quiet) and not keyword_set(silent)) then $
                message, 'Creating doc for ' + $
                    strmid(dpro_files[i], 2) + '...', /info, /noname
            file = file_hash->get(dpro_files[i])
            hide_file = file->is_hidden() or (keyword_set(user) and file->is_private())
            if (~hide_file) then begin
                file->output
            endif
        endfor
    endfor

    if (~keyword_set(assistant) && IDLVersion(/idl61)) then begin
        for i = 0L, nsavfiles - 1L do begin
            if (not keyword_set(quiet) and not keyword_set(silent)) then $
                message, 'Creating doc for ' + $
                    strmid(sav_files[i], 2) + '...', /info, /noname
            osave = obj_new('IDLdocSAVFile', sav_files[i], abs_sav_files[i], $
                system=osystem)
            osave->output
            file_hash->put, sav_files[i], osave
        endfor
    endif

    cd, current=start_dir
    cd, output

    if (nprofiles eq 0) then dirs = sav_dirs
    if (nsavfiles eq 0) then dirs = pro_dirs
    if (nprofiles ne 0 && nsavfiles ne 0) then begin
        dirs = [pro_dirs, sav_dirs]
        dirs = dirs[uniq(dirs, sort(dirs))]
    endif

    if (not keyword_set(quiet) and not keyword_set(silent)) then $
        message, 'Creating overview.html...', /info, /noname
    idldoc_write_overview, osystem, overview, dirs, file_hash

    if (~keyword_set(assistant)) then begin
        if (not keyword_set(quiet) and not keyword_set(silent)) then $
            message, 'Creating directory files listing...', /info, /noname
        for i = 0, n_elements(dirs) - 1L do $
            idldoc_write_dir_files, osystem, $
                pro_files, $
                sav_files, $
                dirs[i], $
                file_hash=file_hash

        if (not keyword_set(quiet) and not keyword_set(silent)) then $
            message, 'Creating idldoc-help.html...', /info, /noname
        idldoc_write_help, osystem

        if (not keyword_set(quiet) and not keyword_set(silent)) then $
            message, 'Creating idldoc-dev-help.html...', /info, /noname
        idldoc_write_dev_help, osystem

        if (not keyword_set(quiet) and not keyword_set(silent)) then $
            message, 'Creating file listings...', /info, /noname
        idldoc_write_all_files, osystem, pro_files, sav_files, file_hash=file_hash

        if (not keyword_set(quiet) and not keyword_set(silent)) then $
            message, 'Creating directory listings...', /info, /noname
        idldoc_write_all_dirs, osystem, dirs, count

        if (not keyword_set(quiet) and not keyword_set(silent)) then $
            message, 'Creating index.html...', /info, /noname
        idldoc_write_index, osystem, pro_dirs

        if (not keyword_set(quiet) and not keyword_set(silent)) then $
            message, 'Creating idldoc-index.html...', /info, /noname
        idldoc_write_full_index, osystem

        if (not keyword_set(quiet) and not keyword_set(silent)) then $
            message, 'Creating directory-overview.html for each directory...', $
                /info, /noname
        idldoc_write_directory_overviews, osystem, dirs, pro_files, $
            sav_files, file_hash=file_hash

        if (not keyword_set(quiet) and not keyword_set(silent)) then $
            message, 'Creating search-page.html...', /info, /noname
        idldoc_write_search, osystem, pro_dirs, pro_files, file_hash=file_hash

        if (n_etc gt 0) then begin
            if (not keyword_set(quiet) and not keyword_set(silent)) then $
                message, 'Creating .idldoc files...', /info, /noname
            idldoc_write_etc, osystem, etc_files, abs_etc_files
        endif

        if (not keyword_set(quiet) and not keyword_set(silent)) then $
            message, 'Creating lib-warnings.html...', /info, /noname
        idldoc_write_warning, osystem, pro_files, file_hash

        if (not keyword_set(quiet) and not keyword_set(silent)) then $
            message, 'Creating idldoc-categories.html...', /info, /noname
        idldoc_write_categories, osystem

        osystem->getProperty, warnings=warnings
        if (not keyword_set(silent)) then $
            if (not keyword_set(quiet) or warnings ne 0) then begin
                msg = strtrim(warnings, 2) + ' warning' + (warnings eq 1 ? '' : 's')
                message, msg, /info, /noname
            endif
    endif else begin
        idldoc_write_assistant_adp, osystem, file_hash
    endelse

    obj_destroy, osystem

    files = file_hash->values(nfiles)
    if (nfiles gt 0) then obj_destroy, files
    obj_destroy, file_hash

    cd, start_dir
    !path = saved_path
end

