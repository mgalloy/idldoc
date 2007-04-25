
;--------------------------------------------------------------------

pro fontbrowser_cleanup, wtop
    compile_opt idl2

    widget_control, wtop, get_uvalue=pstate
    ptr_free, pstate
end

;--------------------------------------------------------------------

pro fontbrowser_event, sevent
    compile_opt idl2

end

;--------------------------------------------------------------------

pro fontbrowser_zoomdrawevent, sevent
    compile_opt idl2

    widget_control, sevent.top, get_uvalue=pstate

    ; Redraw on expose event
    if sevent.type eq 4 then (*pstate).ozoomwindow -> draw
end

;--------------------------------------------------------------------

pro fontbrowser_drawevent, sevent
    compile_opt idl2

    widget_control, sevent.top, get_uvalue=pstate

    ; Redraw on expose event
    if sevent.type eq 4 then begin
        (*pstate).owindow -> draw
        return
    endif

    ; When a button down event occurs, ...
    if sevent.type eq 0 then begin
        o = (*pstate).owindow -> select((*pstate).oview, $
           [sevent.x, sevent.y])
        if obj_valid(o[0]) then otext = o[0] else return
        otext -> getproperty, strings=str
        code = (strtrim(byte(str)*1, 2))[0]
        widget_control, (*pstate).wtext1, $
            set_value='ASCII code: ' + code
        widget_control, (*pstate).wtext2, $
            set_value='View this character with string(' + code + 'B)'
        (*pstate).ozoomtext -> setproperty, strings=str
        (*pstate).ozoomwindow -> draw
    endif
end

;--------------------------------------------------------------------

pro fontbrowser_fontselect, sevent
    compile_opt idl2

    widget_control, sevent.top, get_uvalue=pstate
    widget_control, sevent.id, get_uvalue=uval

    switch uval of
    'fontsys': begin
        ; Set which font system is selected.
        (*pstate).fontsystem = sevent.index - 1
        ; Determine which font list to display.
        case (*pstate).fontsystem of
        -1: fontlist = (*pstate).vecfontnames
        0: return
        1: fontlist = (*pstate).ttfontnames
        endcase
        ; Load the apprpriate font list into the font set droplist.
        widget_control, (*pstate).wfontsetdrop, set_value=fontlist
        end
    'fontset': begin
        ; Set newly selected font in the font object.
        case (*pState).fontSystem of
        -1: fontName = 'Hershey*' + strtrim(sEvent.index + 3, 2)
        0: return
        1: fontName = (*pState).TTFontNames[sEvent.index]
        endcase
        (*pState).oFont -> SetProperty, NAME=fontName
        (*pState).ozoomFont -> SetProperty, NAME=fontName
        end
    endswitch

    ; Redraw window.
    (*pState).oWindow -> Draw
end

;--------------------------------------------------------------------
;+
; <center><img src="fontbrowser.jpg"></center><p>
;
; A program to display characters in the vector and True Type font
; systems. [Device fonts are not supported in the Object Graphics
; system.]<p>
;
; The idea for this program came from Beau Legeer's FONTVIEWER,
; which he developed for the Intro to IDL training course.<p>
;
; @file_comments A program to display characters in the vector
;   and True Type font systems.
; @keyword no_block {in}{type=boolean} Set this keyword to force the
;   program to allow command-line access.
; @examples
;   <code>
;   IDL> fontbrowser<br>
;   </code>
; @author Mark Piper, 2001
; @history
;   2003-07-17, MP: Cleaned up code & IDLdoc'ed it.
; @copyright RSI
;-

pro fontbrowser, no_block=no_block
    compile_opt idl2

    ; A list of font systems used in IDL.
    fontsystemnames = ' ' + ['Vector', 'Device', 'TrueType'] + ' '

    ; A list of vector font sets distributed with IDL.
    vecfontnames = [$
        ' 3 - Simplex Roman', $
        ' 4 - Simplex Greek', $
        ' 5 - Duplex Roman', $
        ' 6 - Complex Roman', $
        ' 7 - Complex Greek', $
        ' 8 - Complex Italic', $
        ' 9 - Math and Special', $
        '10 - Special', $
        '11 - Gothic English', $
        '12 - Simplex Script', $
        '13 - Complex Script', $
        '14 - Gothic Italian', $
        '15 - Gothic German', $
        '16 - Cyrillic', $
        '17 - Triplex Roman', $
        '18 - Triplex Italic', $
        '19 - none', $
        '20 - Miscellaneous']

    ; Set up a widget hierarchy.
    xoff = 200
    yoff = 100
    wtop = widget_base(title='Font Browser', $
        /column, $
        xoffset=xoff, $
        yoffset=yoff)
    wselectbase = widget_base(wtop, $
        /row, $
        /align_center, $
        space=5, $
        event_pro='fontbrowser_fontselect')
    wfontsystemlabel = widget_label(wselectbase, $
        value='Font System:')
    wfontsystemdrop = widget_droplist(wselectbase, $
        value=fontsystemnames, $
        uvalue='fontsys')
    wfontsetlabel = widget_label(wselectbase, $
        value='Font Set:')
    wfontsetdrop = widget_droplist(wselectbase, $
        value=vecfontnames, $
        uvalue='fontset')
    device, get_screen_size=ss
    winsize = min(ss)*0.4
    wdraw = widget_draw(wtop, $
        xsize=winsize, $
        ysize=winsize, $
        graphics_level=2, $
        /expose_events, $
        /button_events, $
        event_pro='fontbrowser_drawevent')
;    winstructions = widget_label(wtop, $
;        value='Click on a character to see it magnified in the' $
;        + ' zoom window.')
    wzoombase = widget_base(wtop, $
        /row, $
        /align_left)
    wzoomdraw = widget_draw(wzoombase, $
        xsize=0.25*winsize, $
        ysize=0.25*winsize, $
        graphics_level=2, $
        /expose_events, $
        event_pro='fontbrowser_zoomdrawevent')
    wtextbase = widget_base(wzoombase, $
        /column, $
        /base_align_left)
    winstructions = widget_label(wtextbase, $
        value='Click on a character to see it magnified in the' $
        + ' zoom window.')
    wtext0 = widget_label(wtextbase, $
        value=' ')
    wtext1 = widget_label(wtextbase, $
        value='ASCII code: 123')
    wtext2 = widget_label(wtextbase, $
        value='View this character with string(123B)')

    widget_control, wtop, /realize

    ; Select an initial font & create a font object.
    fontname = 'Hershey*3'
    fontsize = 9
    ofont = obj_new('idlgrfont', name=fontname, size=fontsize)
    ozoomfont = obj_new('idlgrfont', name=fontname, size=fontsize*5)

    ; Set up an object graphics hierarchy for the zoomed draw window.
    ozoomtext = obj_new('idlgrtext', 'A', $
        color=bytarr(3)+255b, $
        location=[0.05,-0.5,0], $
        align=0.5, $
        font=ozoomfont)
    ozoommodel = obj_new('idlgrmodel')
    ozoommodel -> add, ozoomtext
    ozoomview = obj_new('idlgrview', color=[0,0,255])
    ozoomview -> add, ozoommodel

    ; Set up an object graphics hierarchy for the main draw window.
    ntextelts = 256
    ntextdim = sqrt(ntextelts)
    maxpos = 0.9
    xyloc = 2*maxpos*findgen(ntextdim)/(ntextdim-1)-maxpos
    otextarray = objarr(ntextdim,ntextdim)
    for i = 0, ntextdim-1 do begin
        for j = 0, ntextdim-1 do begin
           otextarray[i,j] = obj_new('idlgrtext', $
             string(byte(ntextdim*j+i)), $
             color=bytarr(3)+255b, $
             location=[xyloc[i],xyloc[j],0], $
             align=0.5, $
             font=ofont, $
             onglass=1)
        endfor
    endfor
    omodel = obj_new('idlgrmodel')
    omodel -> add, otextarray
    oview = obj_new('idlgrview', color=[0,0,255])
    oview -> add, omodel
    oviewgroup = obj_new('idlgrviewgroup')
    oviewgroup -> add, [oview, ofont, ozoomfont]

    ; Retrieve the window object references from the draw windows.
    widget_control, wdraw, get_value=owindow
    widget_control, wzoomdraw, get_value=ozoomwindow

    ; Associate the viewgroup with the window & draw.
    ozoomwindow -> setproperty, graphics_tree=ozoomview
    ozoomwindow -> draw
    owindow -> setproperty, graphics_tree=oviewgroup
    owindow -> draw

    ; Use the window object GetFontNames method to find the
    ; available TrueType fonts.
    ttfontnames = owindow -> getfontnames('*')

    ; Set up state variable.
    sstate = { $
        owindow         : owindow, $
        ozoomwindow     : ozoomwindow, $
        ozoomtext       : ozoomtext, $
        ozoomfont       : ozoomfont, $
        oview           : oview, $
        ofont           : ofont, $
        fontsystem      : -1, $
        fontname        : fontname, $
        vecfontnames    : vecfontnames, $
        ttfontnames     : ttfontnames, $
        wfontsetdrop    : wfontsetdrop, $
        wtext1          : wtext1, $
        wtext2          : wtext2}
    pstate = ptr_new(sstate, /no_copy)
    widget_control, wtop, set_uvalue=pstate

    ; Call XMANAGER.
    xmanager, 'fontbrowser', wtop, $
        event_handler = 'fontbrowser_event', $
        cleanup = 'fontbrowser_cleanup', $
        no_block = keyword_set(no_block)
end