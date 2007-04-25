;+
; Prints the current working directory to the output log.
;
; @examples
;   <pre>
;   IDL> pwd
;   /home/mpiper/IDL
;   </pre>
; @author Mark Piper, 1998
;-
pro pwd
    cd, current=c
    print, c
end
