#AutoIt3Wrapper_Icon=Extras\icon.ico
#include <Misc.au3>
#include <AutoItConstants.au3>
#include <FontConstants.au3>
#include <ColorConstants.au3>
#include <TrayConstants.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Date.au3>
#include <Misc.au3>
#include <Array.au3>
#include <MsgBoxConstants.au3>
#include <FileConstants.au3>
#include <TrayConstants.au3>
#include "Includes\Storage\AppConstant.au3"
#include "Includes\Storage\GlobalStorage.au3"
#include "Includes\Storage\AppState.au3"
#include "Includes\WndHelper.au3"
#include "Includes\Battle\BattleControl.au3"
#include "Includes\Battle\BattleDispatcher.au3"
#include "Includes\Spawn\SpawnDispatcher.au3"

If _Singleton(@ScriptName, 1) = 0 Then
    MsgBox($MB_SYSTEMMODAL, @ScriptName, "The bot already running!")
    Exit
EndIf

#Region ### PROBot GUI ###
Global $BotController = GUICreate("PROBot Controller", 260, 160, 0, 0)
Global $StartBtn = GUICtrlCreateButton("Start", 20, 20, 105, 25, $BS_FLAT)
Global $LoadScriptBtn = GUICtrlCreateButton("Load Script", 135, 20, 105, 25, $BS_FLAT)
Global $StatusLabel = GUICtrlCreateLabel("Status:", 20, 60, 40, 25)
Global $ScriptLabel = GUICtrlCreateLabel("Script:", 20, 80, 40, 25)
Global $StatusValueLabel = GUICtrlCreateLabel("Stopped", 65, 60, 175, 25)
Global $ScriptValueLabel = GUICtrlCreateLabel("No script provided.", 65, 80, 175, 25)
Global $EnableNotificationCheckBox = GUICtrlCreateCheckbox("Send result to Telegram", 20, 100, 220)
Global $EnablePreviewCheckBox = GUICtrlCreateCheckbox("Attach preview photo", 20, 120, 220)
#EndRegion ### PROBot GUI ###

bootstrapBot()

#Region ### PROBot GUI Utilities ###
Func bootstrapBot()
	configureBotGui()
	While 1
		Sleep(10)
		runBot()
	WEnd
EndFunc

Func configureBotGui()
 	Opt("GUIOnEventMode", 1)
	WinSetOnTop($BotController, "", $WINDOWS_ONTOP)
	GUISetIcon(@ScriptDir & "\Extras\icon.ico", -1, $BotController)
	GUICtrlSetFont($StartBtn, 12)
	GUICtrlSetFont($LoadScriptBtn, 12)
	GUICtrlSetFont($StatusLabel, 10)
	GUICtrlSetFont($ScriptLabel, 10)
	GUICtrlSetFont($StatusValueLabel, 10, $FW_BOLD)
	GUICtrlSetColor($StatusValueLabel, $COLOR_RED)
	GUICtrlSetFont($ScriptValueLabel, 10)
	GUICtrlSetFont($EnableNotificationCheckBox, 10)
	GUICtrlSetFont($EnablePreviewCheckBox, 10)
	TraySetState($TRAY_ICONSTATE_HIDE)
	GUICtrlSetOnEvent($StartBtn, "switchBotState")
	GUICtrlSetOnEvent($LoadScriptBtn, "loadScript")
	GUICtrlSetOnEvent($EnableNotificationCheckBox, "switchEnableNotificationState")
	GUICtrlSetOnEvent($EnablePreviewCheckBox, "switchEnablePokemonPreviewState")
	GUISetOnEvent($GUI_EVENT_CLOSE, "exitBot")
	GUISetState(@SW_SHOW)
EndFunc

Func loadScript()
	Const $dialogMessage = "Load script to bot"
	Local $config = FileOpenDialog($dialogMessage, @ScriptDir & "\", "Bot script (*.ini)", $FD_FILEMUSTEXIST)
	If @error Then
		FileChangeDir(@ScriptDir)
	Else
		FileChangeDir(@ScriptDir)
		pbStateSet($BOT_SESSION_SCRIPT, $config)
		pbStateSet($BOT_SESSION_SCRIPT_IN_USE, False)
		setBotState("STOPPED")
	EndIf
	If pbStateGet($BOT_SESSION_SCRIPT) <> '' Then
		Local $split = StringSplit(pbStateGet($BOT_SESSION_SCRIPT), '\')
		Local $size = $split[0]
		GUICtrlSetData($ScriptValueLabel, $split[$size])
	EndIf
EndFunc

Func switchBotState()
	If pbStateGet($BOT_SESSION_SWITCH_STATE_ATTEMPT) = '' Then
		ConsoleWrite("Attempting a state switching " & @CRLF)
		If pbStateGet($BOT_SESSION_STATE) = 'RUNNING' Then
			pbStateSet($BOT_SESSION_SWITCH_STATE_ATTEMPT, 'STOPPED')
		ElseIf pbStateGet($BOT_SESSION_STATE) = 'STOPPED' Then
			If pbStateGet($BOT_SESSION_SCRIPT) <> '' Then
				pbStateSet($BOT_SESSION_SWITCH_STATE_ATTEMPT, 'RUNNING')
			Else
				ConsoleWrite("Attemp RUNNING state failed! Session script is empty." & @CRLF)
			EndIf
		EndIf
	EndIf
EndFunc

Func runBot()
	Local $attemptingState = pbStateGet($BOT_SESSION_SWITCH_STATE_ATTEMPT)
	If $attemptingState <> '' Then
		ConsoleWrite("Attempted a state " & $attemptingState & @CRLF)
		setBotState($attemptingState)
		pbStateSet($BOT_SESSION_SWITCH_STATE_ATTEMPT, '')
	EndIf
	If pbStateGet($BOT_SESSION_FIRST_LOAD) And pbStateGet($BOT_SESSION_SCRIPT) = '' Then
		loadScript()
	EndIf
	If pbStateGet($BOT_SESSION_SCRIPT) <> '' And Not pbStateGet($BOT_SESSION_SCRIPT_IN_USE) Then
		setBotSettingPath(@ScriptDir & "\Settings.ini")
		setBotScriptingPath(pbStateGet($BOT_SESSION_SCRIPT))
		initPROBotStorage()
		setBotState('RUNNING')
		pbStateSet($BOT_SESSION_SCRIPT_IN_USE, True)
	EndIf
	Local $appTitle = getBotSetting($CLIENT_TITLE)
	While pbStateGet($BOT_SESSION_STATE) = 'RUNNING'
		Local $attemptingState = pbStateGet($BOT_SESSION_SWITCH_STATE_ATTEMPT)
		If $attemptingState <> '' Then
			ConsoleWrite("Attempted a state " & $attemptingState & @CRLF)
			setBotState($attemptingState)
			pbStateSet($BOT_SESSION_SWITCH_STATE_ATTEMPT, '')
			ContinueLoop
		EndIf
		Local $app = pbGetApp($appTitle, True)
		If Not $app Or $app = '' Then
			MsgBox($MB_SYSTEMMODAL, "Unable to start bot", "Looks like more than one " & $appTitle & " is running or it not start yet!")
			setBotState('STOPPED')
		EndIf
		pbBattleScreenDispatch($app)
		pbSpawnDirectionRelease()
		If pbStateGet($APP_IN_BATTLE) Then
			pbBattleRivalEvaluationDispatch($app)
			pbBattleHandler($app)
			ContinueLoop
		Else
			pbSpawnMoving()
		EndIf
	WEnd
	pbStateSet($BOT_SESSION_FIRST_LOAD, False)
EndFunc

Func exitBot()
	Exit
EndFunc

Func setBotState(Const $state)
	Switch ($state)
		Case "RUNNING"
			GUICtrlSetData($StartBtn, "Stop")
			GUICtrlSetData($StatusValueLabel, "Running")
			GUICtrlSetColor($StatusValueLabel, $COLOR_GREEN)
		Case "STOPPED", ""
			GUICtrlSetData($StartBtn, "Start")
			GUICtrlSetData($StatusValueLabel, "Stopped")
			GUICtrlSetColor($StatusValueLabel, $COLOR_RED)
	EndSwitch
	pbStateSet($BOT_SESSION_STATE, $state)
EndFunc

Func switchEnableNotificationState()
	If BitAND(GUICtrlRead($EnableNotificationCheckBox), $GUI_CHECKED) = $GUI_CHECKED Then
		ConsoleWrite('Enable Telegram report' & @CRLF)	
		pbStateSet($BOT_NOTIFICATION_ENABLE, True)
	Else
		ConsoleWrite('Disable Telegram report' & @CRLF)
		pbStateSet($BOT_NOTIFICATION_ENABLE, False)
	EndIf
EndFunc

Func switchEnablePokemonPreviewState()
	If BitAND(GUICtrlRead($EnablePreviewCheckBox), $GUI_CHECKED) = $GUI_CHECKED Then
		ConsoleWrite('Enable attach preview photo' & @CRLF)
		pbStateSet($BOT_NOTIFICATION_POKEMON_PREVIEW, True)
	Else
		ConsoleWrite('Disable attach preview photo' & @CRLF)
		pbStateSet($BOT_NOTIFICATION_POKEMON_PREVIEW, False)
	EndIf
EndFunc
#EndRegion ### PROBot GUI Utilities ###