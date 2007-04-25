;+
; Call this program to create the system variable <i>!training</i>,
; containing the absolute file path to the <b>training</b> directory
; (used to store files for IDL classes) on your computer.
; <p>
;
; Use this program to explicitly set the location of <b>training</b>,
; rather than assuming it sits under <i>!dir</i>, which is root-owned
; on UNIX-based OSes.
; <p>
;
; This program is superceded by GET_INTRO_DIR.
; <p>
;
; @param training_dir {in}{optional}{type=string} A string defining
; the path (relative or absolute) to the training directory.
; @examples
; <pre>
; IDL> set_training_directory
; % Training directory set to "/home/mpiper/IDL/training"
; IDL> print, filepath('hello.pro', root=!training)
; /home/mpiper/IDL/training/hello.pro
; </pre>
; @requires IDL 6.0
; @author Mark Piper, RSI, 2004
; @history
;  2005-10, MP: Obsoleted by GET_INTRO_DIR.
;-
pro set_training_directory, training_dir
    compile_opt idl2, obsolete

	if n_params() eq 0 then begin
    	training_dir = dialog_pickfile(/directory, /must_exist, $
    		title='Please Select Training Directory')
    endif else training_dir = file_expand_path(string(training_dir))

    if ~file_test(training_dir) then begin
    	if training_dir eq '' then msg = '' $
    		else msg = 'Directory "' + training_dir + '" not found. '
		message, msg + 'Training directory not set or changed.', $
			/info, /noname
    	return
    endif

    defsysv, '!training', training_dir
    message, 'Training directory set to "' + !training + '"', /info, /noname
end