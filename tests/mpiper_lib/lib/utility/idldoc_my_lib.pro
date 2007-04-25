;+
; Runs IDLdoc on my IDL/lib directory. The results are written
; to my /rsi/home directory.<p>
;
; This program is called by my IDLdoc Library macro.
;
; @examples
;   <code>
;   IDL> idldoc_my_lib<br>
;   </code>
; @author Mark Piper, 2003
;-
pro idldoc_my_lib
    compile_opt idl2

    ; Define input & output directories.
    if strlowcase(!version.os_family) eq 'unix' then begin
        indir = '/rsi/gsg/mpiper/IDL/'
        outdir = '/rsi/home/mpiper/public_html/idldoc/'
    endif else begin
        indir = '\\blender\rsi_gsg\mpiper\IDL\'
        outdir = '\\toaster\rsi_home\mpiper\public_html\idldoc\'
    endelse

    ; Restore IDLdoc.
    a = where(routine_names() eq 'IDLDOC', count)
    if count le 1 then begin
        idldoc_file = filepath('idldoc.sav', root=indir, subdir='idldoc')
        restore, filename=idldoc_file, /verbose
    endif

    ; Run IDLdoc.
    root = filepath('lib', root=indir)
    output = filepath('', root=outdir)
    overview = filepath('overview.txt', root=indir, subdir='lib')
    title = "IDL library - Mark Piper"
    idldoc, root=root, output=output, overview=overview, title=title, $
        /embed, /statistics
end