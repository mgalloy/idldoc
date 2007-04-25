;  Copyright (c) 2005, Research Systems, Inc. All rights reserved.
;       Unauthorized reproduction prohibited.
;
;+
;  FILE:
;       tilingjp2_doc.pro
;
;  CALLING SEQUENCE: tilingjp2_doc
;
;  PURPOSE:
;       Demonstrates interactive large image tiling of a jp2 file created
;       from jpeg image.
;
;
;  MAJOR TOPICS: Visualization
;
;  CATEGORY:
;       IDL Demo System
;
;  EXTERNAL FUNCTIONS, PROCEDURES, and FILES:
;       ohare.jpg
;
;  NAMED STRUCTURES:
;       none.
;
;  COMMON BLOCS:
;       none.
;
;  MODIFICATION HISTORY:
;       3/05,   SH - Written
;-
;-----------------------------------------------------------------
;
;

;-----------------------------------------------------------------
;
;  Purpose: Query which tiles are visible and load the tile data at
;  the requested level.
;
PRO tilingjp2_doc_load_tile_data, pState, oDest
COMPILE_OPT hidden

; Query which tiles are visible and what level is required.
; This returns a structure containing information about each
; tile visible in the view.
ReqTiles = oDest->QueryRequiredTiles((*pState).oView, $
                                     (*pState).oImage, COUNT=nTiles)

IF nTiles GT 0 THEN BEGIN
    WIDGET_CONTROL, /HOURGLASS
ENDIF

; Loop through the array of structures for the required tiles,
; loading data for each one.
FOR i = 0, nTiles - 1 DO BEGIN
    SubRect = [ReqTiles[i].x, ReqTiles[i].y, $
               ReqTiles[i].width, ReqTiles[i].height]

    ; Convert to JPEG2000 canvas coords.
    level = ReqTiles[i].level
    Scale = ISHFT(1, level)
    SubRect = SubRect * Scale

    ; Retrieve the data at the requested level from the JPEG2000 file.
    ; Reduce memory usage by setting PERSISTENT=0 (no persistence).
    ; Normally a tile will only be read once, so this is the correct thing to do.
    oJP2File = OBJ_NEW('IDLffJPEG2000', 'ohareJP2.jp2', PERSISTENT=0)
    TileData = oJP2File->GetData(REGION=SubRect, $
                                           DISCARD_LEVELS=level, ORDER=1)
    ; With persistence turned off,you must close the object
    ; when not reading from it.
    OBJ_DESTROY, oJP2File

    ; Set the data on the image object.
    (*pState).oImage->SetTileData, ReqTiles[i], TileData, NO_FREE=0
ENDFOR

END

;-----------------------------------------------------------------
;
;  Purpose: Advance the panning/zooming animation and load new
;  tile data.
;
PRO tilingjp2_doc_tiling_advance, pState
COMPILE_OPT hidden

(*pState).oView->GetProperty, VIEWPLANE_RECT=vp

IF (*pState).bPanning EQ 1 THEN BEGIN
    ; Panning. This is done by changing the position of the
    ; VIEWPLANE_RECT (vp) which is described by [x,y,width,height]
    ; where x and y are the lower-left corner. How far to move it
    ; is computed from the speed slider setting (speed), the distance
    ; of the mouse from the center of the window (xDelta,yDelta) and
    ; the 'zoom factor' (vp[2] / (*pState).windowDims[0]) which is the
    ; viewplane width divided by the window x dimension. The further
    ; the cursor is from the center of the window, the faster the
    ; view pans.
    factor = (*pState).speed * (vp[2] / (*pState).windowDims[0])
    vp[0] += (*pState).xDelta * factor
    vp[1] += (*pState).yDelta * factor
    (*pState).oView->SetProperty, VIEWPLANE_RECT=vp
ENDIF

IF (*pState).bZooming EQ 1 THEN BEGIN
    ; Zooming. This is done by changing the position and dimensions
    ; of the VIEWPLANE_RECT (vp) which is described by [x,y,width,height]
    ; where x and y are the lower-left corner. When zooming in, a smaller
    ; portion of the total image is displayed in the viewplane rectangle,
    ; which is reflected in smaller vp width and height values. The rectangle
    ; size is computed from:
    ;    factor -  the speed slider setting (speed) times the vp width
    ;              divided by the window x dimension.
    ;    delta  -  yDelta (the absolute vertical change from the center of
    ;              the image times the factor. The further the mouse cursor
    ;              is from the center, the faster the zoom.
    ;    aspect	-  the window y dimension divided by x dimension.

    factor = (*pState).speed * (vp[2] / (*pState).windowDims[0])
    delta = (*pState).yDelta * factor
    aspect = float((*pState).windowDims[1]) / (*pState).windowDims[0]
    vp[0] += delta/2
    vp[1] += delta * aspect /2
    vp[2] -= delta
    vp[3] -= delta * aspect
    (*pState).oView->SetProperty, VIEWPLANE_RECT=vp
    zoom = (*pState).windowDims[0] / vp[2]
    (*pState).zoom = zoom
ENDIF

; Call the routine that queries the required tiles
; and loads the tile data.
tilingjp2_doc_load_tile_data, pState, (*pState).oWindow

; Draw the results in the view.
(*pState).oWindow->Draw, (*pState).oView

; If necessary, update the information about the visible tiles.
IF (*pState).bTilesInfo GT 0 THEN BEGIN
    ; To keep the pan/zoom performance up we only update this
    ; every 0.25 secs.
    IF SYSTIME(1) - (*pState).infoTime GT 0.25 THEN BEGIN
        ; Query for all the visible tiles, not just those that
        ; require data.
        ReqTiles = $
          (*pState).oWindow->QueryRequiredTiles((*pState).oView, $
                                                (*pState).oImage, $
                                                COUNT=nTiles, ALL_VISIBLE=1)

        ; Update the controls that display tile and level information.
        WIDGET_CONTROL, (*pState).wTilesVis, SET_VALUE=nTiles
        IF nTiles GT 0 THEN $
           WIDGET_CONTROL, (*pState).wTileLevel, SET_VALUE=ReqTiles[0].Level
        WIDGET_CONTROL, (*pState).wZoomInfo, SET_VALUE=(*pState).zoom
        (*pState).infoTime = SYSTIME(1)
    ENDIF
END

END

;-----------------------------------------------------------------
PRO tilingjp2_doc_cleanup, wBase

    WIDGET_CONTROL, wBase, GET_UVALUE=pState
    WIDGET_CONTROL, (*pState).wBase, TIMER=0
    OBJ_DESTROY, (*pState).oImage

    PTR_FREE, pState
END

;-----------------------------------------------------------------
;
;  Purpose: Event handler
;
PRO tilingjp2_doc_event, sEvent

COMPILE_OPT idl2, hidden

WIDGET_CONTROL, sEvent.id, GET_UVALUE=uval
WIDGET_CONTROL, sEvent.top, GET_UVALUE=pState

IF (TAG_NAMES(sEvent, /STRUCTURE_NAME) EQ 'WIDGET_TIMER') $
  THEN BEGIN

    IF (*pState).bPanning EQ 1 OR $
      (*pState).bZooming EQ 1 THEN BEGIN

        ; If panning or zooming, advance the animation, load
        ; new tile data as required.
        tilingjp2_doc_tiling_advance, pState

        ; OK, now we have handled the timer event, so there is not
        ; one pending.  If other events are pending, handle one of
        ; those with the following call to WIDGET_EVENT.
        ; (BAD_ID handles the case where this application has been
        ; closed.)

        wDraw = (*pState).wDraw
        wBase = (*pState).wBase
        WIDGET_CONTROL, sEvent.top, SET_UVALUE=pState

        void = WIDGET_EVENT( $
               [sEvent.top, wBase], $
               BAD_ID=bad_id, $
               /NOWAIT $
                           )

        IF bad_id NE 0 THEN $
          RETURN

        ; Launch a new immediate timer event to keep the pan/zoom
        ; animation as smooth as possible.
        WIDGET_CONTROL, (*pState).wDraw, TIMER=0
    ENDIF

    RETURN
ENDIF

CASE uval OF

'PAN_SPEED' : BEGIN
    ; Adjust pan/zoom speed.
    (*pState).speed = sEvent.value
END

'SEND_TO_PRINTER' : BEGIN
    ; Print current view with high rendering and print quality settings.
    oPrinter = OBJ_NEW('IDLgrPrinter', PRINT_QUALITY = 2, $
                       QUALITY = 2)

    IF (dialog_printersetup(oPrinter)) THEN BEGIN
        IF (dialog_printjob(oPrinter)) THEN BEGIN
            ; Set the dimensions of the view so the aspect ratio is
            ; correct when printed.
            windowAspect = FLOAT((*pState).windowDims[0]) / $
                           (*pState).windowDims[1]
            oPrinter->GetProperty, DIMENSIONS = pageSize
            pageSize[1] = pageSize[0] / windowAspect
            (*pState).oView->SetProperty, DIMENSIONS=pageSize

            ; Load the required tiles.
            tilingjp2_doc_load_tile_data, pState, oPrinter

            ;...PRINT!...
            oPrinter->Draw, (*pState).oView, VECTOR=0
            oPrinter->NewDocument

            ; Restore view dims to match window dims.
            (*pState).oView->SetProperty, DIMENSIONS=[0,0]
        ENDIF
    ENDIF

    OBJ_DESTROY,oPrinter
END

'SEND_TO_CLIPBOARD': BEGIN
    ; Copy the current view to the clipboard.
    (*pState).oWindow->GetProperty, RESOLUTION = screenResolution
    oClipboard = OBJ_NEW('IDLgrClipboard', QUALITY = 2, $
                         DIMENSIONS = (*pState).windowDims, $
                         RESOLUTION = screenResolution)

    ; Load the required tiles.
    tilingjp2_doc_load_tile_data, pState, oClipboard

    oClipboard->Draw, (*pState).oView
    OBJ_DESTROY, oClipboard
END

'EXIT': BEGIN
    WIDGET_CONTROL, sEvent.top, SET_UVALUE=sState, /NO_COPY
    WIDGET_CONTROL, sEvent.top, /DESTROY
    RETURN
END


'DISPLAY_HELP' : BEGIN

    result = DIALOG_MESSAGE(['To pan, left-click in the window.', + $
       'The direction and speed of the pan depends on the direction and distance ', + $
       'from the center of the window to the point where you click.', + $
       ' ', 'To zoom, right-click above the window center ' + $
       'to zoom in', 'or right-click below the window center to zoom out.', + $
       ' ', 'Change the slider value to pan or zoom faster or slower.',  + $
       ' ', 'Click Enable Tile Info to return tile level information.', ' ', + $
       'Use File -> Copy and Print items to copy or print visible tiles.'], $
       /INFORMATION, TITLE='Tiling Application Help')
END

'ENABLE_INFO' : BEGIN
    ; Set flag in state block.
    (*pState).bTilesInfo = sEvent.select
END

'DRAW': BEGIN
    ; Handle all events in the draw area.

    ; Convert the event coords to normalized coords with 0,0 at
    ; center of screen.
    delta = [FLOAT(sEvent.x)/(*pState).windowDims[0], $
             FLOAT(sEvent.y)/(*pState).windowDims[1]] - 0.5

    (*pState).xDelta = delta[0]
    (*pState).yDelta = delta[1]

    CASE sEvent.type OF

    ; Button Press
    0: BEGIN
        IF (sEvent.press AND 1) NE 0 THEN BEGIN
            ; Left button, enable panning and fire event.
            (*pState).bPanning = 1
            WIDGET_CONTROL, (*pState).wDraw, TIMER=0
        ENDIF
        IF (sEvent.press and 4) NE 0 THEN BEGIN
            ; Right button, enable zooming and fire event.
            (*pState).bZooming = 1
            WIDGET_CONTROL, (*pState).wDraw, TIMER=0
        ENDIF
    END

    ; Button Release
    1: BEGIN
        IF (sEvent.release and 1) NE 0 THEN $
            ; Disable panning
              (*pState).bPanning = 0
        IF (sEvent.release and 4) NE 0 THEN $
            ; Disable zooming
              (*pState).bZooming = 0
    END

    ; Motion
    2: BEGIN
    END

    ; Expose
    4: BEGIN
        (*pState).oWindow->Draw, (*pState).oView
    END

    ; Handle anything else.
    ELSE: BEGIN
    END

    ENDCASE
END
ENDCASE

END

;-----------------------------------------------------------------
PRO tilingjp2_doc

; Create the JPEG2000 file, if not already generated.
filename = FILEPATH('ohare.jpg', $
                    SUBDIRECTORY=['examples', 'data'])
jp2filename = 'ohareJP2.jp2'

IF ~FILE_TEST(jp2filename) THEN BEGIN

    ; Get data stored in a regular JPEG file.
    READ_JPEG, filename, jpegImg, TRUE=1
    imageDims = SIZE(jpegImg, /DIMENSIONS)

    ; Prepare JPEG2000 object property values.
    ncomponents = 3
    nLayers = 20
    nLevels = 6
    offset = [0,0]
    jp2TileDims = [1024, 1024]
    jp2TileOffset = [0,0]
    bitdepth = [8,8,8]

    ; Create the JPEG2000 image object.
    oJP2File = OBJ_NEW('IDLffJPEG2000',jp2filename , WRITE=1)
    oJP2File->SetProperty, N_COMPONENTS=nComponents, $
      N_LAYERS=nLayers, $
      N_LEVELS=nLevels, $
      OFFSET=offset, $
      TILE_DIMENSIONS=JP2TileDims, $
      TILE_OFFSET=JP2TileOffset, $
      BIT_DEPTH=bitDepth, $
      DIMENSIONS=[imageDims[1],ImageDims[2]]

    ; Set image data, and then destroy the object. You must
    ; create and completely close the jp2 file object before
    ; you can access the data..
    oJP2FILE->SetData, jpegImg
    OBJ_DESTROY, oJP2FILE

ENDIF

; Access the new JPEG2000 object in default READ mode.
oJP2File = OBJ_NEW('IDLffJPEG2000', 'ohareJP2.jp2')

; Set the size of the drawing window.
windowDims = [640,512]

; Retrieve object properties.
oJP2File->GetProperty, DIMENSIONS=imageDims, $
  TILE_DIMENSIONS=JP2TileDims

; Finished with the jp2 file for now.
OBJ_DESTROY, oJP2File

; Create widget interface.
wBase = WIDGET_BASE(TITLE='Tiling', $
  KILL_NOTIFY='tilingjp2_doc_cleanup', ROW=2, MBAR=mbar)

wDraw = WIDGET_DRAW( $
            wBase, $
            XSIZE=windowDims[0], $
            YSIZE=windowDims[1], $
            GRAPHICS_LEVEL=2, $
            RENDERER=0, $
            /BUTTON_EVENTS, $
            /EXPOSE_EVENTS, $
            /MOTION_EVENTS, $
            UVALUE='DRAW' $
            )

; Add Menus.
file_menu = WIDGET_BUTTON(mbar, VALUE='File', /MENU)
wPrint = WIDGET_BUTTON(file_menu, VALUE="Print...", $
                       UVALUE="SEND_TO_PRINTER")
wClip = WIDGET_BUTTON(file_menu, VALUE="Copy to Clipboard", $
                      UVALUE="SEND_TO_CLIPBOARD")
wExit = WIDGET_BUTTON(file_menu, VALUE="Exit", $
                      UVALUE="EXIT")
help_menu = WIDGET_BUTTON(mbar, VALUE='Help', /MENU)
wHelp = WIDGET_BUTTON(help_menu, VALUE="Help", $
                       UVALUE="DISPLAY_HELP")
; Add Controls.
wBottom = WIDGET_BASE(wBase, /ROW)
wSpeedBase = WIDGET_BASE(wBottom, /COL, /FRAME)
wLabel = WIDGET_LABEL(wSpeedBase, VALUE="Pan & Zoom Speed:")
wPanSpeed = WIDGET_SLIDER(wSpeedBase, MINIMUM=1, MAXIMUM=100, $
                          VALUE=5, UVALUE="PAN_SPEED")

wInfoBase = WIDGET_BASE(wBottom, /ROW, /FRAME)
wInfoButtonBase = WIDGET_BASE(wInfoBase, /NONEXCLUSIVE)
wEnableInfo = WIDGET_BUTTON(wInfoButtonBase, VALUE="Enable Tile Info",$
                            UVALUE="ENABLE_INFO")
wInfoLabels = WIDGET_BASE(wInfoBase, /ROW)
wTileLevel = CW_FIELD(wInfoLabels, VALUE='0', UVALUE="TILE_LEVEL", $
                      /LONG, TITLE='Level:', /COLUMN)
wTilesVis = CW_FIELD(wInfoLabels, VALUE='0', UVALUE="TILES_VIS", $
                      /LONG, TITLE='Visible Tiles:', /COLUMN)
wZoomInfo = CW_FIELD(wInfoLabels, VALUE='1.0', UVALUE="ZOOM_INFO", $
                     /FLOAT, TITLE='Zoom:', /COLUMN)

WIDGET_CONTROL, wEnableInfo, /SET_BUTTON
WIDGET_CONTROL, wBase, /REALIZE
WIDGET_CONTROL, wDraw, GET_VALUE=oWindow

;
; Create display objects.
;

; Create the view with the upper left corner initially visible.
; Zoom is 1:1
oView = OBJ_NEW('IDLgrView', COLOR=[0,0,0], $
                VIEWPLANE_RECT=[0,imageDims[1]-windowDims[1],$
                                windowDims[0],windowDims[1]])
oWindow->SetProperty, GRAPHICS_TREE=oView
oModel = OBJ_NEW('IDLgrModel')

; Create an image object that supports tiling. Note that a tiled
; image is not initially assigned any image data.
; TILE_LEVEL_MODE is set to 1 for automatic selection of level based
; on 'zoom'.
oImage = OBJ_NEW('IDLgrImage', TILING=1, $
                 TILED_IMAGE_DIMENSIONS=imageDims, $
                 TILE_DIMENSIONS=JP2TileDims, $
                 ORDER=1, INTERPOLATE=1, TILE_LEVEL_MODE=1)

oModel->Add, oImage
oView->Add, oModel

; Initialize variable used in updating widget control values.
infoTime = SYSTIME(1)

sState = {wBase: wBase, $
          wDraw: wDraw, $
          oWindow: oWindow, $
          oView: oView, $
          oModel: oModel, $
          oImage: oImage, $
          bPanning : 0b, $
          bZooming: 0b, $
          xDelta: 0.0, $
          yDelta: 0.0, $
          windowDims: windowDims, $
          imageDims: imageDims, $
          ntiles: '', $
          level: '', $
          zoom: '1.0', $
          bTilesInfo: 1, $
          speed: 5, $
          wTileLevel: wTileLevel, $
          wTilesVis: wTilesVis, $
          wZoomInfo: wZoomInfo, $
          infoTime: infoTime $
         }

pState = PTR_NEW(sState, /NO_COPY)

; Load the initially visible tile(s).
tilingjp2_doc_load_tile_data, pState, oWindow

WIDGET_CONTROL, wBase, SET_UVALUE=pState

XMANAGER, 'tilingjp2_doc', wBase, /NO_BLOCK

END
