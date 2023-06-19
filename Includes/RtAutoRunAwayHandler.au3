#include-once
#include "HandlerHelper.au3"
#include "Storage\SessionVariable.au3"
#include "Functions\Constant.au3"
#include "Functions\GameClientFunc.au3"
#include "Functions\Logger.au3"
#include "Functions\Reporter.au3"

Func ProBot_HandleAutoRunAway(Const $hwnd)
	If $SessionVariables.Item($RT_ERROR_CODE) Then
		; Special case of run away
		_HandleAutoRunAwayWithError($hwnd)
		ProBot_svSetNextAction("")
		Return
	EndIf
		
	ProBot_WaitActionReady($hwnd, 0.5)
	If Not $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Then
		; When battle suddenly close
		ProBot_svSetNextAction("")
		Return
	EndIf

	If Not $SessionVariables.Item($RT_IS_ACTIONABLE) Then
		ProBot_Log("Battle not ready to press run away, please take action.")
		ProBot_Notify("Battle not ready to press run away, please take action.", True)
		Exit
	EndIf

	; Shiny check before run away
	; Check pokemon if not owned
	ProBot_SendKey($Settings.Item($ACTION_KEY_4))
	ProBot_svSetNextAction("")
	Return
EndFunc

Func _HandleAutoRunAwayWithError(Const $hwnd)
	Switch ($SessionVariables.Item($RT_ERROR_CODE))
		Case $RT_ERROR_CODE_LEADING_NO_USABLE_MOVE
			_TryRunAwayNoUsableMove($hwnd)
		Case $RT_ERROR_CODE_FROZEN_BATTLE
			; Handle pokemon get faint while doing battle
			_TryRunAwayFrozenBattle($hwnd)
		Case $RT_ERROR_CODE_MANUAL_REQUIRED
			Exit
	EndSwitch
EndFunc

Func _TryRunAwayNoUsableMove(Const $hwnd)
	ProBot_WaitActionReady($hwnd, 1, 30)
	$SessionVariables.Item($RT_OUT_BATTLE_ACTION) = $RT_OUT_BATTLE_SWAP_USABLE_LEAD
	If Not $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Then
		ProBot_svSetNextAction("")
		Return
	EndIf

	If Not $SessionVariables.Item($RT_IS_ACTIONABLE) Then
		Exit
	EndIf

	; Still in battle, try to run away
	ProBot_SendKey($Settings.Item($ACTION_KEY_4))
	ProBot_svSetNextAction("")
	Return
EndFunc

Func _TryRunAwayFrozenBattle(Const $hwnd)
	Local $nFirstAliveParty
	Local $dSwitchedParties = ObjCreate("Scripting.Dictionary")
	While 1
		; Try to switch on an alive party
		$nFirstAliveParty = Number(ProBot_GetFirstAliveParty($hwnd))
		If $nFirstAliveParty < 0 Or $nFirstAliveParty > 5 Then
			ProBot_Log("No alive pokemon in team, please take action")
			ProBot_Notify("No alive pokemon in team, please take action", True)
			Exit
		EndIf

		If $dSwitchedParties.Exists($nFirstAliveParty) Then
			ProBot_Log(StringFormat("Alive pokemon %d has been switched, please take action", $nFirstAliveParty))
			ProBot_Notify(StringFormat("Alive pokemon %d has been switched, please take action", $nFirstAliveParty), True)
			Exit
		EndIf

		ProBot_SendKey(ProBot_KeyBinding($nFirstAliveParty + 1))
		ProBot_WaitActionReady($hwnd)
		$dSwitchedParties.Item($nFirstAliveParty) = True

		If Not $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Then
			; When battle suddenly close
			ProBot_Log(StringFormat("Battle suddenly close after switch alive pokemon %d.", $nFirstAliveParty))
			ProBot_svSetNextAction("")
			Return
		EndIf

		If Not $SessionVariables.Item($RT_IS_ACTIONABLE) Then
			ProBot_Log(StringFormat("Battle not ready after switch alive pokemon %d, please take action.", $nFirstAliveParty))
			ProBot_Notify(StringFormat("Battle not ready after switch alive pokemon %d, please take action.", $nFirstAliveParty), True)
			Exit
		EndIf

		ProBot_SendKey($Settings.Item($ACTION_KEY_4))
		ProBot_WaitActionReady($hwnd)
		
			
		If Not $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Then
			; When battle suddenly close
			ProBot_Log("Battle close after press run away.")
			ProBot_svSetNextAction("")
			Return
		EndIf

		If Not $SessionVariables.Item($RT_IS_ACTIONABLE) Then
			ProBot_Log("Battle not ready after press run away, please take action.")
			ProBot_Notify("Battle not ready after press run away, please take action.", True)
			Exit
		EndIf
	WEnd
EndFunc