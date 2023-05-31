#include-once
#include "Storage\SessionVariable.au3"
#include "Storage\BotSetting.au3"
#include "Functions\Constant.au3"
#include "Functions\GameClientFunc.au3"
#include "Functions\NotificationFunc.au3"
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
		EndIf
	EndIf
    If $SessionVariables.Item($RT_ON_BATTLE_START) Then
		; On battle start event, capture & store battle info
		$SessionVariables.Item($RT_RAW_TEXT) = ""
		$SessionVariables.Item($RT_RECOGNISED_OPPONENT) = ""
		Local Const $opponent = ProBot_CaptureOpponent($hwnd)
		$SessionVariables.Item($RT_RAW_TEXT) = $opponent
		$SessionVariables.Item($RT_RECOGNISED_OPPONENT) = ProBot_OpponentExtractText($opponent)
		$SessionVariables.Item($RT_BATTLE_COUNTER) = Number($SessionVariables.Item($RT_BATTLE_COUNTER)) + 1
		If $BattleHolder.Exists($opponent) Then
			$BattleHolder.Item($opponent) = Number($BattleHolder.Item($opponent)) + 1 
		Else
			$BattleHolder.Item($opponent) = 1
		EndIf
	EndIf
EndFunc

Func ProBot_EvaluateGameState(Const $hwnd)
	If $SessionVariables.Item($RT_ON_BATTLE_START) Then
		$SessionVariables.Item($RT_ACTION) = $RT_ACTION_RUNAWAY
		Local $detected = $SessionVariables.Item($RT_RECOGNISED_OPPONENT)
		ConsoleWrite("[Battle] " & $detected & " attacks.. ")
		If ProBot_IsOpponentQualified($detected, $SessionVariables.Item($ACCEPTED_OPPONENT), $SessionVariables.Item($REJECTED_OPPONENT)) Then
			ConsoleWrite("start auto-action!" & @CRLF)
			$SessionVariables.Item($RT_ACTION) = $RT_ACTION_AUTO		
		EndIf
		If $SessionVariables.Item($RT_ACTION) = $RT_ACTION_RUNAWAY Then
			ConsoleWrite("run away!" & @CRLF)
		EndIf
		If $SessionVariables.Item($REPORT_ENABLE) And $SessionVariables.Item($RT_BATTLE_COUNTER) > Random(20, 40, 1) Then
			Local $message = "Found more " & $SessionVariables.Item($RT_BATTLE_COUNTER) & " wild pokemons:" & @CRLF & @CRLF
			For $key In $BattleHolder
				$message = $message & " " & $BattleHolder.Item($key) & " x " & $key & @CRLF
			Next
			$SessionVariables.Item($RT_BATTLE_COUNTER) = 0
			$BattleHolder.RemoveAll
			ProBot_Notify($Settings.Item($REPORT_BOT_URL), $Settings.Item($REPORT_CHAT_ID), $message)
		EndIf
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