;+
; This procedure is used to
; <ol>
; <li> resolve the routines necessary for building IM_ENGINE
; <li> create a .sav file that can be executed with IDL Runtime
;   or IDL Virtual Machine.
; </ol>
; This program is designed to be run from the directory containing
; <b>im_engine.pro</b>.<p>
;
; Note: Need to explicitly resolve CLEANUP_WIDGETS and HANDLE_EVENTS;
; they're called by XMANAGER, so RESOLVE_ALL doesn't catch them.<p>
; Note: XMANAGER ignores the NO_BLOCK keyword in Runtime and VM
; modes.<p> 
;
; @requires IDL 6.0
; @author Mark Piper, 2003
;-
pro build_im_engine
    compile_opt idl2

    resolve_routine, 'im_engine'
    resolve_routine, 'cleanup_widgets'
    resolve_routine, 'handle_events'
    im_engine_classes = [ $
                        'im_engine', $
                        'vector', $
                        'im_histogram', $
                        'im_operator', $
                        'im_smooth', $
                        'im_hist_equal']
    resolve_all, class=im_engine_classes, /continue_on_error
    save, filename='im_engine.sav', /routines
end
