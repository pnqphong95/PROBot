#include-once
#include "..\Storage\BotSetting.au3"
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
Func pbBattleScreenDispatch(Const $hwnd, Const $logFile)
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
        FileWriteLine($logFile, $rival)
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
			Local Const $lastMessage = pbBattleMessageGet($app)
			Local Const $matched = pbBattleLastMessageMatch($lastMessage)
			If $matched Then
				pbStateSet($APP_BATTLE_DECISION, "ACTION_CHAIN")
				pbNotifyPokemonActionChainProcessing(pbStateGet($APP_BATTLE_TITLE))
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
			pbBattleActionChain($app)
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
	Local $runAwayAction = pbBotSettingGet($APP_BATTLE_ACTION_RUN_AWAY)
	If $runAwayAction <> "" Then
		pbBattleWaitForActionReadyDispatch($app, 1000)
		If pbStateGet($APP_BATTLE_CONTROLLER_READY) Then
			Local $randomSendTimes = Random(1, 3, 1)
			Send("{" & $runAwayAction & " " & $randomSendTimes & "}")
			;~ Send key press in random times, check runAwayAction in Default-Bot.ini settings
		EndIf
	EndIf 
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: pbBattleRunAway
 Description: Magic function to perform auto catch,
 steps is configured by user (Configure auto catch action via Default-Bot.ini)

#ce ----------------------------------------------------------------------------
Func pbBattleActionChain(Const $app)
	Local $actions = pbBotActionChainGet()
	If pbStateGet($APP_IN_BATTLE) Then
		pbStateSet($APP_BATTLE_CONTROLLER_READY, False)
		For $actionKey In $actions 
			Local $keys = StringSplit($actionKey, '')
			pbBattleWaitForActionReadyDispatch($app, 1000)
			If Not pbStateGet($APP_BATTLE_CONTROLLER_READY) Then
				pbStateSet($APP_BATTLE_DECISION, "HOLD_ON")
				ExitLoop
			EndIf
			For $keyNum = 1 To $keys[0]
				Send("{" & $keys[$keyNum] &" 1}")
				Sleep(Random(500, 1000, 1))
				ConsoleWrite("Sent key " & $keys[$keyNum] & ".." & @CRLF)			
			Next
			pbStateSet($APP_BATTLE_CONTROLLER_READY, False)
			Local $retryTime = Number($actions.Item($actionKey))
			If $retryTime > 1 Then
				pbBattleWaitScreenClose($app, 1000)
				If pbStateGet($APP_IN_BATTLE) Then
					Local $retryCount = 1
					While $retryCount < $retryTime
						pbBattleWaitForActionReadyDispatch($app, 1000)
						If Not pbStateGet($APP_BATTLE_CONTROLLER_READY) Then
							pbStateSet($APP_BATTLE_DECISION, "HOLD_ON")
							ExitLoop
						EndIf
						For $keyNum = 1 To $keys[0]
							Sleep(Random(500, 1000, 1))
							Send("{" & $keys[$keyNum] &" 1}")
							ConsoleWrite("Retried key " & $keys[$keyNum] & ".." & @CRLF)			
						Next
						pbStateSet($APP_BATTLE_CONTROLLER_READY, False)
						$retryCount = $retryCount + 1			
					WEnd
				Else
					ExitLoop
				EndIf
			EndIf
		Next
		pbBattleWaitScreenClose($app, 1000)
		If pbStateGet($APP_IN_BATTLE) Then
			pbStateSet($APP_BATTLE_DECISION, "HOLD_ON")
			pbNotifyPokemonUncaught(pbStateGet($APP_BATTLE_TITLE))
		Else
			Local $previewFile = pbBattlePokePreview($app)
			pbNotifyPokemonCaught(pbStateGet($APP_BATTLE_TITLE), $previewFile)
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
			Sleep($interval)
			$elapsed = TimerDiff($timer)
		WEnd
		If $ready Then
			ConsoleWrite("Battle action ready .." & $ready & @CRLF)
		EndIf
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
			Sleep($interval)
			$elapsed = TimerDiff($timer)
		WEnd
		If $closed Then
			ConsoleWrite("Battle screen close .." & $closed & @CRLF)
		EndIf
		pbStateSet($APP_IN_BATTLE, Not $closed)
	EndIf
EndFunc