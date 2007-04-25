Function SourceRoot
On_Error, 2
Help, Calls = Calls
UpperRoutine = (StrTok(Calls[1], ' ', /Extract))[0]
Skip = 0
Catch, ErrorNumber
If (ErrorNumber ne 0) then Begin
	Catch, /Cancel
	Message, /Reset
	ThisRoutine = Routine_Info(UpperRoutine, /Functions, /Source)
	Skip = 1
EndIf
If (Skip eq 0) then Begin
	ThisRoutine = Routine_Info(UpperRoutine, /Source)
	If (ThisRoutine.Path eq '') then Begin
		Message, '', /Traceback
	EndIf
EndIf
Catch, /Cancel
If (StrPos(ThisRoutine.Path, Path_Sep()) eq -1) then Begin
	CD, Current = Current
	SourcePath = FilePath(ThisRoutine.Path, Root = Current)
EndIf Else Begin
	SourcePath = ThisRoutine.Path
EndElse
Root = StrMid(SourcePath, 0, $
	StrPos(SourcePath, Path_Sep(), /Reverse_Search) + 1)
Return, Root
End
