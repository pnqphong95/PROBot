#include-once
#include <Date.au3>
#include "Storage\SessionVariable.au3"
#include "Storage\BotSetting.au3"
#include "Functions\Constant.au3"
#include "Functions\GameClientFunc.au3"
#include "Functions\Logger.au3"
#include "Functions\Reporter.au3"
#include "Functions\WinFunc.au3"

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

Func ProBot_WaitActionReady(Const $hwnd, Const $interval = 5, Const $waitSec = 60)
	Local $elapsed = 0, $timer = TimerInit()
	While 1
		Sleep($interval * 1000)
		$SessionVariables.Item($RT_ON_BATTLE_VISIBLE) = False
		$SessionVariables.Item($RT_IS_ACTIONABLE) = False
		If Not ProBot_IsBattleDialogVisible($hwnd) Then
			ExitLoop
		EndIf
		$SessionVariables.Item($RT_ON_BATTLE_VISIBLE) = True
		If ProBot_IsBattleActionReady($hwnd) Then
			$SessionVariables.Item($RT_IS_ACTIONABLE) = True
			ExitLoop
		EndIf
		$elapsed = TimerDiff($timer)
		If $elapsed > $waitSec * 1000 Then
			ExitLoop
		EndIf
	WEnd
EndFunc

Func ProBot_IsBattleDialogVisible($hwnd)
	Local $left = $Settings.Item($BATTLE_INDICATOR_LEFT)
	Local $top = $Settings.Item($BATTLE_INDICATOR_TOP)
	Local $right = $Settings.Item($BATTLE_INDICATOR_RIGHT)
	Local $bottom = $Settings.Item($BATTLE_INDICATOR_BOTTOM)
	Local $color = $Settings.Item($BATTLE_INDICATOR_COLOR_HEX)
	Local $visible = ProBot_IsPixelColorDisplayed($hwnd, $left, $top, $right, $bottom, $color)
	Return $visible
EndFunc

Func ProBot_IsBattleActionReady($hwnd)
	Local $left = $Settings.Item($ACTION_INDICATOR_LEFT)
	Local $top = $Settings.Item($ACTION_INDICATOR_TOP)
	Local $right = $Settings.Item($ACTION_INDICATOR_RIGHT)
	Local $bottom = $Settings.Item($ACTION_INDICATOR_BOTTOM)
	Local $color = $Settings.Item($ACTION_INDICATOR_COLOR_HEX)
	Return ProBot_IsPixelColorDisplayed($hwnd, $left, $top, $right, $bottom, $color, 2)
EndFunc

Func ProBot_CaptureOpponent($hwnd)
	Local $left = $Settings.Item($TITLE_INDICATOR_LEFT)
	Local $top = $Settings.Item($TITLE_INDICATOR_TOP)
	Local $right = $Settings.Item($TITLE_INDICATOR_RIGHT)
	Local $bottom = $Settings.Item($TITLE_INDICATOR_BOTTOM)
	Return ProBot_ExtractText($hwnd, $left, $top, $right, $bottom)
EndFunc

Func ProBot_CaptureLatestLog($hwnd)
	Local $left = $Settings.Item($LOG_INDICATOR_LEFT)
	Local $top = $Settings.Item($LOG_INDICATOR_TOP)
	Local $right = $Settings.Item($LOG_INDICATOR_RIGHT)
	Local $bottom = $Settings.Item($LOG_INDICATOR_BOTTOM)
	Return ProBot_ExtractText($hwnd, $left, $top, $right, $bottom)
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
	ProBot_Notify($message, ProBot_MakeScreenshot($hwnd))
	$SessionVariables.Item($RT_OPPONENT_LOG_ENTRIES_COUNTER) = 0
	$OpponentLogEntries.RemoveAll
EndFunc