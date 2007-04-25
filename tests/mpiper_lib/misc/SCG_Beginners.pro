
;*********************************************
;
;              SCG_Beginners
;
;  IDL Source Code Generator for Beginners
;
;*********************************************


;**********************************
; Instructions to run this program
;**********************************
;
; 1. Open SCG_Beginners.pro file into the IDL Development Environment.
; 2. Select:   Run > Compile SCG_Beginners
; 3. Select:   Run > Run SCG_Beginners
;
; Follow the same steps to run other IDL programs, including the ones you will generate with this utility.
;
;
; There are icons, shortcuts, and alternative ways in IDL to perform steps 2 and 3. Your choice...
;________________________________________________________________________________________________________






;+
; NAME:
;   SCG_Beginners
;
; PURPOSE:
;   Tool that generates source code for sample programs in IDL
;
; CALLING SEQUENCE:
;   SCG_Beginners
;
; INPUTS:
;
; KEYWORD PARAMETERS:
;
; MODIFICATION HISTORY:
;   Written by:  Eduardo Iturrate, RSI, Nov 2005
;   Modified:
;
;-




PRO applications, event

WIDGET_CONTROL, event.top, GET_UVALUE=state, /NO_COPY
WIDGET_CONTROL, event.id, GET_UVALUE = eventval

WIDGET_CONTROL, event.id, GET_UVALUE = eventval
CASE eventval OF

	'dicom_example':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','doc', 'dicom'])
		state.ohelpstrings = PTR_NEW(["IDLffDICOM", "DICOM", "QUERY_DICOM"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END


	'simple':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','doc', 'guibuilder'])
		state.ohelpstrings = PTR_NEW([""])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END


	'viewer':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','doc', 'guibuilder'])
		state.ohelpstrings = PTR_NEW([""])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END


	'adaptiveequalizing':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','doc', 'image'])
		state.ohelpstrings = PTR_NEW([""])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END


	'addingimages':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','doc', 'image'])
		state.ohelpstrings = PTR_NEW([""])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END


	'findinglineswithhough':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','doc', 'image'])
		state.ohelpstrings = PTR_NEW([""])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END


	'morphThinAnimation':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','doc', 'image'])
		state.ohelpstrings = PTR_NEW([""])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END


	'activexcal':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','doc', 'bridges', 'COM'])
		state.ohelpstrings = PTR_NEW(["ActiveX Controls"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END

	'activexexcel':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','doc', 'bridges', 'COM'])
		state.ohelpstrings = PTR_NEW(["ActiveX Controls"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END

	'world_demo':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['external','objbridge', 'java', 'examples'])
		state.ohelpstrings = PTR_NEW(["Java"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END


	'hellojava':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['external','objbridge', 'java', 'examples'])
		state.ohelpstrings = PTR_NEW(["Java"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution. Note that the results will appear on the IDL Command Line."
	END

	'colo_weather':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['external','objbridge', 'java', 'examples'])
		state.ohelpstrings = PTR_NEW(["Java"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution. Note that the results will appear on the IDL Command Line."
	END


	'wbuttons':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','widgets', 'wexmast'])
		state.ohelpstrings = PTR_NEW(["WIDGET_BUTTON", "WIDGET_BASE", "WIDGET_CONTROL"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END

	'wmtest':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','widgets', 'wexmast'])
		state.ohelpstrings = PTR_NEW(["CW_BGROUP", "WIDGET_BASE", "WIDGET_CONTROL"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END

	'wtoggle':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','widgets', 'wexmast'])
		state.ohelpstrings = PTR_NEW(["WIDGET_BUTTON", "WIDGET_BASE", "WIDGET_CONTROL"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END

	'wslider':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','widgets', 'wexmast'])
		state.ohelpstrings = PTR_NEW(["WIDGET_SLIDER", "WIDGET_BASE", "WIDGET_CONTROL"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END

	'wpdmenu':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','widgets', 'wexmast'])
		state.ohelpstrings = PTR_NEW(["CW_PdMenu", "WIDGET_BASE", "WIDGET_CONTROL"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END

	'wdr_scrl':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','widgets', 'wexmast'])
		state.ohelpstrings = PTR_NEW(["WIDGET_DRAW", "WIDGET_BASE", "WIDGET_CONTROL"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END

	'wdraw':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','widgets', 'wexmast'])
		state.ohelpstrings = PTR_NEW(["WIDGET_DRAW", "WIDGET_BASE", "WIDGET_CONTROL"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END

	'wdroplist':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','widgets', 'wexmast'])
		state.ohelpstrings = PTR_NEW(["WIDGET_DROPLIST", "WIDGET_BASE", "WIDGET_CONTROL"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END

	'wlabel':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','widgets', 'wexmast'])
		state.ohelpstrings = PTR_NEW(["WIDGET_LABEL", "WIDGET_BASE", "WIDGET_CONTROL"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END

	'wlabtext':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','widgets', 'wexmast'])
		state.ohelpstrings = PTR_NEW(["WIDGET_TEXT", "WIDGET_LABEL", "WIDGET_BASE", "WIDGET_CONTROL"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END

	'wlist':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','widgets', 'wexmast'])
		state.ohelpstrings = PTR_NEW(["WIDGET_LIST", "WIDGET_BASE", "WIDGET_CONTROL"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END

	'wpopup':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','widgets', 'wexmast'])
		state.ohelpstrings = PTR_NEW(["WIDGET_CONTROL", "WIDGET_BASE"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END

	'wback':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','widgets', 'wexmast'])
		state.ohelpstrings = PTR_NEW(["WIDGET_BASE", "WIDGET_CONTROL"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END

	'wmotion':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','widgets', 'wexmast'])
		state.ohelpstrings = PTR_NEW(["WIDGET_BASE", "WIDGET_CONTROL"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END


	'wsens':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','widgets', 'wexmast'])
		state.ohelpstrings = PTR_NEW(["WIDGET_BASE", "WIDGET_CONTROL"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END

	'tree_widget_example':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','doc', 'widgets'])
		state.ohelpstrings = PTR_NEW(["WIDGET_BASE", "WIDGET_CONTROL"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END


	'table_widget_example1':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','doc', 'widgets'])
		state.ohelpstrings = PTR_NEW(["WIDGET_BASE", "WIDGET_CONTROL"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END

	'table_widget_example2':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','doc', 'widgets'])
		state.ohelpstrings = PTR_NEW(["WIDGET_TABLE", "WIDGET_BASE", "WIDGET_CONTROL"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END


	'tab_widget_example1':BEGIN
		file = FILEPATH(eventval+'.pro', SUBDIRECTORY=['examples','doc', 'widgets'])
		state.ohelpstrings = PTR_NEW(["WIDGET_BASE", "WIDGET_CONTROL"])
		WIDGET_CONTROL, state.tips_window, SET_VALUE="This is an example included in the IDL distribution."
	END



	; SOMETHING ELSE?
	ELSE:BEGIN
		PRINT, "What was this? Widget User Value = " + eventval
	END

ENDCASE


ok = QUERY_ASCII(file, info)
code = READ_BINARY(file, DATA_DIMS=info.bytes)
code = STRING(code)
code = STRSPLIT(code, STRING(13B)+STRING(10B), /EXTRACT)

CD, CURRENT=current
CD, FILE_DIRNAME(file)
RESOLVE_ROUTINE, eventval, /COMPILE_FULL_FILE
CD, current

state.datatype = 'app'
state.appname = eventval

WIDGET_CONTROL, state.wlist3, SET_DROPLIST_SELECT=0
WIDGET_CONTROL, state.wlist2, SET_DROPLIST_SELECT=0
WIDGET_CONTROL, state.wlist1, SET_DROPLIST_SELECT=14
WIDGET_CONTROL, state.wlist2, SENSITIVE=0
WIDGET_CONTROL, state.wlist3, SENSITIVE=0

WIDGET_CONTROL, state.code_window, SET_VALUE=code
state.src1 = PTR_NEW(code)
WIDGET_CONTROL, state.list_ohelp, SET_VALUE=*state.ohelpstrings

WIDGET_CONTROL, event.top, SET_UVALUE=state, /NO_COPY


END



;-------------------------------------------------------------------------
PRO run_auto_event, event

WIDGET_CONTROL, event.top, GET_UVALUE=loop_state, /NO_COPY


WIDGET_CONTROL, event.id, GET_UVALUE = eventval

CASE eventval OF

	'timer':BEGIN
		IF ~loop_state.paused THEN BEGIN
			reset_windows, {top:loop_state.tlb}
			WIDGET_CONTROL, loop_state.wlist1, SET_DROPLIST_SELECT=loop_state.actions[0,loop_state.index]
			WIDGET_CONTROL, loop_state.wlist2, SET_DROPLIST_SELECT=loop_state.actions[1,loop_state.index]
			WIDGET_CONTROL, loop_state.wlist3, SET_DROPLIST_SELECT=loop_state.actions[2,loop_state.index]
			SCG_Beginners_event, {top:loop_state.tlb, id:loop_state.wlist1, index:loop_state.actions[0,loop_state.index]}
			SCG_Beginners_event, {top:loop_state.tlb, id:loop_state.wlist2, index:loop_state.actions[1	,loop_state.index]}
			SCG_Beginners_event, {top:loop_state.tlb, id:loop_state.wlist3, index:loop_state.actions[2,loop_state.index]}
			test_program, {top:loop_state.tlb}
			sz = SIZE(loop_state.actions)
			loop_state.index = loop_state.index+1
			IF loop_state.index GE sz[2] THEN loop_state.index=0
		ENDIF
	END

	'pause': BEGIN
		loop_state.paused = ~loop_state.paused
		IF loop_state.paused THEN BEGIN
			WIDGET_CONTROL, loop_state.tlb, SENSITIVE=1
			WIDGET_CONTROL, loop_state.labelstatus, SET_VALUE=' -- PAUSED'
			WIDGET_CONTROL, loop_state.buttonp, /BITMAP, $
				SET_VALUE=FILEPATH('shift_right.bmp', SUBDIRECTORY=['resource', 'bitmaps'])
		ENDIF ELSE BEGIN
			WIDGET_CONTROL, loop_state.tlb, SENSITIVE=0
			WIDGET_CONTROL, loop_state.labelstatus, SET_VALUE=' -- PLAYING'
			WIDGET_CONTROL, loop_state.buttonp, /BITMAP, $
				SET_VALUE=FILEPATH('pause.bmp', SUBDIRECTORY=['resource', 'bitmaps'])
		ENDELSE
	END

	'stop': BEGIN
		WIDGET_CONTROL, loop_state.tlb, SENSITIVE=1
		WIDGET_CONTROL, loop_state.runall_menuentry, SENSITIVE=1
		WIDGET_CONTROL, event.top, /DESTROY
		RETURN
	END

ENDCASE

IF ~loop_state.paused THEN WIDGET_CONTROL, loop_state.label, TIMER=3.5

WIDGET_CONTROL, event.top, SET_UVALUE=loop_state, /NO_COPY

END


;-------------------------------------------------------------------------
PRO run_auto, event

actions =  [  $
	;1D Data
			[0,0,1], $
			[0,0,4], $
			[0,0,3], $
	;2D Data
			[3,0,1], $
			[3,0,3], $
			[3,0,4], $
			[3,0,5], $
	;8bit Image
			[5,2,1], $
			[5,5,1], $
			[5,6,1], $
			[5,7,1], $
			[5,10,1], $
			[5,12,1], $
			[5,13,1], $
			[5,14,1], $
	;3D Cube
			[4,0,1], $
			[4,0,2], $
			[4,0,3], $
			[4,4,4], $
			[4,2,2], $
	;24b Image
			[6,0,1], $
			[6,1,1], $
			[6,0,3], $
			[6,0,4], $
	;ct Image
			[7,0,1], $
			[7,0,2], $
	;Shapefile
			[10,0,1], $
			[10,0,2], $
	;DXF
			[11,0,1], $
			[11,2,1], $
			[11,3,1], $
	;Text
			[12,0,2], $
			[12,2,2], $
			[12,3,2], $
			[12,4,2]]


WIDGET_CONTROL, event.top, SENSITIVE=0

WIDGET_CONTROL, event.top, GET_UVALUE=state, /NO_COPY
wlist1 = state.wlist1
wlist2 = state.wlist2
wlist3 = state.wlist3
runall_menuentry = state.file_bttn4
WIDGET_CONTROL, runall_menuentry, SENSITIVE=0			;Don't run more than one copy of the animation
WIDGET_CONTROL, event.top, SET_UVALUE=state, /NO_COPY

base = WIDGET_BASE(/COLUMN, TLB_FRAME_ATTR=13)

label = WIDGET_LABEL(base, $
		      VALUE = 'Running in Slideshow Mode', $
		      UVALUE='timer')

base2 = WIDGET_BASE(base, /ROW)

buttonp = WIDGET_BUTTON(base2, $
			  VALUE=FILEPATH('pause.bmp', SUBDIRECTORY=['resource', 'bitmaps']), $
			  UVALUE="pause", $
			  TOOLTIP="Pause Animation", $
			  ACCELERATOR="Ctrl+P", $
		      /BITMAP)

buttons = WIDGET_BUTTON(base2, $
			  VALUE=FILEPATH('stop.bmp', SUBDIRECTORY=['resource', 'bitmaps']), $
			  UVALUE="stop", $
			  TOOLTIP="Stop Animation", $
			  ACCELERATOR="Ctrl+C", $
		      /BITMAP)

labelstatus = WIDGET_LABEL(base2, $
		      VALUE = ' -- PLAYING')

loop_state = {wlist1:wlist1, $
			wlist2:wlist2, $
			wlist3:wlist3, $
			actions:actions, $
			index:0, $
			label:label, $
			labelstatus:labelstatus, $
			paused:0, $
			buttonp:buttonp, $
			runall_menuentry:runall_menuentry, $
			tlb:event.top}

WIDGET_CONTROL, base, /REALIZE
WIDGET_CONTROL, label, TIMER=2
WIDGET_CONTROL, base, SET_UVALUE=loop_state, /NO_COPY
XMANAGER, "run_auto", base, /NO_BLOCK

END



;-------------------------------------------------------------------------
PRO scg_cleanup, event

reset_windows, event
WHILE (!D.WINDOW NE -1) DO WDELETE  ; Sometimes, window 0 is still there.
IF SIZE(event, /dimensions) NE 0 THEN WIDGET_CONTROL, event.top, /DESTROY
HEAP_GC

END


;-------------------------------------------------------------------------
FUNCTION empty_p2_p3, state
; Empties parts 2 and 3 of the options

state.src2 = PTR_NEW("")
code = [[" "], $
		["END"]]
state.src3 = PTR_NEW(code)

RETURN, state

END


;-------------------------------------------------------------------------
FUNCTION empty_p3, state
; Empties part 3 of the options

code = [[" "], $
		["END"]]
state.src3 = PTR_NEW(code)

RETURN, state

END


;-------------------------------------------------------------------------
PRO reset_windows, event
; Kills all windows, 'i' and 'x' tools that are currently open.

Compile_Opt StrictArr	; Otherwise, LookupManagedWidget will be taken as an array...


WHILE (!D.WINDOW NE -1) DO WDELETE
WHILE (ITGETCURRENT(TOOL=oTool) NE '') DO ITDELETE
WHILE (LookupManagedWidget('xobjview') NE 0) DO WIDGET_CONTROL, LookupManagedWidget('xobjview'), /DESTROY
WHILE (LookupManagedWidget('XDISPLAYFILE') NE 0) DO WIDGET_CONTROL, LookupManagedWidget('XDISPLAYFILE'), /DESTROY
WHILE (LookupManagedWidget('xVolume') NE 0) DO WIDGET_CONTROL, LookupManagedWidget('xVolume'), /DESTROY
WHILE (LookupManagedWidget('XInterAnimate') NE 0) DO XINTERANIMATE, /CLOSE
WHILE (LookupManagedWidget('xroi') NE 0) DO WIDGET_CONTROL, LookupManagedWidget('xroi'), /DESTROY

END



;-------------------------------------------------------------------------
PRO save_program, event
; Save source code.

WIDGET_CONTROL, event.top, GET_UVALUE=state, /NO_COPY


IF state.datatype EQ 'app' THEN BEGIN
	application_name=state.appname+'.pro'
	code = REFORM(*state.src1)
ENDIF  ELSE BEGIN
	application_name='example.pro'
	code = [REFORM(*state.src1), REFORM(*state.src2), REFORM(*state.src3)]
ENDELSE


oDir = DIALOG_PICKFILE(TITLE="Select output directory", /DIRECTORY, /WRITE)

IF oDir NE "" THEN BEGIN
	filename = FILEPATH(application_name, root_dir=odir)
	ok = FILE_INFO(filename)
	overwrite = 0
	IF ok.exists THEN BEGIN
		answer = DIALOG_MESSAGE("File exists. Overwrite?", /QUESTION)
		IF answer EQ 'Yes' THEN overwrite=1
	ENDIF ELSE overwrite = 1
	IF overwrite THEN BEGIN
		OPENW, lun, filename, /GET_LUN
		FOR i=0, N_ELEMENTS(code)-1 DO PRINTF, lun, code[i]
		FREE_LUN, lun
		ok = DIALOG_MESSAGE("File Saved: "+filename, /INFORMATION)
	ENDIF
ENDIF


WIDGET_CONTROL, event.top, SET_UVALUE=state, /NO_COPY

END


;-------------------------------------------------------------------------
PRO test_program, event
; Runs program!

WIDGET_CONTROL, event.top, GET_UVALUE=state, /NO_COPY
WIDGET_CONTROL, /HOURGLASS

IF state.datatype EQ 'app' THEN BEGIN				; Running one of the example programs.

	ok=EXECUTE(state.appname)

ENDIF ELSE BEGIN									; Running generated code


	IF !D.WINDOW NE -1 THEN ERASE

	wsz = GET_SCREEN_SIZE()

	code = [REFORM(*state.src1), REFORM(*state.src2), REFORM(*state.src3)]

	itoolwords = ['iplot', 'icont', 'isurf', 'imap,', 'ivolu', 'iimag']
	xtoolwords = ['xobjv']			;Only xobjview seems to be 'willing' to relocate on the screen

	; Run line 1 to total-2, so the PRO and END lines are not processed
	FOR runloop=1, N_ELEMENTS(code)-2 DO BEGIN
		; If calling iTools, add a few keywords
		IF WHERE(itoolwords EQ STRLOWCASE(STRMID(code[runloop], 0, 5))) NE -1 THEN $
				code[runloop]=code[runloop]+', /NO_SAVEPROMPT, DIMENSIONS=[600,600], /DISABLE_SPLASH_SCREEN, LOCATION=[wsz[0]/2-100, 0]'
		IF WHERE(xtoolwords EQ STRLOWCASE(STRMID(code[runloop], 0, 5))) NE -1 THEN $
				code[runloop]=code[runloop]+', XOFFSET=250, YOFFSET=30'
		ok=EXECUTE(code[runloop])
	ENDFOR

	IF N_ELEMENTS(*state.src3) EQ 2 THEN ok=DIALOG_MESSAGE(["No results?", "Select an option for Step 3 - Visualization"])

ENDELSE

DEVICE, DECOMPOSED=0  ; Sometimes running example code changes this.
LOADCT, 0, /SILENT

WIDGET_CONTROL, event.top, SET_UVALUE=state, /NO_COPY

END


;-------------------------------------------------------------------------
PRO SCG_Beginners_event, event
; Event handler


WIDGET_CONTROL, event.top, GET_UVALUE=state, /NO_COPY

WIDGET_CONTROL, state.wlist1, GET_VALUE=options_s1
WIDGET_CONTROL, state.wlist2, GET_VALUE=options_s2
WIDGET_CONTROL, state.wlist3, GET_VALUE=options_s3

WIDGET_CONTROL, event.id, GET_UVALUE = eventval
CASE eventval OF


	'about':BEGIN
		ok = DIALOG_MESSAGE(["Source Code Generator for Beginners", "v.1.1 - November 20, 2005", "Research Systems, Inc.", "http://www.rsinc.com/idl"], /Information)
	END

	'guiprogramming': BEGIN
		wexmaster, GROUP=event.top
	END

	'idltour': BEGIN
		idl_tour
	END


	;======================
	; FILE READING OPTIONS
	;======================
	'list_files':BEGIN

		WIDGET_CONTROL, state.wlist2, SENSITIVE=1
		WIDGET_CONTROL, state.wlist3, SENSITIVE=1

		CASE options_s1[event.index] OF

			'1-D Vector, Binary File':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="We are reading a 512-element vector into IDL. We know this is a binary file of 512 elements."
			code = ["PRO example", $
					" ", $
					"file = '"+FILEPATH('chirp.dat', SUBDIRECTORY=['examples','data'])+"'", $
					"dimensions = 512									;Specify the size of the data", $
					"data = READ_BINARY(file, DATA_DIMS=dimensions)		;Read the file"]
			state.src1 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["READ_BINARY", "BINARY_TEMPLATE", "READ_ASCII"])

			IF state.datatype NE '1d' THEN BEGIN
				state.datatype = '1d'
				WIDGET_CONTROL, state.wlist2, SET_VALUE=state.lists.list_s2_1d
				WIDGET_CONTROL, state.wlist3, SET_VALUE=state.lists.list_s3_1d
				state = empty_p2_p3(state)
			ENDIF

			END


			'2-D Array, Binary File':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="We are reading a 512-element vector into IDL. We know this is a binary file of 248 by 248 elements."
			code = ["PRO example", $
					" ", $
					"file = '"+FILEPATH('convec.dat', SUBDIRECTORY=['examples','data'])+"'", $
					"dimensions = [248,248]									;Specify the size of the data", $
					"data = READ_BINARY(file, DATA_DIMS=dimensions)		;Read the file"]
			state.src1 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["READ_BINARY", "BINARY_TEMPLATE", "READ_ASCII"])

			IF state.datatype NE '2d' THEN BEGIN
				state.datatype = '2d'
				WIDGET_CONTROL, state.wlist2, SET_VALUE=state.lists.list_s2_2d
				WIDGET_CONTROL, state.wlist3, SET_VALUE=state.lists.list_s3_2d
				state = empty_p2_p3(state)
			ENDIF

			END


			'3-D Cube, Binary File':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="We are reading a 512-element vector into IDL. We know this is a binary file of 80 by 100 by 57 elements."
			code = ["PRO example", $
					" ", $
					"file = '"+FILEPATH('head.dat', SUBDIRECTORY=['examples','data'])+"'", $
					"dimensions = [80,100,57]									;Specify the size of the data", $
					"data = READ_BINARY(file, DATA_DIMS=dimensions)		;Read the file"]
			state.src1 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["READ_BINARY", "BINARY_TEMPLATE", "READ_ASCII"])

			IF state.datatype NE '3d' THEN BEGIN
				state.datatype = '3d'
				WIDGET_CONTROL, state.wlist2, SET_VALUE=state.lists.list_s2_3d
				WIDGET_CONTROL, state.wlist3, SET_VALUE=state.lists.list_s3_3d
				state = empty_p2_p3(state)
			ENDIF

			END


			'1-D Vector, Define':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="How to define your own data using IDL routines. Try to avoid FOR loops as much as you can, it's always much faster to find routines and operations that take your variables as a whole."
			code = ["PRO example", $
					" ", $
					"n = 1000						;Number of points", $
					"data = FINDGEN(n)				;Vector of floating point numbers from 0 to n-1", $
					"data = SIN(data/(n-1)*8*!pi)	;Rescale values from 0 to 8*PI and calculate their sine", $
					"data2 = FINDGEN(n)				;Create another ramp vector", $
					"data = data*data2				;Multiply both vectors, element by element", $
					"data = (data+1000)/4.0			;Add 1000 to each element of data and divide it by 4"]
			state.src1 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["FINDGEN", "BINDGEN", "FLTARR", "BYTARR", "SIN", "addition operator"])

			IF state.datatype NE '1d' THEN BEGIN
				state.datatype = '1d'
				WIDGET_CONTROL, state.wlist2, SET_VALUE=state.lists.list_s2_1d
				WIDGET_CONTROL, state.wlist3, SET_VALUE=state.lists.list_s3_1d
				state = empty_p2_p3(state)
			ENDIF

			END


			'2-D Array, Define':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="Remember not to use loops to access your arrays. In this example, by using IDL operations we define a 2-D array."
			code = ["PRO example", $
					" ", $
					"n = 300							;Number of points", $
					"data = FINDGEN(n)				;Vector of floating point numbers from 0 to n-1", $
					"data = SIN(data/(n-1)*4*!pi)	;Rescale values from 0 to 4*PI and calculate their sine", $
					"data2 = data					;Create a copy of data", $
					"data = data#data2				;Using the matrix multiplication operator with these two vectors we end up with a 2-D array", $
					"data = data*100+100				;Multiply each element by 100 and add 100"]
			state.src1 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["# operator", "FINDGEN", "BYTARR", "SIN", "addition operator"])

			IF state.datatype NE '2d' THEN BEGIN
				state.datatype = '2d'
				WIDGET_CONTROL, state.wlist2, SET_VALUE=state.lists.list_s2_2d
				WIDGET_CONTROL, state.wlist3, SET_VALUE=state.lists.list_s3_2d
				state = empty_p2_p3(state)
			ENDIF

			END


			'Irregular Grid, ASCII File':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="This is a set of X, Y, Z numbers, irregulary distributed. Tipically, you'll want to interpolate the values in between in order to created a grid that you can visualize in more ways."
			code = ["PRO example", $
					" ", $
					"file = '"+FILEPATH('irreg_grid1.txt', SUBDIRECTORY=['examples','data'])+"'", $
					"structure = READ_ASCII(file)", $
					"data = structure.field1"]
			state.src1 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["READ_ASCII", "READF"])

			IF state.datatype NE 'irr' THEN BEGIN
				state.datatype = 'irr'
				WIDGET_CONTROL, state.wlist2, SET_VALUE=state.lists.list_s2_irr
				WIDGET_CONTROL, state.wlist3, SET_VALUE=state.lists.list_s3_irr
				state = empty_p2_p3(state)
			ENDIF

			END


			'Text, ASCII File':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="There are several ways of reading ASCII files in IDL. In this case, we read it as a binary stretch of number and we convert them into type String."
			code = ["PRO example", $
					" ", $
					"file = '"+FILEPATH('funcsum_topics.txt', SUBDIRECTORY=['examples','demo','demotext'])+"'", $
					"ok = QUERY_ASCII(file, info)", $
					"data = READ_BINARY(file, DATA_DIMS=info.bytes) 		;Read the file as binary bytes first.", $
					"data = STRING(data)									;Convert to String type."]
			state.src1 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["QUERY_ASCII", "READ_BINARY", "READ_ASCII"])

			IF state.datatype NE 'str' THEN BEGIN
				state.datatype = 'str'
				WIDGET_CONTROL, state.wlist2, SET_VALUE=state.lists.list_s2_str
				WIDGET_CONTROL, state.wlist3, SET_VALUE=state.lists.list_s3_str
				state = empty_p2_p3(state)
			ENDIF

			END


  			'3-D Mesh, Autocad DXF':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="Another type of 3-D data is that composed of vertices (x, y, z positions) and connectivity (the polygons that connect those vertices). DXF is a popular format to hold this kind of data."
			code = ["PRO example", $
					" ", $
					"file = '"+FILEPATH('heart.dxf', SUBDIRECTORY=['examples','data'])+"'", $
					"oDxf = OBJ_NEW('IDLffDXF')", $
					"status = oDxf->Read(file)", $
					"types = oDxf->GetContents()", $
					"drawable = where((types EQ 10) or (types EQ 9) or (types EQ 11))	;Get the type of entities that are most useful for this example.", $
					"entity = oDxf->GetEntity(types[drawable[0]])		; Pick just the first entity", $
					"vertices = *entity[0].vertices						; Pick the first object", $
					"connectivity = *entity[0].connectivity"]
			state.src1 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["IDLffDXF", "OBJ_NEW"])

			IF state.datatype NE 'dxf' THEN BEGIN
				state.datatype = 'dxf'
				WIDGET_CONTROL, state.wlist2, SET_VALUE=state.lists.list_s2_dxf
				WIDGET_CONTROL, state.wlist3, SET_VALUE=state.lists.list_s3_dxf
				state = empty_p2_p3(state)
			ENDIF

			END


			'Image File, JPEG 24-bit':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="The READ_JPEG routine takes care of everything. What we need to have in mind here is that the result will be a 3-dimensional array, of size 3*Columns*Rows."
			code = ["PRO example", $
					" ", $
					"file = '"+FILEPATH('elev_t.jpg', SUBDIRECTORY=['examples','data'])+"'", $
					"READ_JPEG, file, data"]
			state.src1 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["READ_JPEG", "READ_IMAGE"])

			IF state.datatype NE '24b' THEN BEGIN
				state.datatype = '24b'
				WIDGET_CONTROL, state.wlist2, SET_VALUE=state.lists.list_s2_24b
				WIDGET_CONTROL, state.wlist3, SET_VALUE=state.lists.list_s3_24b
				state = empty_p2_p3(state)
			ENDIF

			END


			'Image File, JPEG 8-bit':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="Standard file formats like a JPEG image are easier to read, since the header information contains all the information IDL needs to read the file. The READ_JPEG routine takes care of everything."
			code = ["PRO example", $
					" ", $
					"file = '"+FILEPATH('pollens.jpg', SUBDIRECTORY=['examples','demo', 'demodata'])+"'", $
					"READ_JPEG, file, data"]
			state.src1 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["READ_JPEG", "READ_IMAGE"])

			IF state.datatype NE '2d' THEN BEGIN
				state.datatype = '2d'
				WIDGET_CONTROL, state.wlist2, SET_VALUE=state.lists.list_s2_2d
				WIDGET_CONTROL, state.wlist3, SET_VALUE=state.lists.list_s3_2d
				state = empty_p2_p3(state)
			ENDIF

			END


			'Image File, PNG Indexed':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="Another type of color image is one with one plane and an associated color table."+ $
				" Standard file formats like a JPEG image are easier to read, since the header information contains all the information IDL needs to read the file."
			code = ["PRO example", $
					" ", $
					"file = '"+FILEPATH('afrpolitsm.png', SUBDIRECTORY=['examples','data'])+"'", $
					"data = READ_PNG(file, r, g, b)					;The color table is stored in the r, g, b vectors"]
			state.src1 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["READ_PNG", "READ_IMAGE"])

			IF state.datatype NE 'ct' THEN BEGIN
				state.datatype = 'ct'
				WIDGET_CONTROL, state.wlist2, SET_VALUE=state.lists.list_s2_ct
				WIDGET_CONTROL, state.wlist3, SET_VALUE=state.lists.list_s3_ct
				state = empty_p2_p3(state)
			ENDIF

			END


			'Audio File, WAV':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="Audio data is also 1-D. All the information about how to read this file is contained in the header, and the READ_WAV function takes care of it."
			code = ["PRO example", $
					" ", $
					"file = '"+FILEPATH('hello.wav', SUBDIRECTORY=['lib','wavelet','data'])+"'", $
					"data = READ_WAV(file)"]
			state.src1 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["READ_WAV"])

			IF state.datatype NE '1d' THEN BEGIN
				state.datatype = '1d'
				WIDGET_CONTROL, state.wlist2, SET_VALUE=state.lists.list_s2_1d
				WIDGET_CONTROL, state.wlist3, SET_VALUE=state.lists.list_s3_1d
				state = empty_p2_p3(state)
			ENDIF

			END


			'Map, Arcgis Shapefile':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="A Shapefile contains both map (vector) and database information associated with the map elements."
			code = ["PRO example", $
					" ", $
					"file = '"+FILEPATH('lakes.shp', SUBDIRECTORY=['resource','maps', 'shape'])+"'", $
					"myshape=OBJ_NEW('IDLffShape', file)", $
					"myshape->IDLffShape::GetProperty, N_ENTITIES=num_ent, ENTITY_TYPE=ent_type", $
					"myshape->IDLffShape::GetProperty, ATTRIBUTE_INFO=attr_info", $
					"attr = myShape->getAttributes(/ALL)", $
					"ent = myshape->IDLffShape::GetEntity(/ALL)"]
			state.src1 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["IDLffShape"])

			IF state.datatype NE 'shape' THEN BEGIN
				state.datatype = 'shape'
				WIDGET_CONTROL, state.wlist2, SET_VALUE=state.lists.list_s2_shape
				WIDGET_CONTROL, state.wlist3, SET_VALUE=state.lists.list_s3_shape
				state = empty_p2_p3(state)
			ENDIF

			END



			'Text, XML Network':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="Let's load the current RSS feed from Yahoo! World News. The headline texts will compose our data." +$
				" In order for this example to work, the computer needs to be connected to the Internet."
			code = ["PRO example", $
					" ", $
					"oDoc = OBJ_NEW('IDLffXMLDOMDocument', FILENAME='http://rss.news.yahoo.com/rss/world') 		;Let's take a look at the latest news from Yahoo!", $
					"oTopLevel = oDoc->GetDocumentElement()", $
					"oTitleList = oTopLevel->GetElementsByTagName('title')			;All the headlines are between <title></title> tags.", $
					"n_stories = oTitleList->GetLength()							;How many stories?", $
					"data = STRARR(n_stories)								;Array that will hold the data.", $
					"FOR i=0, n_stories-1 DO data[i] = ((oTitleList->Item(i))->GetFirstChild())->GetNodeValue()			;We need to navigate through the XML hierarchy in order to extract the strings we are looking for.", $
					"data = STRJOIN(data+STRING(13B)+STRING(10B))			;Not really necessary - done here for consistency with other examples, joining all the lines in a single string with carriage returns."]
			state.src1 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["IDLffXMLDOM Classes", "XML"])

			IF state.datatype NE 'str' THEN BEGIN
				state.datatype = 'str'
				WIDGET_CONTROL, state.wlist2, SET_VALUE=state.lists.list_s2_str
				WIDGET_CONTROL, state.wlist3, SET_VALUE=state.lists.list_s3_str
				state = empty_p2_p3(state)
			ENDIF

			END

			' ': BEGIN
				state.datatype = 'app'
			END


			ELSE:BEGIN
		   	PRINT, 'NOT IMPLEMENTED YET
			END

		ENDCASE

		IF state.datatype EQ 'app' THEN BEGIN
			WIDGET_CONTROL, state.wlist2, SENSITIVE=0
			WIDGET_CONTROL, state.wlist3, SENSITIVE=0
		ENDIF


	END



	;==================
	; ANALYSIS OPTIONS
	;==================
	'list_processing':BEGIN


		CASE options_s2[event.index] OF

			'Do Nothing':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="The original data remains unchanged."
			code = ""
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW("")
			CASE state.datatype OF
				'irr':BEGIN
					WIDGET_CONTROL, state.wlist3, SET_VALUE=state.lists.list_s3_irr
					state = empty_p3(state)
				END
				'ct':BEGIN
					WIDGET_CONTROL, state.wlist3, SET_VALUE=state.lists.list_s3_ct
					state = empty_p3(state)
				END
				ELSE:
			ENDCASE
			END


			'Rotate 90°':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="Basic 90 degrees rotation of the array."
			code = ["  ", $
					"data = ROTATE(data, 1)							;Rotate data 90 degrees."]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["ROTATE", "ROT", "TRANSPOSE"])
			END


			'Resize':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="Resize the data to new dimensions."
			code = ["  ", $
					"data = CONGRID(data, 500, 400)					;Resize data to 500 columns and 400 rows."]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["CONGRID", "REBIN"])
			END


			'Invert':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="Basic 90 degrees rotation of the array."
			code = ["  ", $
					"data = MAX(data)-data"]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["addition operator"])
			END


			'Reverse':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="The REVERSE function reverses the order of one dimension of an array."
			code = ["  ", $
					"data = REVERSE(data)"]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["REVERSE", "SHIFT"])
			END


			'Change Color Table':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="A color table can be used to map the data values to a range of different colors. NOTE: it does not apply to iTools."
			code = ["  ", $
					"DEVICE, DECOMPOSED=0				;Work with color tables.", $
					"LOADCT, 13							;Load predefined color table."]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["LOADCT", "XLOADCT", "TVLCT"])
			END


			'Threshold':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="The key for a good threshold is to find the right value to separate the data in two. Here, we use the mean of the variable as a first approach."+$
				" Note how the logical expression GE (Greate or Equal) computes the condition at each element of the data, creating a bi-level image."
			code = ["  ", $
					"thresh_value = MEAN(data)					;Calculate the mean of data.", $
					"data = data GE thresh_value				;Create a new variable data with values 1 or 0 depending if the condition (value >= threshold) is true or not."]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["relational operators"])
			END


			'Threshold and Segment':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="After a threshold, we can separate and label all the different regions in the data."+$
				" By changing to a color table of multiple colors we can differenciate the regions easily."
			code = ["  ", $
					"thresh_value = MEAN(data)					;Calculate the mean of data.", $
					"data = data GE thresh_value				;Create a new variable data with values 1 or 0 depending if the condition (value >= threshold) is true or not.", $
					"data = LABEL_REGION(data)					;Separate blobs into different data values.", $
					"LOADCT, 5									;Load 'colorful' color table."]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["LABEL_REGION", "relational operators", "LOADCT"])
			END


			'Transpose':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="Re-orders the dimensions of the array."
			code = ["  ", $
					"data = TRANSPOSE(data, [0, 2, 1])"]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["TRANSPOSE"])
			END


			'Smooth Filter':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="IDL's SMOOTH function performs a low-pass filter."
			code = ["  ", $
					"data = SMOOTH(data, 7, /EDGE_TRUNCATE)				;Apply filter to image."]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["SMOOTH"])
			END


			'Smooth Filter RGB':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="IDL's SMOOTH performs a low-pass filter. We need to do it three times, one for each image plane."
			code = ["  ", $
					"data[0,*,*] = SMOOTH(data[0,*,*], 7, /EDGE_TRUNCATE)				;Apply filter to red component of image.", $
					"data[1,*,*] = SMOOTH(data[1,*,*], 7, /EDGE_TRUNCATE)				;Idem with green plane.", $
					"data[2,*,*] = SMOOTH(data[2,*,*], 7, /EDGE_TRUNCATE)				;Idem with blue plane."]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["SMOOTH"])
			END


			'Edge Detection Filter':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="We are going to enhance the borders of the image."
			code = ["  ", $
					"data = ROBERTS(data)"]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["Detecting Edges", "SOBEL", "ROBERTS"])
			END


			'Edge Detection Filter RGB':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="We are going to enhance the borders of the image. We need to do it three times, one for each image plane."
			code = ["  ", $
					"data[0,*,*] = ROBERTS(REFORM(data[0,*,*]))				;Apply filter to red component of image.", $
					"data[1,*,*] = ROBERTS(REFORM(data[1,*,*]))				;Idem with green plane.", $
					"data[2,*,*] = ROBERTS(REFORM(data[2,*,*]))				;Idem with blue plane."]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["Detecting Edges", "SOBEL", "ROBERTS"])
			END


			'Convolution':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="We can define our own kernel and convolve it with the original data."
			CASE state.datatype OF
				'1d': templine = "kernel = [-1,0,1]				;Define our filter's kernel."
				'2d': templine = "kernel = [[0,1,0], [-1,0,1], [0,-1,0]]				;Define our filter's kernel."
				'3d': templine = "kernel = INTARR(3,3,3)-1				;Define our filter's kernel (a little 3x3x3 cube of 1's)"
			ENDCASE
			code = ["  ", $
					templine, $
					"data = CONVOL(data, kernel, BIAS=50)				;Convolve kernel with data, in order to filter."]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["CONVOL"])
			END


			'Unsharp-mask Filter':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="The unsharp mask algorithm works by enhancing the contrast between neighboring pixels in an image, and is widely used for astronomical images and for digital photographs."
			code = ["  ", $
					"data = UNSHARP_MASK(data, RADIUS=8)"]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["UNSHARP_MASK"])
			END


			'Watershed':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="The morphological watershed operator segments the data into watershed regions. A collection of morphological filters are available in IDL, and they can be combined to produce the desired effect."
			code = ["  ", $
					"data = WATERSHED(data)", $
					"LOADCT, 38"]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["WATERSHED", "ERODE", "DILATE", "MORPH_OPEN", "MORPH_CLOSE"])
			END


			'Morphological Erosion':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="Mathematical morphology is a method of processing digital images on the basis of shape. The ERODE operator is commonly known as 'shrink'."
			code = ["  ", $
					"radius = 2				; Create the structuring element, a disk with a radius of 2.", $
					"strucElem = SHIFT(DIST(2*radius+1), radius, radius) LE radius", $
					"", $
					"data = ERODE(data, strucElem, /GRAY)		; Use the erosion operator on the image"]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["ERODE", "DILATE", "MORPH_OPEN", "MORPH_CLOSE"])
			END


			'Fourier Transform':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="The Fourier Transform expresses a function in terms of sinusoidal basis functions. It has many scientific applications, particularly in signal processing."
			CASE state.datatype OF
				'1d': templine = "data = SHIFT(data, sz[1]/2+1)						;We need to shift the result so the origin is in the center."
				'2d': templine = "data = SHIFT(data, sz[1]/2+1, sz[2]/2+1)						;We need to shift the result so the origin is in the center."
				'3d': templine = ["data = SHIFT(data, sz[1]/2+1, sz[2]/2+1, sz[3]/2+1)						;We need to shift the result so the origin is in the center.", $
								  "data =  HIST_EQUAL(data)		;For better visualization, spread values."]
			ENDCASE
			code = ["  ", $
					"data = ALOG10(ABS(FFT(data))^2)						;Calculate the Fourier Transform and then it's power.", $
					"sz = SIZE(data)", $
					templine]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["FFT", "mathematics", "SHIFT", "ALOG10", "HILBERT"])
			END


			'Convert to RGB Image':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="You won't get a more colorful image, but you'll be able to display and do the calculations typical of RGB images."
			code = ["  ", $
					"sz = SIZE(data)", $
					"rr = r[data]						;Array holding the red component of the image for each pixel.", $
					"gg = g[data]								;Idem for the green component.", $
					"bb = b[data]								;Idem for blue.", $
					"data = BYTARR(3,sz[1],sz[2])				;There are better ways to put the three together, but here we need to create a 3,n,m image for consistency.", $
					"data[0,*,*]=rr   &   data[1,*,*]=gg   &   data[2,*,*]=bb		;Fill up the three planes into the new array."]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["TrueColor", "COLOR_QUAN"])
			WIDGET_CONTROL, state.wlist3, SET_VALUE=state.lists.list_s3_24b
			state = empty_p3(state)
			END


			'Warp Geometry, Randomly':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="Let's warp the image by stretching it in several points."
			code = ["  ", $
					"sz = SIZE(data)", $
					"x0=[0, 0, sz[1]-1, sz[1]-1, sz[1]/2]			;Initial points (x coordinate)", $
					"y0=[0, sz[2]-1, 0, sz[2]-1, sz[2]/2]  			;Initial points (y coordinate)", $
					"x1=FIX(x0 + 50*RANDOMN(seed, 5))  				;Final points (x coordinate)", $
					"y1=FIX(y0 + 50*RANDOMN(seed, 5))				;Final points (y coordinate)", $
					"data = WARP_TRI(x1, y1, x0, y0, data)"]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["TRIANGULATE", "TRIGRID", "SPH_SCAT", "QHULL"])
			END


			'Interpolate':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="By using Delaunay triangulation IDL can interpolate a regular grid."
			code = ["  ", $
					"TRIANGULATE, data[0,*], data[1,*], tr, b					;Calculate the triangules.", $
					"range_x = (MAX(data[0,*])-MIN(data[0,*]))/10", $
					"range_y = (MAX(data[1,*])-MIN(data[1,*]))/10", $
					"data = TRIGRID(data[0,*], data[1,*], data[2,*], tr, NX=300, NY=300, /QUINTIC)			;Calculate interpolation."]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["TRIANGULATE", "TRIGRID", "SPH_SCAT", "QHULL"])
			WIDGET_CONTROL, state.wlist3, SET_VALUE=state.lists.list_s3_2d
			state = empty_p3(state)
			END


			'Interpolation Wizard':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="If we pass irregular grid data to iImage, it will detect it and launch IDL's gridding wizard."
			code = ["  ", $
					"IIMAGE, data"]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["gridding wizard", "interpolation methods", "kriging"])
			WIDGET_CONTROL, state.wlist3, SET_VALUE=state.lists.list_s3_irr
			state = empty_p3(state)
			END


 			'Define Regions of Interest':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="This interactive tool will allow you to define your own ROIs and extract statistics from them. Here you can also explore rigth-mouse-click > Grow Region."
			code = ["  ", $
					"sz = SIZE(data, /DIMENSIONS)", $
					"mask = BYTARR(sz[0], sz[1])+1		; Initial value for the mask", $
					"XROI, data, TITLE='Draw Region of Interest', REGIONS_OUT=ROIout, /BLOCK", $
					"IF OBJ_VALID(ROIout[0]) THEN mask=ROIout[0]->ComputeMask(DIMENSIONS=sz)  ; Create a mask with the selected pixels", $
					"data = data*(mask GT 0)			;Delete the pixels outside the ROI"]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["XROI"])
			END

			'Wavelet Transform':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="By using Delaunay triangulation IDL can interpolate a regular grid."
			code = ["  ", $
					"wvt = WV_CWT(data, 'Morlet', 6, /PAD, SCALE=scales)	;Continuous wavelet transform", $
					"data = ABS(wvt^2)										;Calculate the wavelet power spectrum"]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["WV_CWT", "WV_DWT", "WV_FN_PAUL", "WV_DENOISE"])
			WIDGET_CONTROL, state.wlist3, SET_VALUE=state.lists.list_s3_wvt
			state = empty_p3(state)
			END


			'Mesh Decimation':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="Decimation reduces the number of vertices necessary to display a 3-D object."
			code = ["  ", $
					"ok = MESH_DECIMATE(vertices, connectivity, newconnectivity, PERCENT_VERTICES=30)", $
					"connectivity = newconnectivity"]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["MESH_DECIMATE", "MESH_OBJ"])
			END


			'Clipping':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="We can define a cutting plane for clipping the mesh. This plane is described by the coefficients (a,b,c,d) of the equation ax+by+cz+d=0."
			code = ["  ", $
					"clip = MESH_CLIP([-3., -1.9, 1., 0.5], vertices, connectivity, clippedVertices, clippedConnectivity)", $
					"vertices = clippedVertices", $
					"connectivity = clippedConnectivity"]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["MESH_CLIP", "MESH_OBJ"])
			END


			'Smooth Vertices':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="This function performs spatial smoothing on a polygon mesh by applying Laplacian smoothing to each vertex."
			code = ["  ", $
					"smoothedVertices = MESH_SMOOTH(vertices, connectivity, ITERATIONS=400)", $
					"vertices =smoothedVertices"]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["MESH_SMOOTH", "MESH_OBJ"])
			END


			'Convert to Uppercase':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="IDL supports a number of  string operations to search, extract, split, join or compare texts."
			code = ["  ", $
					"data = STRUPCASE(data)"]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["STRUPCASE", "STRLOWCASE", "Strings"])
			END


  			'Remove All Blanks':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="IDL supports a number of  string operations to search, extract, split, join or compare strings."
			code = ["  ", $
					"data = STRCOMPRESS(data, /REMOVE_ALL)"]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["STRCOMPRESS", "Strings"])
			END


  			'Randomize Order':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="IDL supports a number of  string operations to search, extract, split, join or compare strings."
			code = ["  ", $
					"data =  STRSPLIT(data, ' ', /EXTRACT, COUNT=n)", $
					"new = FIX(RANDOMU(seed, n)*n)", $
					"data = data[new]", $
					"data =  STRJOIN(data, ' ')"]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["STRCOMPRESS", "Strings"])
			END


  			'Remove All Vowels':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="IDL supports a number of  string operations to search, extract, split, join or compare strings."
			code = ["  ", $
					"data = STRJOIN(STRSPLIT(data, 'AEIOUaeiou', /EXTRACT), '')"]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["STRJOIN", "STRSPLIT", "Strings"])
			END


  			'Order Words Alphabetically':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="IDL supports a number of  string operations to search, extract, split, join or compare strings."
			code = ["  ", $
					"data =  STRSPLIT(data, ' '+STRING(13B)+STRING(10B), /EXTRACT)", $
					"data2 = STRLOWCASE(data)", $
					"data = data[SORT(data2)]", $
					"data =  STRJOIN(data, STRING(10B)+STRING(13B))"]
			state.src2 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["STRSPLIT", "SORT", "STRJOIN", "Strings"])
			END


			ELSE:BEGIN
			PRINT, 'NOT IMPLEMENTED YET
			END


		ENDCASE
	END


	;=======================
	; VISUALIZATION OPTIONS
	;=======================
	'list_visualization':BEGIN

		CASE options_s3[event.index] OF


			'Do Not Visualize':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="Nothing will be displayed."
			code = [" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW("")
			END


			'Print Actual Values':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="View the actual numbers that compose your data."
			code = ["  ", $
					"XDISPLAYFILE, TEXT=STRING(data, /PRINT)", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["XDISPLAYFILE", "STRING"])
			END


			'Basic Statistics':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="Using a few simple functions, it's very easy to extract basic statistical information from your data with IDL."
			code = ["  ", $
					"max = MAX(data)					;Calculate statistics.", $
					"min = MIN(data)", $
					"med = MEDIAN(data)", $
					"var = VARIANCE(data)", $
					"mean = MEAN(data)", $
					"stdev = STDEV(data)", $
					"st = ['Maximum: '+STRING(max, /PRINT), 'Minimum: '+STRING(min, /PRINT), 'Mean: '+STRING(mean, /PRINT), 'Variance: '+STRING(var, /PRINT), 'Standard Dev.: '+STRING(stdev, /PRINT)]", $
					"ok = DIALOG_MESSAGE(st, /Information, TITLE='Basic Statistics')", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["MAX", "MEAN", "MEDIAN", "VARIANCE", "STDEV", "IMAGE_STATISTICS"])
			END


			'Display Text':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="A basic system dialog window can be easily used to display text data."
			code = ["  ", $
					"ok = DIALOG_MESSAGE(data, /Information, TITLE='Text Output')", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["DIALOG_MESSAGE"])
			END


			'Display Text, Interactive':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="Text can also be rendered on graphic windows, allowing for interactive manipulations."
			code = ["  ", $
					"data = STRSPLIT(data, STRING(10B)+STRING(13B), /EXTRACT, COUNT=n)			;Divide text into an array of strings", $
					"oModel  = obj_new('IDLgrModel')				;Create container", $
					"locations = FLTARR(2, N_ELEMENTS(data))			;Vertical locations for each line", $
					"locations[0,*] = FINDGEN(N_ELEMENTS(data))", $
					"oModel->add, OBJ_NEW('IDLgrText', data, /ONGLASS, /KERNING, LOCATIONS=locations, ALIGNMENT=0.5, COLOR=[0,0,0])", $
					"XOBJVIEW, oModel, BACKGROUND=[255,255,255], XSIZE=500, YSIZE=500, SCALE=0.95, TITLE='Click and drag on this window'", $
					"FOR i=60,0,-1 DO  XOBJVIEW_ROTATE, [0,0,-1], i*0.05				;Perform initial animation.", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["DIALOG_MESSAGE"])
			END


			'XY Plot':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="We use PLOT to display a vector (one dimensional array) in an X-Y graphic. You can also use PLOT with 2 or 3 dimensional data, IDL will treat it a a long vector."
			code = ["  ", $
					"PLOT, data, TITLE='Example Data', XTITLE='Sample', YTITLE='Data Value'", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["PLOT"])
			END


			'XY Plot, Interactive':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="IPLOT is the interactive version of PLOT where you can use the mouse to change the properties of your graph on the fly."
			code = ["  ", $
					"IPLOT, data, VIEW_TITLE='Example Data', XTITLE='Sample', YTITLE='Data Value'", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["IPLOT"])
			END


			'XY Plot, 3-D':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="A vector can also be represented in 3-D, just by extending its values into the Z dimension."
			code = ["  ", $
					"oModel  = obj_new('IDLgrModel')				;Create container", $
					"data_s =data#(BYTARR(2)+1)					;Make copies of the plot into a 2D surface", $
					"xsc = NORM_COORD([0, N_ELEMENTS(data)])		; Calculate the right scale factors for each dimension.", $					"
					"ysc = NORM_COORD([0, 15])", $
					"zsc = NORM_COORD([MIN(data_s), MAX(data_s)])/2.0", $

					"oModel->add, OBJ_NEW('IDLgrSurface', data_s, STYLE=2, COLOR=[255,0,0], BOTTOM=[0,0,255], DIFFUSE=[255,255,0], SHADING=1, XCOORD_CONV=xsc, YCOORD_CONV=ysc, ZCOORD_CONV=zsc)", $
					"oModel->add, OBJ_NEW('IDLgrAxis', 0, RANGE=[0,N_ELEMENTS(data)], COLOR=[255,255,255], TICKLAYOUT=2, XCOORD_CONV=xsc, YCOORD_CONV=ysc, ZCOORD_CONV=zsc)", $
					"oModel->add, OBJ_NEW('IDLgrAxis', 2, RANGE=[MIN(data), MAX(data)], COLOR=[255,255,255], XCOORD_CONV=xsc, YCOORD_CONV=ysc, ZCOORD_CONV=zsc)", $
					"XOBJVIEW, oModel, BACKGROUND=[60,60,60], XSIZE=600, YSIZE=600, SCALE=0.9, TITLE='Click and drag on this window'", $
					"FOR i=0, 100 DO  XOBJVIEW_ROTATE, [-1,0,0], 0.9							;Perform initial animation.", $
					"FOR i=0, 50 DO  XOBJVIEW_ROTATE, [0,-1,0],  0.6", $
					"FOR i=0, 50 DO  XOBJVIEW_ROTATE, [1,0,0], 0.6", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["IDLgrModel", "IDLgrSurface", "XOBJVIEW", "XOBJVIEW_ROTATE", "OBJ_NEW"])
			END


			'Surface':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="SHADE_SURF creates a shaded-surface representation of the two-dimensional array."
			code = ["  ", $
					"SHADE_SURF, data", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["SHADE_SURF", "SHOW3", "SURFACE"])
			END


			'Surface, Interactive':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="ISURFACE displays a 2-dimensional array that you can rotate and manipulate in real time."
			code = ["  ", $
					"ISURFACE, data", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["ISURFACE"])
			END


			'Contour Lines':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="Contour lines can be computed and displayed with just one command."
			code = ["  ", $
					"LOADCT, 38							;Load predefined color table.", $
					"CONTOUR, data, /FOLLOW, NLEVELS=10, C_COLORS=[10, 30, 50, 70, 90], /ISOTROPIC", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["CONTOUR"])
			END


			'Contour Lines, Interactive':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="Interactive version of the contour display."
			code = ["  ", $
					"n = 15				;Number of levels", $
					"colors = REFORM(FIX(RANDOMU(seed, 3*n)*250), 3, n)		;Pick random colors  ", $
					"ICONTOUR, data, PLANAR=0, N_LEVELS=n, C_COLOR=colors", $
					"tool = ITGETCurrent(TOOL=oTool)", $
					"void = oTool->DoAction('Operations/Insert/Legend')		;Add legend", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["ICONTOUR"])
			END


			'Contour Lines + Image':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="We can display contour lines overlaid on top of the image represenation of the data. In this case, we manually open a square window."
			code = ["  ", $
					"IMAGE_CONT, data, /WINDOW_SCALE", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["IMAGE_CONT"])
			END


 			'Image':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="TVSCL scales an array values to fit the whole 0-255 data range, and then displays it as an image."
			code = ["  ", $
					"TVSCL, data									;Stretch data values to 0-255 and display as image.", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["TV", "TVSCL", "SLIDE_IMAGE"])
			END


 			'Image 24-bit':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="TV is the simplest way to display image data in IDL. By using the keyword TRUE, we specify a 3-plane RGB image."
			code = ["  ", $
					"DEVICE, DECOMPOSED=1", $
					"TV, data, TRUE=1								;Display image, which has dimensions of (3, m, n)", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["TV", "TVSCL", "SLIDE_IMAGE"])
			END


 			'Image with Color Table':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="TV is the simplest way to display image data in IDL. In this case we need to load the proper color table first."
			code = ["  ", $
					"DEVICE, DECOMPOSED=0							;Work with color tables", $
					"TVLCT, r, g, b									;Load color table from PNG image", $
					"TV, data										;Display image", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["TV", "TVSCL", "SLIDE_IMAGE"])
			END


 			'Histogram':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="A histogram will show the data value distribution."
			code = ["  ", $
					"PLOT, HISTOGRAM(data), PSYM=10, TITLE='Histogram', XTITLE='Data Value', YTITLE='Number of Occurrences'					;Calculate and plot the histogram of data.", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["HISTOGRAM", "PLOT"])
			END


 			'Power Spectrum':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="What's special about this option is that the contour lines are best represented with a logarithmic Y axis."
			code = ["  ", $
					"DEVICE, DECOMPOSED=0", $
					"LOADCT, 39", $
					"CONTOUR, data, /YLOG, YRANGE=[100,1], NLEVELS=50, /FILL, TITLE='Wavelet Power Spectrum'", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["CONTOUR", "LOADCT"])
			END


 			'Histogram RGB':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="Three plots show the histograms for the red, green and blue planes in the RGB image."
			code = ["  ", $
					"LOADCT, 12								; Load a predefined color table", $
					"PLOT, HISTOGRAM(data), PSYM=10, /NODATA, TITLE='Histogram', XTITLE='Data Value', YTITLE='Number of Occurrences'", $
					"OPLOT, HISTOGRAM(data[0,*,*]), PSYM=10, COLOR=200					;OPLOT does not erase previous plots and uses the same axis as the first one.", $
					"OPLOT, HISTOGRAM(data[1,*,*]), PSYM=10, COLOR=20", $
					"OPLOT, HISTOGRAM(data[2,*,*]), PSYM=10, COLOR=100", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["HISTOGRAM", "PLOT", "OPLOT"])
			END


			'Points in 3D':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="This option shows the locations of each point in 3-D (x and y representing location, z their value)."
			code = ["  ", $
					"IPLOT, data, /SCATTER, SYM_INDEX=2, SYM_SIZE=0.5, SYM_THICK=2", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["IPLOT"])
			END


			'Image, Interactive':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="IIMAGE is actually a small image processing application where you can filter, stretch and manipulate your image as you wish."
			code = ["  ", $
					"IIMAGE, data", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["IIMAGE"])
			END


			'Image, Separated Planes':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="We can display the red, green, and blue components in different windows."
			code = ["  ", $
					"DEVICE, DECOMPOSED=0", $
					"sz = SIZE(data)", $
					"WINDOW, 0, XSIZE=sz[2], YSIZE=sz[3]		;Assumes dimensions of 3,n,m color image, but could also be n,3,m or n,m,3.", $
					"LOADCT, 3									;Color table with levels of red", $
					"TV, data[0,*,*]", $
					"WINDOW, 1, XSIZE=sz[2], YSIZE=sz[3]", $
					"LOADCT, 8									;Color table with levels of green", $
					"TV, data[1,*,*]", $
					"WINDOW, 3, XSIZE=sz[2], YSIZE=sz[3]", $
					"LOADCT, 1									;Color table with levels of blue", $
					"TV, data[2,*,*]", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["LOADCT", "TV"])
			END


			'3-D Mesh':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="XVOLUME contains a ton of interactive parameters that you can change once started. " +$
					"Unselect the Auto-Render, Select View > Drag Quality > High and try adding some Image Planes and an IsoSurface."
			code = ["  ", $
					"data = CONGRID(data, 70,70,70)					;Resize data.", $
					"ISOSURFACE, data, 36, verts, conn				;Calculate vertices and polygons for isosurface of voxels with value of 36.", $
					"smtverts = MESH_SMOOTH(verts, conn)			;Remove some of the artifacts.", $
					"data = OBJ_NEW('IDLgrPolygon', smtverts, POLYGONS=conn, COLOR=[220,200,100], SHADING=0, SPECULAR=[220,200,100])", $
					"XOBJVIEW, data, BACKGROUND=[0,0,0], XSIZE=600, YSIZE=600, SCALE=0.95, TITLE='Click and drag on this window'", $
					"FOR i=20,0,-1 DO  XOBJVIEW_ROTATE, [-1,0,0], i*0.4							;Perform initial animation.", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["ISOSURFACE", "XOBJVIEW", "SHADE_VOLUME", "INTERVAL_VOLUME", "TETRA_SURFACE"])
			END


			'Xvolume, Interactive':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="XVOLUME contains a ton of interactive parameters that you can change once started. " +$
					"Unselect the Auto-Render, Select View > Drag Quality > High and try adding some Image Planes and an IsoSurface."
			code = ["  ", $
					"data = CONGRID(data, 80, 80, 80)					;Resize the cube.", $
					"XVOLUME, data, RENDERER=1", $
					"FOR i=0, 3 DO  XVOLUME_ROTATE, [0,0.5,0], i*70			;Perform initial animation.", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["XVOLUME", "ISOSURFACE", "SHADE_VOLUME", "IDLgrVolume"])
			END


			'iVolume, Interactive':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="IVOLUME is part of IDL's iTools framework, and it specializes in working with volume data."
			code = ["  ", $
					"LOADCT, 15", $
					"TVLCT, r, g, b, /GET", $
					"IVOLUME, data, RGB_TABLE0=[[r], [g], [b]], /AUTO_RENDER", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["IVOLUME"])
			END


 			'Compute Mesh Statistics':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="This is how we can compute some basic statistics from the mesh."
			code = ["  ", $
					"triangles = MESH_NUMTRIANGLES(connectivity)", $
					"st = ['Number of Vertices: '+STRING(N_ELEMENTS(vertices), /PRINT), 'Number of Triangles: '+STRING(triangles, /PRINT)]", $
					"ok = DIALOG_MESSAGE(st, /Information, TITLE='Mesh Statistics')", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["XOBJVIEW", "IDLgrPolygon", "IDLgrModel"])
			END


 			'3D Object Viewer':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="IDL's Object Graphics architecture is the most efficient way of visualizing meshes like this."
			code = ["  ", $
					"oModel = OBJ_NEW('IDLgrModel')				;Create container", $
					"oPolygon = OBJ_NEW('IDLgrPolygon', vertices, POLYGONS=connectivity, /SHADING, COLOR=[225,0,0])", $
					"oModel->Add, oPolygon", $
					"XOBJVIEW, oModel, SCALE=0.85, XSIZE=600, YSIZE=600, TITLE='Click and drag on this window'", $
					"FOR i=20,0,-1 DO  XOBJVIEW_ROTATE, [-1,0,0], i*0.4						;Perform initial animation.", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["XOBJVIEW", "IDLgrPolygon", "IDLgrModel"])
			END


			'Animation':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="The XINTERANIMATE procedure is a utility for displaying an animated sequence of images. " +$
				" The speed and direction of the display can be adjusted using the widget interface."
			code = ["  ", $
					"sz = SIZE(data)												;Compute the size of data.", $
					"data = CONGRID(data, sz[1]*3, sz[2]*3, sz[3]*3, CUBIC=-0.5)	;Interpolate to a larger array, so we can see a bigger animation.", $
					"sz = SIZE(data)												;Calculate size again.", $
					"DEVICE, DECOMPOSED=0					;We are going to work with color tables.", $
					"LOADCT, 3					;Let's use a color table with levels of red.", $
					"XINTERANIMATE, SET=[sz[1], sz[2], sz[3]], /TRACK, /CYCLE			;Initialize the animation", $
					"FOR i=0,sz[3]-1 DO XINTERANIMATE, FRAME=i, IMAGE = data(*,*,i)		;Load the frames.", $
					"XINTERANIMATE, 90													;Play the animation.", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["XINTERANIMATE"])
			END


			'Display Database Info':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="This shows just the numerical and text information associated with each cartographic elements of the shapefile."
			code = ["  ", $
					"database = STRARR(num_ent+1)", $
					"database[0] = STRING(attr_info.name, /PRINT)", $
					"FOR i=1, num_ent-1 DO database[i] = STRING(attr[i], /PRINT)", $
					"XDISPLAYFILE, TEXT=STRING(database, /PRINT), WIDTH=45, TITLE='Biggest Lakes Worldwide", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["IDLffShape", "XDISPLAYFILE"])
			END


			'Overlay on Map':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="You can specify a map with the projection and options of your choice and then let IDL overlay other cartographic elements onto the map."
			code = ["  ", $
					"DEVICE, DECOMPOSED=0		;Work with color tables", $
					"LOADCT, 15					;Load color table #15", $
					"TVLCT, 255,255,255, 0		;Window background in white", $
					"WINDOW, 1 , XS=890, YS=550, TITLE='Biggest Lakes Worldwide'		;Open graphic window", $
					"MAP_SET,  /MERCATOR, /ISOTROPIC, /HORIZON, LIMIT=[-60, -170, 75, 175], /GRID, COLOR=155, E_GRID={BOX_AXES:1}, E_HORIZON={FILL:1, COLOR:255}		;Define map projection", $
					"MAP_CONTINENTS, /FILL_CONTINENTS, COLOR=211			;Draw continents", $
					"MAP_CONTINENTS, /COUNTRIES, COLOR=193				;Draw countries", $
					"FOR i=0, num_ent-1 DO POLYFILL,*(ent.vertices)[i], COLOR=85		;Draw shapefile entities", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["MAP_SET", "MAP_CONTINENTS", "MAP_GRID", "POLYFILL"])
			END


			'Image on Map, Interactive':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="IDL's mapping routines are very powerful if you have data that you want to overlay onto a cartographic map. Select your projection, limits, colors, etc. and let IDL take care of the rest."
			code = ["  ", $
					"IMAP, MAP_PROJECTION='Orthographic', LIMIT=[-90, -180, 90, 180]", $
					"IMAP, data, IMAGE_DIMENSIONS=[76.8, 74.4], IMAGE_LOCATION=[-22.7, -35.1], GRID_UNITS=2, RGB_TABLE=[[r],[g],[b]], /OVERPLOT", $
					"tool = ITGETCURRENT(TOOL=oTool)", $
					"void = oTool->DoAction(oTool->FindIdentifiers('*Continents'))", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["IMAP", "MAP_PROJ_IMAGE", "MAP_IMAGE"])
			END


			'Save to File, Binary':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="Nothing will be displayed, the result is written into a binary file in the /examples directory. The number of bytes used per value will depend on the type of the 'data' variable at this point."
			code = ["  ", $
					"file = '"+FILEPATH('temp_'+STRTRIM(STRING(FIX(RANDOMU(seed, 1)*1000)), 2)+'.dat', SUBDIRECTORY=['examples'])+"'		;Use DIALOG_PICKFILE to let the user select filename and location.", $
					"OPENW, lun, file, /GET_LUN					;Open file.", $
					"WRITEU, lun, data							;Write array into file. ", $
					"FREE_LUN, lun								;Close file.", $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["OPENW", "WRITEU", "FREE_LUN", "DIALOG_PICKFILE"])
			END


			'Save to File, JPEG Format':BEGIN
			WIDGET_CONTROL, state.tips_window, SET_VALUE="Nothing will be displayed, the result is written into a JPEG file in the /examples directory."
			CASE state.datatype OF
				'2d': templine = "WRITE_JPEG, file, BYTSCL(data)					;Stretch data before saving, so it will look like an image in all cases."
				'24b': templine = "WRITE_JPEG, file, data, TRUE=1					;Specify this is a true color image."
				'ct': templine = "WRITE_JPEG, file, data, TRUE=1					;Specify this is a true color image."		;This case can happen when we convert the PNG image to true color.
			ENDCASE
			code = ["  ", $
					"file = '"+FILEPATH('temp_'+STRTRIM(STRING(FIX(RANDOMU(seed, 1)*1000)), 2)+'.jpg', SUBDIRECTORY=['examples'])+"'		;Use DIALOG_PICKFILE to let the user select filename and location.", $
					templine, $
					" ", $
					"END"]
			state.src3 = PTR_NEW(code)
			state.ohelpstrings = PTR_NEW(["WRITE_JPEG", "WRITE_TIFF", "WRITE_JPEG2000", "WRITE_PNG", "WRITE_GIF"])
			END



			ELSE:BEGIN
			PRINT, 'NOT IMPLEMENTED YET'
			END

		ENDCASE
	END

	; LEARN ABOUT
	'list_ohelp':BEGIN
		ONLINE_HELP, (*state.ohelpstrings)[event.index]
	END


	; SOMETHING ELSE?
	ELSE:BEGIN
		PRINT, "What was this? Widget User Value = " + eventval
	END

ENDCASE

code = [REFORM(*state.src1), REFORM(*state.src2), REFORM(*state.src3)]
WIDGET_CONTROL, state.code_window, SET_VALUE=code
WIDGET_CONTROL, state.list_ohelp, SET_VALUE=*state.ohelpstrings
WIDGET_CONTROL, event.top, SET_UVALUE=state, /NO_COPY

END


;-------------------------------------------------------------------------
PRO SCG_Beginners

DEVICE, DECOMPOSED=0
LOADCT, 0

; Definition of available options for each step, depending on the type of dataset selected.

; Definition for Step - 1 options (open file)

list_s1 = ['1-D Vector, Binary File', $
		'1-D Vector, Define', $
		'2-D Array, Binary File', $
		'2-D Array, Define', $
		'3-D Cube, Binary File', $
		'Image File, JPEG 8-bit', $
		'Image File, JPEG 24-bit', $
		'Image File, PNG Indexed', $
		'Audio File, WAV', $
		'Irregular Grid, ASCII File', $
		'Map, Arcgis Shapefile', $
		'3-D Mesh, Autocad DXF', $
		'Text, ASCII File', $
		'Text, XML Network', $
		' ']

; Definition for Step - 2 options (processing)

list_s2_1d = ['Do Nothing', $
		'Reverse', $
		'Invert', $
		'Threshold', $
		'Threshold and Segment', $
		'Smooth Filter', $
		'Convolution', $
		'Fourier Transform', $
		'Wavelet Transform']

list_s2_2d = ['Do Nothing', $
		'Rotate 90°', $
		'Resize', $
		'Reverse', $
		'Invert', $
		'Change Color Table', $
		'Threshold', $
		'Threshold and Segment', $
		'Smooth Filter', $
		'Edge Detection Filter', $
		'Convolution', $
		'Unsharp-mask Filter', $
		'Morphological Erosion', $
		'Watershed', $
		'Fourier Transform', $
		'Warp Geometry, Randomly', $
		'Define Regions of Interest']

list_s2_3d = ['Do Nothing', $
		'Reverse', $
		'Invert', $
		'Transpose', $
		'Smooth Filter', $
		'Convolution', $
		'Fourier Transform']

list_s2_24b = ['Do Nothing', $
		'Invert', $
		'Smooth Filter RGB', $
		'Edge Detection Filter RGB', $
		'Unsharp-mask Filter']

list_s2_ct = ['Do Nothing', $
		'Convert to RGB Image']

list_s2_irr = ['Do Nothing', $
		'Interpolate', $
		'Interpolation Wizard']

list_s2_str = ['Do Nothing', $
		'Remove All Blanks', $
		'Remove All Vowels', $
		'Convert to Uppercase', $
		'Randomize Order', $
		'Order Words Alphabetically']

list_s2_dxf = ['Do Nothing', $
		'Mesh Decimation', $
		'Clipping', $
		'Smooth Vertices']

list_s2_shape = ['Do Nothing']

; Definition for Step - 3 options (visualization)

list_s3_1d = ['Do Not Visualize', $
		'XY Plot', $
		'XY Plot, Interactive', $
		'XY Plot, 3-D', $
		'Histogram', $
		'Basic Statistics', $
		'Print Actual Values', $
		'Save to File, Binary']

list_s3_2d = ['Do Not Visualize', $
		'Image', $
		'Image, Interactive', $
		'Surface', $
		'Surface, Interactive', $
		'Contour Lines', $
		'Contour Lines, Interactive', $
		'Contour Lines + Image', $
		'Histogram', $
		'Basic Statistics', $
		'Print Actual Values', $
		'Save to File, JPEG Format']

list_s3_3d = ['Do Not Visualize', $
		'Animation', $
		'3-D Mesh', $
		'Xvolume, Interactive', $
		'iVolume, Interactive', $
		'Histogram', $
		'Basic Statistics', $
		'Print Actual Values', $
		'Save to File, Binary']

list_s3_24b = ['Do Not Visualize', $
		'Image 24-bit', $
		'Image, Interactive', $
		'Image, Separated Planes', $
		'Histogram RGB', $
		'Save to File, JPEG Format']

list_s3_ct = ['Do Not Visualize', $
		'Image with Color Table', $
		'Image on Map, Interactive']

list_s3_irr = ['Do Not Visualize', $
		'Points in 3D', $
		'Print Actual Values']

list_s3_str = ['Do Not Visualize', $
		'Display Text', $
		'Display Text, Interactive']

list_s3_dxf = ['Do Not Visualize', $
		'3D Object Viewer', $
		'Compute Mesh Statistics']

list_s3_shape = ['Do Not Visualize', $
		'Overlay on Map', $
		'Display Database Info']

list_s3_wvt = ['Do Not Visualize', $
		'Power Spectrum']


lists = { list_s1:list_s1, $
		list_s2_1d:list_s2_1d, list_s2_2d:list_s2_2d, list_s2_3d:list_s2_3d, list_s2_24b:list_s2_24b, list_s2_irr:list_s2_irr, $
			list_s2_dxf:list_s2_dxf, list_s2_str:list_s2_str, list_s2_shape:list_s2_shape, list_s2_ct:list_s2_ct, $
		list_s3_1d:list_s3_1d, list_s3_2d:list_s3_2d, list_s3_3d:list_s3_3d, list_s3_24b:list_s3_24b, list_s3_irr:list_s3_irr, $
			list_s3_dxf:list_s3_dxf, list_s3_str:list_s3_str, list_s3_shape:list_s3_shape, list_s3_ct:list_s3_ct, list_s3_wvt:list_s3_wvt }

lengthdialog = 62
font_titles = "ARIAL*14X14*BOLD"


base = WIDGET_BASE(TITLE = "Source Code Generator for Beginners", MBAR=bar_base, /COLUMN, TLB_FRAME_ATTR=1, KILL_NOTIFY='scg_cleanup')

file_menu = WIDGET_BUTTON(bar_base, Value='File', /Menu)
file_bttn1 = WIDGET_BUTTON(file_menu, Value='Test Program', EVENT_PRO = "test_program", ACCELERATOR="F5")
file_bttn2 = WIDGET_BUTTON(file_menu, Value='Save Source Code', EVENT_PRO = "save_program", ACCELERATOR="Ctrl+S")
file_bttn3 = WIDGET_BUTTON(file_menu, Value='Reset Graphic Windows', EVENT_PRO="reset_windows", ACCELERATOR="Ctrl+W")
file_bttn4 = WIDGET_BUTTON(file_menu, Value='Slideshow Mode', EVENT_PRO='run_auto')
file_bttn5 = WIDGET_BUTTON(file_menu, Value='Quit', EVENT_PRO='scg_cleanup')

app_menu = WIDGET_BUTTON(bar_base, Value='Examples', /Menu, Event_pro="applications")

fio_menu = WIDGET_BUTTON(app_menu, Value='File I/O', /Menu)
fio_bttn = WIDGET_BUTTON(fio_menu, Value='DICOM', Uvalue='dicom_example')

imgp_menu = WIDGET_BUTTON(app_menu, Value='Image Processing', /Menu)
imgp_bttn = WIDGET_BUTTON(imgp_menu, Value='Channel Manipulations', Uvalue='addingimages')
imgp_bttn = WIDGET_BUTTON(imgp_menu, Value='Equalization', Uvalue='adaptiveequalizing')
imgp_bttn = WIDGET_BUTTON(imgp_menu, Value='Thinning', Uvalue='morphThinAnimation')
imgp_bttn = WIDGET_BUTTON(imgp_menu, Value='Hough Transform', Uvalue='findinglineswithhough')

gui_menu = WIDGET_BUTTON(app_menu, Value='GUI Programming', /Menu)
mbar_bttn = WIDGET_BUTTON(gui_menu, Value='Button', Uvalue='wbuttons')
mbar_bttn = WIDGET_BUTTON(gui_menu, Value='Button, Non-Exclusive', Uvalue='wmtest')
mbar_bttn = WIDGET_BUTTON(gui_menu, Value='Button, Exclusive', Uvalue='wtoggle')
mbar_bttn = WIDGET_BUTTON(gui_menu, Value='Slider', Uvalue='wslider')
mbar_bttn = WIDGET_BUTTON(gui_menu, Value='Graphics Window', Uvalue='wdraw')
mbar_bttn = WIDGET_BUTTON(gui_menu, Value='Label', Uvalue='wlabel')
mbar_bttn = WIDGET_BUTTON(gui_menu, Value='Text', Uvalue='wlabtext')
mbar_bttn = WIDGET_BUTTON(gui_menu, Value='Table', Uvalue='table_widget_example2')
mbar_bttn = WIDGET_BUTTON(gui_menu, Value='Menu', Uvalue='wpdmenu')
mbar_bttn = WIDGET_BUTTON(gui_menu, Value='List', Uvalue='wlist')
mbar_bttn = WIDGET_BUTTON(gui_menu, Value='Droplist', Uvalue='wdroplist')
mbar_bttn = WIDGET_BUTTON(gui_menu, Value='Tree', Uvalue='tree_widget_example')
mbar_bttn = WIDGET_BUTTON(gui_menu, Value='Tab', Uvalue='tab_widget_example1')
mbar_bttn = WIDGET_BUTTON(gui_menu, Value='Timer', Uvalue='wback', /SEPARATOR)
mbar_bttn = WIDGET_BUTTON(gui_menu, Value='Pop-up Window', Uvalue='wpopup')
mbar_bttn = WIDGET_BUTTON(gui_menu, Value='Motion Detection', Uvalue='wmotion')
mbar_bttn = WIDGET_BUTTON(gui_menu, Value='Sensitizing', Uvalue='wsens')
mbar_bttn = WIDGET_BUTTON(gui_menu, Value='Graphics Window w/ Scroll Bars', Uvalue='wdr_scrl')
mbar_bttn = WIDGET_BUTTON(gui_menu, Value='Selecting Cells on Table', Uvalue='table_widget_example1')

olang_menu = WIDGET_BUTTON(app_menu, Value='Other Languages', /Menu)
IF !VERSION.OS_FAMILY EQ 'Windows' THEN BEGIN
	ext_menu = WIDGET_BUTTON(olang_menu, Value='ActiveX Controls', /Menu)
	cal_bttn = WIDGET_BUTTON(ext_menu, Value='Calendar', Uvalue='activexcal')
	excl_bttn = WIDGET_BUTTON(ext_menu, Value='Excel', Uvalue='activexexcel')
ENDIF
ext_menu = WIDGET_BUTTON(olang_menu, Value='Java', /Menu)
hjav_bttn = WIDGET_BUTTON(ext_menu, Value='Hello Java', Uvalue='hellojava')
colow_bttn = WIDGET_BUTTON(ext_menu, Value='Colorado Weather', Uvalue='colo_weather')
world_bttn = WIDGET_BUTTON(ext_menu, Value='World Demo', Uvalue='world_demo')

other_menu = WIDGET_BUTTON(bar_base, Value='Demos', /Menu)
other_bttn2 = WIDGET_BUTTON(other_menu, Value='IDL Tour', Uvalue='idltour')

help_menu = WIDGET_BUTTON(bar_base, Value='Help', /Menu)
help_bttn1 = WIDGET_BUTTON(help_menu, Value='About', Uvalue='about')

base_up = WIDGET_BASE(base, /ROW)

base_col_1 = WIDGET_BASE(base_up, /COLUMN, /FRAME)

label = WIDGET_LABEL(base_col_1, $
			  FONT=font_titles, $
		      VALUE = 'Step 1 - Load Data')

draw_s1 = WIDGET_DRAW(base_col_1, $
				/ALIGN_CENTER, $
				SENSITIVE=0, $
				XSIZE=16, $
				YSIZE=16)

wlist1 = WIDGET_DROPLIST(base_col_1, $
		   VALUE = list_s1, $
		   UVALUE = 'list_files')

base_col_2 = WIDGET_BASE(base_up, /COLUMN, /FRAME)

label = WIDGET_LABEL(base_col_2, $
			  FONT=font_titles, $
		      VALUE = 'Step 2 - Processing')

draw_s2 = WIDGET_DRAW(base_col_2, $
				/ALIGN_CENTER, $
				SENSITIVE=0, $
				XSIZE=16, $
				YSIZE=16)

wlist2 = WIDGET_DROPLIST(base_col_2, $
		   VALUE = list_s2_1d, $
		   UVALUE = 'list_processing')

base_col_3 = WIDGET_BASE(base_up, /COLUMN, /FRAME)

label = WIDGET_LABEL(base_col_3, $
			  FONT=font_titles, $
		      VALUE = 'Step 3 - Visualization')

draw_s3 = WIDGET_DRAW(base_col_3, $
				/ALIGN_CENTER, $
				SENSITIVE=0, $
				XSIZE=16, $
				YSIZE=16)

wlist3 = WIDGET_DROPLIST(base_col_3, $
		   VALUE = list_s3_1d, $
		   XSIZE=150, $
		   UVALUE = 'list_visualization')

base_down = WIDGET_BASE(base, /COLUMN)

sub_base_down_0 = WIDGET_BASE(base_down, /ROW)

sub_base_down_00 = WIDGET_BASE(sub_base_down_0, /COLUMN)

label = WIDGET_LABEL(sub_base_down_00, $
					FONT = font_titles, $
		 		     VALUE = 'Have in Mind', $
		      		/ALIGN_LEFT)

tips_window = WIDGET_TEXT(sub_base_down_00, $
			/WRAP, $
			FONT="ARIAL*15X15", $
            XSIZE=lengthdialog-16, $
            YSIZE=5, $
            VALUE = "")

sub_base_down_01 = WIDGET_BASE(sub_base_down_0, /COLUMN)

label = WIDGET_LABEL(sub_base_down_01, $
						FONT = font_titles, $
		 	     		VALUE = 'Learn About', $
		    		  	/ALIGN_LEFT)

list_ohelp = WIDGET_LIST(sub_base_down_01, $
		   VALUE = '', $
		   UVALUE = 'list_ohelp', $
		   XSIZE = 16, $
		   YSIZE = 6)


label = WIDGET_LABEL(base_down, $   ; Space
		      VALUE = '   ', $
		      /ALIGN_LEFT)

sub_base_down_1 = WIDGET_BASE(base_down, /ROW)

label = WIDGET_LABEL(sub_base_down_1, $
						FONT = font_titles, $
				    	VALUE = 'Resulting IDL Source Code', $
		      			/ALIGN_LEFT)

label = WIDGET_LABEL(sub_base_down_1, $    ; Space
		      VALUE = '                         ', $
		      /ALIGN_LEFT)

button = WIDGET_BUTTON(sub_base_down_1, $
			  VALUE=FILEPATH('shift_right.bmp', SUBDIRECTORY=['resource', 'bitmaps']), $
			  EVENT_PRO="test_program", $
			  TOOLTIP="Test Program", $
			  ACCELERATOR="F5", $
		      /BITMAP)

label = WIDGET_LABEL(sub_base_down_1, $    ; Space
		      VALUE = '    ', $
		      /ALIGN_LEFT)

button=WIDGET_BUTTON(sub_base_down_1, $
			VALUE=FILEPATH('save.bmp', SUBDIRECTORY=['resource', 'bitmaps']), $
			TOOLTIP="Save Source Code", $
			EVENT_PRO="save_program", $
			ACCELERATOR="Ctrl+S", $
			/BITMAP)

label = WIDGET_LABEL(sub_base_down_1, $    ; Space
		      VALUE = '    ', $
		      /ALIGN_LEFT)

button=WIDGET_BUTTON(sub_base_down_1, $
			VALUE=FILEPATH('delete.bmp', SUBDIRECTORY=['resource', 'bitmaps']), $
			TOOLTIP="Reset Graphic Windows", $
			EVENT_PRO="reset_windows", $
			/BITMAP)

code_window = WIDGET_TEXT(base_down, $
			FONT="ARIAL*16X16", $
			/SCROLL, $
            XSIZE=lengthdialog, $
            YSIZE=15)

WIDGET_CONTROL, base, /REALIZE

WIDGET_CONTROL, draw_s1, GET_VALUE=wid
WSET, wid
img = READ_BMP(FILEPATH("open.bmp", SUBDIR=["resource","bitmaps"]), R, G, B)
R[8]=236 & G[8]=233 & B[8]=216
TVLCT, R, G, B
TV, img

WIDGET_CONTROL, draw_s2, GET_VALUE=wid
WSET, wid
img = READ_BMP(FILEPATH("gears.bmp", SUBDIR=["resource","bitmaps"]), R, G, B)
R[255]=236 & G[255]=233 & B[255]=216
TVLCT, R, G, B
TV, img

WIDGET_CONTROL, draw_s3, GET_VALUE=wid
WSET, wid
img = READ_BMP(FILEPATH("image.bmp", SUBDIR=["resource","bitmaps"]), R, G, B)
R[80]=236 & G[80]=233 & B[80]=216
TVLCT, R, G, B
TV, img

LOADCT, 0

state = {lists:lists, $
		datatype:'1d', $	; The program starts with a 1d example
		wlist1:wlist1, $
		wlist2:wlist2, $
		wlist3:wlist3, $
		ohelpstrings:PTR_NEW(helpitems), $
		list_ohelp:list_ohelp, $
		src1:PTR_NEW(""), $
		src2:PTR_NEW(""), $
		src3:PTR_NEW(""), $
		appname:'', $
		tips_window:tips_window, $
		file_bttn4:file_bttn4, $
		code_window:code_window}


WIDGET_CONTROL, base, SET_UVALUE=state, /NO_COPY

WINDOW, 0

; "Select" the initial two options (load 1-D binary file and plot it)
WIDGET_CONTROL, wlist3, SET_DROPLIST_SELECT=1  ; The program starts with a 1d example
SCG_Beginners_event, {top:base, id:wlist3, index:1}
SCG_Beginners_event, {top:base, id:wlist1, index:0}
test_program, {top:base}
WIDGET_CONTROL, tips_window, SET_VALUE="Make your selection of data, processing, and visualization to create your own example. " +$
									"Run it by clicking on the Test Program icon. Then see the resulting source code, and export it for your own applications."


XMANAGER, "SCG_Beginners", base, /NO_BLOCK

END


