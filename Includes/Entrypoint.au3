#include-once
#include "State\GlobalStateObject.au3"
#include "Form\FormGlobalObject.au3"
#include "State\UserScriptFunction.au3"
#include "State\BotStateFunction.au3"
#include "State\GlobalStateFunction.au3"
#include "Form\FormGlobalFunction.au3"
#include "Form\FormEventFunction.au3"
#include "Battle\BattleDispatcher.au3"
#include "Utilities\NotificationHelper.au3"

Func runBot()
	FormEvent_applyAttemptState()
	If BotState_isFirstLoad() And BotState_sessionScript() = '' Then
		FormEvent_attachScript()
	EndIf
	If  BotState_sessionScript() <> '' And (Not BotState_isScriptInUse() Or BotState_isReloadSessionScript()) Then
		UserScript_setPath(BotState_sessionScript())
		GlobalState_init()
		FormGlobal_refreshCheckboxes()
		FormGlobal_refreshScriptingActionInputValue()
		FormEvent_forceBotRunning()
		If Not BotState_isScriptInUse() Then
			BotState_setScriptInUse(True)
		ElseIf BotState_isReloadSessionScript() Then
			BotState_setReloadSessionScript(False)
		EndIf
	EndIf
	While BotState_isSessionRunning()
		If FormEvent_applyAttemptState() Then
			ContinueLoop
		EndIf
		Local $app = pbGetApp($CLIENT_TITLE, True)
		If Not $app Or $app = '' Then
			MsgBox($MB_SYSTEMMODAL, "Unable to start bot", "Looks like more than one " & $CLIENT_TITLE & " is running or it not start yet!")
			FormEvent_forceBotStop()
		EndIf
		pbBattleScreenDispatch($app)
		pbSpawnDirectionRelease()
		If BattleState_isOn() Then
			pbBattleRivalEvaluationDispatch($app)
			pbBattleHandler($app)
			ContinueLoop
		Else
			Local $aliveSlot = SlotInfo_aliveSlot($app)
			If Not IsNumber($aliveSlot) Or $aliveSlot < 0 Or $aliveSlot > 5 Then
				talkToPlayer("[Stopped] No alive slot, bot force stopped.")
				FormEvent_forceBotStop()
				ContinueLoop
			EndIf
			Local $usableSlot = SlotState_usableSlot($app, $aliveSlot)
			If Not IsNumber($usableSlot) Or $usableSlot < 0 Or $usableSlot > 5 Then
				talkToPlayer("[Stopped] No usable slot, bot force stopped.")
				FormEvent_forceBotStop()
				ContinueLoop
			EndIf
			If $aliveSlot <> $usableSlot Then
				If Not BotState_isAutoSwapUsable() Then
					talkToPlayer("[Stopped] Slot " & $aliveSlot & " don't have usable move, bot force stopped.")
					FormEvent_forceBotStop()
					ContinueLoop
				EndIf
				Local $swapped = SlotState_swapPokemon($usableSlot, $aliveSlot)
				If Not $swapped Then
					talkToPlayer("[Stopped] Can't swap slot " & $usableSlot + 1 & " to slot " & $aliveSlot + 1 & ", bot force stopped.")
					FormEvent_forceBotStop()
				Else
					FormGlobal_refreshScriptingActionInputValue()
				EndIf
			EndIf
			pbSpawnMoving()
		EndIf
	WEnd
	BotState_setFirstLoad(False)
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: pbSpawnDirectionRelease
 Description: Release last direction key (LEFT, RIGHT, UP, DOWN) retrive from BotStateFunction.au3

#ce ----------------------------------------------------------------------------
Func pbSpawnDirectionRelease()
	Local $lastDirection = BotState_lastSpawnDirection()
	If $lastDirection <> "" Then
		Send("{" & $lastDirection & " up}")
	EndIf
EndFunc

Func pbSpawnMoving()
	Local $shortest = BotState_spawnShortPress()
	Local $longest = BotState_spawnLongPress()
	Local $randomPress = Random($shortest, $longest, 1)
	If BotState_lastSpawnDirection() = "" Then
		Local $startDirection = BotState_spawnStartDirection()
		If $startDirection <> "" Then
			BotState_setLastSpawnDirection($startDirection)
		EndIf
	EndIf
	If BotState_lastSpawnDirection() = "LEFT" Then
		Send("{RIGHT down}")
		Sleep($randomPress)
		BotState_setLastSpawnDirection("RIGHT")
	ElseIf BotState_lastSpawnDirection() = "RIGHT" Then
		Send("{LEFT down}")
		Sleep($randomPress)
		BotState_setLastSpawnDirection("LEFT")
	ElseIf BotState_lastSpawnDirection() = "UP" Then
		Send("{DOWN down}")
		Sleep($randomPress)
		BotState_setLastSpawnDirection("DOWN")
	ElseIf BotState_lastSpawnDirection() = "DOWN" Then
		Send("{UP down}")
		Sleep($randomPress)
		BotState_setLastSpawnDirection("UP")
	EndIf
EndFunc