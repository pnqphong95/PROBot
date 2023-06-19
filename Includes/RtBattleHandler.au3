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
			$SessionVariables.Item($RT_LAST_BATTLE_END_TIME) = TimerInit()
			ProBot_ReportOpponentLogEntries($hwnd)
		EndIf
	EndIf
    If $SessionVariables.Item($RT_ON_BATTLE_START) Then
		; On battle start event, capture & store battle info
		$SessionVariables.Item($RT_RAW_TEXT) = ""
		$SessionVariables.Item($RT_RECOGNISED_OPPONENT) = ""
		Local Const $sRawText = ProBot_CaptureOpponent($hwnd)
		$SessionVariables.Item($RT_RAW_TEXT) = $sRawText
		Local Const $sOpponent = ProBot_PokemonExtractName($sRawText)
		$SessionVariables.Item($RT_RECOGNISED_OPPONENT) = $sOpponent
		ProBot_RecordOpponentLogEntry($sOpponent)
	EndIf
EndFunc

Func ProBot_EvaluateBattleState(Const $hwnd)
	If $SessionVariables.Item($RT_ON_BATTLE_START) Then
		$SessionVariables.Item($RT_ACTION) = $RT_ACTION_RUNAWAY
		Local $sOpponent = $SessionVariables.Item($RT_RECOGNISED_OPPONENT)
		Local $sMode = $SessionVariables.Item($SESSION_MODE)
		Local $sCaughtList = $SessionVariables.Item($AUTO_CAUGHT_LIST)
		Local $sFightList = $SessionVariables.Item($AUTO_FIGHT_LIST)
		Switch ($sMode)
			Case $RT_ACTION_AUTO_HUNT
				If ProBot_TextAccepted($sOpponent, $sCaughtList, True) Then
					$SessionVariables.Item($RT_ACTION) = $RT_ACTION_AUTO_HUNT
				EndIf
			Case $RT_ACTION_AUTO_LEVEL
				If ProBot_TextAccepted($sOpponent, $sFightList, True) Or ProBot_TextAccepted($sOpponent, $sCaughtList) Then
					$SessionVariables.Item($RT_ACTION) = $RT_ACTION_AUTO_LEVEL
				EndIf
			Case $RT_ACTION_AUTO_EV_TRAIN
				If ProBot_TextAccepted($sOpponent, $sFightList, True) Or ProBot_TextAccepted($sOpponent, $sCaughtList) Then
					$SessionVariables.Item($RT_ACTION) = $RT_ACTION_AUTO_EV_TRAIN
				EndIf
			Case Else
				ProBot_Log("Unsupported session mode = " & $sMode)
		EndSwitch
	EndIf
EndFunc

Func ProBot_RecordOpponentLogEntry(Const $opponentName)
	$SessionVariables.Item($RT_OPPONENT_LOG_ENTRIES_COUNTER) = Number($SessionVariables.Item($RT_OPPONENT_LOG_ENTRIES_COUNTER)) + 1
	If $OpponentLogEntries.Exists($opponentName) Then
		$OpponentLogEntries.Item($opponentName) = Number($OpponentLogEntries.Item($opponentName)) + 1 
	Else
		$OpponentLogEntries.Item($opponentName) = 1
	EndIf
EndFunc

Func ProBot_ReportOpponentLogEntries(Const $hwnd)
	Local $maxThreshold = $SessionVariables.Item($RT_OPPONENT_LOG_ENTRIES_THRESHOLD) + 5
	Local $minThreshold = $SessionVariables.Item($RT_OPPONENT_LOG_ENTRIES_THRESHOLD) - 5
	If $SessionVariables.Item($RT_OPPONENT_LOG_ENTRIES_COUNTER) < Random($minThreshold, $maxThreshold, 1) Then Return
	Local $message = "Encounter " & $SessionVariables.Item($RT_OPPONENT_LOG_ENTRIES_COUNTER) & " wild pokemons:" & @CRLF
	For $opponentName In $OpponentLogEntries
		Local $replacedStr = StringReplace($opponentName & " (" & $OpponentLogEntries.Item($opponentName) & ")", @LF, "")
		$message = $message & $replacedStr & @CRLF
	Next
	ProBot_Notify($message, True, ProBot_MakeScreenshot($hwnd))
	$SessionVariables.Item($RT_OPPONENT_LOG_ENTRIES_COUNTER) = 0
	$OpponentLogEntries.RemoveAll
EndFunc