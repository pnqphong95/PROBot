#include-once
#include "Storage\SessionFunc.au3"
#include "Functions\GameStateFunc.au3"

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
	EndIf
EndFunc

Func ProBot_EvaluateGameState(Const $hwnd)
	If $SessionVariables.Item($RT_ON_BATTLE_START) Then
		If ProBot_IsOpponentQualified($SessionVariables.Item($RT_RECOGNISED_OPPONENT)) Then
			ConsoleWrite("[Battle, Accepted] " & $SessionVariables.Item($RT_RECOGNISED_OPPONENT) & " attacks!" & @CRLF)
			$SessionVariables.Item($RT_ACTION) = "AutoAction"
		Else
			ConsoleWrite("[Battle, Rejected] " & $SessionVariables.Item($RT_RECOGNISED_OPPONENT) & " attacks!" & @CRLF)
			$SessionVariables.Item($RT_ACTION) = "RunAway"
		EndIf
	EndIf
EndFunc

Func ProBot_DelegateHandler(Const $hwnd)
	Switch $SessionVariables.Item($RT_ACTION)
		Case "RunAway"
			ProBot_HandleRunAway($hwnd)
		Case "AutoAction"
			
	EndSwitch
EndFunc

Func ProBot_HandleRunAway(Const $hwnd)
	ProBot_WaitActionReady($hwnd, 1)
	If $SessionVariables.Item($RT_IS_ACTIONABLE) Then
		Send("{V 1}")
	EndIf
EndFunc

Func ProBot_WaitActionReady(Const $hwnd, Const $interval = 5, Const $waitSec = 60)
	Local $elapsed = 0, $timer = TimerInit()
	While 1
		Sleep($interval * 1000)
		$SessionVariables.Item($RT_ON_BATTLE_VISIBLE) = False
		$SessionVariables.Item($RT_IS_ACTIONABLE) = False
		If ProBot_IsBattleDialogVisible($hwnd) Then
			$SessionVariables.Item($RT_ON_BATTLE_VISIBLE) = True
			If ProBot_IsBattleActionReady($hwnd) Then
				$SessionVariables.Item($RT_IS_ACTIONABLE) = True
				ExitLoop
			EndIf
		EndIf
		$elapsed = TimerDiff($timer)
		If $elapsed > $waitSec * 1000 Then
			ExitLoop
		EndIf
	WEnd
EndFunc