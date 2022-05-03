#include-once
#include "Includes\Storage\AppSetting.au3"
#include "Includes\Storage\BotSetting.au3"
#include "Includes\Storage\AppState.au3"
#include "Includes\NotificationHelper.au3"
#include "Includes\BattleControl.au3"

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: mknBattleScreenDispatch
 Description: Scan the screen and dispatch screen state to AppState.au3

#ce ----------------------------------------------------------------------------
Func mknBattleScreenDispatch(Const $hwnd, Const $logFile)
    mknStateSet($APP_BATTLE_BEGIN, False)
	mknStateSet($APP_BATTLE_END, False)
    Local Const $isDisplayed = mknBattleIsDisplayed($hwnd)
    If $isDisplayed Then
		; Dispatch battle state on
        If Not mknStateGet($APP_IN_BATTLE) Then
			mknStateSet($APP_IN_BATTLE, True)
            mknStateSet($APP_BATTLE_BEGIN, True)
		EndIf
	Else
        ; Dispatch battle state off
		If mknStateGet($APP_IN_BATTLE) Then
			mknStateSet($APP_BATTLE_END, True)
			mknStateSet($APP_IN_BATTLE, False)
		EndIf
	EndIf
    If mknStateGet($APP_BATTLE_BEGIN) Then
		; In battle BEGIN state, dispatch rival name to AppState.au3
        mknStateSet($APP_BATTLE_TITLE_RAWTEXT, "")
		mknStateSet($APP_BATTLE_TITLE, "")
		Local Const $rival = mknBattleRivalGet($hwnd)
		mknStateSet($APP_BATTLE_TITLE_RAWTEXT, $rival)
		mknStateSet($APP_BATTLE_TITLE, mknBattleWildPokemonNameExtract($rival))
        FileWriteLine($logFile, $rival)
	EndIf
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: mknBattleRivalEvaluationDispatch
 Description: At battle begin state, call this method to evaluate the rival,
    if it in wishlist or not in skiplist, then hold battle wait for user action.
    Otherwise, set run away of battle.

#ce ----------------------------------------------------------------------------
Func mknBattleRivalEvaluationDispatch()
	If mknStateGet($APP_BATTLE_BEGIN) Then
		mknStateSet($APP_BATTLE_DECISION, "RUN_AWAY")
		Local $rivalName = mknStateGet($APP_BATTLE_TITLE)
		If mknBattleRivalQualified($rivalName) Then
			mknStateSet($APP_BATTLE_DECISION, "AUTO_CATCH")
			mknNotifyPokemonAutoCatch(mknStateGet($APP_BATTLE_TITLE))
		EndIf
	EndIf
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: mknBattleHandler
 Description: Depend on rival evaluation, decision is made and call correspoding handler.

#ce ----------------------------------------------------------------------------
Func mknBattleHandler(Const $app)
	Switch mknStateGet($APP_BATTLE_DECISION)
		Case "RUN_AWAY"
			mknBattleRunAway($app)
		Case "AUTO_CATCH"
			mknBattleAutocatch($app)
		Case "HOLD_ON"
		Case Else
			; Leave the control to the user
	EndSwitch
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: mknBattleRunAway
 Description: Send key press to run away from battle (Configure runAwayAction key via Default-Bot.ini)

#ce ----------------------------------------------------------------------------
Func mknBattleRunAway(Const $app)
	Local $runAwayAction = mknBotSettingGet($APP_BATTLE_ACTION_RUN_AWAY)
	If $runAwayAction <> "" Then
		mknBattleWaitForActionReadyDispatch($app, 1000)
		If mknStateGet($APP_BATTLE_CONTROLLER_READY) Then
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
 Function: mknBattleRunAway
 Description: Magic function to perform auto catch,
 steps is configured by user (Configure auto catch action via Default-Bot.ini)

#ce ----------------------------------------------------------------------------
Func mknBattleAutocatch(Const $app)
	Local $actions = mknBotAutoCatchActions()
	If mknStateGet($APP_IN_BATTLE) Then
		mknStateSet($APP_BATTLE_CONTROLLER_READY, False)
		For $actionKey In $actions 
			Local $keys = StringSplit($actionKey, '')
			mknBattleWaitForActionReadyDispatch($app, 1000)
			If Not mknStateGet($APP_BATTLE_CONTROLLER_READY) Then
				mknStateSet($APP_BATTLE_DECISION, "HOLD_ON")
				ExitLoop
			EndIf
			For $keyNum = 1 To $keys[0]
				Send("{" & $keys[$keyNum] &" 1}")
				Sleep(Random(500, 1000, 1))
				ConsoleWrite("Sent key " & $keys[$keyNum] & ".." & @CRLF)			
			Next
			mknStateSet($APP_BATTLE_CONTROLLER_READY, False)
			Local $retryTime = Number($actions.Item($actionKey))
			If $retryTime > 1 Then
				mknBattleWaitScreenClose($app, 1000)
				If mknStateGet($APP_IN_BATTLE) Then
					Local $retryCount = 1
					While $retryCount < $retryTime
						mknBattleWaitForActionReadyDispatch($app, 1000)
						If Not mknStateGet($APP_BATTLE_CONTROLLER_READY) Then
							mknStateSet($APP_BATTLE_DECISION, "HOLD_ON")
							ExitLoop
						EndIf
						For $keyNum = 1 To $keys[0]
							Sleep(Random(500, 1000, 1))
							Send("{" & $keys[$keyNum] &" 1}")
							ConsoleWrite("Retried key " & $keys[$keyNum] & ".." & @CRLF)			
						Next
						mknStateSet($APP_BATTLE_CONTROLLER_READY, False)
						$retryCount = $retryCount + 1			
					WEnd
				Else
					ExitLoop
				EndIf
			EndIf
		Next
		mknBattleWaitScreenClose($app, 1000)
		If mknStateGet($APP_IN_BATTLE) Then
			mknStateSet($APP_BATTLE_DECISION, "HOLD_ON")
			mknNotifyPokemonUncaught(mknStateGet($APP_BATTLE_TITLE))
		Else
			mknNotifyPokemonCaught(mknStateGet($APP_BATTLE_TITLE))
		EndIf
	EndIf
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: mknBattleWaitForActionReadyDispatch
 Description: At battle begin state, call this method to evaluate the rival,
    if it in wishlist or not in skiplist, then hold battle wait for user action.
    Otherwise, set run away of battle.

#ce ----------------------------------------------------------------------------
Func mknBattleWaitForActionReadyDispatch(Const $app, Const $interval = 3000, Const $waitSec = 90)
	If Not mknStateGet($APP_BATTLE_CONTROLLER_READY) Then
        Local $elapsed = 0, $timer = TimerInit()
		Local $ready = False
		While Not $ready And $elapsed < $waitSec * 1000
			$ready = mknBattleControlable($app)
			Sleep($interval)
			$elapsed = TimerDiff($timer)
		WEnd
		If $ready Then
			ConsoleWrite("Battle action ready .." & $ready & @CRLF)
		EndIf
		mknStateSet($APP_BATTLE_CONTROLLER_READY, $ready)
	EndIf
EndFunc

#cs ----------------------------------------------------------------------------

 Version: 0.1.0
 AutoIt Version: 3.3.16.0
 Author: pnqphong95
 Function: mknBattleWaitScreenClose
 Description: At battle begin state, call this method to evaluate the rival,
    if it in wishlist or not in skiplist, then hold battle wait for user action.
    Otherwise, set run away of battle.

#ce ----------------------------------------------------------------------------
Func mknBattleWaitScreenClose(Const $app, Const $interval = 3000, Const $waitSec = 90)
	If mknStateGet($APP_IN_BATTLE) Then
        Local $elapsed = 0, $timer = TimerInit()
		Local $closed = False
		While Not $closed And $elapsed < $waitSec * 1000
			$closed = Not mknBattleIsDisplayed($app)
			Sleep($interval)
			$elapsed = TimerDiff($timer)
		WEnd
		If $closed Then
			ConsoleWrite("Battle screen close .." & $closed & @CRLF)
		EndIf
		mknStateSet($APP_IN_BATTLE, Not $closed)
	EndIf
EndFunc