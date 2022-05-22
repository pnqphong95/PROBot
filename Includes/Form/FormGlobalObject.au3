#include-once
#include <ButtonConstants.au3>
#include <FontConstants.au3>
#include <GUIConstantsEx.au3>
#include <ColorConstants.au3>
#include <TrayConstants.au3>

Global $BotController, $BotIcon
Global $StartBtn, $LoadScriptBtn, $ReloadScriptBtn
Global $StatusValue, $ScriptValue
Global $EnableNotificationCheckBox, $EnablePreviewCheckBox, $AutoSolveCheckBox
Global $DesiredOpponent, $DesiredMessage, $IgnoredOpponent
Global $SlotActionInputs[6]
FormGlobal_initDefault()

Func FormGlobal_initDefault()
    Opt("GUIOnEventMode", 1)
    TraySetState($TRAY_ICONSTATE_HIDE)
    $BotController = GUICreate("PROBot", 320, 680, 0, 0)
	GUISetIcon(@ScriptDir & "\Extras\icon.ico", -1, $BotController)

	$StartBtn = GUICtrlCreateButton("", 20, 20, 90, 25, $BS_FLAT)
	GUICtrlSetFont($StartBtn, 10)
	$LoadScriptBtn = GUICtrlCreateButton("Script", 115, 20, 90, 25, $BS_FLAT)
	GUICtrlSetFont($LoadScriptBtn, 10)
	$ReloadScriptBtn = GUICtrlCreateButton("Reload script", 210, 20, 90, 25, $BS_FLAT)
	GUICtrlSetFont($ReloadScriptBtn, 10)

	Local $StatusLabel = GUICtrlCreateLabel("Status:", 20, 60, 40, 25)
	GUICtrlSetFont($StatusLabel, 10, $FW_BOLD)
	$StatusValue = GUICtrlCreateLabel("", 65, 60, 225, 25)
	GUICtrlSetFont($StatusValue, 10, $FW_BOLD)
	GUICtrlSetColor($StatusValue, $COLOR_RED)

	Local $ScriptLabel = GUICtrlCreateLabel("Script:", 20, 80, 40, 25)
	GUICtrlSetFont($ScriptLabel, 10, $FW_BOLD)
	$ScriptValue = GUICtrlCreateLabel("", 65, 80, 225, 25)
	GUICtrlSetFont($ScriptValue, 10)

	$EnableNotificationCheckBox = GUICtrlCreateCheckbox("Send notification to channel", 20, 120, 270)
    GUICtrlSetFont($EnableNotificationCheckBox, 10)
	$EnablePreviewCheckBox = GUICtrlCreateCheckbox("Attach pokemon preview", 20, 140, 270)
    GUICtrlSetFont($EnablePreviewCheckBox, 10)
	$AutoSolveCheckBox = GUICtrlCreateCheckbox("Auto-swap usable slot", 20, 160, 270)
    GUICtrlSetFont($AutoSolveCheckBox, 10)

	Local $DesiredOpponentLabel = GUICtrlCreateLabel("Desired Opponent:", 20, 200, 280, 25)
	GUICtrlSetFont($DesiredOpponentLabel, 10, $FW_BOLD)
	$DesiredOpponent = GUICtrlCreateEdit("", 20, 220, 280, 60)

	Local $DesiredMessageLabel = GUICtrlCreateLabel("Desired Message:", 20, 290, 280, 25)
	GUICtrlSetFont($DesiredMessageLabel, 10, $FW_BOLD)
	$DesiredMessage = GUICtrlCreateEdit("", 20, 310, 280, 60)

	Local $IgnoredOpponentLabel = GUICtrlCreateLabel("Ignored Opponent:", 20, 380, 280, 25)
	GUICtrlSetFont($IgnoredOpponentLabel, 10, $FW_BOLD)
	$IgnoredOpponent = GUICtrlCreateEdit("", 20, 400, 280, 60)

	Local $TopSlotInput = 480
	For $i = 0 To 5
		Local $SlotLabel = GUICtrlCreateLabel("Slot " & $i + 1 & ":", 20, $TopSlotInput + ($i * 30), 40, 25)
		GUICtrlSetFont($SlotLabel, 10, $FW_BOLD)
		$SlotActionInputs[$i] = GUICtrlCreateInput("", 65, $TopSlotInput + ($i * 30), 235, 25)
	Next

    GUISetState(@SW_HIDE)
EndFunc