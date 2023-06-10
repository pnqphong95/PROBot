#include-once
#include <Array.au3>
#include <Math.au3>
#include <AutoItConstants.au3>
#include "Storage\SessionVariable.au3"
#include "Storage\BotSetting.au3"
#include "Functions\Constant.au3"
#include "Functions\WinFunc.au3"
#include "Functions\Logger.au3"
#include "Functions\Reporter.au3"
#include "Functions\GameClientFunc.au3"
#include "RtBattleHandler.au3"

Func ProBot_DelegateActionHandler(Const $hwnd)
	Switch $SessionVariables.Item($RT_ACTION)
		Case $RT_ACTION_RUNAWAY
			ProBot_PressRunAwayButton($hwnd)
			$SessionVariables.Item($RT_ACTION) = ""
		Case $RT_ACTION_AUTO_LEVEL
			ProBot_HandleAutoLevel($hwnd)
			$SessionVariables.Item($RT_ACTION) = ""
	EndSwitch
EndFunc

Func ProBot_HandleAutoLevel(Const $hwnd)
	Local $nUsableParty = ProBot_GetFirstUsableParty($hwnd)
	Local $aUsableMoves = ProBot_CheckMoves($hwnd, $nUsableParty)
	Local $nFoundPokemonType = ProBot_LookupPokemonData($DataPokemonTypes, $SessionVariables.Item($RT_RECOGNISED_OPPONENT))
	Local $nEffectiveMove = Random(0, UBound($aUsableMoves) - 1, 1)
	If $nFoundPokemonType Then 
		Local $sType1 = $DataPokemonTypes[$nFoundPokemonType][3]
		Local $sType2 = $DataPokemonTypes[$nFoundPokemonType][4]
		ProBot_Log("Check move against " & $SessionVariables.Item($RT_RECOGNISED_OPPONENT) & ", type = " & $sType1 & " " & $sType2)
		$nEffectiveMove = ProBot_PickEffectiveMove($DataTypeChart, $aUsableMoves, $sType1, $sType2)
	Else
		ProBot_Log("Unable to check move, pick random move " & $aUsableMoves[$nEffectiveMove][0])
	EndIf
	ProBot_WaitActionReady($hwnd, 0.5)
	If Not $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Or Not $SessionVariables.Item($RT_IS_ACTIONABLE) Then
		ProBot_Notify("[Battle] PENDING, require manual action!!!")
		Exit
	EndIf
	While $aUsableMoves[$nEffectiveMove][1] > 0
		ProBot_PressFightButton($hwnd)
		ProBot_SendKey(ProBot_KeyBinding($aUsableMoves[$nEffectiveMove][2]))
		$aUsableMoves[$nEffectiveMove][1] = $aUsableMoves[$nEffectiveMove][1] - 1
		ProBot_Log("Used " & $aUsableMoves[$nEffectiveMove][0] & ", remaining point = " & $aUsableMoves[$nEffectiveMove][1])
		If $aUsableMoves[$nEffectiveMove][1] = 0 Then
			If $nFoundPokemonType Then 
				Local $sType1 = $DataPokemonTypes[$nFoundPokemonType][3]
				Local $sType2 = $DataPokemonTypes[$nFoundPokemonType][4]
				ProBot_Log("Recheck move against " & $SessionVariables.Item($RT_RECOGNISED_OPPONENT) & ", type = " & $sType1 & " " & $sType2)
				$nEffectiveMove = ProBot_PickEffectiveMove($DataTypeChart, $aUsableMoves, $sType1, $sType2)
			Else
				ProBot_Log("Unable to recheck move, pick random move " & $aUsableMoves[$nEffectiveMove][0])
			EndIf
		EndIf
		ProBot_WaitActionReady($hwnd, 2)
		If Not $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Then
			ExitLoop
		EndIf
		If Not $SessionVariables.Item($RT_IS_ACTIONABLE) Then
			ProBot_Notify("[Battle] PENDING, require manual action!!!")
			Exit
		EndIf
	WEnd
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

Func ProBot_NotifyBattleClosed(Const $hwnd)
	Local $doneOpponent = $SessionVariables.Item($RT_RECOGNISED_OPPONENT)
	Switch ($SessionVariables.Item($SESSION_MODE))
		Case "Hunting"
			Sleep(5000)
			ProBot_Notify("Caught 1 " & StringUpper($doneOpponent) & @CRLF, ProBot_CaptureCaughtPreview($hwnd))
		Case "Training"
		Case "Money"
	EndSwitch
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

Func ProBot_CheckMoves($hwnd, Const $partyNumber = 0)
	ProBot_TogglePokemonInfoDialog($hwnd, $partyNumber)
	Local $left = $Settings.Item($MOVE_LIST_INDICATOR_LEFT), $right = $Settings.Item($MOVE_LIST_INDICATOR_RIGHT)
	Local $top = $Settings.Item($MOVE_LIST_INDICATOR_TOP), $bottom = $Settings.Item($MOVE_LIST_INDICATOR_BOTTOM)
	Local $pointLeft = $Settings.Item($MOVE_POINT_INDICATOR_LEFT), $pointRight = $Settings.Item($MOVE_POINT_INDICATOR_RIGHT)
	Local $moveRawText = ProBot_ExtractText($hwnd, $left, $top, $right, $bottom, 3)
	Local $pointRawText = ProBot_ExtractText($hwnd, $pointLeft, $top, $pointRight, $bottom, 3)
	ProBot_TogglePokemonInfoDialog($hwnd, $partyNumber)
	Return ProBot_CreateUsableMoveArray($DataPokemonMoves, $moveRawText, $pointRawText)
EndFunc

Func ProBot_CaptureCaughtPreview($hwnd)
	Local $left = $Settings.Item($PREVIEW_INDICATOR_LEFT)
	Local $top = $Settings.Item($PREVIEW_INDICATOR_TOP)
	Local $right = $Settings.Item($PREVIEW_INDICATOR_RIGHT)
	Local $bottom = $Settings.Item($PREVIEW_INDICATOR_BOTTOM) 
	Return ProBot_MakeScreenshotArea($hwnd, $left, $top, $right, $bottom)
EndFunc

Func ProBot_PressFightButton(Const $hwnd)
	ProBot_Log("Press fight button.")
	_ProBot_PressActionButton($hwnd, $ACTION_KEY_1, 2)
EndFunc

Func ProBot_PressPokemonButton(Const $hwnd)
	_ProBot_PressActionButton($hwnd, $ACTION_KEY_2)
EndFunc

Func ProBot_PressItemButton(Const $hwnd)
	_ProBot_PressActionButton($hwnd, $ACTION_KEY_3)
EndFunc

Func ProBot_PressRunAwayButton(Const $hwnd)
	_ProBot_PressActionButton($hwnd, $ACTION_KEY_4, 4)
EndFunc

Func _ProBot_PressActionButton(Const $hwnd, Const $key, Const $sleep = 0)
	ProBot_WaitActionReady($hwnd, 1)
	If $SessionVariables.Item($RT_IS_ACTIONABLE) Then
		Send("{" & $Settings.Item($key) & " 1}")
		If Number($sleep) > 0 Then
			Sleep($sleep * 1000)
		EndIf
	EndIf
EndFunc

Func ProBot_TogglePokemonInfoDialog(Const $hwnd, Const $partyNumber = 0)
	Opt("MouseCoordMode", 2)
	ProBot_ActivateWindow($hwnd)
	MouseClick($MOUSE_CLICK_PRIMARY, $Settings.Item($FIRST_PARTY_INDICATOR_X), $Settings.Item($FIRST_PARTY_INDICATOR_Y) + $Settings.Item($FIRST_PARTY_INDICATOR_SPACE) * $partyNumber, 2)
	Sleep(800)
EndFunc