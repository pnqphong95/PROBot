#include-once
#include "HandlerHelper.au3"
#include "Storage\SessionVariable.au3"
#include "Functions\GameClientFunc.au3"
#include "Functions\Logger.au3"
#include "Functions\Reporter.au3"

Func ProBot_HandleAutoRunAway(Const $hwnd)
	Switch ($SessionVariables.Item($RT_ERROR_CODE))
		Case $RT_ERROR_CODE_LEADING_NO_USABLE_MOVE
			ProBot_Notify("WARNING! Leading pokemon have no usable move, closing bot..", True)
			Exit
		Case $RT_ERROR_CODE_FROZEN_BATTLE
			; Try to switch on an usable party
			Local $nUsableParty, $nLastUsableParty
			While 1
				$nUsableParty = ProBot_GetFirstUsableParty($hwnd)
				If Not $nUsableParty Or $nUsableParty < 0 Or $nUsableParty > 5 Then
					ProBot_Notify("WARNING! Don't have usable pokemon to switch on.")
					ExitLoop
				EndIf

				If $nUsableParty = $nLastUsableParty Then
					ProBot_Notify("WARNING! Unable to recover from frozen battle, closing bot..", True)
					Exit
				EndIf

				$nLastUsableParty = $nUsableParty
				ProBot_SendKey(ProBot_KeyBinding($nUsableParty + 1))
				ProBot_WaitActionReady($hwnd)
				ProBot_Log("Switched on usable pokemon " & $nUsableParty + 1)
				If Not $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Then
					ProBot_svSetNextAction("")
					Return
				EndIf

				If $SessionVariables.Item($RT_IS_ACTIONABLE) Then
					ProBot_Log("Battle recovered from frozen, try to run away..")
					ProBot_SendKey($Settings.Item($ACTION_KEY_4))
					ProBot_WaitActionReady($hwnd)
					If Not $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Then
						ProBot_Log("Run away from frozen battle..")
						ProBot_svSetNextAction("")
						Return
					EndIf
				EndIf
			WEnd
	EndSwitch

	If Not $SessionVariables.Item($RT_ERROR_CODE) Then
		; Check battle ready
		ProBot_WaitActionReady($hwnd)
		If Not $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Or Not $SessionVariables.Item($RT_IS_ACTIONABLE) Then
			ProBot_Notify("WARNING! Unable to auto run away, closing bot..", True)
			Exit
		EndIf

		; Shiny check before run away
		; Check pokemon if not owned
		ProBot_SendKey($Settings.Item($ACTION_KEY_4))
	EndIf
	

	ProBot_svSetNextAction("")
	Return
EndFunc