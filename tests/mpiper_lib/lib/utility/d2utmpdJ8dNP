;+
; The SOURCEROOT function, in combination with
; FILEPATH, allows a program to locate other
; files within a routine source file's related
; directory tree.
; <p>
;
; For example, an IDL routine file named
; C:\myapp\abc.pro calls SOURCEROOT as in
; <p>
; <pre>
;    PRO ABC
;    PRINT, SOURCEROOT()
;    END
; </pre>
; the resulting output will be the string "C:\myapp".
; <p>
;
; If data associated with the application are in
; C:\myapp\mydata, a data file in this directory
; can be located via
; <p>
; <pre>
;    IDL> datafile = FilePath('data.dat',$
;    IDL>   ROOT=SourceRoot(), $
;    IDL>   SUBDIR=['data'])
; </pre>
; The programmer can distribute the application
; to another user who may install the original directory tree
; into "D:\app".
; No code modifications would be required for this
; user to successfully locate the data.dat file.
; <p>
;
; If the routine ABC were compiled and saved to
; an IDL SAVE file and distributed, the SOURCEROOT
; function will return the path to the SAVE file
; instead.
;
; @author Jim Pendleton
;-
Function SourceRoot
Help, Calls = Calls
UpperRoutine = (StrTok(Calls[1], ' ', /Extract))[0]
Skip = 0
Catch, ErrorNumber
If (ErrorNumber ne 0) then Begin
    Catch, /Cancel
    ThisRoutine = Routine_Info(UpperRoutine, /Functions, /Source)
    Skip = 1
EndIf
If (Skip eq 0) then Begin
    ThisRoutine = Routine_Info(UpperRoutine, /Source)
EndIf
Case StrUpCase(!version.os_family) of
    'WINDOWS' : DirSep = '\'
    'UNIX' : DirSep = '/'
    'MACOS' : DirSep = ':'
    'VMS' : DirSep = ']'
    Else : DirSep = ''
EndCase
Root = StrMid(ThisRoutine.Path, 0, StrPos(ThisRoutine.Path, DirSep, /Reverse_Search) + 1)
Return, Root
End
