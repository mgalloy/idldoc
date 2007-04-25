Pro Query_Object_Tree_Properties, Event
    Widget_Control, Event.ID, Get_UValue = oObject
    DescriptionText = $
        Widget_Info(Event.Top, Find_by_UName = 'DescriptionText')
    Help, oObject, Output = Reference
    Name = '<No Name>'
    ClassName = Obj_Class(oObject)
    Components = StrTok(Reference[0], '(', /Extract)
    Reference = (StrTok(Components[0], 'ObjHeapVar', /Extract, /Regex))[1]
    SkipName = 0
    Catch, ErrorNumber
    If (ErrorNumber ne 0) then Begin
        Catch, /Cancel
        SkipName = 1
    EndIf
    If (not SkipName) then Begin
        oObject->GetProperty, Name = Name
        Catch, /Cancel
    EndIf
    SkipAll = 0
    Catch, ErrorNumber
    If (ErrorNumber ne 0) then Begin
        Catch, /Cancel
        SkipAll = 1
    EndIf
    If (not SkipAll) then Begin
        oObject->GetProperty, All = All
        Catch, /Cancel
        Help, /Structure, All, Output = HelpDump
    EndIf
    If (N_elements(HelpDump) eq 0) then Begin
        HelpDump = ''
    EndIf
    Widget_Control, DescriptionText, $
        Set_Value = [Name, ClassName, $
                     'Object Heap Variable ' + Reference, '', HelpDump]
End


Pro Query_Object_Tree_Event, Event
    Catch, ErrorNumber
    If (ErrorNumber ne 0) then Begin
        Catch, /Cancel
        Help, /Last_Message, Output = LastError
        v = Dialog_Message(Title = 'Query Object Tree Error', /Error, $
                           LastError)
        Return
    EndIf
    EventType = Tag_Names(Event, /Structure)
    Case 1 of
        StrPos(EventType, 'WIDGET_TREE') ne -1 : Begin
            Case EventType of
                'WIDGET_TREE_SEL' : Begin
                    Query_Object_Tree_Properties, Event
                End
                Else :
            EndCase
        End
        Else : Begin
            Widget_Control, Event.ID, Get_UValue = UValue
            Case UValue of
                'Update' : Begin
                    FirstFolder = Widget_Info(Event.Top, $
                                              Find_by_UName = 'FirstFolder')
                    Widget_Control, FirstFolder, Get_UValue = oRoot
                    TreeBase = Widget_Info(Event.Top, $
                                           Find_by_UName = 'TreeBase')
                    Tree = Widget_Info(TreeBase, /Child)
                    Widget_Control, Tree, /Destroy
                    Query_Object_Tree_Build_Tree, oRoot, Parent = TreeBase
                End
                Else : Begin
                End
            EndCase
        End
    EndCase
End


Pro Query_Object_Tree_Build_Tree, oRoot, T, Indent = Indent, Parent = Parent
    Compile_Opt StrictArr
    If (not Obj_Valid(oRoot)) then Begin
        Return
    EndIf
    If (N_elements(Indent) eq 0) then Begin
        If (N_elements(Parent) eq 0) then Begin
            TLB = Widget_Base(/Column)
        EndIf Else Begin
            TLB = Parent
        EndElse
        T = Widget_Tree(TLB, /Folder, Value = 'Root Object', /Top, $
                        XSize = 600, YSize = 600, UName = 'TreeRoot')
        T = Widget_Tree(T, /Folder, UName = 'FirstFolder')
        Widget_Control, T, Set_Value = 'Root Object', Set_UValue = oRoot
        Spaces = ''
        Indent = 0
    EndIf Else Begin
        If (Indent gt 0) then Begin
            Spaces = StrJoin(Replicate(' ', Indent))
        EndIf Else Begin
            Spaces = ''
        EndElse
    EndElse
    SkipName = 0
    Catch, ErrorNumber
    If (ErrorNumber ne 0) then Begin
        Catch, /Cancel
        SkipName = 1
    EndIf
    Name = ''
    If (not SkipName) then Begin
        oRoot->GetProperty, Name = Name
        Catch, /Cancel
    EndIf
    If (Name eq '') then Begin
        Help, oRoot, Output = HelpDump
        Components = StrTok(HelpDump[0], '(', /Extract)
        Reference = (StrTok(Components[0], 'ObjHeapVar', /Extract, /Regex))[1]
        Type = (StrTok(Components[1], ')', /Extract))[0]
    EndIf
    Widget_Control, T, $
        Set_Value = (Name ne '' ? Name : Type + ' ' + Reference), $
        Set_UValue = oRoot
    If (Obj_IsA(oRoot, 'IDL_CONTAINER')) then Begin
        oAll = oRoot->Get(/All, Count = Count)
        For I = 0L, Count - 1 Do Begin
            HasChild = Obj_IsA(oAll[I], 'IDL_CONTAINER')
            If (HasChild) then Begin
                NewT = Widget_Tree(T, /Folder)
            EndIf Else Begin
                NewT = Widget_Tree(T)
            EndElse
            Query_Object_Tree_Build_Tree, oAll[I], NewT, Indent = Indent + 3
        EndFor
        Indent = Indent - 3
    EndIf
End

Pro Query_Object_Tree, oRoot
    TLB = Widget_Base(Title = 'Object Query', /Row, UName = 'TLB')
    LeftColumn = Widget_Base(TLB, /Column, UName = 'LeftColumn')
    TreeBase = Widget_Base(LeftColumn, UName = 'TreeBase')
    Query_Object_Tree_Build_Tree, oRoot, Parent = TreeBase
    UpdateButton = Widget_Button(LeftColumn, Value = 'Update', $
                                 UValue = 'Update', $
                                 UName = 'UpdateButton', /Align_Left)
    RightColumn = Widget_Base(TLB, /Column)
    DescriptionText = Widget_Text(RightColumn, XSize = 80, YSize = 24, $
                                  UName = 'DescriptionText', /Scroll)
    Widget_Control, TLB, /Realize
    XManager, 'Query_Object_Tree', TLB, /No_Block
End
