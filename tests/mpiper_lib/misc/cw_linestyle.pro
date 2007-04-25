Function CW_Linestyle_Event, Event
Compile_Opt StrictArr
UValueBase = Widget_Info(Event.Handler, Find_by_UName = 'UValueBase')
Widget_Control, UValueBase, Get_UValue = State
EventType = Tag_Names(Event, /Structure_Name)
NewEvent = 0
Case EventType of
	'WIDGET_DRAW' : Begin
		Case Event.Type of
			0 : Begin
;
; Button Press
;
				Case Event.Press of
					1 : Begin
;
; Left mouse button
;
						Widget_Control, Event.ID, Get_Value = oDrawWindow
						oDrawWindow->GetProperty, Graphics_Tree = oView
						oModel = oView->GetByName('LinestyleModel')
						oSelected = oDrawWindow->Select(oView, [Event.X, Event.Y])
						If (Size(oSelected[0], /TName) eq 'OBJREF') then Begin
							oSelected[0]->GetProperty, Name = Name
							Components = StrTok(Name, '_', /Extract)
							Linestyle = Long(Components[N_elements(Components) - 1])
							If (State.Linestyle ne Linestyle) then Begin
								oNewHighlight = $
									oSelected[0]->GetByName('LinestyleHighlightPolygon')
								oNewHighlight->SetProperty, Hide = 0
								oNewPolyline = $
									oSelected[0]->GetByName('LinestylePolyline')
								oNewPolyline->SetProperty, Color = [255, 255, 255]
								oPrevious = oView->GetByName('LinestyleModel/' + $
									'LinestyleModel_' + StrTrim(State.Linestyle, 2))
								oOldHighlight = oPrevious->GetByName( $
									'LinestyleHighlightPolygon')
								oOldHighlight->SetProperty, Hide = 1
								oOldPolyline = $
									oPrevious->GetByName('LinestylePolyline')
								oOldPolyline->SetProperty, Color = [0, 0, 0]
								NewEvent = {CW_Linestyle_Event, $
									ID : Event.Handler, $
									Top : Event.Top, $
									Handler : 0L, $
									Linestyle : Linestyle $
									}
							EndIf
							State.Linestyle = Linestyle
							oDrawWindow->Draw
						EndIf
						End
					Else :
				EndCase
				End
			2 : Begin
;
; Motion
;
				Widget_Control, Event.ID, Get_Value = oDrawWindow
				oDrawWindow->GetProperty, Graphics_Tree = oView
				oModel = oView->GetByName('LinestyleModel')
				oSelected = oDrawWindow->Select(oView, [Event.X, Event.Y])
				If (Size(oSelected[0], /TName) eq 'OBJREF') then Begin
					oSelected[0]->GetProperty, Name = Name
					Components = StrTok(Name, '_', /Extract)
					SelectedLine = Long(Components[N_elements(Components) - 1])
					For I = 0L, oModel->Count() - 1 Do Begin
						oLineModel = oModel->Get(Position = I)
						oHighlightLine = $
							oLineModel->GetByName('LinestyleHighlightPolyline')
						oHighlightLine->SetProperty, Hide = I ne SelectedLine
					EndFor
				EndIf
				oDrawWindow->Draw
				End
			Else :
		EndCase
		End
	Else :
EndCase
Widget_Control, UValueBase, Set_UValue = State
Return, NewEvent
End


Pro CW_Linestyle_Set_Value, ID, Value
Compile_Opt StrictArr
UValueBase = Widget_Info(ID, Find_by_UName = 'UValueBase')
Widget_Control, UValueBase, Get_UValue = State
State.Linestyle = Value
Widget_Control, UValueBase, Set_UValue = State
End


Function CW_Linestyle_Get_Value, ID, Value
Compile_Opt StrictArr
Widget_Control, Widget_Info(ID, Find_by_UName = 'UValueBase'), $
	Get_UValue = State
Return, State.Linestyle
End


Pro CW_Linestyle_Init, ID
Compile_Opt StrictArr
UValueBase = Widget_Info(ID, Find_by_UName = 'UValueBase')
Widget_Control, UValueBase, Get_UValue = State
DrawWidget = Widget_Info(ID, Find_by_UName = 'LinestyleDrawWidget')
Widget_Control, DrawWidget, Get_Value = oDrawWindow
oDrawWindow->SetCurrentCursor, 'Arrow'
oDrawWindow->GetProperty, Dimensions = Dimensions
Colors = Widget_Info(ID, /System_Colors)
oView = Obj_New('IDLgrView', Viewplane_Rect = [0, -10, Dimensions + [0, 20]], $
	Color = Colors.Face_3D, Name = 'LinestyleView')
oDrawWindow->SetProperty, Graphics_Tree = oView
oModel = Obj_New('IDLgrModel', Name  = 'LinestyleModel')
oView->Add, oModel
NLines = 7
DY = Dimensions[1]/Float(NLines)
For I = 0, NLines - 1 Do Begin
	oLineModel = Obj_New('IDLgrModel', Name = 'LinestyleModel_' + $
		StrTrim(I, 2), /Select_Target)
	oModel->Add, oLineModel
	oPolygon1 = Obj_New('IDLgrPolygon', $
		[0, 1, 1, 0]*(Dimensions[0] - 1), $
		Dimensions[1] - ([0, 0, 1, 1]*DY + I*DY), $
		[0, 0, 0, 0], $
		Name = 'LinestylePolygon', $
		Color = Colors.Face_3D, Style = 2)
	oLineModel->Add, oPolygon1
	oPolygonHighlight = Obj_New('IDLgrPolygon', $
		[.05, .95, .95, .05]*(Dimensions[0] - 1), $
		Dimensions[1] - ([.05, .05, .95, .95]*DY + I*DY), $
		[.1, .1, .1, .1], $
		Name = 'LinestyleHighlightPolygon', $
		Color = Colors.Shadow_3D, $
		Hide = I ne State.Linestyle, Style = 2)
	oLineModel->Add, oPolygonHighlight
	oPolylineHighlight = Obj_New('IDLgrPolyline', $
		[.05, .95, .95, .05, .05]*(Dimensions[0] - 1), $
		Dimensions[1] - ([.05, .05, .95, .95, .05]*DY + I*DY), $
		[.11, .11, .11, .11, .11], $
		Name = 'LinestyleHighlightPolyline', $
		Color = [0, 0, 0], $
		Hide = I ne State.Linestyle, Linestyle = 0)
	oLineModel->Add, oPolylineHighlight
	oPolyline = Obj_New('IDLgrPolyline', $
		[.2, .8]*(Dimensions[0] - 1), $
		Dimensions[1] - ([0, 0] + (I + .5)*DY), [.2, .2], $
		Linestyle = I, $
		Color = State.Linestyle eq I ? [255, 255, 255] : [0, 0, 0], $
		Name = 'LinestylePolyline')
	oLineModel->Add, oPolyline
EndFor
oDrawWindow->Draw
Widget_Control, ID, Map = 1
End


Function CW_Linestyle, Parent, $
	Value = Value, $
	UValue = UValue, $
	Frame = Frame, $
	UName = UName
On_Error, 2
Compile_Opt StrictArr
Linestyle = N_elements(Value) eq 1 ? Value : 0
State = {CW_Linestyle_State, $
	Linestyle : Long(Linestyle) $
	}
TLB = Widget_Base(Parent, Frame = Frame, $
	Event_Func = 'CW_Linestyle_Event', $
	Func_Get_Value = 'CW_Linestyle_Get_Value', $
	Pro_Set_Value = 'CW_Linestyle_Set_Value', $
	UValue = UValue, UName = UName, $
	Notify_Realize = 'CW_Linestyle_Init')
Base = Widget_Base(TLB, UName = 'UValueBase', $
	UValue = State)
DrawWidget = Widget_Draw(Base, $
	Graphics_Level = 2, Retain = 2, $
	/Button_Events, /Motion_Events, UName = 'LinestyleDrawWidget')
Widget_Control, TLB, Map = 0
Return, TLB
End