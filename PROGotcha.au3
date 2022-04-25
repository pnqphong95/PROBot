#include <Misc.au3>
#include <Array.au3>
#include "Libs\ProConstant.au3"
#include "Libs\Environment.au3"
#include "Libs\Utility.au3"
#include "Libs\NotificationHelper.au3"
#include "Libs\ScreenCapturing.au3"

Global $GlobalUser32
$GlobalUser32 = DllOpen("user32.dll")
_penvSet($APP_BATTLE_HOLD_ON_NOTIFICATION, True)
_penvSet($APP_BATTLE_OPPONENT_WISH, "Togepi Froakie Larvesta Lar vesta")

While 1
	Local $app = _getApp(True)
	_scanBattleScreenCtl($app)
	_releasePressingKeys()
	If _penv($APP_IN_BATTLE) Then
		_evalOpponentCtl()
		_battleProcessingCtl()
		ContinueLoop
	Else
		If _penv($APP_IN_SPAWN) Or _pressingMovingKey($GlobalUser32) Then
			_executeSpawnFunc(200, 300)
			_penvSet($APP_IN_SPAWN, True)
		EndIf
	EndIf
WEnd
DllClose($GlobalUser32)


Func _scanBattleScreenCtl(Const $proHnwd)
	_penvSet($APP_BATTLE_BEGIN, False)
	_penvSet($APP_BATTLE_END, False)
	Local $battleScreen = _captureScreenBattle($proHnwd)
	If $battleScreen Then
		; Dispatch state battle.on to env when battle dialog displayed on screen
		If Not _penv($APP_IN_BATTLE) Then
			_penvSet($APP_BATTLE_BEGIN, True)
			_penvSet($APP_IN_BATTLE, True)
		EndIf
	Else
		If _penv($APP_IN_BATTLE) Then
			_penvSet($APP_BATTLE_END, True)
			_penvSet($APP_IN_BATTLE, False)
		EndIf
	EndIf
	If _penv($APP_BATTLE_BEGIN) Then
		_penvSet($APP_BATTLE_TITLE_RAWTEXT, "")
		_penvSet($APP_BATTLE_TITLE, "")
		Local $battleTitle = _captureBattleTitle($proHnwd)
		_penvSet($APP_BATTLE_TITLE_RAWTEXT, $battleTitle)
		_penvSet($APP_BATTLE_TITLE, _extractWildPokemonName($battleTitle))
		ConsoleWrite(_penv($APP_BATTLE_TITLE) & " attack! " & @CRLF)
	EndIf
EndFunc


Func _evalOpponentCtl()
	If _penv($APP_BATTLE_BEGIN) Then
		_penvSet($APP_BATTLE_DECISION, "RUN_AWAY")
		Local $wildPokemonName = _penv($APP_BATTLE_TITLE)
		If _valueableOpponent($wildPokemonName) Then
			_penvSet($APP_BATTLE_DECISION, "HOLD_ON")
			If _penv($APP_BATTLE_HOLD_ON_NOTIFICATION) Then
				pro_NotifyPokemon(_penv($APP_BATTLE_TITLE))
			EndIf
		EndIf
	EndIf
EndFunc


Func _battleProcessingCtl()
	Switch _penv($APP_BATTLE_DECISION)
		Case "RUN_AWAY"
			Send("{V 2}")
		Case "HOLD_ON"
		Case Else
	EndSwitch
EndFunc


Func _pressingMovingKey(Const $userCtl)
	Return _IsPressed("25", $userCtl) Or _IsPressed("26", $userCtl) Or _IsPressed("27", $userCtl) Or _IsPressed("28", $userCtl)
EndFunc

Func _executeSpawnFunc(Const $lowest, Const $highest)
	Local $randomPress = Random($lowest, $highest, 1)
	If _penv($APP_SPAWN_LAST_DIRECTION) = "" Or _penv($APP_SPAWN_LAST_DIRECTION) = "LEFT" Then
		Send("{RIGHT down}")
		Sleep($randomPress)
		_penvSet($APP_SPAWN_LAST_DIRECTION, "RIGHT")
	Else
		Send("{LEFT down}")
		Sleep($randomPress)
		_penvSet($APP_SPAWN_LAST_DIRECTION, "LEFT")
	EndIf
EndFunc

Func _releasePressingKeys()
	Send("{" & _penv($APP_SPAWN_LAST_DIRECTION) & " up}")
EndFunc

Func _valueableOpponent(Const $name)
	Local $wish = StringInStr(_penv($APP_BATTLE_OPPONENT_WISH), $name)
	; Local $notSkip = Not StringInStr(_penv($APP_BATTLE_OPPONENT_SKIP, $name)
	; Temporarily set skip all if not wish
	Local $notSkip = False
	Return $name = "" Or $wish Or $notSkip
EndFunc