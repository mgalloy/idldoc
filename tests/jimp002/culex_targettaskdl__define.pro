;+
; This function creates a TaskDL object specific for managing
; flight data target calculations.
;
; @Param
;   Targets {in}{required}{type=string}
;       TBD ???: Set this parameter to the vector of "targets"
;       to be performed.  This may be a list of subdirectories containing
;       specific target data files and metadata, database file names
;       or something else.
;
; @Keyword
;   _Ref_Extra {in}{out}{optional}
;       Any extra keywords are passed on to the superclass INIT method
;       by reference.
;
; @Returns
;   This function returns 1 for success or 0 for failure.
;
; @Author
;   JLP, RSI Global Services
;
; @History
;   October 20, 2005 - Original Version
;-
Function Culex_TargetTaskDL::Init, $
    Targets, $
    _Ref_Extra = Extra
Compile_Opt StrictArr
On_Error, 2
ResourceDirectory = FilePath('', Root = SourceRoot(), $
    SubDir = ['resource'])
If (~self->Culex_DistributedTaskDL::Init('Target', ResourceDirectory, $
    Targets, _Extra = Extra)) then Begin
    Return, 0
EndIf
Return, 1
End


;+
; This procedure defines the member variables of the
; Culex_TargetTaskDL class.
;
; @Inherits
;   Culex_DistributedTaskDL
;
; @Author
;   JLP, RSI Global Services
;
; @History
;   October 20, 2005 - Original Version
;
; @File_Comments
;   This file defines the TaskDL subclass associated with the
;   target task farming, used by the master node.
;-
Pro Culex_TargetTaskDL__Define
Compile_Opt StrictArr
On_Error, 2
TargetTaskDL = {Culex_TargetTaskDL, $
    Inherits Culex_DistributedTaskDL $
    }
End