#include-once
#include "Storage\SessionVariable.au3"
#include "Storage\BotSetting.au3"
#include "Functions\Constant.au3"
#include "Functions\NotificationFunc.au3"
#include "RtBattleHandler.au3"

Func ProBot_DelegateActionHandler(Const $hwnd)
	Switch $SessionVariables.Item($RT_ACTION)
		Case $RT_ACTION_RUNAWAY
			ProBot_HandleRunAway($hwnd)
		Case $RT_ACTION_AUTO
			ProBot_HandleAuto($hwnd)
		Case $RT_ACTION_HOLD_ON
			Sleep(15000)
	EndSwitch
EndFunc

Func ProBot_HandleRunAway(Const $hwnd)
	ProBot_WaitActionReady($hwnd, 1)
	If $SessionVariables.Item($RT_IS_ACTIONABLE) Then
		Send("{" & $Settings.Item($ACTION_KEY_4) & " 1}")
		Sleep(3000)
	EndIf
	$SessionVariables.Item($RT_ACTION) = ""
EndFunc

Func ProBot_HandleAuto(Const $hwnd)
	ProBot_WaitActionReady($hwnd, 1)
	If Not $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Or Not $SessionVariables.Item($RT_IS_ACTIONABLE) Then
		$SessionVariables.Item($RT_ACTION) = $RT_ACTION_HOLD_ON
		Return
	EndIf
	For $key In $RuntimeActions
		Local $ActionPair = StringSplit($key, "-")
		Local $ActionNo = $ActionPair[1]
		Local $Type = ProBot_ActionTypeBinding($ActionPair[2])
		Local $Selection = ProBot_KeyBinding(Number($RuntimeActions.Item($key)))
		ProBot_SendKeys($Type, $Selection)
		ConsoleWrite("[Battle] ..")
		ProBot_WaitActionReady($hwnd, 1)
		ConsoleWrite(".completed!" & @CRLF)
		If Not $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Then
			$SessionVariables.Item($RT_ACTION) = ""
			If $SessionVariables.Item($REPORT_ENABLE) = 1 Then
				Local $message = "Gotcha! New caught " & $SessionVariables.Item($RT_RECOGNISED_OPPONENT)
				ProBot_Notify($Settings.Item($REPORT_BOT_URL), $Settings.Item($REPORT_CHAT_ID), $message)
			EndIf
			Return
		EndIf
		If Not $SessionVariables.Item($RT_IS_ACTIONABLE) Then
			ConsoleWrite("[Battle] Looks like game client is crash, hold on..")
			$SessionVariables.Item($RT_ACTION) = $RT_ACTION_HOLD_ON
			Return
		EndIf
	Next
EndFunc

Func ProBot_KeyBinding(Const $number)
	Switch (Number($number))
		Case 1
			Return $Settings.Item($ACTION_KEY_1)
		Case 2
			Return $Settings.Item($ACTION_KEY_2)
		Case 3
			Return $Settings.Item($ACTION_KEY_3)
		Case 4
			Return $Settings.Item($ACTION_KEY_4)
		Case Else
			Return ""
	EndSwitch
EndFunc

Func ProBot_ActionTypeBinding(Const $type)
	Switch (StringLower($type))
		Case $RT_ACTION_KEY_FIGHT
			Return $Settings.Item($ACTION_KEY_1)
		Case $RT_ACTION_KEY_POKEMON
			Return $Settings.Item($ACTION_KEY_2)
		Case $RT_ACTION_KEY_ITEM
			Return $Settings.Item($ACTION_KEY_3)
		Case Else
			Return ""
	EndSwitch
EndFunc