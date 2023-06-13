#include-once
#include "HandlerHelper.au3"
#include "Functions\Reporter.au3"

Func ProBot_HandleAutoRunAway(Const $hwnd)
	Switch ($SessionVariables.Item($RT_ERROR_CODE))
		Case $RT_ERROR_CODE_LEADING_NO_USABLE_MOVE
			ProBot_Notify("WARNING! Leading pokemon have no usable move, closing bot..", True)
			Exit
		Case $RT_ERROR_CODE_FROZEN_BATTLE
			ProBot_Notify("WARNING! Unable to auto perform action, closing bot..", True)
			Exit
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
	$SessionVariables.Item($RT_ERROR_CODE) = ""
	$SessionVariables.Item($RT_ACTION) = ""
	Return
EndFunc