#include-once
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
Func mknBattleScreenDispatch(Const $hwnd)
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
        ConsoleWrite("[Rival] " & mknStateGet($APP_BATTLE_TITLE) & @CRLF)
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
			mknStateSet($APP_BATTLE_DECISION, "HOLD_ON")
			mknNotifyPokemonFound(mknStateGet($APP_BATTLE_TITLE))
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
			; Function to leave the battle
			Send("{V 2}")
		Case "AUTO_CATCH"
			; Function handle auto catch pokemon
		Case "HOLD_ON"
		Case Else
			; Leave the control to the user
	EndSwitch
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
Func mknBattleWaitForActionReadyDispatch(Const $app, Const $waitSec = 30)
	If Not mknStateGet($APP_BATTLE_CONTROLLER_READY) Then
        Local $elapsed = 0, $timer = TimerInit()
		Local $ready = False
		While Not $ready And $elapsed < $waitSec * 1000
			Sleep(3000)
			$ready = mknBattleControlable($app)
			$elapsed = TimerDiff($timer)
		WEnd
		If $ready Then
			ConsoleWrite("Battle is ready to receive action.." & @CRLF)
		EndIf
		mknStateSet($APP_BATTLE_CONTROLLER_READY, $ready)
	EndIf
EndFunc

;~ Func _useFalseSwipe(Const $app)
;~ 	Local $pokeControllerSelect = "X"
;~ 	Local $pokeSelect = "X"
;~ 	Local $fightMoveControllerSelect = "Z"
;~ 	Local $fightMoveSelect = "X"
;~ 	If mknStateGet($APP_BATTLE_CONTROLLER_STATE_POKEMON) = "" Then
;~ 		mknBattleWaitForActionReadyDispatch($app)
;~ 		Send("{" & $pokeControllerSelect &" 1}")
;~ 		Sleep(Random(500, 1000, 1))
;~ 		Send("{" & $pokeSelect &" 1}")
;~ 		mknStateSet($APP_BATTLE_CONTROLLER_STATE_POKEMON, $pokeSelect)
;~ 		mknStateSet($APP_BATTLE_CONTROLLER_READY, False)
;~ 	EndIf

;~ 	If mknStateGet($APP_BATTLE_CONTROLLER_STATE_FIGHT) = "" Then
;~ 		mknBattleWaitForActionReadyDispatch($app)
;~ 		Send("{" & $fightMoveControllerSelect &" 1}")
;~ 		Sleep(Random(500, 1000, 1))
;~ 		Send("{" & $fightMoveSelect &" 1}")
;~ 		mknStateSet($APP_BATTLE_CONTROLLER_STATE_FIGHT, $fightMoveSelect)
;~ 		mknStateSet($APP_BATTLE_CONTROLLER_READY, False)
;~ 	EndIf
;~ EndFunc