;+
; This program demonstrates how to make a plot with a vertical independent
; axis increasing downward; in this case, an oceanic temperature profile
; as a function of depth below sea level.
; <p>
;
; The data, representative of a low-latitude open ocean temperature
; profile, are taken from Figure 4.4 in Pickard, G.L. and W.J. Emery,
; 1990: <i>Descriptive Physical Oceanography</i>, 5th edition, Pergamon
; Press, Oxford, 320 pp.
; <p>
;
; This code is used in the chapter "Line Plots" in the <i>Introduction
; to IDL</i> course manual.
; <p>
;
; @requires IDL 5.2
; @uses GET_INTRO_DIR, the IDL SAVE file <b>depth_profile.sav</b>
; @author Mark Piper, RSI, 2003
; @history
; 2005-10, MP: Replaced SOURCEROOT and <i>!training</i> with
; GET_INTRO_DIR function<br>
;-
pro depth_profile_ex
    compile_opt idl2

    ; Temperature profile. See reference above.
    restore, filepath('depth_profile.sav', root_dir=get_intro_dir()), /verbose
    min_depth = min(depth, max=max_depth)

    plot, temperature, depth, $
        yrange=[max_depth, min_depth], $
        xstyle=4, $
        ystyle=8, $
        ymargin=[2,4], $
        ytitle='Depth (m)', $
        psym=-5, $
        symsize=0.8
    axis, xaxis=1, xtitle='Temperature (!uo!nC)'
end