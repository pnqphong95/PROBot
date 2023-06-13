#include-once
#include "..\Functions\Logger.au3"

Global Const $SESSION_MODE = "bot.session.mode"
Global Const $REPORT_ENABLE = "bot.session.report.enable"
Global Const $AUTO_CAUGHT_LIST = "bot.session.battle.auto-caught-list"
Global Const $AUTO_FIGHT_LIST = "bot.session.battle.auto-fight-list"
Global Const $SYNC_POKEMON_SLOT_NUMBER = "bot.session.battle.sync-slot-number"
Global Const $FALSE_SWIPE_POKEMON_SLOT_NUMBER = "bot.session.battle.fs-slot-number"
Global Const $SPAWN_INITIAL_DIRECTION = "bot.session.spawn.direction"
Global Const $SPAWN_MIN = "bot.session.spawn.min"
Global Const $SPAWN_MAX = "bot.session.spawn.max"
Global Const $RT_SPAWN_LAST_DIRECTION = "bot.session.runtime.spawn.last-direction"
Global Const $RT_ON_BATTLE_VISIBLE = "bot.session.runtime.battle.on-visible"
Global Const $RT_ON_BATTLE_START = "bot.session.runtime.battle.on-start"
Global Const $RT_ON_BATTLE_STOP = "bot.session.runtime.battle.on-stop"
Global Const $RT_RAW_TEXT = "bot.session.runtime.battle.raw-text"
Global Const $RT_RAW_LOG = "bot.session.runtime.battle.raw-log"
Global Const $RT_RECOGNISED_OPPONENT = "bot.session.runtime.battle.recogised-opponent"
Global Const $RT_IS_ACTIONABLE = "bot.session.runtime.battle.actionable"
Global Const $RT_ACTION = "bot.session.runtime.battle.action"
Global Const $RT_OUT_BATTLE_ACTION = "bot.session.runtime.out-battle.action"
Global Const $RT_ERROR_CODE = "bot.session.runtime.error-code"
Global Const $RT_ERROR_CODE_LEADING_NO_USABLE_MOVE = "error_leading_no_usable_move"
Global Const $RT_ERROR_CODE_FROZEN_BATTLE = "error_frozen_battle"
Global Const $RT_OPPONENT_LOG_ENTRIES_COUNTER = "bot.session.runtime.opponent-log-entries-counter"
Global Const $RT_OPPONENT_LOG_ENTRIES_THRESHOLD = "bot.session.runtime.opponent-log-entries-threshold"
Global Const $RT_LAST_BATTLE_END_TIME = "bot.session.runtime.last-battle-end-time"
Global $SessionVariables = ObjCreate("Scripting.Dictionary")
Global $OpponentLogEntries = ObjCreate("Scripting.Dictionary")
Global $PartyData = ObjCreate("Scripting.Dictionary")

; Static config from config file
$SessionVariables.Item($SESSION_MODE) = ""
$SessionVariables.Item($REPORT_ENABLE) = 1
$SessionVariables.Item($AUTO_CAUGHT_LIST) = ""
$SessionVariables.Item($AUTO_FIGHT_LIST) = ""
$SessionVariables.Item($SYNC_POKEMON_SLOT_NUMBER) = 1
$SessionVariables.Item($FALSE_SWIPE_POKEMON_SLOT_NUMBER) = 2
$SessionVariables.Item($SPAWN_INITIAL_DIRECTION) = "Left"
$SessionVariables.Item($SPAWN_MIN) = 600
$SessionVariables.Item($SPAWN_MAX) = 1000
$SessionVariables.Item($RT_OPPONENT_LOG_ENTRIES_THRESHOLD) = 30

; Runtime variables
$SessionVariables.Item($RT_SPAWN_LAST_DIRECTION) = ""
$SessionVariables.Item($RT_ON_BATTLE_VISIBLE) = False
$SessionVariables.Item($RT_ON_BATTLE_START) = False
$SessionVariables.Item($RT_ON_BATTLE_STOP) = False
$SessionVariables.Item($RT_RAW_TEXT) = ""
$SessionVariables.Item($RT_RAW_LOG) = ""
$SessionVariables.Item($RT_RECOGNISED_OPPONENT) = ""
$SessionVariables.Item($RT_IS_ACTIONABLE) = False
$SessionVariables.Item($RT_ACTION) = ""
$SessionVariables.Item($RT_OPPONENT_LOG_ENTRIES_COUNTER) = 0
$SessionVariables.Item($RT_LAST_BATTLE_END_TIME) = 0
$SessionVariables.Item($RT_OUT_BATTLE_ACTION) = ""

Func ProBot_LoadSessionVariables(Const $file)
	If Not FileExists($file) Then
		ProBot_Log("File not exist. File dir = " & $file)
		Return
	EndIf
	Local $sessionVars = IniReadSection($file, "SessionVariables")
	If @error Or $sessionVars[0][0] < 1 Then
		ProBot_Log("File is empty. File dir = " & $file)
		Return
	EndIf
	For $i = 1 To $sessionVars[0][0]
		Local $key = $sessionVars[$i][0]
		Local $newValue = $sessionVars[$i][1]
		Local $oldValue = $SessionVariables.Item($key)
		$SessionVariables.Item($key) = $newValue
		;~ If $oldValue <> $newValue Then
		;~ 	ProBot_Log($key & " = " & $oldValue & "  ->  " & $newValue)
		;~ Else
		;~ 	ProBot_Log($key & " = " & $newValue)
		;~ EndIf
	Next
EndFunc

Func ProBot_svGetPartyUsableMoves(Const $partyNumber = 0)
	Return $PartyData.Item($partyNumber & ".aUsableMoves")
EndFunc

Func ProBot_svSetPartyUsableMoves(Const $aUsableMoves, Const $partyNumber = 0)
	$PartyData.Item($partyNumber & ".aUsableMoves") = $aUsableMoves
EndFunc

Func ProBot_svSetNextAction(Const $nextAction, Const $errorCode = "")
	$SessionVariables.Item($RT_ACTION) = $nextAction
	$SessionVariables.Item($RT_ERROR_CODE) = $errorCode
EndFunc