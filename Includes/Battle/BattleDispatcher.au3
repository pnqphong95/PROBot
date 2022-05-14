#include-once
#include "..\Storage\GlobalStorage.au3"
#include "..\Storage\AppState.au3"
#include "..\NotificationHelper.au3"
#include "BattleControl.au3"

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: pbBattleScreenDispatch
 Description: Scan the screen and dispatch screen state to AppState.au3

#ce ----------------------------------------------------------------------------
Func pbBattleScreenDispatch(Const $hwnd)
    pbStateSet($APP_BATTLE_BEGIN, False)
	pbStateSet($APP_BATTLE_END, False)
    Local Const $isDisplayed = pbBattleIsDisplayed($hwnd)
    If $isDisplayed Then
		; Dispatch battle state on
        If Not pbStateGet($APP_IN_BATTLE) Then
			pbStateSet($APP_IN_BATTLE, True)
            pbStateSet($APP_BATTLE_BEGIN, True)
		EndIf
	Else
        ; Dispatch battle state off
		If pbStateGet($APP_IN_BATTLE) Then
			pbStateSet($APP_BATTLE_END, True)
			pbStateSet($APP_IN_BATTLE, False)
		EndIf
	EndIf
    If pbStateGet($APP_BATTLE_BEGIN) Then
		; In battle BEGIN state, dispatch rival name to AppState.au3
        pbStateSet($APP_BATTLE_TITLE_RAWTEXT, "")
		pbStateSet($APP_BATTLE_TITLE, "")
		Local Const $rival = pbBattleRivalGet($hwnd)
		pbStateSet($APP_BATTLE_TITLE_RAWTEXT, $rival)
		pbStateSet($APP_BATTLE_TITLE, pbBattleWildPokemonNameExtract($rival))
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
	If pbStateGet($APP_BATTLE_BEGIN) Then
		pbStateSet($APP_BATTLE_DECISION, "RUN_AWAY")
		Local $rivalName = pbStateGet($APP_BATTLE_TITLE)
		If pbBattleRivalQualified($rivalName) Then
			pbStateSet($APP_BATTLE_CONTROLLER_READY, False)
			pbBattleWaitForActionReadyDispatch($app, 1000, 30)
			Local $lastMessage = pbBattleMessageGet($app)
			Local $matched = pbBattleLastMessageMatch($lastMessage)
			If $matched Then
				pbStateSet($APP_BATTLE_DECISION, "ACTION_CHAIN")
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
	Switch pbStateGet($APP_BATTLE_DECISION)
		Case "RUN_AWAY"
			pbBattleRunAway($app)
		Case "ACTION_CHAIN"
			pbBattleScriptingAction($app)
		Case "HOLD_ON"
		Case Else
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
	Local $runAwayAction = getBotScripting($BOT_BATTLE_ACTION_EXIT)
	If $runAwayAction <> "" Then
		pbBattleWaitForActionReadyDispatch($app, 1000)
		If pbStateGet($APP_BATTLE_CONTROLLER_READY) Then
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
Func pbBattleScriptingAction(Const $app)
	If pbStateGet($APP_IN_BATTLE) Then
		Local $sentAction = '', $sentValue = '', $lastAction, $lastActionType
		pbStateSet($APP_BATTLE_CONTROLLER_READY, False)
		For $action In $BattleAutomateAction
			;~ Action format: StepNumber_ActionType
    		Local $actionType = StringSplit($action, "-")[2]
			Local $dictValue = $BattleAutomateAction.Item($action)
			Local $actionChoice = Number($dictValue)
			Local $actionKey = resolveActionKey($actionType)
			Local $actionValue = resolveActionValue($actionType, $actionChoice)
			Switch ($actionType)
				Case $CLIENT_BATTLE_ACTION_CR
					ConsoleWrite('[Action ' & $action & '] Waiting action ready ' & @CRLF)
					pbBattleWaitForActionReadyDispatch($app, 1000, $actionValue)
					If Not pbStateGet($APP_BATTLE_CONTROLLER_READY) Then
						ConsoleWrite('[Action ' & $action & '] Waited ' & $actionValue & ', but action not ready ' & @CRLF)
						pbStateSet($APP_BATTLE_DECISION, "HOLD_ON")
						ExitLoop
					EndIf
				Case $CLIENT_BATTLE_ACTION_CB
					ConsoleWrite('[Action ' & $action & '] Waiting battle close ' & @CRLF)
					pbBattleWaitScreenClose($app, 1000, $actionValue)
					If Not pbStateGet($APP_IN_BATTLE) Then
						ConsoleWrite('[Action ' & $action & '] Battle closed after ' & $actionValue & ' seconds.' & @CRLF)
						ExitLoop
					Else
						Local $lastMessage = pbBattleMessageGet($app)
						Local $noPPLeft = StringInStr($lastMessage, "no PP")
						If Not @error And $noPPLeft > 0 Then
							removeClosableBattleAction($lastAction)
						EndIf
					EndIf
				Case $CLIENT_BATTLE_ACTION_POKEMON
					ConsoleWrite('[Action ' & $action & '] Send Pokemon #' & $actionChoice & @CRLF)
					$lastAction = $action
					$sentAction = $actionKey
					$sentValue = $actionValue
					pbBattleSendAutomateAction($actionType, $sentAction, $sentValue)
					pbStateSet($APP_BATTLE_CONTROLLER_READY, False)
				Case $CLIENT_BATTLE_ACTION_FIGHT
					ConsoleWrite('[Action ' & $action & '] Use move #' & $actionChoice & @CRLF)
					$lastAction = $action
					$sentAction = $actionKey
					$sentValue = $actionValue
					pbBattleSendAutomateAction($actionType, $sentAction, $sentValue)
					pbStateSet($APP_BATTLE_CONTROLLER_READY, False)
				Case $CLIENT_BATTLE_ACTION_ITEM
					ConsoleWrite('[Action ' & $action & '] Use item #' & $actionChoice & @CRLF)
					$lastAction = $action
					$sentAction = $actionKey
					$sentValue = $actionValue
					pbBattleSendAutomateAction($actionType, $sentAction, $sentValue)
					pbStateSet($APP_BATTLE_CONTROLLER_READY, False)
				Case $CLIENT_BATTLE_ACTION_RETRY
					ConsoleWrite('[Action ' & $action & '] Will retry action ' & $lastAction & @CRLF)
					Local $retryTime = $actionChoice
					pbBattleRetryAction($app, $retryTime, $actionType, $sentAction, $sentValue)
				Case Else
			EndSwitch
		Next
		If pbStateGet($APP_IN_BATTLE) Then
			pbStateSet($APP_BATTLE_DECISION, "HOLD_ON")
			pbNotifyBattleNotClosed(pbStateGet($APP_BATTLE_TITLE))
		Else
			If pbStateGet($BOT_NOTIFICATION_POKEMON_PREVIEW) Then
				Local $previewFile = pbBattlePokePreview($app)
				pbNotifyBattleClosed(pbStateGet($APP_BATTLE_TITLE), $previewFile)
			Else
				pbNotifyBattleClosed(pbStateGet($APP_BATTLE_TITLE))
			EndIf
		EndIf
	EndIf
EndFunc


#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: pbBattleRetryAction
 Description: Internal function perform retry battle action 

#ce ----------------------------------------------------------------------------
Func pbBattleRetryAction(Const $app, Const $retryTime, Const $actionType, Const $sentAction, Const $sentChoice)
	If $retryTime > 1 Then
		pbBattleWaitScreenClose($app, 1000, 8)
		If pbStateGet($APP_IN_BATTLE) Then
			Local $retryCount = 0
			While $retryCount < $retryTime
				pbBattleWaitScreenClose($app, 1000, 8)
				If pbStateGet($APP_IN_BATTLE) Then
					pbBattleWaitForActionReadyDispatch($app, 1000)
					If Not pbStateGet($APP_BATTLE_CONTROLLER_READY) Then
						pbStateSet($APP_BATTLE_DECISION, "HOLD_ON")
						ExitLoop
					EndIf
					pbBattleSendAutomateAction($actionType, $sentAction, $sentChoice)
					$retryCount = $retryCount + 1
				EndIf
			WEnd
		EndIf
	EndIf
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: pbBattleWaitForActionReadyDispatch
 Description: At battle begin state, call this method to evaluate the rival,
    if it in wishlist or not in skiplist, then hold battle wait for user action.
    Otherwise, set run away of battle.

#ce ----------------------------------------------------------------------------
Func pbBattleWaitForActionReadyDispatch(Const $app, Const $interval = 3000, Const $waitSec = 90)
	If Not pbStateGet($APP_BATTLE_CONTROLLER_READY) Then
        Local $elapsed = 0, $timer = TimerInit()
		Local $ready = False
		While Not $ready And $elapsed < $waitSec * 1000
			$ready = pbBattleControlable($app)
			If Not $ready Then
				ConsoleWrite(".")
			EndIf
			Sleep($interval)
			$elapsed = TimerDiff($timer)
		WEnd
		ConsoleWrite(@CRLF)
		pbStateSet($APP_BATTLE_CONTROLLER_READY, $ready)
	EndIf
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: pbBattleWaitScreenClose
 Description: At battle begin state, call this method to evaluate the rival,
    if it in wishlist or not in skiplist, then hold battle wait for user action.
    Otherwise, set run away of battle.

#ce ----------------------------------------------------------------------------
Func pbBattleWaitScreenClose(Const $app, Const $interval = 3000, Const $waitSec = 90)
	If pbStateGet($APP_IN_BATTLE) Then
		Local $elapsed = 0, $timer = TimerInit()
		Local $closed = False
		While Not $closed And $elapsed < $waitSec * 1000
			$closed = Not pbBattleIsDisplayed($app)
			If Not $closed Then
				ConsoleWrite("*")
			EndIf
			Sleep($interval)
			$elapsed = TimerDiff($timer)
		WEnd
		ConsoleWrite(@CRLF)
		pbStateSet($APP_IN_BATTLE, Not $closed)
	EndIf
EndFunc