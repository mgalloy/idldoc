;+
; Loads a color table used in the <i>Introduction to IDL</i>
; course manual. The black and white entries have been swapped
; to make nicer screen captures for the manual.
;
; @keyword silent {in}{optional}{type=boolean} Set this keyword
;  to suppress the informational message displayed in the
;  output log.
; @examples
; <pre>
; IDL> load_grays
; % Intro to IDL grayscale color table loaded.
; </pre>
; @requires IDL 6.0
; @author Mark Piper, RSI, 2003
;-
pro load_grays, silent=silent
	compile_opt idl2

	; We're using color tables, so switch to indexed color mode.
	device, decomposed=0

    loadct, 0, /silent
    top = !d.table_size-1
    tvlct, 0, 0, 0, (top < 255)
    tvlct, 255, 255, 255, 0
    if ~keyword_set(silent) then $
    	message, 'Intro to IDL grayscale color table loaded.', $
    		/info, /noname
end