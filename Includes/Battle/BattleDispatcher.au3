#include-once
#include "..\Constant\ClientKeyBinding.au3"
#include "..\Constant\StateConstant.au3"
#include "..\State\GlobalStateFunction.au3"
#include "..\State\BotStateFunction.au3"
#include "..\State\SlotInfoFunction.au3"
#include "..\State\SlotStateFunction.au3"
#include "..\State\SlotScriptingFunction.au3"
#include "..\State\BattleStateFunction.au3"
#include "..\Utilities\NotificationHelper.au3"
#include "BattleAutomate.au3"
#include "BattleControl.au3"
#include "..\Form\FormGlobalFunction.au3"

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: pbBattleScreenDispatch
 Description: Scan the screen and dispatch screen state to BattleStateFunction.au3

#ce ----------------------------------------------------------------------------
Func pbBattleScreenDispatch(Const $hwnd)
	BattleState_setBegin(False)
	BattleState_setEnd(False)
    Local Const $isDisplayed = pbBattleIsDisplayed($hwnd)
    If $isDisplayed Then
		; Dispatch battle state on
        If Not BattleState_isOn() Then
			BattleState_setOn(True)
			BattleState_setBegin(True)
		EndIf
	Else
        ; Dispatch battle state off
		If BattleState_isOn() Then
			BattleState_setOn(False)
			BattleState_setEnd(True)
		EndIf
	EndIf
    If BattleState_isBegin() Then
		; In battle BEGIN state, dispatch rival name to BattleStateFunction.au3
		BattleState_setTitleRaw("")
		BattleState_setTitle("")
		Local Const $rival = pbBattleRivalGet($hwnd)
		BattleState_setTitleRaw($rival)
		BattleState_setTitle(pbBattleWildPokemonNameExtract($rival))
	EndIf
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: pbBattleRivalEvaluationDispatch
 Description: At battle begin state, call this method to evaluate the rival,
    if it in wishlist or not in skiplist, then hold battle wait for user action.
    Otherwise, set run away of battle.

#ce ----------------------------------------------------------------------------
Func pbBattleRivalEvaluationDispatch(Const $app)
	If BattleState_isBegin() Then
		BattleState_setDecisionRunAway()
		Local $rivalName = BattleState_title()
		If pbBattleRivalQualified($rivalName) Then
			If BotState_desiredMessage() = "" Then
				BattleState_setDecisionActionChain()
			Else
				pbBattleActionFree($app, 1)
				If BattleState_isActionReady() Then
					Local $lastMessage = pbBattleMessageGet($app)
					Local $matched = pbBattleLastMessageMatch($lastMessage)
					If $matched Then
						BattleState_setDecisionActionChain()
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: pbBattleHandler
 Description: Depend on rival evaluation, decision is made and call correspoding handler.

#ce ----------------------------------------------------------------------------
Func pbBattleHandler(Const $app)
	Switch BattleState_decision()
		Case "RUN_AWAY"
			pbBattleRunAway($app)
		Case "ACTION_CHAIN"
			Local $aliveSlot = SlotInfo_aliveSlot($app)
			pbBattleScriptingAction($app, $aliveSlot)
		Case "HOLD_ON"
			; Leave the control to the user
	EndSwitch
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: pbBattleRunAway
 Description: Send key press to run away from battle (Configure runAwayAction key via Default-Bot.ini)

#ce ----------------------------------------------------------------------------
Func pbBattleRunAway(Const $app)
	Local $runAwayAction = $CLIENT_BATTLE_ACTION_KEY_4
	If $runAwayAction <> "" Then
		pbBattleActionFree($app, 1)
		If BattleState_isActionReady() Then
			Send("{" & $runAwayAction & " 1}")
		EndIf
	EndIf
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: pbBattleScriptingAction
 Description: Magic function to perform auto catch,
 steps is configured by user (Configure auto catch action via Default-Bot.ini)

#ce ----------------------------------------------------------------------------
Func pbBattleScriptingAction(Const $app, Const $activeSlot = 0)
	pbBattleActionFree($app, 1)
	If Not BattleState_isOn() Then
		Return
	EndIf
	If Not BattleState_isActionReady() Then
		talkToPlayer("[Pending] Game client get frozen when start scripting slot " & $activeSlot)
		BattleState_setDecisionOnHold()
		Return
	EndIf
	Local $actionSteps = SlotScripting_at($activeSlot)
	If $actionSteps.Count < 1 Then
		talkToPlayer("[Pending] Pokemon Slot " & $activeSlot + 1 & " don't have any action.")
		BattleState_setDecisionOnHold()
		Return
	EndIf
	For $step In $actionSteps
		Local $stepPair = StringSplit($step, "-")
		Local $stepNum = $stepPair[1]
		Local $action = $stepPair[2]
		Local $choice = Number($actionSteps.Item($step))
		If $CLIENT_BATTLE_ACTION_POKEMON = $action Then
			pbBattlePokemonSwitch($app, $action, $choice, $activeSlot)
			Return
		EndIf
		Local $actionKey = resolveAction($action)
		Local $choiceValue = resolveChoice($action, $choice)
		pbBattleSendAutomateAction($actionKey, $choiceValue)
		pbBattleActionFree($app, 1)
		If Not BattleState_isOn() Then
			ExitLoop
		EndIf
		If Not BattleState_isActionReady() Then
			talkToPlayer("[Pending] Game client get frozen when perform " & $step)
			BattleState_setDecisionOnHold()
			Return
		EndIf
		If $CLIENT_BATTLE_ACTION_FIGHT = $action Then
			Local $message = pbBattleMessageGet($app)
			Local $noPPText = StringInStr($message, "no PP")
			If Not @error And $noPPText > 0 Then
				SlotState_removeAction($activeSlot, $action, $choice)
				FormGlobal_refreshScriptingActionInputValue()
				If SlotState_actionScript($activeSlot) <> "" Then
					pbBattleScriptingAction($app, $activeSlot)
				Else
					SlotState_setNoUsableMove($activeSlot)
					pbBattleRunAway($app)
				EndIf
				Return
			EndIf	
		EndIf
	Next
	If BattleState_isOn() Then
		talkToPlayer("[Pending] Pokemon Slot " & $activeSlot + 1 & " completed action, but battle not closed.")
		BattleState_setDecisionOnHold()
	Else
		If BotState_isPokemonPreviewEnable() Then
			Local $previewFile = pbBattlePokePreview($app)
			pbNotifyBattleClosed(BattleState_title(), $previewFile)
		Else
			pbNotifyBattleClosed(BattleState_title())
		EndIf
	EndIf
EndFunc

Func pbBattleActionFree(Const $app, Const $interval = 5, Const $waitSec = 60)
	Local $elapsed = 0, $timer = TimerInit()
	While 1
		Sleep($interval * 1000)
		Local $inBattle = pbBattleIsDisplayed($app)
		If Not $inBattle Then
			BattleState_setOn(False)
			ExitLoop
		EndIf
		BattleState_setOn(True)
		Local $actionFree = pbBattleControlable($app)
		If $actionFree Then
			BattleState_setActionReady(True)
			ExitLoop
		EndIf
		BattleState_setActionReady(False)
		$elapsed = TimerDiff($timer)
		If $elapsed > $waitSec * 1000 Then
			ExitLoop
		EndIf
	WEnd
EndFunc

Func pbBattlePokemonSwitch(Const $app, Const $action, Const $choice, Const $active = 0)
	If $choice = $active + 1 Then
		talkToPlayer("[Pending] Can't switch to current active slot." & $choice)
		BattleState_setDecisionOnHold()
		Return
	EndIf
	If Not SlotState_isUsableSlot($app, $choice - 1) Then
		talkToPlayer("[Pending] Slot " & $choice & " is fainted or has no pp.")
		BattleState_setDecisionOnHold()
		Return
	EndIf
	Local $actionKey = resolveAction($action)
	Local $choiceValue = resolveChoice($action, $choice)
	pbBattleSendAutomateAction($actionKey, $choiceValue)
	pbBattleActionFree($app, 1)
	If BattleState_isOn() Then 
		If Not BattleState_isActionReady() Then
			talkToPlayer("[Pending] Game client get frozen when switching to slot " & $choice)
			BattleState_setDecisionOnHold()
			Return
		EndIf	
		pbBattleScriptingAction($app, $choice - 1)
	EndIf
EndFunc