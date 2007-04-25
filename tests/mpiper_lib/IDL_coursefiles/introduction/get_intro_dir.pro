;+
; Call this function to return the absolute file path to the
; <b>introduction</b> directory (used to store files for the
; <i>Introduction to IDL</i> class) on your computer.
; <p>
;
; This routine replaces SET_TRAINING_DIRECTORY, which is now obsolete.
; <p>
;
; @pre This file must reside in the same directory as the course files.
; @returns The path to the directory where the course files reside.
; @examples
; <pre>
; IDL> dir = get_intro_dir()
; IDL> print, filepath('hello.pro', root=dir)
; /home/mpiper/IDL/introduction/hello.pro
; </pre>
; @uses SOURCEROOT or SOURCEPATH
; @requires IDL 5.2
; @author Mark Piper, RSI, 2005
;-
function get_intro_dir
    compile_opt idl2

    switch 1 of
        stregex(!version.release, 'development', /fold_case, /boolean) :
        float(!version.release) ge 6.2 : begin
            return, sourcepath()
            break
        end
        else : return, sourceroot()
    endswitch
end
