;+
; This procedure returns the directory path associated with
; the routine calling this function.  This is useful for
; building applications that need to bootstrap resource and
; configuration files when the installation directory may not
; be known until run time.  Use this function in conjunction
; with FILEPATH to build platform-independent file path strings
; to your resources. <br>
; For example, <pre>
;   b = WIDGET_BUTTON(tlb, /BITMAP, $
;     VALUE=FILEPATH('up.bmp', ROOT = SourcePath(), SUBDIR = ['resource'])</pre>
; This will search for a file named "up.bmp" in the subdirectory named
; "resource" below the directory in which is located the source code
; (or SAVE file) for the routine containing the above statement.
;
; @Keyword
;   Base_Name {out}{optional}{type=string}
;       Set this keyword to a named variable to retrieve the
;       base file name of the routine's source.
;
; @Returns
;   The return value is the root directory path to
;   the calling routine's source file or SAVE file.
;
; @Examples <pre>
;   Create a file myapp.pro with the contents and run it.
;     PRO MYAPP
;     PRINT, SourcePath()
;     END
;   The printed output will be the full path to the
;   directory in which abc.pro was created, regardless of
;   IDL's current working directory.</pre>
;
; @History
;   03/18/2005  JLP, RSI - Original version
;-
Function SourcePath, Base_Name = BaseName
Compile_Opt StrictArr
On_Error, 2
Stack = Scope_Traceback(/Structure)
Filename = Stack[N_elements(Stack) - 2].Filename
If (Arg_Present(BaseName)) then Begin
    BaseName = File_BaseName(Filename)
EndIf
Return, File_DirName(Filename)
End