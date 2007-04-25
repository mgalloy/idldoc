; Copyright (c) 2002-2004, Research Systems, Inc.  All rights reserved.
;       Unauthorized reproduction prohibited.
;+
; NAME:
;   example4tool__define
;
; PURPOSE:
;   Example custom iTool launch routine, used to display
;   the example user interface panel described in "Creating
;   a User Interface Panel" in the iTool Developer's Guide.
;
; CATEGORY:
;   iTools
;   
;-
;
PRO example4tool, IDENTIFIER = identifier, _EXTRA = _extra

   ; Register our iTool class with the iTool system.
   ITREGISTER, 'Example 4 Tool', 'example4tool'
   
   ; Register the user interface panel, setting the TYPE
   ; keyword.
   ITREGISTER, 'Example Panel', 'Example4_panel', $
      TYPE = 'EXAMPLE', /UI_PANEL

   ; Create an instance of an iTool that uses our user interface
   ; panel.
   identifier = IDLITSYS_CREATETOOL('Example 4 Tool',$
      VISUALIZATION_TYPE = ['Surface'], $
      TITLE = 'Example iTool with Panel', $
      _EXTRA = _extra)



END
