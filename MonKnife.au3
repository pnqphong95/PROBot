#include <Misc.au3>
#include <Array.au3>
#include "Includes\Storage\AppConstant.au3"
#include "Includes\Storage\AppSetting.au3"
#include "Includes\Storage\AppState.au3"
#include "Includes\NotificationHelper.au3"
#include "Includes\WndHelper.au3"
#include "Includes\BattleControl.au3"

mknAppSettingInit(@ScriptDir & "\MonKnife.ini")
mknStateSet($APP_BATTLE_OPPONENT_WISH, "Froakie")

; pro_StartWorker()

Func pro_StartWorker()
	Local $User32 = DllOpen("user32.dll")
	While 1
		Local $app = mknGetApp(True)
		_scanBattleScreenCtl($app)
		_releasePressingKeys()
		If mknStateGet($APP_IN_BATTLE) Then
			_evalOpponentCtl()
			_battleProcessingCtl($app)
			ContinueLoop
		Else
			If mknStateGet($APP_IN_SPAWN) Or _pressingMovingKey($User32) Then
				_executeSpawnFunc(200, 300)
				mknStateSet($APP_IN_SPAWN, True)
			EndIf
		EndIf
	WEnd
	DllClose($User32)
EndFunc

Func _scanBattleScreenCtl(Const $hnwd)
	mknStateSet($APP_BATTLE_BEGIN, False)
	mknStateSet($APP_BATTLE_END, False)
	Local $battleScreen = mknBattleIsDisplayed($hnwd)
	If $battleScreen Then
		; Dispatch state battle.on to env when battle dialog displayed on screen
		If Not mknStateGet($APP_IN_BATTLE) Then
			mknStateSet($APP_BATTLE_BEGIN, True)
			mknStateSet($APP_IN_BATTLE, True)
		EndIf
	Else
		If mknStateGet($APP_IN_BATTLE) Then
			mknStateSet($APP_BATTLE_END, True)
			mknStateSet($APP_IN_BATTLE, False)
		EndIf
	EndIf
	If mknStateGet($APP_BATTLE_BEGIN) Then
		mknStateSet($APP_BATTLE_TITLE_RAWTEXT, "")
		mknStateSet($APP_BATTLE_TITLE, "")
		Local $battleRival = mknBattleRivalGet($hnwd)
		mknStateSet($APP_BATTLE_TITLE_RAWTEXT, $battleRival)
		mknStateSet($APP_BATTLE_TITLE, mknBattleWildPokemonNameExtract($battleRival))
		ConsoleWrite(mknStateGet($APP_BATTLE_TITLE) & " attack! " & @CRLF)
	EndIf
EndFunc

Func _evalOpponentCtl()
	If mknStateGet($APP_BATTLE_BEGIN) Then
		mknStateSet($APP_BATTLE_DECISION, "RUN_AWAY")
		Local $wildPokemonName = mknStateGet($APP_BATTLE_TITLE)
		If _valueableOpponent($wildPokemonName) Then
			mknStateSet($APP_BATTLE_DECISION, "HOLD_ON")
			mknNotifyPokemonFound(mknStateGet($APP_BATTLE_TITLE))
		EndIf
	EndIf
EndFunc

Func _battleProcessingCtl(Const $app)
	Switch mknStateGet($APP_BATTLE_DECISION)
		Case "RUN_AWAY"
			Send("{V 2}")
		Case "HOLD_ON"
			; _useFalseSwipe($app)
		Case Else
	EndSwitch
EndFunc

Func _pressingMovingKey(Const $userCtl)
	Return _IsPressed("25", $userCtl) Or _IsPressed("26", $userCtl) Or _IsPressed("27", $userCtl) Or _IsPressed("28", $userCtl)
EndFunc

Func _executeSpawnFunc(Const $lowest, Const $highest)
	Local $randomPress = Random($lowest, $highest, 1)
	If mknStateGet($APP_SPAWN_LAST_DIRECTION) = "" Or mknStateGet($APP_SPAWN_LAST_DIRECTION) = "LEFT" Then
		Send("{RIGHT down}")
		Sleep($randomPress)
		mknStateSet($APP_SPAWN_LAST_DIRECTION, "RIGHT")
	Else
		Send("{LEFT down}")
		Sleep($randomPress)
		mknStateSet($APP_SPAWN_LAST_DIRECTION, "LEFT")
	EndIf
EndFunc

Func _releasePressingKeys()
	Send("{" & mknStateGet($APP_SPAWN_LAST_DIRECTION) & " up}")
EndFunc

Func _valueableOpponent(Const $name)
	Local $wish = StringInStr(mknStateGet($APP_BATTLE_OPPONENT_WISH), $name)
	; Local $notSkip = Not StringInStr(mknStateGet($APP_BATTLE_OPPONENT_SKIP, $name)
	; Temporarily set skip all if not wish
	Local $notSkip = False
	Return $name = "" Or $wish Or $notSkip
EndFunc

Func _waitForBattleControlFree(Const $app, Const $waitSec = 30)
	If Not mknStateGet($APP_BATTLE_CONTROLLER_FREE) Then
		Local $free = False, $timer = TimerInit(), $elapsed = 0
		While Not $free And $elapsed < $waitSec * 1000
			Sleep(2000)
			$free = mknBattleControlable($app)
			$elapsed = TimerDiff($timer)
		WEnd
		If $free Then
			ConsoleWrite("Wait for select action!" & @CRLF)
		EndIf
		mknStateSet($APP_BATTLE_CONTROLLER_FREE, $free)
	EndIf
EndFunc

Func _useFalseSwipe(Const $app)
	Local $pokeControllerSelect = "X"
	Local $pokeSelect = "X"
	Local $fightMoveControllerSelect = "Z"
	Local $fightMoveSelect = "X"
	If mknStateGet($APP_BATTLE_CONTROLLER_STATE_POKEMON) = "" Then
		_waitForBattleControlFree($app)
		Send("{" & $pokeControllerSelect &" 1}")
		Sleep(Random(500, 1000, 1))
		Send("{" & $pokeSelect &" 1}")
		mknStateSet($APP_BATTLE_CONTROLLER_STATE_POKEMON, $pokeSelect)
		mknStateSet($APP_BATTLE_CONTROLLER_FREE, False)
	EndIf

	If mknStateGet($APP_BATTLE_CONTROLLER_STATE_FIGHT) = "" Then
		_waitForBattleControlFree($app)
		Send("{" & $fightMoveControllerSelect &" 1}")
		Sleep(Random(500, 1000, 1))
		Send("{" & $fightMoveSelect &" 1}")
		mknStateSet($APP_BATTLE_CONTROLLER_STATE_FIGHT, $fightMoveSelect)
		mknStateSet($APP_BATTLE_CONTROLLER_FREE, False)
	EndIf
EndFunc

Func mknGetApp(Const $activate = False)
	Local $appTitle = mknAppSettingGet($APP_TITLE)
	Local $hnwds = WinList($appTitle)
	Local $instanceNum = $hnwds[0][0]
	If ($instanceNum > 1) Then
		MsgBox($MB_SYSTEMMODAL, "Error", "More than 1 instance of " & $appTitle &" is running. Please exit them.")
		Exit
	ElseIf ($instanceNum < 1) Then
		MsgBox($MB_SYSTEMMODAL, "Error", "Look like you didn't start " & $appTitle & " yet.")
		Exit
	Else
		Local $appHnwd = $hnwds[1][1]
		If $activate Then
			WinActivate($appHnwd)
		EndIf
		Return $appHnwd
	EndIf
EndFunc