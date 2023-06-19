#include-once
#include <AutoItConstants.au3>
#include "Storage\BotSetting.au3"
#include "Storage\SessionVariable.au3"
#include "Functions\Constant.au3"
#include "Functions\WinFunc.au3"
#include "Functions\GameClientFunc.au3"
#include "Functions\Reporter.au3"

Func ProBot_MouseClickInGame(Const $hwnd, Const $x, Const $y, Const $clicks = 1)
	Opt("MouseCoordMode", 2)
	Opt("MouseClickDownDelay", 1000)
	ProBot_ActivateWindow($hwnd)
	MouseClick($MOUSE_CLICK_PRIMARY, $x, $y, $clicks)
EndFunc

Func ProBot_CaptureCaughtPreview($hwnd)
	Local $left = $Settings.Item($PREVIEW_INDICATOR_LEFT)
	Local $top = $Settings.Item($PREVIEW_INDICATOR_TOP)
	Local $right = $Settings.Item($PREVIEW_INDICATOR_RIGHT)
	Local $bottom = $Settings.Item($PREVIEW_INDICATOR_BOTTOM) 
	Return ProBot_MakeScreenshotArea($hwnd, $left, $top, $right, $bottom)
EndFunc

Func ProBot_CloseEvolveDialogIfAppeared($hwnd)
	Local $evolveDialogText = ProBot_ExtractText($hwnd, 620, 700, 1000, 820)
	If $evolveDialogText And StringInStr($evolveDialogText, "evolve") > 0 Then
		; Click no evolve
		ProBot_MouseClickInGame($hwnd, 555, 565)
	EndIf
EndFunc

; Battle functions
Func ProBot_IsHighHp(Const $hwnd)
	Local $x = $Settings.Item($OPPONENT_HEALTH_INDICATOR_X)
	Local $y = $Settings.Item($OPPONENT_HEALTH_INDICATOR_Y)
	Local $color = $Settings.Item($OPPONENT_HEALTH_COLOR)
	Return ProBot_IsPixelColorDisplayed($hwnd, $x, $y, $x, $y, $color, 2)
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

Func ProBot_PressFightButton(Const $moveKey)
	ProBot_SendKey($Settings.Item($ACTION_KEY_1), $moveKey)
EndFunc

Func ProBot_PressPokemonButton(Const $pokemonKey)
	ProBot_SendKey($Settings.Item($ACTION_KEY_2), $pokemonKey)
EndFunc

Func ProBot_PressItemButton(Const $itemKey)
	ProBot_SendKey($Settings.Item($ACTION_KEY_3), $itemKey)
EndFunc

; Manage usable pokemon functions
Func ProBot_PromoteUsablePokemon(Const $hwnd)
	Local $nUsableParty = ProBot_GetFirstUsableParty($hwnd)
	ProBot_Log(StringFormat("First usable party is %d", $nUsableParty))
	If $nUsableParty < 0 Or $nUsableParty > 5 Then
		ProBot_Log("No more usable slot in the team.")
		Sleep(5000)
		ProBot_Notify("No more usable slot in the team.", True, ProBot_MakeScreenshot($hwnd))
		Exit
	EndIf
	If $nUsableParty > 0 Then
		_internal_SwapPartySlot($hwnd, 0, $nUsableParty)
		$PartyData.RemoveAll
		Local $sLog = StringFormat("Successful to swapped first slot with slot %d.", $nUsableParty + 1)
		ProBot_Log($sLog)
		ProBot_Notify($sLog, True)
	EndIf
	Return
EndFunc

Func ProBot_GetFirstAliveParty(Const $hwnd)
	For $i = 0 To 5
		If ProBot_IsAliveParty($hwnd, $i) Then Return $i
	Next
	Return -1
EndFunc

Func ProBot_IsAliveParty(Const $hwnd, Const $partyNumber = 0)
	Local $x = $Settings.Item($FIRST_PARTY_INDICATOR_X)
	Local $y = $Settings.Item($FIRST_PARTY_INDICATOR_Y)
	Local $space = $Settings.Item($FIRST_PARTY_INDICATOR_SPACE)
	Local $color = $Settings.Item($FIRST_PARTY_COLOR)
	Return ProBot_IsPixelColorDisplayed($hwnd, $x, $y + $space * $partyNumber, $x, $y + $space * $partyNumber, $color, 2)
EndFunc

Func ProBot_GetFirstUsableParty(Const $hwnd)
	For $i = 0 To 5
		If ProBot_IsAliveParty($hwnd, $i) Then
			ProBot_GetAndCacheUsableMoves($hwnd, $i)
			If ProBot_svHasUsableMoves($i) Then Return $i
		EndIf
	Next
	Return -1
EndFunc

Func ProBot_GetAndCacheUsableMoves(Const $hwnd, Const $partyNumber = 0)
	Local $aUsableMoves
	If Not $PartyData.Exists($partyNumber & ".aUsableMoves") Then
		$aUsableMoves = _internal_CheckMoves($hwnd, $partyNumber)
	Else
		$aUsableMoves = ProBot_svGetPartyUsableMoves($partyNumber)
		If UBound($aUsableMoves) < 1 Then
			$aUsableMoves = _internal_CheckMoves($hwnd, $partyNumber)
		EndIf
	EndIf
	ProBot_svSetHasUsableMoves($partyNumber, True)
	ProBot_svSetPartyUsableMoves($aUsableMoves)
	If UBound($aUsableMoves) < 1 Then
		ProBot_svSetHasUsableMoves($partyNumber, False)
	Else
		For $i = 0 To UBound($aUsableMoves) - 1
			; aUsableMoves[name, point, key, id, type, power, accuracy, disabled_by_user]
			ProBot_Log(StringFormat("Pokemon %d, usable move: %s (%d), power = %d", $partyNumber + 1, $aUsableMoves[$i][0], $aUsableMoves[$i][1], $aUsableMoves[$i][5]))
		Next
	EndIf
	Return $aUsableMoves
EndFunc

; Internal functions
Func _internal_CheckMoves($hwnd, Const $partyNumber = 0)
	_internal_TogglePokemonInfoDialog($hwnd, $partyNumber)
	Local $left = $Settings.Item($MOVE_LIST_INDICATOR_LEFT), $right = $Settings.Item($MOVE_LIST_INDICATOR_RIGHT)
	Local $top = $Settings.Item($MOVE_LIST_INDICATOR_TOP), $bottom = $Settings.Item($MOVE_LIST_INDICATOR_BOTTOM)
	Local $pointLeft = $Settings.Item($MOVE_POINT_INDICATOR_LEFT), $pointRight = $Settings.Item($MOVE_POINT_INDICATOR_RIGHT)
	Local $moveImage = ProBot_TesseractWinScreenshot($hwnd, $left, $top, $right, $bottom, 3)
	Local $pointImage = ProBot_TesseractWinScreenshot($hwnd, $pointLeft, $top, $pointRight, $bottom, 3)
	_internal_TogglePokemonInfoDialog($hwnd, $partyNumber)
	Local $moveRawText = ProBot_TesseractWinTextRecognise($moveImage)
	Local $pointRawText = ProBot_TesseractWinTextRecognise($pointImage)
	Return ProBot_CreateUsableMoveArray($aPokemonMoveData, $moveRawText, $pointRawText)
EndFunc

Func _internal_TogglePokemonInfoDialog(Const $hwnd, Const $partyNumber = 0)
	ProBot_MouseClickInGame($hwnd, $Settings.Item($FIRST_PARTY_INDICATOR_X), _
		$Settings.Item($FIRST_PARTY_INDICATOR_Y) + $Settings.Item($FIRST_PARTY_INDICATOR_SPACE) * $partyNumber)
	Sleep(800)
EndFunc

Func _internal_SwapPartySlot(Const $hwnd, Const $partyNumber1, Const $partyNumber2)
	Opt("MouseCoordMode", 2)
	Local $x = $Settings.Item($FIRST_PARTY_INDICATOR_X)
	Local $y = $Settings.Item($FIRST_PARTY_INDICATOR_Y)
	Local $space = $Settings.Item($FIRST_PARTY_INDICATOR_SPACE)
	ProBot_ActivateWindow($hwnd)
	MouseClickDrag($MOUSE_CLICK_PRIMARY, $x, $y + $partyNumber1 * $space - $partyNumber1 * 3, $x, $y + $partyNumber2 * $space - $partyNumber2 * 3, 40)
	ProBot_MoveMouseIntoGameClient("PROClient")
EndFunc