#include-once
#include "HandlerHelper.au3"
#include "Functions\GameClientFunc.au3"
#include "Functions\Reporter.au3"

Func ProBot_HandleAutoLevel(Const $hwnd)
	; Check usable moves
	Local $nUsableParty = ProBot_GetFirstUsableParty($hwnd)
	Local $aUsableMoves = $PartyData.Item($nUsableParty & ".aUsableMoves")
	If UBound($aUsableMoves) < 1 Then
		$aUsableMoves = ProBot_CheckMoves($hwnd, $nUsableParty)
	EndIf
	If UBound($aUsableMoves) < 1 Then
		$SessionVariables.Item($RT_ACTION) = $RT_ACTION_RUNAWAY
		$SessionVariables.Item($RT_ERROR_CODE) = $RT_ERROR_CODE_LEADING_NO_USABLE_MOVE
		Return
	EndIf

	; Calculate effective move
	Local $nEffectiveMove = -1
	Local $currentOpponent = $SessionVariables.Item($RT_RECOGNISED_OPPONENT)
	Local $nFoundPokemonType = ProBot_LookupPokemonData($DataPokemonTypes, $currentOpponent)
	If $nFoundPokemonType Then 
		Local $sType1 = $DataPokemonTypes[$nFoundPokemonType][3]
		Local $sType2 = $DataPokemonTypes[$nFoundPokemonType][4]
		ProBot_Log("Pokemon " & $currentOpponent & ", type = " & $sType1 & " " & $sType2)
		$nEffectiveMove = ProBot_PickEffectiveMove($DataTypeChart, $aUsableMoves, $sType1, $sType2)
	Else
		ProBot_Log("Pokemon " & $currentOpponent & ", unable to detect effective move. ")
	EndIf

	; If no usable move
	If $nEffectiveMove < 0 Then
		$SessionVariables.Item($RT_ACTION) = $RT_ACTION_RUNAWAY
		$SessionVariables.Item($RT_ERROR_CODE) = $RT_ERROR_CODE_LEADING_NO_USABLE_MOVE
		Return
	EndIf

	; Check battle ready
	ProBot_WaitActionReady($hwnd, 2)
	If Not $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Or Not $SessionVariables.Item($RT_IS_ACTIONABLE) Then
		ProBot_Notify("WARNING! Unable to auto perform action, try to run away.", True)
		$SessionVariables.Item($RT_ACTION) = $RT_ACTION_RUNAWAY
		$SessionVariables.Item($RT_ERROR_CODE) = $RT_ERROR_CODE_FROZEN_BATTLE
		Return
	EndIf

	; Perform effective move
	While $aUsableMoves[$nEffectiveMove][1] > 0
		Local $moveName = $aUsableMoves[$nEffectiveMove][0]
		Local $moveKey = ProBot_KeyBinding($aUsableMoves[$nEffectiveMove][2])
		$aUsableMoves[$nEffectiveMove][1] = $aUsableMoves[$nEffectiveMove][1] - 1
		ProBot_PressFightButton($moveKey)
		ProBot_Log("Used move --> " & $moveName & " (remaining point = " & $aUsableMoves[$nEffectiveMove][1] _
		& ", type = " & $aUsableMoves[$nEffectiveMove][4] & ", damage = " & $nEffectiveMove & ")")
		If $aUsableMoves[$nEffectiveMove][1] = 0 Then
			If $nFoundPokemonType Then 
				Local $sType1 = $DataPokemonTypes[$nFoundPokemonType][3]
				Local $sType2 = $DataPokemonTypes[$nFoundPokemonType][4]
				ProBot_Log("Pokemon " & $currentOpponent & ", type = " & $sType1 & " " & $sType2)
				$nEffectiveMove = ProBot_PickEffectiveMove($DataTypeChart, $aUsableMoves, $sType1, $sType2)
			Else
				ProBot_Log("Pokemon " & $currentOpponent & ", unable to detect effective move. ")
			EndIf

			; If no usable move
			If $nEffectiveMove < 0 Then
				$SessionVariables.Item($RT_ACTION) = $RT_ACTION_RUNAWAY
				$SessionVariables.Item($RT_ERROR_CODE) = $RT_ERROR_CODE_LEADING_NO_USABLE_MOVE
				Return
			EndIf
		EndIf
	
		; Check if battle ready for perform next action (timeout 60s)
		ProBot_WaitActionReady($hwnd, 2)
		If Not $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Then
			; If battle closed, opponent get faint, then exit action loop
			$PartyData.Item($nUsableParty & ".aUsableMoves") = $aUsableMoves
			ProBot_MoveMouseIntoGameClient("PROClient")
			$UsableMoveHolder = $aUsableMoves
			$SessionVariables.Item($RT_ACTION) = ""
			$SessionVariables.Item($RT_ERROR_CODE) = ""
			Return
		EndIf

		If Not $SessionVariables.Item($RT_IS_ACTIONABLE) Then
			; If battle not closed, and still not ready to perform action, try to run away.
			ProBot_Notify("WARNING! Unable to continue due to unexpected screen, try to run away.", True)
			$SessionVariables.Item($RT_ACTION) = $RT_ACTION_RUNAWAY
			$SessionVariables.Item($RT_ERROR_CODE) = $RT_ERROR_CODE_FROZEN_BATTLE
			Return
		EndIf
	WEnd

	$SessionVariables.Item($RT_ACTION) = ""
	$SessionVariables.Item($RT_ERROR_CODE) = ""
	Return
EndFunc

Func ProBot_CheckMoves($hwnd, Const $partyNumber = 0)
	ProBot_TogglePokemonInfoDialog($hwnd, $partyNumber)
	Local $left = $Settings.Item($MOVE_LIST_INDICATOR_LEFT), $right = $Settings.Item($MOVE_LIST_INDICATOR_RIGHT)
	Local $top = $Settings.Item($MOVE_LIST_INDICATOR_TOP), $bottom = $Settings.Item($MOVE_LIST_INDICATOR_BOTTOM)
	Local $pointLeft = $Settings.Item($MOVE_POINT_INDICATOR_LEFT), $pointRight = $Settings.Item($MOVE_POINT_INDICATOR_RIGHT)
	Local $moveImage = ProBot_TesseractWinScreenshot($hwnd, $left, $top, $right, $bottom, 3)
	Local $pointImage = ProBot_TesseractWinScreenshot($hwnd, $pointLeft, $top, $pointRight, $bottom, 3)
	ProBot_TogglePokemonInfoDialog($hwnd, $partyNumber)
	Local $moveRawText = ProBot_TesseractWinTextRecognise($moveImage)
	Local $pointRawText = ProBot_TesseractWinTextRecognise($pointImage)
	Return ProBot_CreateUsableMoveArray($DataPokemonMoves, $moveRawText, $pointRawText)
EndFunc

