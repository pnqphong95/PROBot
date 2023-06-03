#include-once

Global Const $REPORT_ENABLE = "bot.session.report.enable"
Global Const $ACCEPTED_OPPONENT = "bot.session.battle.accepted-opponent"
Global Const $REJECTED_OPPONENT = "bot.session.battle.rejected-opponent"
Global Const $ACTIONS_ON_ACCEPT = "bot.session.battle.actions-on-accept"
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
Global Const $RT_STATE = "bot.session.runtime.state"
Global Const $RT_OPPONENT_LOG_ENTRIES_COUNTER = "bot.session.runtime.opponent-log-entries-counter"
Global $SessionVariables = ObjCreate("Scripting.Dictionary")
Global $RuntimeActions = ObjCreate("Scripting.Dictionary")
Global $OpponentLogEntries = ObjCreate("Scripting.Dictionary")

; Static config from config file
$SessionVariables.Item($REPORT_ENABLE) = 1
$SessionVariables.Item($ACCEPTED_OPPONENT) = ""
$SessionVariables.Item($REJECTED_OPPONENT) = ""
$SessionVariables.Item($ACTIONS_ON_ACCEPT) = ""
$SessionVariables.Item($SPAWN_INITIAL_DIRECTION) = "Left"
$SessionVariables.Item($SPAWN_MIN) = 600
$SessionVariables.Item($SPAWN_MAX) = 1000

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

Func ProBot_LoadSessionVariables(Const $file)
	If Not FileExists($file) Then
		ConsoleWrite("[Variables] file not exist. File dir = " & $file & @CRLF)
		Return
	EndIf
	Local $sessionVars = IniReadSection($file, "SessionVariables")
	If @error Or $sessionVars[0][0] < 1 Then
		ConsoleWrite("[Variables] file is empty. File dir = " & $file & @CRLF)
		Return
	EndIf
	For $i = 1 To $sessionVars[0][0]
		Local $key = $sessionVars[$i][0]
		Local $newValue = $sessionVars[$i][1]
		Local $oldValue = $SessionVariables.Item($key)
		$SessionVariables.Item($key) = $newValue
		If $oldValue <> $newValue Then
			ConsoleWrite("[Variables] " & $key & " = " & $oldValue & "  ->  " & $newValue & @CRLF)
		Else
			ConsoleWrite("[Variables] " & $key & " = " & $newValue & @CRLF)
		EndIf
	Next
	ProBot_LoadActionOnAccept()
EndFunc

Func ProBot_LoadActionOnAccept()
	If $SessionVariables.Item($ACTIONS_ON_ACCEPT) = "" Then
		Return
	EndIf
	Local $Actions = StringSplit($SessionVariables.Item($ACTIONS_ON_ACCEPT), ".")
	If $Actions[0] < 1 Then
		Return
	EndIf
	$RuntimeActions.RemoveAll
	For $i = 1 To $Actions[0]
		Local $Pair = StringSplit($Actions[$i], "")
		If $Pair[0] <> 2 Then
			ConsoleWrite("[Variables] Unable to parse " & $Actions[$i] & ", Only allow 1 dot in action." & @CRLF)
			Exit
		EndIf
		If StringLen($Pair[1]) <> 1 Or Not StringInStr("PpFfIi", $Pair[1]) Then
			ConsoleWrite("[Variables] Unable to parse " & $Actions[$i] & ", Only allow pokemon (p), item(i), fight(f) case-insensitive." & @CRLF)
			Exit
		EndIf
		If Number($Pair[2]) < 1 Or Number($Pair[2]) > 4 Then
			ConsoleWrite("[Variables] Unable to parse " & $Actions[$i] & ", Only allow action value is number [1-4]." & @CRLF)
			Exit
		EndIf
		$RuntimeActions.Item($i & "-" & $Pair[1]) = $Pair[2]
	Next
EndFunc