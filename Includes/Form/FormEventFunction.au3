#include-once
#include <FileConstants.au3>
#include "..\State\BotStateFunction.au3"
#include "FormGlobalObject.au3"
#include "FormGlobalFunction.au3"

Func FormEvent_bindUiEvents()
	GUICtrlSetOnEvent($StartBtn, "FormEvent_switchState")
	GUICtrlSetOnEvent($LoadScriptBtn, "FormEvent_attachScript")
	GUICtrlSetOnEvent($ReloadScriptBtn, "FormEvent_attemptReloadCurrentScript")
	GUICtrlSetOnEvent($EnableNotificationCheckBox, "FormEvent_switchNotificationState")
	GUICtrlSetOnEvent($EnablePreviewCheckBox, "FormEvent_switchPreviewState")
	GUICtrlSetOnEvent($AutoSolveCheckBox, "FormEvent_switchAutoSolveState")
	GUISetOnEvent($GUI_EVENT_CLOSE, "FormEvent_exitBot")
EndFunc

Func FormEvent_switchState()
	If BotState_attemptingSessionState() = '' Then
		Local $currentState = BotState_sessionState()
		If BotState_isSessionRunning() Then
			FormEvent_attemptBotState("STOPPED")
		ElseIf BotState_isSessionStopped() Then
			If BotState_sessionScript() <> '' Then
				FormEvent_attemptBotState("RUNNING")
            Else
				ConsoleWrite("Attemp RUNNING state failed! Session script is empty." & @CRLF)
			EndIf
		EndIf
	EndIf
EndFunc

Func FormEvent_attachScript()
	Const $dialogMessage = "Attach script to bot"
	Local $config = FileOpenDialog($dialogMessage, @ScriptDir & "\", "Bot script (*.ini)", $FD_FILEMUSTEXIST)
	If @error Then
		FileChangeDir(@ScriptDir)
	Else
		FileChangeDir(@ScriptDir)
		BotState_setSessionScript($config)
		BotState_setScriptInUse(False)
		FormEvent_forceBotStop()
        FormGlobal_refreshScriptValue()
		FormGlobal_refreshReloadScriptBtn()
	EndIf
EndFunc

Func FormEvent_attemptReloadCurrentScript()
	BotState_setReloadSessionScript(True)
EndFunc

Func FormEvent_switchNotificationState()
	BotState_setNotificationEnable(FormGlobal_isEnableNotification())
EndFunc

Func FormEvent_switchPreviewState()
	BotState_setPokemonPreviewEnable(FormGlobal_isEnablePreview())
EndFunc

Func FormEvent_switchAutoSolveState()
	BotState_setAutoSwapUsable(FormGlobal_isEnableAutoSolve())
EndFunc

Func FormEvent_exitBot()
	Exit
EndFunc

Func FormEvent_applyAttemptState()
    Local $attemptingState = BotState_attemptingSessionState()
    If $attemptingState <> '' Then
        BotState_setAttemptSessionState("")
        FormEvent_forceBotState($attemptingState)
        Return True
    EndIf
EndFunc

Func FormEvent_attemptBotState(Const $state)
    BotState_setAttemptSessionState($state)
    FormGlobal_refreshStartBtn()
EndFunc

Func FormEvent_forceBotState(Const $newState)
	If BotState_isSessionStopped() And $newState = "RUNNING" Then
		FormGlobal_saveFieldToState()
	EndIf
	BotState_setSessionState($newState)
	FormGlobal_refreshStartBtn()
    FormGlobal_refreshStatusValue()
	FormGlobal_refreshScriptingActionInputState()
EndFunc

Func FormEvent_forceBotRunning()
    FormEvent_forceBotState("RUNNING")
EndFunc

Func FormEvent_forceBotStop()
    FormEvent_forceBotState("STOPPED")
EndFunc