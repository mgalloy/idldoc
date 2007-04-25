;+
; This method ensures that the .sav file associated with the
; task is available, then adds the task to the TaskDL queue.
;
; @Param
;   Tasks {in}{required}{type=string}
;       Set this parameter to the path(s) to the directory in which
;       the data reside for applying the task.
; @Keyword
;   Task_Name {in}{optional}{type=string}
;       Set this keyword to the name of the task (e.g., "target" or
;       "calibration") to use to construct the SAVE file names.
;       By default, the value of self.TaskName is used.
;
; @Author
;   JLP, RSI Global Services
;
; @History
;   February 10, 2006 - Original Version
;-
Pro Culex_DistributedTaskDL::AddTasks, Tasks, $
    Task_Name = TaskName_Local
Compile_Opt StrictArr
On_Error, 2
;
; Tell the task the name of the procedure for each worker
; to run.  The IDL SAVE file associated with a distributed
; task is simply "culex_" + task name + ".sav", for example
; "culex_calibration.sav" and "culex_target.sav".
;
TaskName = N_elements(TaskName_Local) eq 1 ? $
    TaskName_Local : $
    self.TaskName
RestoreFile = $
    File_Search(FilePath('culex_' + StrLowcase(TaskName) + '.sav', $
    Root = SourceRoot(), SubDir = ['..', 'save_add']), $
    Count = Count)
If (Count eq 0) then Begin
    Message, 'Unable to locate the culex_' + $
        StrLowCase(self.TaskName) + '.sav in !path.', $
        /Traceback
EndIf
self->TaskDL::Check_Procedure, 'culex_' + StrLowCase(TaskName), $
    Restore = RestoreFile
;
; For each of the calibrations, create a task.
;
For I = 0L, N_elements(Tasks) - 1 Do Begin
    self->TaskDL::Add_Task, 'culex_' + StrLowCase(Taskname) + ',"' + $
        Tasks[I] + '"'
EndFor
End


;+
; This method reads the host list file and adds the
; hosts to the TaskDL worker list.
;
; @Author
;   JLP, RSI Global Services
;
; @History
;   February 10, 2006 - Original Version
;-
Pro Culex_DistributedTaskDL::AddWorkers
Compile_Opt StrictArr
On_Error, 2
;
; Add a worker for each entry in the host list.
;
Hosts = self->GetHostList(Count = NHosts)
For I = 0L, NHosts - 1 Do Begin
    self->TaskDL::Add_Worker, Hosts[I]
EndFor
End


;+
; This method is called during the destruction of this object.
;
; @Author
;   JLP, RSI Global Services
;
; @History
;   February 1, 2006 - Original Version
;-
Pro Culex_DistributedTaskDL::Cleanup
Compile_Opt StrictArr
On_Error, 2
;
; Decommit all workers, if any are still working.
;
self->DecommissionAllWorkers
;
; Don't leak the task log parser.
;
Obj_Destroy, self.oCulexTaskLogParser
;
; Call the superclass cleanup, if it had one.
;
;self->TaskDL::Cleanup
End


;+
; This method decommissions all workers via directed tasks the
; next time each looks for a task to perform.  Decommissioning
; does not kill any task that is already executing.
;
; @Keyword
;   Decommissioned {out}{optional}
;       Set this keyword to a named variable to retrieve the
;       number of decommission tasks were issued.  Decommission
;       tasks are only issued to workers that are in an "active"
;       or "unknown" state.
; @Keyword
;   Directed {in}{optional}{type=boolean}{default=1}
;       Set this keyword to 0 to indicate that the tasks to decommit
;       the workers should be added to the end of the current task
;       list queue and shouldn't be given higher priority than
;       calculation tasks, allowing any existing tasks in the queue
;       to complete before decommissioning.  The default action is
;       to add the decommission tasks at a higher priority than other
;       tasks, potentially leaving some calculation tasks in an unfinished
;       state.
;
; @Author
;   JLP, RSI Global Services
;
; @History
;   February 3, 2006 - Original Version
;-
Pro Culex_DistributedTaskDL::DecommissionAllWorkers, $
    Decommissioned = Decommissioned, $
    Directed = Directed_Local
Compile_Opt StrictArr
On_Error, 2
;
; The default action for the Directed keyword is to do it,
; so we're looking for the user setting it to 0.
;
Directed = N_elements(Directed_Local) ne 0 ? $
    Keyword_Set(Directed_Local) : $
    1
;
; How many workers do we have?
;
WorkerInfo = self->TaskDL::Get_Worker_Info()
Decommissioned = 0
If (N_elements(WorkerInfo) gt 4) then Begin
;
; For each of the hosts, put in tickets to remove
; them when they're finished working on the tasks.
; This will free them for subsequent target tasks
; which may be performed after all calibration tasks have
; completed.
;
    For I = 0L, N_elements(WorkerInfo)/4 - 1 Do Begin
        If (WorkerInfo[3, I] ne 1) then Begin
;
; A worker is not already marked as decommissioned.
;
            If (Directed) then Begin
;
; Specify this particular worker to be decommissioned,
; meaning it will be decommitted even if there are
; other tasks in the queue.  Otherwise we issue a
; "general" decommit task that the first worker that
; sees it will obey, after all other tasks preceding it
; in the queue have been taken.
;
                WorkerID = WorkerInfo[0, I]
            EndIf
            self->TaskDL::Remove_Worker, WorkerID = WorkerID
            Decommissioned++
        EndIf
    EndFor
EndIf
End


;+
; This function gets the node names from a node text file, and
; returns an array of those hostnames.
;
; @Keyword
;   Count {out}{optional}
;       Set this keyword to a named variable to retrieve the
;       number of hosts returned in the list.
;
; @Returns
;   This function returns the host list read from file as a string
;   vector.
;
; @Author
;   JLP, RSI Global Services
;
; @History
;   October 19, 2005 - Original Version
;-
Function Culex_DistributedTaskDL::GetHostList, $
    Count = Count
Compile_Opt StrictArr
On_Error, 2
;
; For flexibility we allow either a "*_host_list.txt"
; file and a "host_list.txt" file.  If the former is present,
; then we read that; it is assumed to be a list of nodes
; specifically to be tasked with the task run.  Otherwise
; we check for the latter file, which is a "default" set of nodes
; on which any farmed tasks can be run, either calibration or
; target analysis.  The specific task host file resides
; the the resource subdirectory of the specific task directory.
;
Filename = FilePath(Root = self.ResourceDirectory, $
    StrLowCase(self.TaskName) + '_host_list.txt')
NodeFile = File_Search(Filename, Count = Count)
If (Count eq 0) then Begin
;
; We didn't find a "task"_host_list.txt file so look for
; a more general host_list.txt file.  This files resides in
; the resource subdirectory of the main culex directory.
;
    Filename = FilePath(Root = SourceRoot(), $
        SubDir = ['resource'], 'host_list.txt')
    NodeFile = File_Search(Filename, Count = Count)
EndIf
If (Count eq 0) then Begin
;
; We didn't find either host name file so we won't be
; able to farm out our tasks.  Simply abort.
;
    Message, 'Cannot find the host list file: ' + NodeFile, /Traceback
EndIf
;
; Read the host list file and strip the empty lines.
;
HostList = StrArr(File_Lines(Filename))
OpenR, LUN, NodeFile, /Get_LUN
ReadF, LUN, HostList
Free_LUN, LUN
GoodLines = Where(StrCompress(HostList, /Remove_All) ne '', NHosts)
If (NHosts eq 0) then Begin
    Message, 'Host list file is empty : ' + NodeFile, /Traceback
EndIf Else Begin
    HostList = StrTrim(HostList[GoodLines], 2)
EndElse
Count = N_elements(HostList)
Return, HostList
End


;+
; This method is retrieves properties of this object.
;
; @Keyword
;   Culex_TaskLogParser {out}{optional}
;       Set this keyword to named variable to retrieve the
;       Culex_TaskLogParser object reference associated with
;       this object.
; @Keyword
;   Initialization_Time {out}{optional}
;       Set this keyword to a named variable to retrieve the
;       time at which the object was initialized, in
;       SYSTIME(1) format.
;
; @Author
;   JLP, RSI Global Services
;
; @History
;   February 1, 2006 - Original Version
;-
Pro Culex_DistributedTaskDL::GetProperty, $
    Culex_TaskLogParser = oCulexTaskLogParser, $
    Initialization_Time = InitializationTime
Compile_Opt StrictArr
On_Error, 2
If (Arg_Present(oCulexTaskLogParser)) then Begin
    oCulexTaskLogParser = self.oCulexTaskLogParser
EndIf
If (Arg_Present(InitializationTime)) then Begin
    InitializationTime = self.InitializationTime
EndIf
End


;+
; This method initializes the TaskDL object and automatically
; loads the worker list.
;
; @Param
;   TaskName {in}{required}{type=string}
;       Set this parameter to the name of the task to be performed.
;       The TaskName string is used as the bases for determining
;       the name of the .sav file to be executed by the worker,
;       among other things.
; @Param
;   ResourceDirectory {in}{required}{type=string}
;       Set this parameter to the name of the resource directory
;       associated with the specified TaskName.  This is the
;       name of the directory in which to look for specific
;       items such as the host list text file.
; @Param
;   Tasks {in}{required}{type=TBD}
;       TBD ???: Set this parameter to the vector of "tasks"
;       to be performed.  This may be a list of subdirectories containing
;       specific "task" data files and metadata, database file names
;       or something else.
; @Keyword
;   Session_Name {in}{out}{optional}{type=string vector}
;       Set this parameter to the session name to be applied to the
;       TaskDL session.  The default name is constructed from
;       task name and the system time.
;
; @Returns
;   This method returns 1 for success or 0 for failure.
;
; @Uses
;   self->GetHostList <br>
;   self->TaskDL::Add_Worker <br>
;   self->TaskDL::Check_Procedure <br>
;   self->TaskDL::Add_Task <br>
;   self->TaskDL::Remove_Worker
;-
Function Culex_DistributedTaskDL::Init, TaskName, $
    ResourceDirectory, Tasks, $
    Session_Name = SessionName_Local
Compile_Opt StrictArr
On_Error, 2
;
; Initialize member variables
;
self.TaskName = TaskName
self.ResourceDirectory = ResourceDirectory
SessionName = N_elements(SessionName) eq 1 ? $
    SessionName : $
    self.TaskName + '_' + $
    StrJoin((StrTok(SysTime(), ' ', /Extract))[1:*], '')
Status = self->TaskDL::Init(Name = SessionName)
If (~Status) then Begin
    Return, 0
EndIf
self.InitializationTime = SysTime(1)
self->AddWorkers
self->AddTasks, Tasks
;
; Add a task log parser for use by the monitor GUI, passing
; in the path to the flight directory.
;
self.oCulexTaskLogParser = Obj_New('Culex_TaskLogParser', $
    File_DirName(File_DirName(Tasks[0])))
Return, 1
End


;+
; This method sets properties of this object.
;
; @Author
;   JLP, RSI Global Services
;
; @History
;   February 1, 2006 - Original Version
;-
Pro Culex_DistributedTaskDL::SetProperty
Compile_Opt StrictArr
On_Error, 2
End


;+
; This procedure defines the member variables of the
; Culex_DistributedTaskDL class.  It is an abstract class,
; and should have a specific implementation for each of
; unique processing tasks, such as calibration and target
; calculations.
;
; @Abstract
;
; @Inherits
;   TaskDL <it>(Tech-X Corp)</it>
;
; @Field
;   TaskName
;       This field defines the type of task and is specified
;       by the subclass during the call to the INIT method.
;       This string is used to determine the location of
;       the associated task's .sav file, the definition of the
;       session name, etc.
; @Field
;   ResourceDirectory
;       This field defines the resource subdirectory of the
;       subclass.
; @Field
;   InitializationTime
;       Time in SYSTIME(1) format of the creation time of the object.
;       Used to determine if log files are older than the task by
;       the task monitor.
; @Field
;   oCulexTaskLogParser
;       Reference to a Culex_TaskLogParser object used to parser
;       .log files from the flight directory.
;
; @File_Comments
;   This code defines the abstract class Culex_DistributedTaskDL,
;   which in turn is subset from (Tech-X Corp's) TaskDL class.
;   This class is subclassed for each of the processing tasks
;   that will be farmed out in a multiprocessor environment,
;   for example the calibration and target tasks.
;-
Pro Culex_DistributedTaskDL__Define
DistributedTaskDL = {Culex_DistributedTaskDL, $
    Inherits TaskDL, $
    TaskName            : '', $
    ResourceDirectory   : '', $
    InitializationTime  : 0L, $
    oCulexTaskLogParser : Obj_New() $ ; Destroy in ::Cleanup
    }
End