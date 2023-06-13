#include-once
#include "HandlerHelper.au3"
#include "Functions\Logger.au3"
#include "Functions\Reporter.au3"

Func ProBot_CaptureGameState(Const $hwnd)
	$SessionVariables.Item($RT_ON_BATTLE_START) = False
	$SessionVariables.Item($RT_ON_BATTLE_STOP) = False
    If ProBot_IsBattleDialogVisible($hwnd) Then
        If Not $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Then
			$SessionVariables.Item($RT_ON_BATTLE_VISIBLE) = True
			$SessionVariables.Item($RT_ON_BATTLE_START) = True
		EndIf
	Else
		If $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Then
			$SessionVariables.Item($RT_ON_BATTLE_VISIBLE) = False
			$SessionVariables.Item($RT_ON_BATTLE_STOP) = True
			ProBot_ReportOpponentLogEntries($hwnd)
		EndIf
	EndIf
    If $SessionVariables.Item($RT_ON_BATTLE_START) Then
		; On battle start event, capture & store battle info
		$SessionVariables.Item($RT_RAW_TEXT) = ""
		$SessionVariables.Item($RT_RECOGNISED_OPPONENT) = ""
		Local Const $opponent = ProBot_CaptureOpponent($hwnd)
		$SessionVariables.Item($RT_RAW_TEXT) = $opponent
		$SessionVariables.Item($RT_RECOGNISED_OPPONENT) = ProBot_PokemonExtractName($opponent)
		ProBot_RecordOpponentLogEntry($opponent)
	EndIf
EndFunc

Func ProBot_EvaluateGameState(Const $hwnd)
	If $SessionVariables.Item($RT_ON_BATTLE_START) Then
		ProBot_Log("Battle start..")
		$SessionVariables.Item($RT_ACTION) = $RT_ACTION_RUNAWAY
		Local $detected = $SessionVariables.Item($RT_RECOGNISED_OPPONENT)
		Switch ($SessionVariables.Item($SESSION_MODE))
			Case $RT_ACTION_AUTO_HUNT
				If ProBot_TextAccepted($detected, $SessionVariables.Item($AUTO_CAUGHT_LIST)) Then
					ProBot_Log("Trying to catch " & $detected)
					$SessionVariables.Item($RT_ACTION) = $RT_ACTION_AUTO_HUNT
				EndIf
			Case $RT_ACTION_AUTO_LEVEL
				If ProBot_TextAccepted($detected, $SessionVariables.Item($AUTO_FIGHT_LIST)) Then
					$SessionVariables.Item($RT_ACTION) = $RT_ACTION_AUTO_LEVEL
				EndIf
			Case $RT_ACTION_AUTO_EV_TRAIN
				If ProBot_TextAccepted($detected, $SessionVariables.Item($AUTO_FIGHT_LIST)) Then
					ProBot_Log("Trying to ev-fight " & $detected)
					$SessionVariables.Item($RT_ACTION) = $RT_ACTION_AUTO_EV_TRAIN
				EndIf
			Case Else
				ProBot_Log("Unsupported session mode = " & $SessionVariables.Item($SESSION_MODE))
		EndSwitch
	EndIf
EndFunc

Func ProBot_RecordOpponentLogEntry(Const $opponentRawText)
	$SessionVariables.Item($RT_OPPONENT_LOG_ENTRIES_COUNTER) = Number($SessionVariables.Item($RT_OPPONENT_LOG_ENTRIES_COUNTER)) + 1
	If $OpponentLogEntries.Exists($opponentRawText) Then
		$OpponentLogEntries.Item($opponentRawText) = Number($OpponentLogEntries.Item($opponentRawText)) + 1 
	Else
		$OpponentLogEntries.Item($opponentRawText) = 1
	EndIf
EndFunc

Func ProBot_ReportOpponentLogEntries(Const $hwnd)
	Local $maxThreshold = $SessionVariables.Item($RT_OPPONENT_LOG_ENTRIES_THRESHOLD) + 5
	Local $minThreshold = $SessionVariables.Item($RT_OPPONENT_LOG_ENTRIES_THRESHOLD) - 5
	If $SessionVariables.Item($RT_OPPONENT_LOG_ENTRIES_COUNTER) < Random($minThreshold, $maxThreshold, 1) Then Return
	Local $message = "[ENCOUNTER] " & $SessionVariables.Item($RT_OPPONENT_LOG_ENTRIES_COUNTER) & " wild pokemons:" & @CRLF
	For $opponentName In $OpponentLogEntries
		Local $replacedStr = StringReplace($OpponentLogEntries.Item($opponentName) & " x " & $opponentName, @LF, "")
		$message = $message & $replacedStr & @CRLF
	Next
	ProBot_Notify($message, True, ProBot_MakeScreenshot($hwnd))
	$SessionVariables.Item($RT_OPPONENT_LOG_ENTRIES_COUNTER) = 0
	$OpponentLogEntries.RemoveAll
EndFunc