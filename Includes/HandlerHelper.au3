#include-once
#include <AutoItConstants.au3>
#include "Storage\BotSetting.au3"
#include "Storage\SessionVariable.au3"
#include "Functions\Constant.au3"
#include "Functions\WinFunc.au3"
#include "Functions\GameClientFunc.au3"

Func ProBot_TogglePokemonInfoDialog(Const $hwnd, Const $partyNumber = 0)
	ProBot_MouseClickInGame($hwnd, $Settings.Item($FIRST_PARTY_INDICATOR_X), _
		$Settings.Item($FIRST_PARTY_INDICATOR_Y) + $Settings.Item($FIRST_PARTY_INDICATOR_SPACE) * $partyNumber)
	Sleep(800)
EndFunc

Func ProBot_MouseClickInGame(Const $hwnd, Const $x, Const $y, Const $clicks = 1)
	Opt("MouseCoordMode", 2)
	Opt("MouseClickDownDelay", 1000)
	ProBot_ActivateWindow($hwnd)
	MouseClick($MOUSE_CLICK_PRIMARY, $x, $y, $clicks)
EndFunc

Func ProBot_PressFightButton(Const $moveKey)
	ProBot_SendKey($Settings.Item($ACTION_KEY_1), $moveKey)
EndFunc

Func ProBot_CaptureCaughtPreview($hwnd)
	Local $left = $Settings.Item($PREVIEW_INDICATOR_LEFT)
	Local $top = $Settings.Item($PREVIEW_INDICATOR_TOP)
	Local $right = $Settings.Item($PREVIEW_INDICATOR_RIGHT)
	Local $bottom = $Settings.Item($PREVIEW_INDICATOR_BOTTOM) 
	Return ProBot_MakeScreenshotArea($hwnd, $left, $top, $right, $bottom)
EndFunc

Func ProBot_GetFirstUsableParty(Const $hwnd)
	For $i = 0 To 5 Step +1
		Local $x = $Settings.Item($FIRST_PARTY_INDICATOR_X)
		Local $y = $Settings.Item($FIRST_PARTY_INDICATOR_Y)
		Local $space = $Settings.Item($FIRST_PARTY_INDICATOR_SPACE)
		Local $color = $Settings.Item($FIRST_PARTY_COLOR)
		If ProBot_IsPixelColorDisplayed($hwnd, $x, $y + $space * $i, $x, $y + $space * $i, $color, 2) Then
			Return $i
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
		Case 5
			Return $Settings.Item($ACTION_KEY_3)
		Case 6
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

Func ProBot_CloseEvolveDialogIfAppeared($hwnd)
	Local $evolveDialogText = ProBot_ExtractText($hwnd, 620, 700, 1000, 820)
	If $evolveDialogText And StringInStr($evolveDialogText, "evolve") > 0 Then
		; Click no evolve
		ProBot_MouseClickInGame($hwnd, 555, 565)
	EndIf
EndFunc

