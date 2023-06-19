#include-once
#include "HandlerHelper.au3"
#include "Functions\Constant.au3"
#include "Functions\GameClientFunc.au3"
#include "Functions\Logger.au3"
#include "Functions\Reporter.au3"

Func ProBot_HandleAutoLevel(Const $hwnd)
	; Collect opponent type
	Local $sTargetPokemon = $SessionVariables.Item($RT_RECOGNISED_OPPONENT)
	Local $nPokemonType = ProBot_LookupPokemonData($aPokemonTypeData, $sTargetPokemon)
	If $nPokemonType Then 
		Local $sType1 = $aPokemonTypeData[$nPokemonType][3]
		Local $sType2 = $aPokemonTypeData[$nPokemonType][4]
		ProBot_Log("Found pokemon " & $sTargetPokemon & ", type = " & $sType1 & " " & $sType2)
	Else
		ProBot_Log("Found pokemon " & $sTargetPokemon & ", unknown type. ")
	EndIf

	; Verify opponent if it's in caught list
	Local $sCaughtList = $SessionVariables.Item($AUTO_CAUGHT_LIST)
	If ProBot_TextAccepted($sTargetPokemon, $sCaughtList) Then
		Sleep(5000)
		ProBot_Log(StringFormat("This pokemon %s is in caught list, please take action.", $sTargetPokemon))
		ProBot_Notify(StringFormat("This pokemon %s is in caught list, please take action.", $sTargetPokemon), True, ProBot_MakeScreenshot($hwnd))
		Exit
	EndIf
	
	; Check usable moves
	Local $nUsableParty = ProBot_GetFirstAliveParty($hwnd)
	Local $aUsableMoves = ProBot_GetAndCacheUsableMoves($hwnd, $nUsableParty)
	If UBound($aUsableMoves) < 1 Then
		ProBot_Log(StringFormat("Pokemon %d have 0 usable moves.", $nUsableParty + 1))
		ProBot_svSetNextAction($RT_ACTION_RUNAWAY, $RT_ERROR_CODE_LEADING_NO_USABLE_MOVE)
		ProBot_MoveMouseIntoGameClient("PROClient")
		Return
	EndIf

	; Calculate effective move
	Local $nEffectiveMove = -1
	If $nPokemonType Then 
		Local $sType1 = $aPokemonTypeData[$nPokemonType][3]
		Local $sType2 = $aPokemonTypeData[$nPokemonType][4]
		$nEffectiveMove = ProBot_PickEffectiveMove($aTypeChartData, $aUsableMoves, $sType1, $sType2)
	Else
		$nEffectiveMove = ProBot_PickEffectiveMove($aTypeChartData, $aUsableMoves)
	EndIf

	; If no effective move
	If $nEffectiveMove < 0 Then
		ProBot_Log(StringFormat("Pokemon %d have 0 effective moves.", $nUsableParty + 1))
		ProBot_svSetHasUsableMoves($nUsableParty, False)
		ProBot_svSetNextAction($RT_ACTION_RUNAWAY, $RT_ERROR_CODE_LEADING_NO_USABLE_MOVE)
		ProBot_MoveMouseIntoGameClient("PROClient")
		Return
	EndIf

	
	ProBot_WaitActionReady($hwnd, 2, 30)
	If Not $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Then
		; When battle suddenly closed.
		ProBot_svSetNextAction("")
		Return
	EndIf
			
	If Not $SessionVariables.Item($RT_IS_ACTIONABLE) Then
		; When battle not ready after 30s
		ProBot_Log("Battle not ready after a while, please take action.")
		ProBot_Notify("Battle not ready after a while, please take action.", True)
		ProBot_svSetNextAction($RT_ACTION_RUNAWAY, $RT_ERROR_CODE_MANUAL_REQUIRED)
		Return
	EndIf

	; Perform effective move
	While $aUsableMoves[$nEffectiveMove][1] > 0
		Local $moveName = $aUsableMoves[$nEffectiveMove][0]
		Local $movePoint = $aUsableMoves[$nEffectiveMove][1]
		ProBot_Log(StringFormat("Use move %s (%d)", $moveName, $movePoint))
		Local $moveKey = $aUsableMoves[$nEffectiveMove][2]
		ProBot_PressFightButton(ProBot_KeyBinding($moveKey))
		$aUsableMoves[$nEffectiveMove][1] = $movePoint - 1
		ProBot_svSetPartyUsableMoves($aUsableMoves, $nUsableParty)
		If $aUsableMoves[$nEffectiveMove][1] = 0 Then
			If $nPokemonType Then 
				Local $sType1 = $aPokemonTypeData[$nPokemonType][3]
				Local $sType2 = $aPokemonTypeData[$nPokemonType][4]
				$nEffectiveMove = ProBot_PickEffectiveMove($aTypeChartData, $aUsableMoves, $sType1, $sType2)
			Else
				$nEffectiveMove = ProBot_PickEffectiveMove($aTypeChartData, $aUsableMoves)
			EndIf

			; If no usable move
			If $nEffectiveMove < 0 Then
				ProBot_Log(StringFormat("Pokemon %d have 0 effective moves.", $nUsableParty + 1))
				ProBot_svSetHasUsableMoves($nUsableParty, False)
				ProBot_svSetNextAction($RT_ACTION_RUNAWAY, $RT_ERROR_CODE_LEADING_NO_USABLE_MOVE)
				ProBot_MoveMouseIntoGameClient("PROClient")
				Return
			EndIf
		EndIf
	
		ProBot_WaitActionReady($hwnd, 2, 20)
		If Not $SessionVariables.Item($RT_ON_BATTLE_VISIBLE) Then
			; If battle closed, opponent get faint, then exit action loop
			ProBot_MoveMouseIntoGameClient("PROClient")
			ProBot_svSetNextAction("")
			Return
		EndIf

		If Not $SessionVariables.Item($RT_IS_ACTIONABLE) Then
			; If battle not closed, and still not ready to perform action
			ProBot_Log("Battle not ready after a while, pokemon may get faint.")
			ProBot_Notify("Battle not ready after a while, pokemon may get faint.", True)
			ProBot_svSetNextAction($RT_ACTION_RUNAWAY, $RT_ERROR_CODE_FROZEN_BATTLE)
			Return
		EndIf
	WEnd

	ProBot_svSetNextAction("")
	Return
EndFunc