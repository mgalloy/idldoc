;---------------------------------------------------------------------------------------
; Simple IDL 6.2 Image Animation Demo / Test
; - Show IDL 6.2 image performance
; - Show IDL 6.2 IDLgrModel enhancements
; - Show IDL 6.2 Window Timer support
;
; Demo can be switched to draw the images with the pre-6.2 image support, which is very
; slow because the image resizing and interpolation is done in software.
;
; If you have a fast machine and can't seem to get past 60, 72, 75, 85 or so FPS, then
; you need to turn off vertical sync.
;---------------------------------------------------------------------------------------


;---------------------------------------------------------------------------------------
; Timer Observer Class
; This class responds to timer messages
;---------------------------------------------------------------------------------------
function timer_observer::init
    self.inc = 1
    return, 1
end

pro timer_observer::cleanup
end

; OnTimer is called when the itWindow timer event occurs.
pro timer_observer::OnTimer, oWin
	;; Decide index of next image to display
    self.currentImage += self.inc
    if self.currentImage ge self.nImages then self.currentImage = 0
    if self.currentImage lt 0 then self.currentImage = self.nImages-1

	;; Tell grModel which item to display
    self.oImages->SetProperty, ACTIVE_POSITION=self.currentImage

	;; Update window
    oWin->Draw

	;; Update widgets
    WIDGET_CONTROL, self.wFrameIndicator, SET_VALUE=self.currentImage

	;; Start keeping track of the time.
    if self.timerImages eq 0 then $
        self.timerStart = SYSTIME(1)
    self.timerImages++
end

function timer_observer::GetStatus
    return, self.status
end

function timer_observer::GetRate
    a = self.timerImages / (SYSTIME(1) - self.timerStart)
    return, a
end

pro timer_observer::SetProperty, $
    CURRENT_IMAGE = currentImage, $
    INCREMENT = inc, $
    NIMAGES = nImages, $
    OIMAGES = oImages, $
    WFRAMEINDICATOR = wFrameIndicator, $
    TIMER_IMAGES = timerImages

    if N_ELEMENTS(currentImage) gt 0 then $
        self.currentImage = currentImage

    if N_ELEMENTS(inc) gt 0 then $
        self.inc = inc

    if N_ELEMENTS(nImages) gt 0 then $
        self.nImages = nImages

    if N_ELEMENTS(oImages) gt 0 then $
        self.oImages = oImages

    if N_ELEMENTS(wFrameIndicator) gt 0 then $
        self.wFrameIndicator = wFrameIndicator

    if N_ELEMENTS(timerImages) gt 0 then $
        self.timerImages = timerImages
end

pro timer_observer::GetProperty, $
    CURRENT_IMAGE = currentImage, $
    INCREMENT = inc, $
    NIMAGES = nImages, $
    OIMAGES = oImages, $
    WFRAMEINDICATOR = wFrameIndicator, $
    TIMER_IMAGES = timerImages

    if ARG_PRESENT(currentImage) then $
        currentImage = self.currentImage

    if ARG_PRESENT(inc) then $
        inc = self.inc

end

pro timer_observer__define
    struct = { timer_observer, $
        currentImage: 0L, $
        inc: 0L, $
        nImages: 0L, $
        oImages: OBJ_NEW(), $
        wFrameIndicator: 0L, $
        timerStart: 0.0d, $
        timerImages: 0L, $
        status: 0b $
    }
end

;---------------------------------------------------------------------------------------
; Clean up on shutdown
;---------------------------------------------------------------------------------------

pro kill, wBase
    WIDGET_CONTROL, wBase, GET_UVALUE=pState
    WIDGET_CONTROL, (*pState).wBase, TIMER=0
    OBJ_DESTROY, (*pState).oAnimation
    OBJ_DESTROY, (*pState).oContours
    OBJ_DESTROY, (*pState).oTextLabels
    OBJ_DESTROY, (*pState).oOverlay
    OBJ_DESTROY, (*pState).oPalette
    OBJ_DESTROY, (*pState).oObserver
    PTR_FREE, pState
end

;---------------------------------------------------------------------------------------
; Event Handler
;---------------------------------------------------------------------------------------

pro animation1_event, sEvent

    COMPILE_OPT idl2, hidden

	;; Resize
    if (TAG_NAMES(sEvent, /STRUC) eq 'WIDGET_BASE') then begin
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=pState
        (*pState).windowDims=[sevent.x, sevent.y-200]
        WIDGET_CONTROL, (*pState).wDraw, XSIZE=sevent.x, YSIZE=sevent.y-200
        return
    endif

	;; Timer
    if (TAG_NAMES(sEvent, /STRUC) eq 'WIDGET_TIMER') then begin
        WIDGET_CONTROL, sEvent.top, GET_UVALUE=pState
        fps = (*pState).oObserver->getRate()
        fps = STRING(fps, FORMAT='(%"%5.1f")')
        WIDGET_CONTROL, (*pState).wAnimateFPS, SET_VALUE=fps
        WIDGET_CONTROL, (*pState).wBase, TIMER=1
        return
    endif

    WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval
    WIDGET_CONTROL, sEvent.top, GET_UVALUE=pState
    case uval of

    'ANIMATE_QUIT': begin
        WIDGET_CONTROL, sEvent.top, /DESTROY
    end
    'ANIMATE_STOP': begin
        (*pState).oWindow->SetEventMask, TIMER_EVENTS=0
        (*pState).oWindow->Draw, (*pState).oView
        WIDGET_CONTROL, (*pState).wAnimateStepF, SENSITIVE=1
        WIDGET_CONTROL, (*pState).wAnimateStepB, SENSITIVE=1
        WIDGET_CONTROL, (*pState).wAnimateCurrentFrame, $
                        SET_VALUE=(*pState).currentFrame
    end
    'ANIMATE_PLAY': begin
        (*pState).oWindow->SetEventMask, TIMER_EVENTS=1
        (*pState).oObserver->SetProperty, TIMER_IMAGES=0
        WIDGET_CONTROL, (*pState).wAnimateStepF, SENSITIVE=0
        WIDGET_CONTROL, (*pState).wAnimateStepB, SENSITIVE=0
        end
    'ANIMATE_STEPF': begin
        (*pState).oObserver->OnTimer, (*pState).oWindow
        (*pState).oObserver->SetProperty, TIMER_IMAGES=0
        end
    'ANIMATE_STEPB': begin
        (*pState).oObserver->GetProperty, INC=advance
        (*pState).oObserver->SetProperty, INC= -advance
        (*pState).oObserver->OnTimer, (*pState).oWindow
        (*pState).oObserver->SetProperty, INC=advance
        (*pState).oObserver->SetProperty, TIMER_IMAGES=0
        end
    'RENDER_61': begin
    	for i=0, N_ELEMENTS((*pState).oImages) - 1 do $
    		(*pState).oImages[i]->SetProperty, RENDER_METHOD=sEvent.select
    	end
    'ANIMATE_RATE': begin
        interval = 1.0 / sEvent.value
        (*pState).oWindow->SetTimerInterval, interval
        end
    'ANIMATE_ADVANCE': begin
        advance = sEvent.value
        (*pState).oObserver->SetProperty, INC=advance
        end
    'ANIMATE_OVERLAY': begin
        if sEvent.select ne 0 then $
            (*pState).oModel->Add, (*pState).oOverlay $
        else $
            (*pState).oModel->Remove, (*pState).oOverlay
        (*pState).oWindow->Draw, (*pState).oView
        end
    'ANIMATE_CONTOURS': begin
        if sEvent.select ne 0 then begin
            for i=0, (*pState).nFrames - 1 do begin
                oModel = (*pState).oAnimation->Get(POSITION=i)
                oModel->Add, (*pState).oContours[i]
            endfor
        endif else begin
            for i=0, (*pState).nFrames - 1 do begin
                oModel = (*pState).oAnimation->Get(POSITION=i)
                oModel->Remove, (*pState).oContours[i]
            endfor
        endelse
        (*pState).oWindow->Draw, (*pState).oView
        end
    'ANIMATE_TEXT': begin
        if sEvent.select ne 0 then begin
            for i=0, (*pState).nFrames - 1 do begin
                oModel = (*pState).oAnimation->Get(POSITION=i)
                oModel->Add, (*pState).oTextLabels[i]
            endfor
        endif else begin
            for i=0, (*pState).nFrames - 1 do begin
                oModel = (*pState).oAnimation->Get(POSITION=i)
                oModel->Remove, (*pState).oTextLabels[i]
            endfor
        endelse
        (*pState).oWindow->Draw, (*pState).oView
        end
    'DRAW': begin
        ; Handle all events in the draw area.
        case sEvent.type of
            ; Button Press
            0: begin
                if (sEvent.press and 1) ne 0 then $
                    (*pState).bDragging = 1
                if (sEvent.press and 2) ne 0 then $
                    (*pState).bFlicking = 1
                if (sEvent.press and 4) ne 0 then $
                    (*pState).bZooming = 1
                (*pState).x = sEvent.x
                (*pState).y = sEvent.y
                (*pState).oWindow->Draw, (*pState).oView
            end

            ; Button Release
            1: begin
                if (sEvent.release and 1) ne 0 then $
                    (*pState).bDragging = 0
                if (sEvent.release and 2) ne 0 then $
                    (*pState).bFlicking = 0
                if (sEvent.release and 4) ne 0 then $
                    (*pState).bZooming = 0
            end

            ; Motion
            2: begin
                if ((*pState).bDragging) then begin
                    delx = sEvent.x - (*pState).x
                    dely = sEvent.y - (*pState).y
                    (*pState).x = sEvent.x
                    (*pState).y = sEvent.y
                    (*pState).oView->GetProperty, VIEWPLANE_RECT=vp
                    factor = (*pState).windowDims[0] / vp[2]
                    vp[0] -= delx / factor
                    vp[1] -= dely / factor
                    (*pState).oView->SetProperty, VIEWPLANE_RECT=vp
                    (*pState).oWindow->Draw, (*pState).oView
                endif
                if ((*pState).bFlicking) then begin
                    delx = sEvent.x - (*pState).x
                    dely = sEvent.y - (*pState).y
                    (*pState).x = sEvent.x
                    (*pState).y = sEvent.y
                    if abs(delx) gt abs(dely) then del = delx else del = dely
                    del = del ge 0 ? 1 : -1
                    (*pState).oObserver->GetProperty, CURRENT_IMAGE=currentImage
                    currentImage += del
                    if currentImage lt 0 then currentImage = (*pState).nFrames-1
                    if currentImage ge (*pState).nFrames then currentImage = 0
                    (*pState).oObserver->SetProperty, CURRENT_IMAGE=currentImage
                    (*pState).oAnimation->SetProperty, ACTIVE_POSITION=currentImage
                    (*pState).oWindow->Draw, (*pState).oView
                    WIDGET_CONTROL, (*pState).wAnimateCurrentFrame, SET_VALUE=currentImage
                endif
                if ((*pState).bZooming) then begin
                    delx = sEvent.x - (*pState).x
                    dely = sEvent.y - (*pState).y
                    (*pState).x = sEvent.x
                    (*pState).y = sEvent.y
                    (*pState).oView->GetProperty, VIEWPLANE_RECT=vp
                    factor = (*pState).windowDims[0] / vp[2]
                    del = (abs(delx) gt abs(dely) ? delx : dely) / factor
                    vp[0] += del/2
                    vp[1] += del/2
                    vp[2] -= del
                    vp[3] -= del
                    (*pState).oView->SetProperty, VIEWPLANE_RECT=vp
                    (*pState).oWindow->Draw, (*pState).oView
                endif
            end

            ; Expose
            4: begin
                ; expose events now handled by itwindow.
                ;(*pState).oWindow->Draw, (*pState).oView
            end
            else: begin
            end
        endcase
    end
    endcase
end


;-----------------------------------------------------------------------------
;+
; An example of animation using IDL 6.2.
;
; @author Karl Schultz, RSI, 2005
; @history
;  2005-08, MP: Annotation of Karl's sparse documentation!<br>
;-
pro animation1

    PRINT, 'NOTE: In order to run this demo at very high frame rates, you must be sure that your monitor vertical sync is turned off!!!!!!!'

    renderer = 0
    windowDims = [600L,600]

    ;; Set up base and draw widget
    wBase = WIDGET_BASE( $
        TITLE='Object Graphics Animation Demo (Renderer='+ $
        STRTRIM(STRING(renderer),2)+')', $
        KILL_NOTIFY='kill', $
        /COLUMN, /TLB_SIZE_EVENTS)
    wDraw = WIDGET_DRAW(wBase, $
        XSIZE=windowDims[0], $
        YSIZE=windowDims[1], $
        CLASSNAME='IDLitWindow', $
        GRAPHICS_LEVEL=2, $
        RENDERER=renderer, $
        /BUTTON_EVENTS, $
        /EXPOSE_EVENTS, $
        /MOTION_EVENTS, $
        UVALUE='DRAW' $
        )

    ;; Set up widgets for control panel
    wPanel = WIDGET_BASE(wBase, /COL)
    wPanelBase = WIDGET_BASE(wPanel, /COL, /FRAME)
    wPanelRow1 = WIDGET_BASE(wPanelBase, /ROW, /FRAME)
    wPanelRow2 = WIDGET_BASE(wPanelBase, /ROW, /FRAME)
    wPanelRow3 = WIDGET_BASE(wPanelBase, /ROW, /FRAME)
    wPanelRow4 = WIDGET_BASE(wPanelBase, /ROW, /FRAME)

    ;; Row 1
    wButtonBox = WIDGET_BASE(wPanelRow1, /ROW, /FRAME)
    lab = BYTARR(32,32)
    for i=0, 7 do $
        lab[8:8+2*i, i+8] = 1
    for i=0, 7 do $
        lab[8:22-2*i, i+16] = 1
    lab = SHIFT(lab, -4, 0)
    lab[22:27, 8:23] = 1
    savelab = lab
    wAnimateStepB = WIDGET_BUTTON(wButtonBox, $
        VALUE=CVTTOBM(REVERSE(lab)), $
        /BITMAP, $
        UVALUE="ANIMATE_STEPB")
    lab = BYTARR(32,32)
    lab[8:23, 8:23] = 1
    wAnimateStop = WIDGET_BUTTON(wButtonBox, $
        VALUE=CVTTOBM(lab), $
        /BITMAP, $
        UVALUE="ANIMATE_STOP")
    lab = BYTARR(32,32)
    for i=0, 7 do $
        lab[8:8+2*i, i+8] = 1
    for i=0, 7 do $
        lab[8:22-2*i, i+16] = 1
    wAnimatePlay = WIDGET_BUTTON(wButtonBox, $
        VALUE=CVTTOBM(lab), $
        /BITMAP, $
        UVALUE="ANIMATE_PLAY")
    wAnimateStepF = WIDGET_BUTTON(wButtonBox, $
        VALUE=CVTTOBM(savelab), $
        /BITMAP, $
        UVALUE="ANIMATE_STEPF")
    wRenderBase = WIDGET_BASE(wPanelRow1, /NONEXCLUSIVE)
    wRenderButton = WIDGET_BUTTON(wRenderBase, $
        VALUE='Use IDL 6.1 rendering', $
        UVALUE='RENDER_61')

    ;; Row 2
    wLabel = WIDGET_LABEL(wPanelRow2, VALUE="Rate (fps):")
    wAnimateRate = WIDGET_SLIDER(wPanelRow2, $
        MINIMUM=1, $
        MAXIMUM=200, $
        UVALUE="ANIMATE_RATE")
    wLabel = WIDGET_LABEL(wPanelRow2, VALUE="Frame Advance:")
    wAnimateAdvance = WIDGET_SLIDER(wPanelRow2, $
        MINIMUM=-5, $
        MAXIMUM=5, $
        VALUE=1, $
        UVALUE="ANIMATE_ADVANCE")

    ;; Row 3
    wAnimateCurrentFrame = CW_FIELD(wPanelRow3, $
        VALUE='0', $
        UVALUE="ANIMATE_CURRENT_FRAME", $
        /INTEGER, $
        TITLE='Current Frame:', $
        XSIZE=4)
    wAnimateFPS = CW_FIELD(wPanelRow3, $
        VALUE='0', $
        UVALUE="ANIMATE_FPS", $
        /STRING, $
        /NOEDIT, $
        TITLE='FPS:', $
        XSIZE=6)

    ;; Row 4
    wOverlayBase = WIDGET_BASE(wPanelRow4, /NONEXCLUSIVE)
    wOverlayButton = WIDGET_BUTTON(wOverlayBase, $
        VALUE='Overlay', $
        UVALUE='ANIMATE_OVERLAY')
    wContoursBase = WIDGET_BASE(wPanelRow4, /NONEXCLUSIVE)
    wContoursButton = WIDGET_BUTTON(wContoursBase, $
        VALUE='Contours', $
        UVALUE='ANIMATE_CONTOURS')
    wTextBase = WIDGET_BASE(wPanelRow4, /NONEXCLUSIVE)
    wTextButton = WIDGET_BUTTON(wTextBase, $
        VALUE='Text Labels', $
        UVALUE='ANIMATE_TEXT')
    wQuit = WIDGET_BUTTON(wPanelRow4, $
        VALUE="Quit", $
        UVALUE="ANIMATE_QUIT")

    WIDGET_CONTROL, wBase, /REALIZE
    WIDGET_CONTROL, wDraw, GET_VALUE=oWindow


    ;; Create the graphics hierarchy.
    oView = OBJ_NEW('IDLgrView', $
        VIEWPLANE_RECT=[0,0,80, 100], $
        COLOR=[180,180,180], $
        ZCLIP=[100,-100], $
        EYE=101)
    oModel = OBJ_NEW('IDLgrModel')
    oView->Add, oModel
    oWindow->SetProperty, GRAPHICS_TREE=oView
    oObserver = OBJ_NEW('timer_observer')


    ;; Read data
    nFrames = 57
    head = read_binary( $
        filepath('head.dat', SUBDIR=['examples','data']), $
        DATA_DIMS=[80,100, 57])

    ;; Create animation and frames
    oAnimation = OBJ_NEW('IDLgrModel', RENDER_METHOD=1)
    oObserver->SetProperty, NIMAGES=nFrames, oIMAGES=oAnimation
    oWindow->AddWindowEventObserver, oObserver
    oImages = OBJARR(57)
    oContours = OBJARR(57)
    oTextLabels = OBJARR(57)
    oPalette = OBJ_NEW('IDLgrPalette')
    oPalette->LoadCT, 4
    for i=0, 56 do begin
        oImages[i] = OBJ_NEW('IDLgrImage', head[*,*,i], $
            PALETTE=oPalette, $
            /INTERP, $
            RENDER_METHOD=0)
        oM = OBJ_NEW('IDLgrModel')
        oM->Add, oImages[i]
        oAnimation->Add, oM
        ISOCONTOUR, head[*,*,i], verts, conn
        oContours[i] = OBJ_NEW('IDLgrPolyline', verts, $
            POLYLINES=conn, COLOR=[255,255,0])
        oTextLabels[i] = OBJ_NEW('IDLgrText', STRTRIM(STRING(i),2), $
            COLOR=[0,255,0])
    endfor
    
    ;; Put first frame in main view.
    currentFrame = 0
    oModel->Add, oAnimation

    ;; Compute a contour for overlay
    oImages[30]->GetProperty, DATA=data
    ISOCONTOUR, data, verts, conn
    oPolyline = OBJ_NEW('IDLgrPolyline', verts, POLYLINES=conn, $
        COLOR=[255,0,0])
    oOverlay = OBJ_NEW('IDLgrModel')
    oOverlay->Add, oPolyline

    ;; Set up widget values
    oWindow->SetTimerInterval, 0.1
    WIDGET_CONTROL, wAnimateRate, SET_VALUE=10
    WIDGET_CONTROL, wAnimateAdvance, SET_VALUE=1
    oObserver->SetProperty, INC=1
    oObserver->SetProperty, WFRAMEINDICATOR=wAnimateCurrentFrame

    WIDGET_CONTROL, wBase, TIMER=1

    sState = {wBase: wBase, $
        wDraw: wDraw, $
        wAnimateStop: wAnimateStop, $
        wAnimatePlay: wAnimatePlay, $
        wAnimateStepF: wAnimateStepF, $
        wAnimateStepB: wAnimateStepB, $
        wAnimateRate: wAnimateRate, $
        wAnimateAdvance: wAnimateAdvance, $
        wAnimateCurrentFrame: wAnimateCurrentFrame, $
        wAnimateFPS: wAnimateFPS, $
        oWindow: oWindow, $
        oView: oView, $
        oModel: oModel, $
        oImages: oImages, $
        oPalette: oPalette, $
        oContours: oContours, $
        oTextLabels: oTextLabels, $
        oAnimation: oAnimation, $
        oOverlay: oOverlay, $
        oObserver: oObserver, $
        nFrames : nFrames, $
        currentFrame: currentFrame, $
        bDragging : 0b, $
        bZooming: 0b, $
        bFlicking: 0, $
        x: 0, $
        y: 0, $
        windowDims: windowDims, $
        nTimer: 0, $
        timerVal: 0.01, $
        dummy: 0}
    pState = PTR_NEW(sState, /NO_COPY)
    WIDGET_CONTROL, wBase, SET_UVALUE=pState

    XMANAGER, $
        'animation1', $
        wBase, /NO_BLOCK
end
