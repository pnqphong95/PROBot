#AutoIt3Wrapper_Icon=Extras\icon.ico
#include <Misc.au3>
#include <MsgBoxConstants.au3>
If _Singleton(@ScriptName, 1) = 0 Then
    MsgBox($MB_SYSTEMMODAL, @ScriptName, "The bot already running!")
    Exit
EndIf

#include "Includes\Entrypoint.au3"
#include "Includes\Form\FormGlobalFunction.au3"
#include "Includes\Form\FormEventFunction.au3"

FormEvent_bindUiEvents()
FormGlobal_refreshBot()
GUISetState(@SW_SHOW)
While 1
	Sleep(20)
	runBot()
WEnd