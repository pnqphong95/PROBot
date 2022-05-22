#include-once
#include "..\State\GlobalStateObject.au3"
#include "..\State\SlotStateFunction.au3"
#include "..\State\BotStateFunction.au3"
#include "FormGlobalObject.au3"

Func FormGlobal_isEnableNotification()
	Return BitAND(GUICtrlRead($EnableNotificationCheckBox), $GUI_CHECKED) = $GUI_CHECKED
EndFunc

Func FormGlobal_isEnablePreview()
	Return BitAND(GUICtrlRead($EnablePreviewCheckBox), $GUI_CHECKED) = $GUI_CHECKED
EndFunc

Func FormGlobal_isEnableAutoSolve()
	Return BitAND(GUICtrlRead($AutoSolveCheckBox), $GUI_CHECKED) = $GUI_CHECKED
EndFunc

Func FormGlobal_refreshCheckboxes()
	If BotState_isNotificationEnable() Then
		GUICtrlSetState($EnableNotificationCheckBox, $GUI_CHECKED)
	Else
		GUICtrlSetState($EnableNotificationCheckBox, $GUI_UNCHECKED)
	EndIf
	If BotState_isPokemonPreviewEnable() Then
		GUICtrlSetState($EnablePreviewCheckBox, $GUI_CHECKED)
	Else
		GUICtrlSetState($EnablePreviewCheckBox, $GUI_UNCHECKED)
	EndIf
	If BotState_isAutoSwapUsable() Then
		GUICtrlSetState($AutoSolveCheckBox, $GUI_CHECKED)
	Else
		GUICtrlSetState($AutoSolveCheckBox, $GUI_UNCHECKED)
	EndIf
EndFunc

Func FormGlobal_refreshStartBtn()
	Local $stateAttempting = BotState_attemptingSessionState()
	If $stateAttempting <> '' Then
		GUICtrlSetState($StartBtn, $GUI_DISABLE)
	Else
		GUICtrlSetState($StartBtn, $GUI_ENABLE)
	EndIf
	Switch (BotState_sessionState())
		Case "RUNNING"
			GUICtrlSetData($StartBtn, "Stop")
		Case "STOPPED", ""
			GUICtrlSetData($StartBtn, "Start")
	EndSwitch
EndFunc

Func FormGlobal_refreshReloadScriptBtn()
	If BotState_sessionScript() <> "" Then
		GUICtrlSetState($ReloadScriptBtn, $GUI_ENABLE)
	Else
		GUICtrlSetState($ReloadScriptBtn, $GUI_DISABLE)
	EndIf
EndFunc

Func FormGlobal_refreshStatusValue()
	Switch (BotState_sessionState())
		Case "RUNNING"
			GUICtrlSetData($StatusValue, "Running")
			GUICtrlSetColor($StatusValue, $COLOR_GREEN)
		Case "STOPPED", ""
			GUICtrlSetData($StatusValue, "Stopped")
			GUICtrlSetColor($StatusValue, $COLOR_RED)
	EndSwitch
EndFunc

Func FormGlobal_refreshScriptValue()
	Local $sessionScript = BotState_sessionScript()
	If $sessionScript <> '' Then
		Local $split = StringSplit($sessionScript, '\')
		Local $size = $split[0]
		GUICtrlSetData($ScriptValue, $split[$size])
	Else
		GUICtrlSetData($ScriptValue, "No script provided!")
	EndIf
EndFunc

Func FormGlobal_refreshScriptingActionInputValue()
	GUICtrlSetData($DesiredOpponent, BotState_desiredOpponent())
	GUICtrlSetData($IgnoredOpponent, BotState_ignoredOpponent())
	GUICtrlSetData($DesiredMessage, BotState_desiredMessage())
	For $i = 0 To 5
		GUICtrlSetData($SlotActionInputs[$i], SlotState_actionScript($i))
	Next
EndFunc

Func FormGlobal_refreshScriptingActionInputState()
	Local $state = $GUI_ENABLE
	If BotState_isSessionRunning() Then
		$state = $GUI_DISABLE
	ElseIf BotState_isSessionStopped() Then
		$state = $GUI_ENABLE
	EndIf
	GUICtrlSetState($DesiredOpponent, $state)
	GUICtrlSetState($DesiredMessage, $state)
	GUICtrlSetState($IgnoredOpponent, $state)
	For $i = 0 To 5
		GUICtrlSetState($SlotActionInputs[$i], $state)
	Next
EndFunc

Func FormGlobal_refreshBot()
	FormGlobal_refreshStartBtn()
	FormGlobal_refreshReloadScriptBtn()
	FormGlobal_refreshStatusValue()
	FormGlobal_refreshScriptValue()
	FormGlobal_refreshCheckboxes()
	FormGlobal_refreshScriptingActionInputValue()
	FormGlobal_refreshScriptingActionInputState()
EndFunc

Func FormGlobal_saveFieldToState()
	BotState_setDesiredOpponent(GUICtrlRead($DesiredOpponent))
	BotState_setDesiredMessage(GUICtrlRead($DesiredMessage))
	BotState_setIgnoredOpponent(GUICtrlRead($IgnoredOpponent))
	For $slot = 0 To 5
		SlotState_saveActionScript($slot, GUICtrlRead($SlotActionInputs[$slot]))
	Next
EndFunc