;+
; Run IDLdoc on various test cases and the IDLdoc source code itself.
;
; @keyword assistant {in}{optional}{type=boolean} produce ADP help instead of
;          output optimized for web pages
; @keyword idldoc {in}{optional}{type=boolean} run on IDLdoc source code
; @keyword small {in}{optional}{type=boolean} run on a small example of two
;          .pro files
; @keyword sav {in}{optional}{type=boolean} run on a series of SAV files
; @keyword idl_lib {in}{optional}{type=boolean} run on the running version of
;          IDL's lib directory
; @keyword idl_complete {in}{optional}{type=boolean} run on the running version of
;          IDL's main directory
; @keyword time {out}{optional}{type=float} time of IDLdoc run
; @keyword nobrowser {in}{optional}{type=boolean} set to not display output
;-
pro test_idldoc, assistant=assistant, idldoc=idldoc, dist_docset=dist_docset, $
    small=small, sav=sav, empty=empty, $
    idl_lib=idl_lib, idl_complete=idl_complete, bizarre=bizarre, $
    class_diagram=class_diagram, gs_code_library=gs_code_library, $
    itools_course=itools_course, itools_lib=itools_lib, $
    jimp001=jimp001, $
    jimp002=jimp002, $
    mpiper_lib=mpiper_lib, $
    time=time, nobrowser=nobrowser

    compile_opt strictarr

    nonavbar = 0B
    statistics = 0B
    pre = 0B
    user = 0B

    location = sourceroot()
    proot = strjoin((strsplit(location, $
        path_sep(), count=ndirs, /extract))[0:ndirs-2], path_sep())
    if (!version.os_family eq 'unix') then proot = '/' + proot
    browser_location = '"C:\Program Files\Mozilla Firefox\firefox.exe"'

    case 1B of
    keyword_set(class_diagram) : begin
            root = filepath('', subdir=['tests', 'class_diagram'], root=proot)
            title = 'Class diagram'
            subtitle = 'Making class diagrams'
            if (keyword_set(assistant)) then begin
                output = filepath('', $
                    subdir=['tests', 'class_diagram_adp_docs'], root=proot)
            endif else begin
                output = filepath('', $
                    subdir=['tests', 'class_diagram_docs'], root=proot)
            endelse
        end
    keyword_set(empty) : begin
            root = filepath('', subdir=['tests', 'empty'], root=proot)
            title = 'Empty'
            subtitle = 'No .pro, .sav, or .idldoc files'
            if (keyword_set(assistant)) then begin
                output = filepath('', $
                    subdir=['tests', 'empty_adp_docs'], root=proot)
            endif else begin
                output = filepath('', $
                    subdir=['tests', 'empty_docs'], root=proot)
            endelse
        end
    keyword_set(bizarre) : begin
            root = filepath('', subdir=['tests', 'bizarre'], root=proot)
            title = 'Bizarre tests'
            subtitle = 'Oddball test output for IDLdoc'
            footer = root + 'footer'
            overview = root + 'overview'
            if (keyword_set(assistant)) then begin
                output = filepath('', $
                    subdir=['tests', 'bizarre_adp_docs'], root=proot)
            endif else begin
                output = filepath('', $
                    subdir=['tests', 'bizarre_files_docs'], root=proot)
            endelse
        end
    keyword_set(idldoc) : begin
            root = filepath('', subdir=['dist'], root=proot)
            title = 'IDLdoc project documentation'
            subtitle = '"The IDL code documentation project documentation"'
            statistics = 1B
            footer = root + 'footer'
            overview = root + 'overview'
            if (keyword_set(assistant)) then begin
                output = filepath('', subdir=['adp_docs'], root=proot)
            endif else begin
                output = filepath('', subdir=['docs'], root=proot)
            endelse
        end
    keyword_set(dist_docset) : begin
            root = filepath('', subdir=['dist'], root=proot)
            title = 'IDLdoc project documentation'
            subtitle = '"The IDL code documentation project documentation"'
            statistics = 0B
            nonavbar = 1B
            user = 1B
            overview = root + 'overview'
            if (keyword_set(assistant)) then begin
                output = filepath('', subdir=['adp_docs'], root=proot)
            endif else begin
                output = filepath('', subdir=['docs'], root=proot)
            endelse
        end
    keyword_set(small) : begin
            root = filepath('', subdir=['tests', 'small'], root=proot)
            title = 'Small test'
            subtitle = 'Test output for IDLdoc'
            statistics = 1B
            footer = root + 'footer'
            overview = root + 'overview'
            if (keyword_set(assistant)) then begin
                output = filepath('', $
                    subdir=['tests', 'small_adp_docs'], root=proot)
            endif else begin
                output = filepath('', $
                    subdir=['tests', 'small_docs'], root=proot)
            endelse
        end
    keyword_set(sav) : begin
            root = filepath('', subdir=['tests', 'sav_files'], root=proot)
            title = 'SAV file test'
            subtitle = 'SAV file test output for IDLdoc'
            footer = root + 'footer'
            overview = root + 'overview'
            if (keyword_set(assistant)) then begin
                output = filepath('', $
                    subdir=['tests', 'sav_files_adp_docs'], root=proot)
            endif else begin
                output = filepath('', $
                    subdir=['tests', 'sav_files_docs'], root=proot)
            endelse
        end
    keyword_set(itools_course) : begin
            proot = 'C:\Documents and Settings\mgalloy\My Documents\classes\itools'
            root = filepath('', subdir=['cd'], root=proot)
            title = 'iTools Programming'
            subtitle = 'IDL 6.2 (iTools 2.2)'
            footer = filepath('footer', subdir=['class'], root=proot)
            overview = filepath('overview', subdir=['class'], root=proot)
            if (keyword_set(assistant)) then begin
                output = filepath('', $
                    subdir=['cd', 'adp_docs'], root=proot)
            endif else begin
                output = filepath('', $
                    subdir=['cd', 'docs'], root=proot)
            endelse
        end
    keyword_set(gs_code_library) : begin
            root = '\\blender\RSI_GSG\gs_code_library'
            title = 'GS Code Library'
            subtitle = 'As of ' + systime()
            if (keyword_set(assistant)) then begin
                output = filepath('', $
                    subdir=['tests', 'gs_code_library_adp_docs'], root=proot)
            endif else begin
                output = filepath('', $
                    subdir=['tests', 'gs_code_library_docs'], root=proot)
            endelse
            log_file = output + 'errors.log'
        end
    keyword_set(idl_lib) : begin
            root = filepath('', subdir=['lib'])
            title = 'IDL ' + !version.release + ' library'
            subtitle = 'Build date: ' + !version.build_date
            if (keyword_set(assistant)) then begin
                output = filepath('', $
                    subdir=['tests', 'idl_lib_adp_docs'], root=proot)
            endif else begin
                pre = 1B
                output = filepath('', $
                    subdir=['tests', 'idl_lib_docs'], root=proot)
            endelse
        end
    keyword_set(itools_lib) : begin
            proot = 'C:\Documents and Settings\mgalloy\My Documents\classes\itools'
            root = 'C:\RSI\IDL62\lib\itools'
            title = 'iTools code'
            subtitle = 'IDL ' + !version.release + ' library'
            if (keyword_set(assistant)) then begin
                output = filepath('', $
                    subdir=['cd', 'itools_lib_adp_docs'], root=proot)
            endif else begin
                pre = 1B
                output = filepath('', $
                    subdir=['cd', 'itools_lib_docs'], root=proot)
            endelse
        end
    keyword_set(idl_complete) : begin
            root = filepath('')
            title = 'IDL ' + !version.release
            subtitle = 'Build date: ' + !version.build_date
            if (keyword_set(assistant)) then begin
                output = filepath('', $
                    subdir=['tests', 'idl_complete_adp_docs'], root=proot)
            endif else begin
                pre = 1B
                output = filepath('', $
                    subdir=['tests', 'idl_complete_docs'], root=proot)
            endelse
        end
    keyword_set(jimp001) : begin
            root = filepath('', subdir=['tests', 'jimp001'], root=proot)
            title = 'Tests from the jimp'
            subtitle = 'Problem with the OBSOLETE tag?'
            overview = root + 'overview'
            if (keyword_set(assistant)) then begin
                output = filepath('', $
                    subdir=['tests', 'jimp001_adp_docs'], root=proot)
            endif else begin
                output = filepath('', $
                    subdir=['tests', 'jimp001_docs'], root=proot)
            endelse
        end
    keyword_set(jimp002) : begin
            root = filepath('', subdir=['tests', 'jimp002'], root=proot)
            title = 'Tests from the jimp'
            subtitle = 'Problems with CREATE_STRUCT?'
            overview = root + 'overview'
            if (keyword_set(assistant)) then begin
                output = filepath('', $
                    subdir=['tests', 'jimp002_adp_docs'], root=proot)
            endif else begin
                output = filepath('', $
                    subdir=['tests', 'jimp002_docs'], root=proot)
            endelse
        end
    keyword_set(mpiper_lib) : begin
            root = filepath('', subdir=['tests', 'mpiper_lib'], root=proot)
            title = 'mpiper_lib'
            subtitle = 'Mark Piper''s library'
            if (keyword_set(assistant)) then begin
                output = filepath('', $
                    subdir=['tests', 'mpiper_lib_adp_docs'], root=proot)
            endif else begin
                output = filepath('', $
                    subdir=['tests', 'mpiper_lib_docs'], root=proot)
            endelse
        end

    else :
    endcase

    start_time = systime(/seconds)
    idldoc, root=root, output=output, embed=1B, nonavbar=nonavbar, pre=pre, $
        title=title, subtitle=subtitle, statistics=statistics, $
        footer=footer, overview=overview, assistant=keyword_set(assistant), $
        log_file=log_file
    end_time = systime(/seconds)
    time = end_time - start_time

    if (~keyword_set(nobrowser) && !version.os_family ne 'unix') then begin
        if (keyword_set(assistant)) then begin
            online_help, book=output + 'idldoc-lib.adp'
        endif else begin
            spawn, browser_location $
                + ' "' + output + 'index.html"', $
                /nowait, /noshell
        endelse
    endif
end
